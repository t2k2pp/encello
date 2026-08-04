import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/domain/services/tts_service.dart';
import 'package:encello/providers/audio.dart';
import 'package:encello/ui/screens/settings_screen.dart';
import 'package:encello/ui/screens/word_detail_screen.dart';
import 'package:encello/ui/widgets/speak_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';
import '../helpers/study_fixture.dart';
import '../helpers/test_database.dart';

/// M4 の完了条件（[Docs/09_roadmap.md]）:
/// 音声パックを入れた語は録音、入れていない語は合成音声で鳴り、バッジでどちらか分かる。
/// パックを消しても合成音声で鳴り続ける。
void main() {
  late AppDatabase db;
  late Profile me;

  setUp(() async {
    db = newTestDatabase();
    me = await createTestProfile(db, name: 'たろう');
  });

  /// apple に音声ファイルを持つパックを入れ、学習者に使わせる。
  Future<void> installPack(int wordId) async {
    final packId = await db
        .into(db.audioPacks)
        .insert(
          AudioPacksCompanion.insert(
            packId: 'jhs_en_us_v1',
            name: '中学英単語 音声（米）',
            source: AudioPackSource.imported.value,
            lang: SpeechLang.en.value,
            entryCount: const Value(1),
          ),
        );
    await db
        .into(db.wordAudios)
        .insert(
          WordAudiosCompanion.insert(
            wordId: wordId,
            packId: packId,
            lang: SpeechLang.en.value,
            filePath: 'jhs_en_us_v1/audio/apple.mp3',
          ),
        );
    await (db.update(db.profiles)..where((t) => t.id.equals(me.id))).write(
      ProfilesCompanion(audioPackIds: Value('[$packId]')),
    );
  }

  Future<Profile> reloadProfile() =>
      (db.select(db.profiles)..where((t) => t.id.equals(me.id))).getSingle();

  Future<Word> firstWord() => db.select(db.words).getSingle();

  group('読み上げボタンと音源バッジ', () {
    testWidgets('voice があればボタンが出て、パックが無いのでバッジは出ない', (tester) async {
      await seedStudyTarget(db, me);
      final word = await firstWord();

      await pumpWithProviders(
        tester,
        db: db,
        child: WordDetailScreen(wordId: word.id, profile: await reloadProfile()),
        activeProfile: await reloadProfile(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SpeakWordButton), findsOneWidget);
      // パックが1つも無ければ全部 🔉 になり情報にならないため出さない。
      expect(find.text('🔉'), findsNothing);
      expect(find.text('🎙'), findsNothing);
    });

    testWidgets('パックを入れた語は 🎙 のバッジが付く', (tester) async {
      await seedStudyTarget(db, me);
      final word = await firstWord();
      await installPack(word.id);
      final profile = await reloadProfile();

      await pumpWithProviders(
        tester,
        db: db,
        child: WordDetailScreen(wordId: word.id, profile: profile),
        activeProfile: profile,
      );
      await tester.pumpAndSettle();

      expect(find.text('🎙'), findsOneWidget);
    });

    testWidgets('パックに無い語は 🔉（合成音声）になる', (tester) async {
      await seedStudyTarget(
        db,
        me,
        headwords: const {'apple': 'りんご', 'banana': 'バナナ'},
      );
      final words = await db.select(db.words).get();
      final apple = words.firstWhere((w) => w.headword == 'apple');
      final banana = words.firstWhere((w) => w.headword == 'banana');
      await installPack(apple.id);
      final profile = await reloadProfile();

      await pumpWithProviders(
        tester,
        db: db,
        child: WordDetailScreen(wordId: banana.id, profile: profile),
        activeProfile: profile,
      );
      await tester.pumpAndSettle();

      expect(find.text('🔉'), findsOneWidget);
    });

    testWidgets('voice もパックも無ければボタンごと出さない', (tester) async {
      await seedStudyTarget(db, me);
      final word = await firstWord();

      await pumpWithProviders(
        tester,
        db: db,
        child: WordDetailScreen(wordId: word.id, profile: me),
        activeProfile: me,
        ttsCapability: TtsCapability.none,
      );
      await tester.pumpAndSettle();

      // 無効化してグレーにするのではなく、出さない。
      expect(find.byIcon(Icons.volume_up), findsNothing);
    });
  });

  group('使えるモード', () {
    testWidgets('英語 voice があればリスニングが選べる', (tester) async {
      final seeded = await seedStudyTarget(db, me);
      final container = await pumpWithProviders(
        tester,
        db: db,
        child: const SizedBox.shrink(),
        activeProfile: seeded.profile,
      );

      final modes = await container.read(
        availableModesProvider(seeded.profile).future,
      );
      expect(modes, contains(StudyMode.listening));
      expect(modes, contains(StudyMode.spell));
      expect(modes, contains(StudyMode.flashcard));
    });

    testWidgets('英語 voice もパックも無ければリスニングは選択肢に出ない', (tester) async {
      final seeded = await seedStudyTarget(db, me);
      final container = await pumpWithProviders(
        tester,
        db: db,
        child: const SizedBox.shrink(),
        activeProfile: seeded.profile,
        ttsCapability: TtsCapability.none,
      );

      final modes = await container.read(
        availableModesProvider(seeded.profile).future,
      );
      expect(modes, isNot(contains(StudyMode.listening)));
      // 無音で送れるフラッシュカードは音が無くても選べる。
      expect(modes, contains(StudyMode.flashcard));
    });

    testWidgets('英語 voice が無くても英語のパックがあればリスニングが選べる', (tester) async {
      await seedStudyTarget(db, me);
      final word = await firstWord();
      await installPack(word.id);
      final profile = await reloadProfile();

      final container = await pumpWithProviders(
        tester,
        db: db,
        child: const SizedBox.shrink(),
        activeProfile: profile,
        ttsCapability: const TtsCapability(enVoices: [], jaVoices: []),
      );

      final modes = await container.read(
        availableModesProvider(profile).future,
      );
      expect(modes, contains(StudyMode.listening));
    });
  });

  group('設定の音声カード', () {
    testWidgets('音声が1つも無い端末ではカードを1行に置き換える', (tester) async {
      await pumpWithProviders(
        tester,
        db: db,
        child: SettingsScreen(profile: me),
        activeProfile: me,
        wrapInScaffold: true,
        ttsCapability: TtsCapability.none,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Tab).at(1));
      await tester.pumpAndSettle();

      expect(find.textContaining('この端末では音声を再生できません'), findsOneWidget);
      // 選ぶ意味のない設定を並べない。
      expect(find.text('合成音声'), findsNothing);
    });

    testWidgets('パックが無いときは音源の選択を出さない', (tester) async {
      await pumpWithProviders(
        tester,
        db: db,
        child: SettingsScreen(profile: me),
        activeProfile: me,
        wrapInScaffold: true,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Tab).at(1));
      await tester.pumpAndSettle();

      expect(find.textContaining('音声パックを追加すると'), findsOneWidget);
      expect(find.text('合成音声'), findsOneWidget);
    });

    testWidgets('端末から消えた voice が設定に残っていれば警告する', (tester) async {
      await (db.update(db.profiles)..where((t) => t.id.equals(me.id))).write(
        const ProfilesCompanion(ttsEnVoice: Value('消えた音声')),
      );
      final profile = await reloadProfile();

      await pumpWithProviders(
        tester,
        db: db,
        child: SettingsScreen(profile: profile),
        activeProfile: profile,
        wrapInScaffold: true,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Tab).at(1));
      await tester.pumpAndSettle();

      // 勝手に別の voice へ切り替えず、選び直させる。
      expect(find.textContaining('選択中の音声が見つかりません'), findsOneWidget);
    });
  });
}
