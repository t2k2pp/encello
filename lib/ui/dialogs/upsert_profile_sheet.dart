import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/database/app_database.dart';
import '../../providers/providers.dart';
import '../widgets/emoji_picker_sheet.dart';
import '../widgets/profile_avatar.dart';

/// 学習者の追加/編集シート（[STYLE_GUIDE §4.2]）。
///
/// 追加した場合は作成した [Profile] を、編集した場合は `null` を返す
/// （追加直後にその学習者で開始できるようにするため）。
Future<Profile?> showUpsertProfileSheet(
  BuildContext context, {
  Profile? editing,
}) {
  return showModalBottomSheet<Profile>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _UpsertProfileSheet(editing: editing),
  );
}

class _UpsertProfileSheet extends ConsumerStatefulWidget {
  final Profile? editing;

  const _UpsertProfileSheet({required this.editing});

  @override
  ConsumerState<_UpsertProfileSheet> createState() =>
      _UpsertProfileSheetState();
}

class _UpsertProfileSheetState extends ConsumerState<_UpsertProfileSheet> {
  late final TextEditingController _nameCtrl;
  late String _emoji;
  late int _colorSeed;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _emoji = e?.emoji ?? '🙂';
    _colorSeed = e?.colorSeed ?? 0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickEmoji() async {
    final picked = await pickEmoji(context);
    if (picked != null && mounted) setState(() => _emoji = picked);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);
    final repo = ref.read(profileRepositoryProvider);
    try {
      final editing = widget.editing;
      if (editing == null) {
        final created = await repo.create(
          name: name,
          emoji: _emoji,
          colorSeed: _colorSeed,
          // 新しい学習者はアプリの既定配色から始める。
          paletteId: pinkPalette.id,
        );
        if (mounted) Navigator.pop(context, created);
      } else {
        await repo.updateIdentity(
          editing.id,
          name: name,
          emoji: _emoji,
          colorSeed: _colorSeed,
        );
        // 編集したのが現在の学習者なら、画面に出ている値を読み直す。
        if (ref.read(activeProfileProvider)?.id == editing.id) {
          await ref.read(activeProfileProvider.notifier).reload();
        }
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存に失敗しました: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.editing == null ? '学習者を追加' : '学習者を編集',
              style: AppText.sectionTitle(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ProfileAvatar(
                  emoji: _emoji,
                  colorSeed: _colorSeed,
                  size: 56,
                  selected: true,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    autofocus: widget.editing == null,
                    maxLength: 20,
                    decoration: const InputDecoration(
                      labelText: '名前',
                      counterText: '',
                    ),
                    onSubmitted: (_) => _save(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('アバター', style: AppText.caption()),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickEmoji,
              icon: const Icon(Icons.emoji_emotions_outlined, size: 18),
              label: const Text('絵文字を選ぶ'),
            ),
            const SizedBox(height: 16),
            Text('色', style: AppText.caption()),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var i = 0; i < AppColors.accentPalette.length; i++)
                  _ColorDot(
                    color: AppColors.accentPalette[i],
                    selected: i == _colorSeed,
                    onTap: () => setState(() => _colorSeed = i),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _saving ? null : _save,
              child: const Text('保存'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// 識別色の選択肢（36px 色玉、選択中は ink 枠3px＋白チェック。[STYLE_GUIDE §4.2]）。
class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        // 最小タップ領域 44×44 を確保する（NFR-06）。
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.ink : Colors.transparent,
                  width: 3,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
