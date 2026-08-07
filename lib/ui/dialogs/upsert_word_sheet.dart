import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../data/database/app_database.dart';
import '../../providers/providers.dart';
import '../widgets/soft_card.dart';
import '../widgets/soft_dropdown.dart';

/// 単語の追加/編集シート（[STYLE_GUIDE §4.2]、[Docs/06_features/dictionary.md] §2.2）。
///
/// [wordbookId] を渡すと、追加した語をその単語帳へ所属させる。
/// 既存の共有語と `(headword, partOfSpeech)` が一致する場合は新規作成せず、
/// **既存の語をその単語帳に所属させる**（学習状態を分けないため）。
Future<void> showUpsertWordSheet(
  BuildContext context, {
  required Profile profile,
  Word? editing,
  int? wordbookId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _UpsertWordSheet(
      profile: profile,
      editing: editing,
      wordbookId: wordbookId,
    ),
  );
}

class _UpsertWordSheet extends ConsumerStatefulWidget {
  final Profile profile;
  final Word? editing;
  final int? wordbookId;

  const _UpsertWordSheet({
    required this.profile,
    required this.editing,
    required this.wordbookId,
  });

  @override
  ConsumerState<_UpsertWordSheet> createState() => _UpsertWordSheetState();
}

class _UpsertWordSheetState extends ConsumerState<_UpsertWordSheet> {
  late final TextEditingController _headwordCtrl;
  late final TextEditingController _phoneticCtrl;
  late final TextEditingController _meaningCtrl;
  late final TextEditingController _exampleEnCtrl;
  late final TextEditingController _exampleJaCtrl;
  late PartOfSpeech _partOfSpeech;
  late int _level;
  bool _saving = false;

  /// 既存の共有語と一致したときに出す案内（推測で黙って結合しない）。
  Word? _existing;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _headwordCtrl = TextEditingController(text: e?.headword ?? '');
    _phoneticCtrl = TextEditingController(text: e?.phonetic ?? '');
    _meaningCtrl = TextEditingController(text: e?.meaning ?? '');
    // 例文欄が読み書きするのは**ユーザーが書いた文**（`sourcePresetId = null`）だけ。
    // 単語帳由来の例文はここでは触らない（[Docs/03_data_model.md] §2.4）。
    _exampleEnCtrl = TextEditingController();
    _exampleJaCtrl = TextEditingController();
    _partOfSpeech = e == null
        ? PartOfSpeech.noun
        : PartOfSpeech.fromValue(e.partOfSpeech);
    _level = e?.level ?? 1;
    _headwordCtrl.addListener(_checkExisting);
    if (e != null) _loadUserExample(e.id);
  }

  /// 編集時に、その語に書き残したユーザーの文を読み込む。
  Future<void> _loadUserExample(int wordId) async {
    final example = await ref.read(wordRepositoryProvider).userExampleOf(wordId);
    if (!mounted || example == null) return;
    _exampleEnCtrl.text = example.exampleEn;
    _exampleJaCtrl.text = example.exampleJa;
  }

  @override
  void dispose() {
    _headwordCtrl.dispose();
    _phoneticCtrl.dispose();
    _meaningCtrl.dispose();
    _exampleEnCtrl.dispose();
    _exampleJaCtrl.dispose();
    super.dispose();
  }

  /// 追加時のみ、入力中の見出し語が既存語と一致するかを見る。
  Future<void> _checkExisting() async {
    if (widget.editing != null) return;
    final headword = _headwordCtrl.text.trim();
    if (headword.isEmpty) {
      if (_existing != null && mounted) setState(() => _existing = null);
      return;
    }
    final found = await ref
        .read(wordRepositoryProvider)
        .findByHeadword(
          headword,
          _partOfSpeech,
          profileId: widget.profile.id,
        );
    if (!mounted) return;
    if (found?.id != _existing?.id) setState(() => _existing = found);
  }

  Future<void> _save() async {
    final headword = _headwordCtrl.text.trim();
    final meaning = _meaningCtrl.text.trim();
    if (headword.isEmpty || _saving) return;
    if (meaning.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('日本語訳を入力してください')));
      return;
    }
    setState(() => _saving = true);

    final words = ref.read(wordRepositoryProvider);
    final wordbooks = ref.read(wordbookRepositoryProvider);
    try {
      final editing = widget.editing;
      if (editing != null) {
        await words.updateWord(
          editing,
          headword: headword,
          partOfSpeech: _partOfSpeech,
          meaning: meaning,
          phonetic: _phoneticCtrl.text,
          exampleEn: _exampleEnCtrl.text,
          exampleJa: _exampleJaCtrl.text,
          level: _level,
        );
      } else {
        // 既存の語があればそれを使い、行を増やさない（学習状態を共有する）。
        final existing = await words.findByHeadword(
          headword,
          _partOfSpeech,
          profileId: widget.profile.id,
        );
        final id =
            existing?.id ??
            await words.createShared(
              headword: headword,
              partOfSpeech: _partOfSpeech,
              meaning: meaning,
              phonetic: _phoneticCtrl.text,
              exampleEn: _exampleEnCtrl.text,
              exampleJa: _exampleJaCtrl.text,
              level: _level,
            );
        final wordbookId = widget.wordbookId;
        if (wordbookId != null) await wordbooks.addWord(wordbookId, id);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      final message = e is StateError ? e.message : '保存に失敗しました: $e';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final existing = _existing;
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
              widget.editing == null ? '単語を追加' : '単語を編集',
              style: AppText.sectionTitle(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _headwordCtrl,
              autofocus: widget.editing == null,
              maxLength: 60,
              decoration: const InputDecoration(
                labelText: '見出し語',
                counterText: '',
              ),
            ),
            if (existing != null) ...[
              const SizedBox(height: 8),
              SoftCard(
                color: AppColors.accentSoft,
                padding: const EdgeInsets.all(10),
                child: Text(
                  'この語はすでに登録されています。新しく作らず、その語をこの単語帳に所属させます。'
                  '学習状態は共有されます。',
                  style: AppText.caption(color: AppColors.ink2),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SoftDropdown<PartOfSpeech>(
                    value: _partOfSpeech,
                    hint: '品詞',
                    items: [
                      for (final p in PartOfSpeech.values)
                        (value: p, label: p.label),
                    ],
                    onChanged: (p) {
                      setState(() => _partOfSpeech = p);
                      _checkExisting();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SoftDropdown<int>(
                    value: _level,
                    hint: 'レベル',
                    items: [
                      for (var i = 1; i <= 5; i++)
                        (value: i, label: 'レベル $i'),
                    ],
                    onChanged: (v) => setState(() => _level = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _meaningCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: '日本語訳'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneticCtrl,
              decoration: const InputDecoration(
                labelText: '発音記号（任意）',
                hintText: '/ˈæpəl/',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _exampleEnCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '自分で書く例文（任意）',
                helperText: '単語帳に載っている例文とは別に残ります',
                helperMaxLines: 2,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _exampleJaCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: '例文の和訳（任意）'),
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
