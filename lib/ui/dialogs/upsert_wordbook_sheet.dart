import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/database/app_database.dart';
import '../../providers/providers.dart';
import '../widgets/color_dot.dart';
import '../widgets/emoji_picker_sheet.dart';

/// 単語帳の追加/編集シート（[STYLE_GUIDE §4.2]、[Docs/06_features/wordbooks.md] §4）。
///
/// ユーザー単語帳は全学習者で共有する（マイ単語帳だけが個人のもの）。
Future<void> showUpsertWordbookSheet(
  BuildContext context, {
  Wordbook? editing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _UpsertWordbookSheet(editing: editing),
  );
}

class _UpsertWordbookSheet extends ConsumerStatefulWidget {
  final Wordbook? editing;

  const _UpsertWordbookSheet({required this.editing});

  @override
  ConsumerState<_UpsertWordbookSheet> createState() =>
      _UpsertWordbookSheetState();
}

class _UpsertWordbookSheetState extends ConsumerState<_UpsertWordbookSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _noteCtrl;
  late String _emoji;
  late int _colorSeed;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _emoji = e?.emoji ?? '📗';
    _colorSeed = e?.colorSeed ?? 0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noteCtrl.dispose();
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
    final note = _noteCtrl.text.trim();
    final repo = ref.read(wordbookRepositoryProvider);
    try {
      final editing = widget.editing;
      if (editing == null) {
        await repo.create(
          name: name,
          emoji: _emoji,
          colorSeed: _colorSeed,
          note: note.isEmpty ? null : note,
        );
      } else {
        await repo.update(
          editing.id,
          name: name,
          emoji: _emoji,
          colorSeed: _colorSeed,
          note: note.isEmpty ? null : note,
        );
      }
      if (mounted) Navigator.pop(context);
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
              widget.editing == null ? '単語帳を追加' : '単語帳を編集',
              style: AppText.sectionTitle(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _pickEmoji,
                  child: Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.seedColor(
                        _colorSeed,
                      ).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _emoji,
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    autofocus: widget.editing == null,
                    maxLength: 40,
                    decoration: const InputDecoration(
                      labelText: '単語帳の名前',
                      counterText: '',
                    ),
                    onSubmitted: (_) => _save(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickEmoji,
              icon: const Icon(Icons.emoji_emotions_outlined, size: 18),
              label: const Text('絵文字を選ぶ'),
            ),
            const SizedBox(height: 16),
            Text('色', style: AppText.caption()),
            const SizedBox(height: 8),
            ColorDotPicker(
              selectedSeed: _colorSeed,
              onChanged: (seed) => setState(() => _colorSeed = seed),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: '説明（任意）'),
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
