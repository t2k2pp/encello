import 'dart:io';
import 'dart:ui' as ui;

import 'package:encello/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// アプリアイコンとスプラッシュのロゴを描き出す
/// （[Docs/08_platform_setup.md] §5）。
///
/// ```
/// flutter test tool/build_brand_images.dart
/// dart run flutter_launcher_icons          # 続けてランチャーアイコンの各解像度を生成する
/// ```
///
/// 画像編集ソフトで作った PNG を置くのではなく、**アプリと同じトークンから描く**。
/// 配色を変えたときに画像だけ取り残されるのを防ぐため、色は
/// [pinkPalette]（[Docs/08_platform_setup.md] §5 が既定とする配色）から取る。
///
/// Flutter のレンダラで描くので `flutter test` の上で走らせる。テスト本体では
/// ないため `test/` ではなく `tool/` に置く（`flutter test` の既定の走査対象は
/// `test/` なので、通常のテスト実行では拾われない）。
void main() {
  /// アイコン原画の一辺。`flutter_launcher_icons` がここから各解像度へ縮小する。
  const iconSize = 1024.0;

  /// アダプティブアイコンは `adaptive_icon_foreground_inset: 18` で内側へ寄せられ、
  /// さらに端末のマスクで四隅が削られる。図柄はこの割合まで内側に収める。
  const iconSafe = 0.80;

  /// スプラッシュのロゴ幅（dp）。1x の PNG がこの画素数になる。
  const splashLogoDp = 200.0;

  /// Android の密度バケット。`drawable-<bucket>/` に 1x 比の PNG を置く。
  /// レイヤーリストの `bitmap` は密度ごとの実寸で描かれるため、1枚では足りない。
  const androidDensities = <String, double>{
    'mdpi': 1.0,
    'hdpi': 1.5,
    'xhdpi': 2.0,
    'xxhdpi': 3.0,
    'xxxhdpi': 4.0,
  };

  /// iOS の `LaunchImage.imageset`。ファイル名の接尾辞と倍率。
  const iosScales = <String, double>{'': 1.0, '@2x': 2.0, '@3x': 3.0};

  /// 1枚描いて PNG のバイト列にする。
  ///
  /// フォントの読み込みと `Picture.toImage` はエンジン側の応答を待つため、
  /// 呼び出し側は `runAsync` の中から呼ぶこと（`flutter_test` の疑似時間の中では
  /// 完了しない。[Docs/07_testing_strategy.md] §4 と同じ理由）。
  Future<Uint8List> render(
    double width,
    double height,
    void Function(Canvas) paint,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));
    paint(canvas);
    final image = await recorder.endRecording().toImage(
      width.round(),
      height.round(),
    );
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    return png!.buffer.asUint8List();
  }

  /// 同梱フォント（Noto Sans JP）を読み込む。テスト環境の既定フォントは字形が
  /// 潰れるため、実機と同じ字形になるよう明示的に読み込む。
  Future<void> loadFont() async {
    final bytes = await File(
      'assets/google_fonts/NotoSansJP-ExtraBold.ttf',
    ).readAsBytes();
    await (FontLoader('NotoSansJP')
          ..addFont(Future.value(bytes.buffer.asByteData())))
        .load();
  }

  Future<void> write(String path, Uint8List bytes) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
    // 書けたことを確かめる（黙って0バイトを置かない）。
    expect(file.lengthSync(), greaterThan(0), reason: '$path が空');
  }

  testWidgets('アプリアイコンの原画を描き出す', (tester) async {
    await tester.runAsync(() async {
      await loadFont();
      await write(
        'assets/icon/app_icon.png',
        await render(iconSize, iconSize, (canvas) {
          canvas.drawRect(
            const Rect.fromLTWH(0, 0, iconSize, iconSize),
            Paint()..color = pinkPalette.bg,
          );
          _paintMark(canvas, iconSize, iconSize, iconSize * iconSafe);
        }),
      );
    });
  });

  testWidgets('スプラッシュのロゴを描き出す（Android の各密度と iOS の各倍率）', (tester) async {
    await tester.runAsync(() async {
      await loadFont();

      // 背景はネイティブ側（`launch_background.xml` / storyboard）が塗るので、
      // ロゴは**背景を塗らずに**描く。塗ると濃さのわずかな差が四角く見える。
      for (final entry in androidDensities.entries) {
        final width = splashLogoDp * entry.value;
        final height = _markHeightFor(width);
        await write(
          'android/app/src/main/res/drawable-${entry.key}/splash_logo.png',
          await render(
            width,
            height,
            (canvas) => _paintMark(canvas, width, height, width),
          ),
        );
      }

      // iOS の `LaunchImage` は storyboard が中央へ原寸で置く。
      for (final entry in iosScales.entries) {
        final width = splashLogoDp * entry.value;
        final height = _markHeightFor(width);
        await write(
          'ios/Runner/Assets.xcassets/LaunchImage.imageset/'
          'LaunchImage${entry.key}.png',
          await render(
            width,
            height,
            (canvas) => _paintMark(canvas, width, height, width),
          ),
        );
      }
    });
  });
}

