import 'package:drift/native.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// メモリ上の DB を1つ作る。テスト終了時に必ず閉じる。
///
/// `beforeOpen` の `PRAGMA foreign_keys = ON` が効くため、学習者の削除で
/// 学習記録が cascade で消えることまで検証できる。
AppDatabase newTestDatabase() {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return db;
}

/// テスト用の学習者を作る（マイ単語帳も一緒にできる）。
Future<Profile> createTestProfile(
  AppDatabase db, {
  required String name,
  String emoji = '🙂',
  int colorSeed = 0,
  String paletteId = 'pink',
}) {
  return ProfileRepository(db).create(
    name: name,
    emoji: emoji,
    colorSeed: colorSeed,
    paletteId: paletteId,
  );
}

/// 共有の単語（`ownerProfileId = null`）を1語作り、id を返す。
Future<int> createSharedWord(
  AppDatabase db, {
  required String headword,
  String partOfSpeech = 'noun',
  String meaning = 'いみ',
}) {
  return db
      .into(db.words)
      .insert(
        WordsCompanion.insert(
          headword: headword,
          partOfSpeech: partOfSpeech,
          meaning: meaning,
        ),
      );
}
