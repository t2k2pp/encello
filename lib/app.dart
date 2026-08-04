import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/enums.dart';
import 'providers/providers.dart';
import 'ui/screens/profile_gate_screen.dart';
import 'ui/screens/root_shell.dart';
import 'ui/widgets/shared_text_listener.dart';

/// アプリのルート。日本語を主言語とし、Material のローカライズも日本語/英語に対応。
///
/// 表示設定（文字サイズ・余白）と配色は**現在の学習者のもの**。学習者が未選択の間は
/// プロファイルゲート（SCR-00）を出し、既定の設定で描画する。
class EncelloApp extends ConsumerWidget {
  const EncelloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(activeProfileProvider);
    final textSize = profile == null
        ? TextSizeOption.medium
        : TextSizeOption.fromValue(profile.textScale);
    final density = profile == null
        ? UiDensity.standard
        : UiDensity.fromValue(profile.density);

    return MaterialApp(
      title: 'encello',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(density: density),
      builder: (context, child) {
        // 設定の文字サイズを端末側の文字拡大設定に乗算して適用する
        // （端末側の拡大を尊重しつつ、アプリ内でさらに調整できるようにする）。
        // 既定（中=1.0）は端末の textScaler をそのまま使う。
        if (textSize.scale == 1.0) return child!;
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(
              media.textScaler.scale(1.0) * textSize.scale,
            ),
          ),
          child: child!,
        );
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ja'), Locale('en')],
      locale: const Locale('ja'),
      // 他アプリからの共有テキストはプロファイルゲートを経由せず届く
      // （[Docs/06_features/my_words.md] §4.2）。ゲートの手前・後ろどちらでも
      // クイック登録シートを開けるよう、ルート直下に一度だけ差し込む。
      home: SharedTextListener(
        profile: profile,
        child: profile == null
            ? const ProfileGateScreen()
            // 配色 id だけでなく学習者 id もキーに含める。同じ配色の別人へ
            // 切り替えたときに古い状態が残らないようにするため
            // （[Docs/06_features/profiles.md] §5）。
            : KeyedSubtree(
                key: ValueKey('${profile.id}:${profile.palette}'),
                child: RootShell(profile: profile),
              ),
      ),
    );
  }
}
