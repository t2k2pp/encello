import 'package:flutter/material.dart';

/// テーマ配色の1セット（[STYLE_GUIDE §1.2]、[Docs/05_design_system.md] §1.1）。
///
/// 背景・文字・アクセント等の「テーマで変わる色」だけを持つ。判定色（正解・惜しい・
/// 不正解）や習熟度色のように**意味が固定された色**は [AppColors] の `static const`
/// のままテーマ間で共有する。
@immutable
class AppPalette {
  const AppPalette({
    required this.id,
    required this.label,
    required this.bg,
    required this.card,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.line,
    required this.accent,
    required this.accentSoft,
    required this.accentDeep,
    required this.chipBg,
  });

  /// 永続化・[ValueKey] 用の識別子（'pink' / 'blue' など）
  final String id;

  /// 設定画面に出す表示名
  final String label;

  final Color bg;
  final Color card;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color line;
  final Color accent;
  final Color accentSoft;
  final Color accentDeep;
  final Color chipBg;
}

/// オレンジ系（pricello の既定）
const orangePalette = AppPalette(
  id: 'orange',
  label: 'オレンジ',
  bg: Color(0xFFFBF6F1),
  card: Color(0xFFFFFFFF),
  ink: Color(0xFF2B2622),
  ink2: Color(0xFF6B6059),
  ink3: Color(0xFFA39890),
  line: Color(0xFFEEE6DC),
  accent: Color(0xFFEC6A3A),
  accentSoft: Color(0xFFFDE9DF),
  accentDeep: Color(0xFFC4481E),
  chipBg: Color(0xFFF3ECE2),
);

/// イエロー系（shcello の既定）。純黄は白文字のコントラストが取れないため
/// accent は白に対して 3.0:1 の金茶にし、黄色らしさは bg / accentSoft / chipBg で出す。
const yellowPalette = AppPalette(
  id: 'yellow',
  label: 'イエロー',
  bg: Color(0xFFFDFAF0),
  card: Color(0xFFFFFFFF),
  ink: Color(0xFF3B3418),
  ink2: Color(0xFF736A4C),
  ink3: Color(0xFFB3A984),
  line: Color(0xFFF1E9D2),
  accent: Color(0xFFBE8C0E),
  accentSoft: Color(0xFFFBF0D2),
  accentDeep: Color(0xFF8F6A05),
  chipBg: Color(0xFFF5EEDC),
);

/// グリーン系（breezy-recipe-stock の既定）
const greenPalette = AppPalette(
  id: 'green',
  label: 'グリーン',
  bg: Color(0xFFF4FAF6),
  card: Color(0xFFFFFFFF),
  ink: Color(0xFF22423F),
  ink2: Color(0xFF5C7370),
  ink3: Color(0xFF98ACA8),
  line: Color(0xFFE2EEE7),
  accent: Color(0xFF2F9E8F),
  accentSoft: Color(0xFFDFF3EE),
  accentDeep: Color(0xFF1E7A6C),
  chipBg: Color(0xFFEAF3ED),
);

/// ブルー系（stocello / mdcello の既定）
const bluePalette = AppPalette(
  id: 'blue',
  label: 'ブルー',
  bg: Color(0xFFF3F7FB),
  card: Color(0xFFFFFFFF),
  ink: Color(0xFF24384A),
  ink2: Color(0xFF5A6E80),
  ink3: Color(0xFF97A9B9),
  line: Color(0xFFE1EAF2),
  accent: Color(0xFF3E7BC0),
  accentSoft: Color(0xFFE0ECF8),
  accentDeep: Color(0xFF2A5C99),
  chipBg: Color(0xFFE9F0F7),
);

/// パープル系（pacello の既定）
const purplePalette = AppPalette(
  id: 'purple',
  label: 'パープル',
  bg: Color(0xFFF8F5FB),
  card: Color(0xFFFFFFFF),
  ink: Color(0xFF3A2E4A),
  ink2: Color(0xFF6D6180),
  ink3: Color(0xFFA99BB9),
  line: Color(0xFFECE4F3),
  accent: Color(0xFF8A63C0),
  accentSoft: Color(0xFFEFE6F8),
  accentDeep: Color(0xFF6A44A0),
  chipBg: Color(0xFFF0E9F7),
);

