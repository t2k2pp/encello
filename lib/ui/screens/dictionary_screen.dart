import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';

/// SCR-08 辞書（[Docs/04_screens_and_flows.md] §4.7）。
///
/// 検索・フィルタ・ソート・リスト/グリッド切替は、単語が入る段階で実装する。
/// 単語が1語も無い状態で操作部品だけを並べても意味がないため、いまは空状態だけを出す。
class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      emoji: '🔤',
      message: 'まだ単語がありません',
      subMessage: '単語帳を入れると、ここで英語・日本語のどちらからでも引けるようになります。',
    );
  }
}
