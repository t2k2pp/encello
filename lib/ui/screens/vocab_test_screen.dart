import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/wordbook_repository.dart';
import '../../domain/usecases/vocab_size_estimator.dart';
import '../../domain/usecases/vocab_test_builder.dart';
import '../../providers/providers.dart';
import '../../providers/stats.dart';
import '../dialogs/confirm_dialog.dart';
import '../widgets/band_progress_bar.dart';
import '../widgets/centered_content.dart';
import '../widgets/empty_state.dart';
import '../widgets/soft_card.dart';

/// 前回の測定から日が浅いときの警告（[Docs/06_features/vocab_size_test.md] §6）。
///
/// 実行はできる。差が誤差に埋もれることだけを伝える。
const kVocabRetestWarnDays = 7;

/// 測定を開く。前回から7日以内なら、押す前に警告を出す。
Future<void> openVocabTest(
  BuildContext context,
  WidgetRef ref, {
  required Profile profile,
}) async {
  final last = await ref.read(vocabTestRepositoryProvider).latest(profile.id);
  if (!context.mounted) return;
  if (last != null) {
    final days = ref.read(clockProvider)().difference(last.takenAt).inDays;
    if (days < kVocabRetestWarnDays) {
      final ok = await confirmDestructive(
        context,
        title: '語彙力を測り直しますか',
        message:
            '前回から$days日です。差が誤差の範囲になることがあります。\n'
            '測り直しても、これまでの記録は消えません。',
        confirmLabel: '測る',
      );
      if (!ok || !context.mounted) return;
    }
  }
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => VocabTestScreen(profile: profile),
    ),
  );
}

/// SCR-18 語彙力測定（[Docs/04_screens_and_flows.md] §4.13）。
///
/// Yes/No 方式＋擬似語による当てずっぽう補正。意味の入力はさせず、
/// 「意味が言えるか」の自己申告だけを取る（1問2〜3秒）。
/// 擬似語が混ざっていることは結果画面まで伏せる。
class VocabTestScreen extends ConsumerStatefulWidget {
  final Profile profile;

  const VocabTestScreen({super.key, required this.profile});

  @override
  ConsumerState<VocabTestScreen> createState() => _VocabTestScreenState();
}

class _VocabTestScreenState extends ConsumerState<VocabTestScreen> {
  late final Future<VocabTestPlan> _plan = _buildPlan();

  /// 質問番号 → 「わかる」と答えたか。
  final _answers = <int, bool>{};
  int _index = 0;

  /// 保存まで終わった結果。null = まだ測定中。
  ({VocabSizeEstimate estimate, VocabSizeTest? previous})? _result;
  bool _saving = false;

  Future<VocabTestPlan> _buildPlan() async {
    final repo = ref.read(vocabTestRepositoryProvider);
    final bands = await repo.loadBands();
    final pseudowords = await ref.read(pseudowordAssetsProvider).load();
    final recent = await repo.recentlyAskedWordIds(widget.profile.id);
    return VocabTestBuilder.build(
      bands: bands,
      pseudowords: pseudowords,
      random: Random(ref.read(clockProvider)().microsecondsSinceEpoch),
      recentlyAsked: recent,
    );
  }

  Future<void> _answer(VocabTestPlan plan, bool known) async {
    _answers[_index] = known;
    if (_index + 1 < plan.questions.length) {
      // 送りのアニメーションは入れない（2〜3秒に1問なので、動きがあると遅く感じる）。
      setState(() => _index++);
      return;
    }
    await _finish(plan);
  }