/// パステルピンク系（**encello の既定**）
const pinkPalette = AppPalette(
  id: 'pink',
  label: 'ピンク',
  bg: Color(0xFFFDF5F8),
  card: Color(0xFFFFFFFF),
  ink: Color(0xFF4A2A38),
  ink2: Color(0xFF7C5866),
  ink3: Color(0xFFB89AA6),
  line: Color(0xFFF3E2EA),
  accent: Color(0xFFD86A93),
  accentSoft: Color(0xFFF7E3EC),
  accentDeep: Color(0xFFB84A73),
  chipBg: Color(0xFFF6E7EE),
);

/// 選べるテーマ配色。姉妹アプリ共通の6配色で、並びも全アプリで揃える
/// （色相環順: オレンジ→イエロー→グリーン→ブルー→パープル→ピンク。[STYLE_GUIDE §1.2]）。
const appPalettes = <AppPalette>[
  orangePalette,
  yellowPalette,
  greenPalette,
  bluePalette,
  purplePalette,
  pinkPalette,
];

/// id から配色を得る。未知の id（廃止配色など）は**このアプリの既定＝ピンク**へ
/// 戻す（[STYLE_GUIDE §1.2] の既定表）。
AppPalette paletteById(String? id) =>
    appPalettes.firstWhere((p) => p.id == id, orElse: () => pinkPalette);

/// デザイントークン（色）。[Docs/05_design_system.md] §1。
///
/// テーマで変わる色は [active] 配色から読む。学習者の切り替え・設定変更時に
/// [setActive] で差し替え、実際の再描画はルートが `'<profileId>:<paletteId>'` を
/// キーにサブツリーを作り直して行う（`app.dart` の [KeyedSubtree]）。
///
/// **これらの getter を参照する式に `const` を付けてはならない**（定数式にならない）。
abstract final class AppColors {
  static AppPalette _active = pinkPalette;

  /// 現在のテーマ配色
  static AppPalette get active => _active;

  /// テーマ配色を差し替える（学習者の切り替え・設定変更・起動時に呼ぶ）
  static void setActive(AppPalette palette) => _active = palette;

  static Color get bg => _active.bg;
  static Color get card => _active.card;
  static Color get ink => _active.ink; // 主要テキスト
  static Color get ink2 => _active.ink2; // 二次テキスト
  static Color get ink3 => _active.ink3; // 三次テキスト/プレースホルダ
  static Color get line => _active.line; // 罫線/区切り
  static Color get accent => _active.accent; // CTA/FAB/選択状態
  static Color get accentSoft => _active.accentSoft;
  static Color get accentDeep => _active.accentDeep; // 破壊的操作の文字色
  static Color get chipBg => _active.chipBg;

  // --- 判定色（semantic・テーマ切替で変えない。[Docs/05_design_system.md] §1.2）---
  //
  // 正誤のフィードバックはこのアプリの中核なので、配色を変えても意味が変わらない
  // よう固定する。**色だけで正誤を伝えない**（必ずアイコンと文言を添える）。

  /// 正解。白背景では 3.5:1 のため**バッジ・アイコン・18px以上の太字**にだけ使う
  static const correct = Color(0xFF379B5C);

  /// 正解の説明文（本文サイズ用。白背景 5.3:1）
  static const correctText = Color(0xFF2A7746);

  /// 「惜しい」帯の背景（白文字 3.0:1）
  static const nearMissFill = Color(0xFFBE8C0E);

  /// 「惜しい」の文字（本文サイズ用。白背景 4.6:1）
  static const nearMissText = Color(0xFF96700B);

  /// 不正解（白背景 5.2:1・白文字 5.2:1 のどちらでも使える）
  static const wrong = Color(0xFFC43A34);

  /// 習熟度リングの背景
  static const masteryTrack = Color(0xFFEDE7EA);

  // --- 習熟度色（[Docs/05_design_system.md] §1.3）---
  //
  // 未学習は [line]（テーマ追従）、学習中は [accent]（テーマ追従）で表すため、
  // ここに定数として持つのは意味が固定される「定着」「マスター」だけ。

  /// 定着（出題間隔が21日以上）
  static const settled = Color(0xFF7BA7D4);

  /// マスター（出題間隔が90日以上かつ直近が正解）。正解色と同じ緑を使う
  static const mastered = correct;

  // --- 識別色（[STYLE_GUIDE §1.1]）---

  /// 単語帳・学習者の識別色。`palette[seed % 9]` で安定して割り当てる
  static const accentPalette = <Color>[
    Color(0xFFEC6A3A),
    Color(0xFF3A7BEC),
    Color(0xFF379B5C),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
    Color(0xFF64748B),
  ];

  /// 任意のシード（colorSeed 等）から安定して識別色を選ぶ。
  static Color seedColor(int seed) =>
      accentPalette[seed.abs() % accentPalette.length];
}
