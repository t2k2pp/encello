import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/wordbook_repository.dart';
import '../../providers/providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/soft_card.dart';
import 'wordbooks_screen.dart';

/// SCR-01 ホーム（[Docs/04_screens_and_flows.md] §4.1）。
///
/// 学習対象の単語帳が1冊も選ばれていない間は、案内と単語帳選びへの導線だけを出す
/// （勝手にどれかを選んだことにしない。[Docs/06_features/wordbooks.md] §6）。
/// 今日のカード・モードカード・語彙力カードは、それぞれの機能が入った時点で足す。
class HomeScreen extends ConsumerWidget {
  /// 現在の学習者。
  final Profile profile;

  const HomeScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = AppSpacing.of(context);
    // 単語帳の選択は他画面からも変わるため、最新の学習者を見る。
    final current = ref.watch(activeProfileProvider) ?? profile;
    final selected = decodeIdList(current.selectedWordbookIds).toSet();
    final books = ref.watch(wordbooksProvider(current.id)).value;
    final studying = books
        ?.where((b) => selected.contains(b.wordbook.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: spacing.screenPadding.copyWith(bottom: 0),
          child: _HomeHeader(profile: current),
        ),
        Expanded(
          child: studying == null
              ? const Center(child: CircularProgressIndicator())
              : studying.isEmpty
              ? EmptyState(
                  emoji: '📚',
                  message: '学習する単語帳を選びましょう',
                  subMessage: '選んだ単語帳の語が、辞書と学習の対象になります。あとから何度でも変えられます。',
                  actionLabel: '自分で単語帳を選ぶ',
                  onAction: () => _openWordbooks(context, current),
                )
              : ListView(
                  padding: spacing.screenPadding.copyWith(bottom: 32),
                  children: [
                    _StudyTargetCard(
                      books: studying,
                      onEdit: () => _openWordbooks(context, current),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  void _openWordbooks(BuildContext context, Profile profile) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WordbooksScreen(profile: profile),
      ),
    );
  }
}

/// 学習対象にしている単語帳のまとめ。
class _StudyTargetCard extends StatelessWidget {
  final List<WordbookWithCount> books;
  final VoidCallback onEdit;

  const _StudyTargetCard({required this.books, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final total = books.fold(0, (sum, b) => sum + b.wordCount);
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('学習する単語帳', style: AppText.sectionTitle())),
              TextButton(onPressed: onEdit, child: const Text('変更')),
            ],
          ),
          Text('${books.length}冊 ・ のべ$total語', style: AppText.caption()),
          const SizedBox(height: 8),
          for (final b in books)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Text(
                    b.wordbook.emoji,
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      b.wordbook.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(),
                    ),
                  ),
                  Text('${b.wordCount}語', style: AppText.caption()),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// ホームの見出し行。右上に現在の学習者のアバターを置き、タップで切り替える
/// （学習者が1人だけのときも表示する。自分の色と絵文字が見えることに意味がある）。
class _HomeHeader extends ConsumerWidget {
  final Profile profile;

  const _HomeHeader({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ホーム',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.title(),
              ),
              Text(
                '${profile.name} さん',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: '学習者を切り替える',
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => ref.read(activeProfileProvider.notifier).clear(),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: ProfileAvatar(
                emoji: profile.emoji,
                colorSeed: profile.colorSeed,
                selected: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
