import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/study_launcher.dart';
import '../../application/study_session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/wordbook_repository.dart';
import '../../domain/usecases/family_quiz_builder.dart';
import '../../domain/usecases/study_queue_builder.dart';
import '../../providers/audio.dart';
import '../../providers/providers.dart';
import '../screens/choice_study_screen.dart';
import '../screens/flashcard_screen.dart';
import '../screens/spell_study_screen.dart';
import '../widgets/soft_dropdown.dart';

/// SCR-02 モード選択シート（[Docs/04_screens_and_flows.md] §4.2）。
///
/// **そのとき使えるモードだけ**をプルダウンに並べる。条件を満たさないモードは
/// 選択肢に出さない（[STYLE_GUIDE §0-4]）。
Future<void> showStartStudySheet(
  BuildContext context, {
  required Profile profile,
  QueuePolicy initialPolicy = QueuePolicy.reviewFirst,
  StudyMode? initialMode,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _StartStudySheet(
      profile: profile,
      initialPolicy: initialPolicy,
      initialMode: initialMode,
    ),
  );
}

class _StartStudySheet extends ConsumerStatefulWidget {
  final Profile profile;
  final QueuePolicy initialPolicy;
  final StudyMode? initialMode;

  const _StartStudySheet({
    required this.profile,
    required this.initialPolicy,
    required this.initialMode,
  });

  @override
  ConsumerState<_StartStudySheet> createState() => _StartStudySheetState();
}

class _StartStudySheetState extends ConsumerState<_StartStudySheet> {
  late QueuePolicy _policy = widget.initialPolicy;
  late int _limit = widget.profile.sessionSize;
  late StudyMode _mode = widget.initialMode ?? StudyMode.spell;
  late FlashcardMode _flashcardMode = FlashcardMode.fromValue(
    widget.profile.flashcardMode,
  );
  late FlashcardTestFormat _testFormat = FlashcardTestFormat.fromValue(
    widget.profile.flashcardTestFormat,
  );
  bool _starting = false;

  /// 開始できなかった理由。シートを閉じずにここへ1行で出す。
  String? _error;

  /// 選択式の画面で扱うモード。
  static const _choiceModes = {
    StudyMode.choice,
    StudyMode.speed,
    StudyMode.confusion,
    StudyMode.parts,
  };

  /// 問題数の選択肢（FR-10）。`null` = 期限到来分すべて。
  static const _limits = <int?>[10, 20, 50, null];

