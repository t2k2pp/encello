import 'package:meta/meta.dart';

import '../../core/utils/enums.dart';

/// プリセット単語帳アセット（`assets/wordbooks/<presetId>.json`）の1冊。
/// 形式は [Docs/06_features/wordbooks.md] §3。
@immutable
class PresetWordbook {
  final String presetId;
  final String name;
  final String emoji;
  final WordbookCategory category;
  final int colorSeed;
  final int seedVersion;

  /// 語彙力測定で帯として使うときの語数。帯に使わない単語帳は null。
  final int? bandSize;
  final int sortOrder;
  final String? note;
  final List<PresetWord> words;

  const PresetWordbook({
    required this.presetId,
    required this.name,
    required this.emoji,
    required this.category,
    required this.colorSeed,
    required this.seedVersion,
    required this.bandSize,
    required this.sortOrder,
    required this.note,
    required this.words,
  });

  /// アセットの JSON から読む。欠けている必須項目や未知の値は推測で補わず例外にする
  /// （壊れたアセットのまま空の単語帳で起動させない）。
  factory PresetWordbook.fromJson(Map<String, dynamic> json) {
    return PresetWordbook(
      presetId: _requireString(json, 'presetId'),
      name: _requireString(json, 'name'),
      emoji: _requireString(json, 'emoji'),
      category: WordbookCategory.fromValue(_requireString(json, 'category')),
      colorSeed: _requireInt(json, 'colorSeed'),
      seedVersion: _requireInt(json, 'seedVersion'),
      bandSize: json['bandSize'] as int?,
      sortOrder: _requireInt(json, 'sortOrder'),
      note: _optionalString(json, 'note'),
      words: [
        for (final w in _requireList(json, 'words'))
          PresetWord.fromJson(w as Map<String, dynamic>),
      ],
    );
  }
}

/// プリセット単語帳に収録された1語。
@immutable
class PresetWord {
  /// アセット内の識別子（例 `jhs_v1:apple:noun`）。`words.presetId` に入れ、
  /// 「元に戻す」でアセットを引き直すキーにする。
  final String presetId;
  final String headword;
  final PartOfSpeech partOfSpeech;

  /// 発音記号。用意できない語は空（推測で書かない）。
  final String? phonetic;
  final String meaning;
  final String? exampleEn;
  final String? exampleJa;
  final int level;

  const PresetWord({
    required this.presetId,
    required this.headword,
    required this.partOfSpeech,
    required this.phonetic,
    required this.meaning,
    required this.exampleEn,
    required this.exampleJa,
    required this.level,
  });

  factory PresetWord.fromJson(Map<String, dynamic> json) {
    final level = _requireInt(json, 'level');
    if (level < 1 || level > 5) {
      throw FormatException('level は 1〜5 で指定してください: $level');
    }
    return PresetWord(
      presetId: _requireString(json, 'presetId'),
      // 見出し語は小文字で正規化して保存する（[Docs/03_data_model.md] §2.3）。
      headword: _requireString(json, 'headword').trim().toLowerCase(),
      partOfSpeech: PartOfSpeech.fromValue(
        _requireString(json, 'partOfSpeech'),
      ),
      phonetic: _optionalString(json, 'phonetic'),
      meaning: _requireString(json, 'meaning'),
      exampleEn: _optionalString(json, 'exampleEn'),
      exampleJa: _optionalString(json, 'exampleJa'),
      level: level,
    );
  }
}

String _requireString(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is! String || v.isEmpty) {
    throw FormatException('$key が文字列で入っていません: $v');
  }
  return v;
}

/// 空文字は「値なし」として null に寄せる（空文字と null を DB で混在させない）。
String? _optionalString(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v == null) return null;
  if (v is! String) throw FormatException('$key が文字列ではありません: $v');
  final trimmed = v.trim();
  return trimmed.isEmpty ? null : trimmed;
}

int _requireInt(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is! int) throw FormatException('$key が整数で入っていません: $v');
  return v;
}

List<dynamic> _requireList(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is! List) throw FormatException('$key が配列で入っていません: $v');
  return v;
}