  Future<void> _finish(VocabTestPlan plan) async {
    if (_saving) return;
    setState(() => _saving = true);

    final byBand = <int, ({int asked, int known})>{};
    var pseudoAsked = 0;
    var pseudoKnown = 0;
    final askedWordIds = <int>[];
    for (var i = 0; i < plan.questions.length; i++) {
      final q = plan.questions[i];
      final known = _answers[i] ?? false;
      if (q.isPseudo) {
        pseudoAsked++;
        if (known) pseudoKnown++;
        continue;
      }
      askedWordIds.add(q.wordId!);
      final current = byBand[q.wordbookId!] ?? (asked: 0, known: 0);
      byBand[q.wordbookId!] = (
        asked: current.asked + 1,
        known: current.known + (known ? 1 : 0),
      );
    }

    final estimate = VocabSizeEstimator.estimate(
      bands: [
        for (final band in plan.bands)
          if (byBand.containsKey(band.wordbookId))
            VocabBandAnswers(
              wordbookId: band.wordbookId,
              name: band.name,
              bandSize: band.bandSize,
              asked: byBand[band.wordbookId]!.asked,
              known: byBand[band.wordbookId]!.known,
            ),
      ],
      pseudoAsked: pseudoAsked,
      pseudoKnown: pseudoKnown,
    );

    final repo = ref.read(vocabTestRepositoryProvider);
    final previous = await repo.latest(widget.profile.id);
    await repo.save(
      profileId: widget.profile.id,
      takenAt: ref.read(clockProvider)(),
      estimate: estimate,
      askedWordIds: askedWordIds,
    );
    // 統計・ホームの語彙力カードを読み直させる。
    ref.invalidate(vocabHistoryProvider(widget.profile.id));
    ref.invalidate(achievementStatsProvider(widget.profile.id));
    if (!mounted) return;
    setState(() {
      _result = (estimate: estimate, previous: previous);
      _saving = false;
    });
  }

  /// 途中でやめたら測定を破棄する（部分的な結果を保存しない）。
  Future<void> _abort() async {
    if (_answers.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final ok = await confirmDestructive(
      context,
      title: '測定をやめますか',
      message: 'ここまでの回答は保存されません。次に測るときは最初からになります。',
      confirmLabel: 'やめる',
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      body: SafeArea(
        child: CenteredContent(
          child: result != null
              ? _ResultView(
                  profile: widget.profile,
                  estimate: result.estimate,
                  previous: result.previous,
                )
              : FutureBuilder<VocabTestPlan>(
                  future: _plan,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return EmptyState(
                        emoji: '⚠️',
                        message: '測定を始められませんでした',
                        subMessage: '${snapshot.error}',
                      );
                    }
                    final plan = snapshot.data;
                    if (plan == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final realCount =
                        plan.questions.length - plan.pseudoCount;
                    if (realCount < VocabTestBuilder.minRealWords) {
                      // 測れるだけの語が無いのに、それらしい数字を出さない。
                      return const EmptyState(
                        emoji: '📏',
                        message: 'まだ語彙力を測れません',
                        subMessage:
                            '測定には、級ごとの単語帳に十分な語が必要です。'
                            '単語帳を追加してからお試しください。',
                      );
                    }
                    return _QuestionView(
                      plan: plan,
                      index: _index,
                      busy: _saving,
                      onAnswer: (known) => _answer(plan, known),
                      onAbort: _abort,
                    );
                  },
                ),
        ),
      ),
    );
  }
}

/// 出題（語を1つだけ大きく出し、下に2ボタン）。
class _QuestionView extends StatelessWidget {
  final VocabTestPlan plan;
  final int index;
  final bool busy;
  final void Function(bool known) onAnswer;
  final VoidCallback onAbort;

