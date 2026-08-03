import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 任意の内容を返すアセットバンドル。プリセット投入のテストで、
/// アセット側の版や収録語を差し替えるために使う。
class FakeAssetBundle extends CachingAssetBundle {
  final Map<String, String> contents;

  FakeAssetBundle(this.contents);

  @override
  Future<ByteData> load(String key) async {
    final value = contents[key];
    if (value == null) throw FlutterError('アセットがありません: $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}

/// テスト用のプリセット単語帳 JSON を組み立てる。
String presetJson({
  String presetId = 'jhs_v1',
  String name = '中学英単語',
  String emoji = '🏫',
  String category = 'juniorHigh',
  int colorSeed = 1,
  int seedVersion = 1,
  int? bandSize = 1600,
  int sortOrder = 10,
  String? note = 'テスト用',
  required List<Map<String, Object?>> words,
}) {
  return jsonEncode({
    'presetId': presetId,
    'name': name,
    'emoji': emoji,
    'category': category,
    'colorSeed': colorSeed,
    'seedVersion': seedVersion,
    'bandSize': bandSize,
    'sortOrder': sortOrder,
    'note': note,
    'words': words,
  });
}

/// テスト用のプリセット語1件。
Map<String, Object?> presetWordJson({
  required String headword,
  String partOfSpeech = 'noun',
  String meaning = 'いみ',
  String? phonetic,
  String? exampleEn,
  String? exampleJa,
  int level = 1,
  String? presetId,
}) {
  return {
    'presetId': presetId ?? 'jhs_v1:$headword:$partOfSpeech',
    'headword': headword,
    'partOfSpeech': partOfSpeech,
    'meaning': meaning,
    'phonetic': phonetic,
    'exampleEn': exampleEn,
    'exampleJa': exampleJa,
    'level': level,
  };
}