  Future<void> _start() async {
    if (_starting) return;
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      if (_mode == StudyMode.flashcard) {
        await ref
            .read(flashcardProvider.notifier)
            .start(
              profile: widget.profile,
              mode: _flashcardMode,
              testFormat: _testFormat,
              policy: _policy,
              limit: _limit,
            );
        if (!mounted) return;
        Navigator.of(context).pop();
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const FlashcardScreen()),
        );
        return;
      }
      if (_choiceModes.contains(_mode)) {
        await ref
            .read(studyLauncherProvider)
            .start(
              profile: widget.profile,
              mode: _mode,
              policy: _policy,
              limit: _limit,
            );
        if (!mounted) return;
        Navigator.of(context).pop();
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ChoiceStudyScreen()),
        );
        return;
      }
      if (_mode == StudyMode.family) {
        final members = await ref
            .read(modeRepositoryProvider)
            .loadFamilyMembers(widget.profile.id);
        await ref
            .read(studySessionProvider.notifier)
            .startFamily(
              profile: widget.profile,
              questions: FamilyQuizBuilder.build(members),
              limit: _limit,
            );
      } else {
        await ref
            .read(studySessionProvider.notifier)
            .start(
              profile: widget.profile,
              mode: _mode,
              policy: _policy,
              limit: _limit,
            );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const SpellStudyScreen()));
    } on StudyStartFailure catch (e) {
      // 空のセッションを開始しない。シートを閉じず理由を出す。
      if (mounted) {
        setState(() {
          _starting = false;
          _error = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _starting = false;
          _error = '学習を開始できませんでした: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final books =
        ref.watch(wordbooksProvider(widget.profile.id)).value ?? const [];
    final modes =
        ref.watch(availableModesProvider(widget.profile)).value ??
        const [StudyMode.spell];
    final selected = decodeIdList(widget.profile.selectedWordbookIds).toSet();
    final studying = books
        .where((b) => selected.contains(b.wordbook.id))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('学習をはじめる', style: AppText.sectionTitle()),
            const SizedBox(height: 12),
            // **そのとき使えるモードだけ**を並べる。まだ実装していないモードや、
            // 音が鳴らせない端末のリスニングは選択肢に出さない。
            _Row(
              label: 'モード',
              child: SoftDropdown<StudyMode>(
                value: modes.contains(_mode) ? _mode : modes.first,
                hint: 'モード',
                items: [
                  for (final m in modes)
                    (value: m, label: '${m.emoji} ${m.label}'),
                ],
                onChanged: (m) => setState(() => _mode = m),
              ),
            ),
            if (_mode == StudyMode.flashcard)
              _Row(
                label: '送り方',
                child: SoftDropdown<FlashcardMode>(
                  value: _flashcardMode,
                  hint: '送り方',
                  items: [
                    for (final m in FlashcardMode.values)
                      (value: m, label: m.label),
                  ],
                  onChanged: (m) => setState(() => _flashcardMode = m),
                ),
              ),
            // 流し見のあとに何で確かめるか。ここで選べないと、確かめ方を変える
            // たびに設定画面へ行くことになる（[Docs/06_features/flashcard_mode.md] §3）。
            if (_mode == StudyMode.flashcard)
              _Row(
                label: '確認テスト',
                child: SoftDropdown<FlashcardTestFormat>(
                  value: _testFormat,
                  hint: '確認テスト',
                  items: [
                    for (final f in FlashcardTestFormat.values)
                      (value: f, label: f.label),
                  ],
                  onChanged: (f) => setState(() => _testFormat = f),
                ),
              ),
            _Row(
              label: '単語帳',
              child: Text(
                studying.isEmpty
                    ? '選ばれていません'
                    : studying.map((b) => b.wordbook.name).join(' ・ '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(
                  color: studying.isEmpty ? AppColors.ink3 : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // スピードは50問固定、取り違えは自分の組の数で決まる。
            if (_mode != StudyMode.speed) ...[
              Text('問題数', style: AppText.caption()),
              const SizedBox(height: 6),
              SegmentedButton<int>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                segments: [
                  for (final n in _limits)
                    ButtonSegment(
                      value: n ?? _allCount,
                      label: Text(n == null ? '全部' : '$n'),
                    ),
                ],
                selected: {_limit},
                onSelectionChanged: (s) => setState(() => _limit = s.first),
              ),
            ],
            // 取り違えは対象が自分の組に限られるので、出題方針の行を出さない。
            if (_mode != StudyMode.confusion && _mode != StudyMode.speed) ...[
              const SizedBox(height: 12),
              Text('出題', style: AppText.caption()),
              const SizedBox(height: 6),
              SegmentedButton<QueuePolicy>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                segments: [
                  for (final p in QueuePolicy.values)
                    ButtonSegment(value: p, label: Text(p.label)),
                ],
                selected: {_policy},
                onSelectionChanged: (s) => setState(() => _policy = s.first),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: AppText.caption(color: AppColors.accentDeep),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _starting ? null : _start,
              child: const Text('はじめる'),
            ),
          ],
        ),
      ),
    );
  }

  /// 「全部」を表す問題数。候補プールがこれを超えることは実運用では無い。
  static const _allCount = 9999;
}

class _Row extends StatelessWidget {
  final String label;
  final Widget child;

  const _Row({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption(),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