  const _QuestionView({
    required this.plan,
    required this.index,
    required this.busy,
    required this.onAnswer,
    required this.onAbort,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final question = plan.questions[index];
    return Column(
      children: [
        Padding(
          padding: spacing.screenPadding.copyWith(bottom: 0),
          child: Row(
            children: [
              IconButton(
                onPressed: onAbort,
                tooltip: '測定をやめる',
                icon: const Icon(Icons.close),
              ),
              Expanded(
                child: Text(
                  '${index + 1} / ${plan.questions.length}',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  question.headword,
                  maxLines: 1,
                  style: AppText.headword(),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: spacing.screenPadding,
          child: Column(
            children: [
              Text('意味が言えますか？', style: AppText.caption()),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy ? null : () => onAnswer(false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: const Text('わからない'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: busy ? null : () => onAnswer(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: const Text('わかる'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 結果（[Docs/06_features/vocab_size_test.md] §5）。
class _ResultView extends ConsumerStatefulWidget {
  final Profile profile;
  final VocabSizeEstimate estimate;
  final VocabSizeTest? previous;

  const _ResultView({
    required this.profile,
    required this.estimate,
    required this.previous,
  });

  @override
  ConsumerState<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends ConsumerState<_ResultView> {
  bool _applied = false;
  bool _busy = false;

  /// 推奨単語帳をそのまま学習対象に設定する。押さなければ何も変えない。
  Future<void> _applyRecommendation(int wordbookId) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final profile = ref.read(activeProfileProvider) ?? widget.profile;
      final ids = decodeIdList(profile.selectedWordbookIds).toSet()
        ..add(wordbookId);
      await ref
          .read(profileRepositoryProvider)
          .updateSettings(
            profile.id,
            ProfilesCompanion(selectedWordbookIds: Value(encodeIdList(ids))),
          );
      await ref.read(activeProfileProvider.notifier).reload();
      if (mounted) setState(() => _applied = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('学習対象にできませんでした: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final estimate = widget.estimate;
    final recommended = estimate.recommendedBand;

    return ListView(
      padding: spacing.screenPadding.copyWith(bottom: 32),
      children: [
        Text('あなたの語彙力', style: AppText.title()),
        SizedBox(height: spacing.gap),
        SoftCard(
          child: Column(
            children: [
              Text(
                '推定 ${estimate.estimatedSize} 語',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.style(size: 28, weight: FontWeight.w800),
              ),
              if (widget.previous != null) ...[
                const SizedBox(height: 4),
                Text(
                  _diffLabel(
                    estimate.estimatedSize,
                    widget.previous!.estimatedSize,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                '${estimate.bands.fold(0, (s, b) => s + b.asked)}問からの推定値です。'
                '±10%程度の幅があります。',
                textAlign: TextAlign.center,
                style: AppText.caption(),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.gap),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('級ごとの到達率', style: AppText.sectionTitle()),
              const SizedBox(height: 8),
              for (final band in estimate.bands)
                BandProgressBar(
                  label: band.name,
                  ratio: band.corrected,
                  estimatedWords: band.estimatedWords,
                  highlighted: band.wordbookId == recommended?.wordbookId,
                ),
            ],
          ),
        ),
        if (recommended != null) ...[
          SizedBox(height: spacing.gap),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('次に取り組むとよい単語帳', style: AppText.sectionTitle()),
                const SizedBox(height: 4),
                Text(
                  recommended.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(),
                ),
                const SizedBox(height: 4),
                Text(
                  estimate.isAllBandsHigh
                      ? 'かなり仕上がっています。ここからは取りこぼしを埋めていきましょう。'
                      : 'この帯はあと約${recommended.remainingWords}語です。',
                  style: AppText.caption(),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: _applied || _busy
                      ? null
                      : () => _applyRecommendation(recommended.wordbookId),
                  child: Text(_applied ? '学習対象にしました' : 'この単語帳を学習対象にする'),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: spacing.gap),
        SoftCard(
          child: Text(
            '実在しない語が${estimate.pseudoAsked}問混ざっていました。'
            'うち${estimate.pseudoKnown}問に「わかる」と答えています。'
            '${estimate.pseudoKnown > 0 ? 'その分を差し引いて推定しています。' : ''}',
            style: AppText.caption(),
          ),
        ),
        SizedBox(height: spacing.gap),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('閉じる'),
        ),
      ],
    );
  }

  /// 前回差。推定誤差より小さい差は「ほぼ同じ」と出す
  /// （誤差を成長として見せない。[Docs/06_features/vocab_size_test.md] §8）。
  static String _diffLabel(int current, int previous) {
    if (VocabSizeEstimator.isWithinNoise(current: current, previous: previous)) {
      return '前回とほぼ同じです';
    }
    final diff = current - previous;
    return diff > 0 ? '前回から +$diff 語' : '前回から $diff 語';
  }
}