/// 図柄。タイル3枚の比率をここ1か所で決め、アイコンもスプラッシュも同じ形にする。
const _tileCount = 3;
const _tileGapRatio = 0.10; // タイル幅に対する間隔
const _faceRatio = 1.12; // タイル幅に対する面の高さ
const _underlineRatio = 0.15; // タイル幅に対する下線の高さ
const _underlineGapRatio = 0.11; // タイル幅に対する面と下線の間隔

/// 図柄の幅から高さを求める。スプラッシュ用の画像の縦横比に使う。
double _markHeightFor(double markWidth) {
  final tileWidth =
      markWidth / (_tileCount + _tileGapRatio * (_tileCount - 1));
  return tileWidth * (_faceRatio + _underlineGapRatio + _underlineRatio);
}

/// 図柄を [width] × [height] の中央へ、幅 [markWidth] で描く。
///
/// 綴りを打つ画面の文字タイル（`LetterTiles`）をそのまま図案にする。
/// 開いた1枚のタイルに `e`、その右に未入力のタイルを2つ並べ、
/// 「これから綴る」状態を表す。
void _paintMark(Canvas canvas, double width, double height, double markWidth) {
  const palette = pinkPalette;

  final tileWidth =
      markWidth / (_tileCount + _tileGapRatio * (_tileCount - 1));
  final tileGap = tileWidth * _tileGapRatio;
  final faceHeight = tileWidth * _faceRatio;
  final underlineHeight = tileWidth * _underlineRatio;
  final underlineGap = tileWidth * _underlineGapRatio;

  final left = (width - markWidth) / 2;
  final top = (height - _markHeightFor(markWidth)) / 2;

  for (var i = 0; i < _tileCount; i++) {
    _paintTile(
      canvas,
      face: Rect.fromLTWH(
        left + i * (tileWidth + tileGap),
        top,
        tileWidth,
        faceHeight,
      ),
      underlineHeight: underlineHeight,
      underlineGap: underlineGap,
      palette: palette,
      character: i == 0 ? 'e' : null,
    );
  }
}

/// 文字タイル1枚。埋まっているタイルは accent の面に白抜きの文字と accentDeep の
/// 下線、未入力のタイルは accentSoft の面と accent の下線（`LetterTiles` と同じ
/// 「埋まっているほど濃い」関係）。
void _paintTile(
  Canvas canvas, {
  required Rect face,
  required double underlineHeight,
  required double underlineGap,
  required AppPalette palette,
  required String? character,
}) {
  final filled = character != null;
  canvas.drawRRect(
    RRect.fromRectAndRadius(face, Radius.circular(face.width * 0.24)),
    Paint()..color = filled ? palette.accent : palette.accentSoft,
  );
  if (filled) _paintCharacter(canvas, face, character, palette.card);

  final underline = Rect.fromLTWH(
    face.left,
    face.bottom + underlineGap,
    face.width,
    underlineHeight,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(underline, Radius.circular(underlineHeight / 2)),
    Paint()..color = filled ? palette.accentDeep : palette.accent,
  );
}

/// タイルの面に文字を1つ、中央へ描く。
///
/// `TextPainter` の行ボックスは上下にアセンダ・ディセンダの余白を含む。
/// そのまま中央に置くと `e` のような**上下に伸びない字**が下がって見えるので、
/// ベースラインから x ハイトの半分だけ下げた位置に字の中心が来るよう合わせる。
void _paintCharacter(Canvas canvas, Rect face, String character, Color color) {
  final fontSize = face.height * 0.66;
  final painter = TextPainter(
    text: TextSpan(
      text: character,
      style: TextStyle(
        color: color,
        fontFamily: 'NotoSansJP',
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        height: 1.0,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  // Noto Sans の x ハイトは em の約 0.54。
  final baselineY = face.center.dy + fontSize * 0.54 / 2;
  final toBaseline = painter.computeDistanceToActualBaseline(
    TextBaseline.alphabetic,
  );
  painter.paint(
    canvas,
    Offset(face.center.dx - painter.width / 2, baselineY - toBaseline),
  );
}
