import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/database/app_database.dart';
import '../../providers/providers.dart';
import '../../providers/stats.dart';
import 'soft_card.dart';

/// 学習リマインダーの設定（[Docs/06_features/reminders.md] §5）。
///
/// 権限は**起動時に求めない**。ここで ON にしようとしたときに初めて求める
/// （何のための許可かが分かる場面で聞く）。拒否されたらトグルを ON にせず、
/// 理由を1行出す。ON に見せかけて鳴らない状態を作らない。
class ReminderSettingsCard extends ConsumerStatefulWidget {
  final Profile profile;

  const ReminderSettingsCard({super.key, required this.profile});

  @override
  ConsumerState<ReminderSettingsCard> createState() =>
      _ReminderSettingsCardState();
}

class _ReminderSettingsCardState extends ConsumerState<ReminderSettingsCard> {
  /// 権限が無い・拒否されたときの1行表示。
  String? _notice;
  bool _busy = false;

  /// 設定を書き換えたら読み直すため、最新の学習者を見る。
  Profile get profile => ref.read(activeProfileProvider) ?? widget.profile;

  Future<void> _toggle(bool on) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      if (on) {
        final service = ref.read(reminderServiceProvider);
        final granted =
            await service.hasPermission() || await service.requestPermission();
        if (!granted) {
          setState(() {
            _busy = false;
            _notice = '通知が許可されていません。端末の設定から許可できます。';
          });
          return;
        }
      }
      await _patch(ProfilesCompanion(reminderEnabled: Value(on)));
    } catch (e) {
      if (mounted) setState(() => _notice = 'リマインダーを設定できませんでした: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: profile.reminderHour,
        minute: profile.reminderMinute,
      ),
    );
    if (picked == null) return;
    await _patch(
      ProfilesCompanion(
        reminderHour: Value(picked.hour),
        reminderMinute: Value(picked.minute),
      ),
    );
  }

  /// 設定を書き換え、そのプロファイルの通知を作り直す。
  Future<void> _patch(ProfilesCompanion patch) async {
    await ref.read(profileRepositoryProvider).updateSettings(profile.id, patch);
    await ref.read(activeProfileProvider.notifier).reload();
    final fresh = ref.read(activeProfileProvider);
    if (fresh == null) return;
    await ref
        .read(reminderSchedulerProvider)
        .reschedule(fresh, now: ref.read(clockProvider)());
  }

  Future<void> _sendTest() async {
    try {
      await ref
          .read(reminderSchedulerProvider)
          .sendTest(profile, now: ref.read(clockProvider)());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('5秒後にテスト通知を出します')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('テスト通知を送れませんでした: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(activeProfileProvider) ?? widget.profile;
    final time =
        '${profile.reminderHour.toString().padLeft(2, '0')}:'
        '${profile.reminderMinute.toString().padLeft(2, '0')}';
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('学習リマインダー', style: AppText.sectionTitle())),
              Switch(
                value: profile.reminderEnabled,
                activeThumbColor: AppColors.accent,
                onChanged: _busy ? null : _toggle,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '毎日きまった時刻に、その日の復習をお知らせします。'
            '目標を達成した日は通知しません。',
            style: AppText.caption(),
          ),
          if (profile.reminderEnabled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text('時刻', style: AppText.body())),
                OutlinedButton(onPressed: _pickTime, child: Text(time)),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _sendTest,
              icon: const Icon(Icons.notifications_active_outlined, size: 18),
              label: const Text('テスト通知を送る'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
          if (_notice != null) ...[
            const SizedBox(height: 8),
            Text(_notice!, style: AppText.caption(color: AppColors.accentDeep)),
          ],
        ],
      ),
    );
  }
}
