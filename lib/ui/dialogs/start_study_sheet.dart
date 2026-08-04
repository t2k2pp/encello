import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/study_session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/wordbook_repository.dart';
import '../../domain/usecases/study_queue_builder.dart';
import '../../providers/providers.dart';
import '../screens/spell_study_screen.dart';

/// SCR-02 モード選択シート（[Docs/04_screens_and_flows.md] §4.2）。
///
/// **そのとき使えるモードだけ**をプルダウンに並べる。条件を満たさないモードは
/// 選択肢に出さない（[STYLE_GUIDE §0-4]）。
Future<void> showStartStudySheet(
  BuildContext context, {
  required Profile profile,
  QueuePolicy initialPolicy = QueuePolicy.reviewFirst,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) =>
        _StartStudySheet(profile: profile, initialPolicy: initialPolicy),
  );
}

class _StartStudySheet extends ConsumerStatefulWidget {
  final Profile profile;
  final QueuePolicy initialPolicy;

  const _StartStudySheet({required this.profile, required this.initialPolicy});

  @override
  ConsumerState<_StartStudySheet> createState() => _StartStudySheetState();
}

class _StartStudySheetState extends ConsumerState<_StartStudySheet> {
  late QueuePolicy _policy = widget.initialPolicy;
  late int _limit = widget.profile.sessionSize;
  bool _starting = false;

  /// 開始できなかった理由。シートを閉じずにここへ1行で出す。
  String? _error;

  /// 問題数の選択肢（FR-10）。`null` = 期限到来分すべて。
  static const _limits = <int?>[10, 20, 50, null];

  Future<void> _start() async {
    if (_starting) return;
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      await ref
          .read(studySessionProvider.notifier)
          .start(
            profile: widget.profile,
            mode: StudyMode.spell,
            policy: _policy,
            limit: _limit,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const SpellStudyScreen()),
      );
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
    final books = ref.watch(wordbooksProvider(widget.profile.id)).value ?? const [];
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
            // モードはスペルだけが実装済み。他のモードは実装した時点で並べる。
            _Row(
              label: 'モード',
              child: Text(
                '${StudyMode.spell.emoji} ${StudyMode.spell.label}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(),
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
