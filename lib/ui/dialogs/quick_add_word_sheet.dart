import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../data/database/app_database.dart';
import '../../providers/dictionary_listing.dart';
import '../../providers/providers.dart';
import '../widgets/english_keyboard.dart';
import '../widgets/soft_card.dart';
import '../widgets/soft_dropdown.dart';

/// マイ単語のクイック登録シート（[Docs/06_features/my_words.md] §4.1）。
///
/// 見出し語の入力には**アプリ内英字キーボード（[EnglishKeyboard]）**だけを使う。
/// `TextField`（`EditableText`）を見出し語に使うと OS の IME が予測変換で綴りを
/// 見せてしまうため、ここだけは絶対に使わない（[Docs/06_features/spell_mode.md] §2.1）。
/// 訳・見つけた文は日本語入力が要るため通常の `TextField` でよい。
///
/// 呼び出し口: 辞書画面ヘッダーの「＋単語」、シェル FAB の長押し
/// （[Docs/06_features/my_words.md] §4.1）。
Future<void> showQuickAddWordSheet(
  BuildContext context, {
  required Profile profile,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _QuickAddWordSheet(profile: profile),
  );
}

class _QuickAddWordSheet extends ConsumerStatefulWidget {
  final Profile profile;

  const _QuickAddWordSheet({required this.profile});

  @override
  ConsumerState<_QuickAddWordSheet> createState() =>
      _QuickAddWordSheetState();
}

class _QuickAddWordSheetState extends ConsumerState<_QuickAddWordSheet> {
  String _typed = '';
  PartOfSpeech _partOfSpeech = PartOfSpeech.noun;
  final _meaningCtrl = TextEditingController();
  final _exampleCtrl = TextEditingController();
  bool _saving = false;

  /// 見出し語＋品詞が一致する**共有の**既存語（推測で登録先を決めないための分岐）。
  Word? _existing;

  @override
  void dispose() {
    _meaningCtrl.dispose();
    _exampleCtrl.dispose();
    super.dispose();
  }

  bool get _hasConflict => _existing != null;

  void _onKey(String ch) {
    setState(() => _typed = '$_typed$ch');
    _checkExisting();
  }

  void _onBackspace() {
    if (_typed.isEmpty) return;
    setState(() => _typed = _typed.substring(0, _typed.length - 1));
    _checkExisting();
  }

  void _onPartOfSpeechChanged(PartOfSpeech p) {
    setState(() => _partOfSpeech = p);
    _checkExisting();
  }

  /// 入力中の見出し語＋品詞が既存の**共有**語と一致するか確認する。
  /// 自分のマイ単語との重複はここでは示さない（保存時に一意制約で弾かれる）。
  Future<void> _checkExisting() async {
    final headword = _typed.trim();
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
    final shared = (found != null && found.ownerProfileId == null)
        ? found
        : null;
    if (shared?.id != _existing?.id) setState(() => _existing = shared);
  }

  Future<void> _save({bool keepOpen = false}) async {
    final headword = _typed.trim();
    if (headword.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(wordRepositoryProvider)
          .createOwned(
            ownerProfileId: widget.profile.id,
            headword: headword,
            partOfSpeech: _partOfSpeech,
            meaning: _meaningCtrl.text.trim(),
            exampleEn: _exampleCtrl.text,
          );
      if (!mounted) return;
      if (keepOpen) {
        // シートは閉じず、入力だけをクリアして連続登録できるようにする
        // （[Docs/06_features/my_words.md] §4.1）。
        setState(() {
          _typed = '';
          _meaningCtrl.clear();
          _exampleCtrl.clear();
          _existing = null;
          _saving = false;
        });
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存に失敗しました: $e')));
    }
  }

  /// 既存の共有語を、新規作成せずに自分のマイ単語帳へ所属させる
  /// （その語が自分のマイ単語帳に選ばれていれば出題対象に入る）。
  Future<void> _useExisting() async {
    final existing = _existing;
    if (existing == null || _saving) return;
    setState(() => _saving = true);
    try {
      final wordbooks = ref.read(wordbookRepositoryProvider);
      final myBook = await wordbooks.myWordsBookOf(widget.profile.id);
      await wordbooks.addWord(myBook.id, existing.id);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('学習対象にできませんでした: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _typed.trim().isNotEmpty && !_saving && !_hasConflict;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('単語を追加', style: AppText.sectionTitle()),
            const SizedBox(height: 12),
            _HeadwordDisplay(typed: _typed),
            const SizedBox(height: 8),
            EnglishKeyboard(
              layout: KeyboardLayout.fromValue(widget.profile.keyboardLayout),
              onKey: _onKey,
              onBackspace: _onBackspace,
              onSubmit: canSave ? () => _save() : null,
              submitLabel: '保存',
            ),
            if (_hasConflict) ...[
              const SizedBox(height: 4),
              _ExistingWordCard(
                existing: _existing!,
                profile: widget.profile,
                busy: _saving,
                onRegisterMine: () => _save(),
                onUseExisting: _useExisting,
              ),
            ],
            const SizedBox(height: 12),
            SoftDropdown<PartOfSpeech>(
              value: _partOfSpeech,
              hint: '品詞',
              items: [
                for (final p in PartOfSpeech.values) (value: p, label: p.label),
              ],
              onChanged: _onPartOfSpeechChanged,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _meaningCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '訳',
                hintText: '空でもよい（下書きとして保存します）',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _exampleCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '見つけた文（任意）',
                hintText: 'この単語を見つけた文',
              ),
            ),
            const SizedBox(height: 20),
            if (!_hasConflict)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: canSave ? () => _save(keepOpen: true) : null,
                      child: const Text(
                        '保存してもう1語',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: canSave ? () => _save() : null,
                      child: const Text(
                        '保存',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// 見出し語の入力表示（読み取り専用。入力は [EnglishKeyboard] から行う）。
class _HeadwordDisplay extends StatelessWidget {
  final String typed;

  const _HeadwordDisplay({required this.typed});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Text(
        typed.isEmpty ? '見出し語を入力' : typed,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: typed.isEmpty
            ? AppText.body(color: AppColors.ink3)
            : AppText.style(size: 24, weight: FontWeight.w700),
      ),
    );
  }
}

/// 既存の共有語が見つかったときの案内（[Docs/06_features/my_words.md] §4.1）。
/// マイ単語として登録するか、既存の語を学習対象にするかを明示的に選ばせる
/// （推測でどちらかに倒さない）。
class _ExistingWordCard extends ConsumerWidget {
  final Word existing;
  final Profile profile;
  final bool busy;
  final VoidCallback onRegisterMine;
  final VoidCallback onUseExisting;

  const _ExistingWordCard({
    required this.existing,
    required this.profile,
    required this.busy,
    required this.onRegisterMine,
    required this.onUseExisting,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref
        .watch(
          wordbooksOfWordProvider(
            (wordId: existing.id, profileId: profile.id),
          ),
        )
        .value;
    final names = books?.map((b) => b.name).join('、');
    final locationText = names == null
        ? 'この語はすでに登録されています。'
        : names.isEmpty
        ? 'この語はすでに登録されています（所属している単語帳はありません）。'
        : 'この語は「$names」にあります。';

    return SoftCard(
      color: AppColors.accentSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locationText,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(color: AppColors.ink2),
          ),
          const SizedBox(height: 4),
          Text(
            '新しく作らず、マイ単語として登録するか、既存の語を学習対象にするか選んでください。',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : onUseExisting,
                  child: const Text(
                    '既存の語を学習対象にする',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                  onPressed: busy ? null : onRegisterMine,
                  child: const Text(
                    'マイ単語として登録する',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
