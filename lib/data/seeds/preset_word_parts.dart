import 'package:meta/meta.dart';

import '../../core/utils/enums.dart';

/// 語の部品と派生語ファミリーのアセット（`assets/word_parts.json`）。
/// 形式は [Docs/06_features/word_parts.md] §9。
///
/// `seedVersion` は単語帳と同じ値にそろえる。投入ゲートはアセットの最大
/// `seedVersion` だけを見るため、ここだけ版がずれると端末に届かない
/// （[Docs/06_features/wordbooks.md] §3.1）。
@immutable
class PresetWordParts {
  final int seedVersion;
  final List<PresetPart> parts;
  final List<PresetPartLink> links;
  final List<PresetFamily> families;

  const PresetWordParts({
    required this.seedVersion,
    required this.parts,
    required this.links,
    required this.families,
  });

  factory PresetWordParts.fromJson(Map<String, dynamic> json) {
    return PresetWordParts(
      seedVersion: _requireInt(json, 'seedVersion'),
      parts: [
        for (final p in _requireList(json, 'parts'))
          PresetPart.fromJson(p as Map<String, dynamic>),
      ],
      links: [
        for (final l in _requireList(json, 'links'))
          PresetPartLink.fromJson(l as Map<String, dynamic>),
      ],
      families: [
        for (final f in _requireList(json, 'families'))
          PresetFamily.fromJson(f as Map<String, dynamic>),
      ],
    );
  }
}

/// 語の部品1つ（[Docs/06_features/word_parts.md] §2.1）。
@immutable
class PresetPart {
  /// 表記（`re-` / `port` / `-able`）。ハイフンの位置が種別を表す。
  final String form;
  final WordPartType type;
  final String meaning;
  final String? origin;
  final String? note;
  final int level;

  const PresetPart({
    required this.form,
    required this.type,
    required this.meaning,
    required this.origin,
    required this.note,
    required this.level,
  });

  factory PresetPart.fromJson(Map<String, dynamic> json) {
    return PresetPart(
      form: _requireString(json, 'form'),
      type: WordPartType.fromValue(_requireString(json, 'type')),
      meaning: _requireString(json, 'meaning'),
      origin: _optionalString(json, 'origin'),
      note: _optionalString(json, 'note'),
      level: _requireInt(json, 'level'),
    );
  }
}

/// 1語の分解（[Docs/06_features/word_parts.md] §2.2・§3.1）。
///
/// 語の参照は `headword` だけで行う。同じ綴りの語は品詞が違っても分解が同じなので、
/// **その見出し語のすべての品詞のレコードに同じ紐付けを張る**。
@immutable
class PresetPartLink {
  final String headword;

  /// 語の中での並び。この順に `word_part_links.position` を 0 から振る。
  final List<String> parts;

  /// 分解の説明1行。空なら部品の意味を `+` で繋いだだけを表示する。
  final String? partsNote;

  const PresetPartLink({
    required this.headword,
    required this.parts,
    required this.partsNote,
  });

  factory PresetPartLink.fromJson(Map<String, dynamic> json) {
    final parts = [for (final p in _requireList(json, 'parts')) p as String];
    if (parts.isEmpty) {
      throw FormatException('parts が空です: ${json['headword']}');
    }
    return PresetPartLink(
      headword: _requireString(json, 'headword'),
      parts: parts,
      partsNote: _optionalString(json, 'partsNote'),
    );
  }
}

/// 派生語ファミリー1つ（[Docs/06_features/word_families.md] §2）。
@immutable
class PresetFamily {
  final String baseForm;
  final String? note;

  /// 語族に属する見出し語。`baseForm` も含む。2語以上。
  final List<String> members;

  const PresetFamily({
    required this.baseForm,
    required this.note,
    required this.members,
  });

  factory PresetFamily.fromJson(Map<String, dynamic> json) {
    final members = [
      for (final m in _requireList(json, 'members')) m as String,
    ];
    final baseForm = _requireString(json, 'baseForm');
    // 1語の語族はカードも出題も成立しない（word_families.md §3・§4.2）。
    if (members.length < 2) {
      throw FormatException('語族 $baseForm の members が2語未満です');
    }
    if (!members.contains(baseForm)) {
      throw FormatException('語族 $baseForm の members に baseForm がありません');
    }
    return PresetFamily(
      baseForm: baseForm,
      note: _optionalString(json, 'note'),
      members: members,
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
