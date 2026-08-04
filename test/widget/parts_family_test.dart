import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/application/study_launcher.dart';
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/wordbook_repository.dart';
import 'package:encello/domain/entities/mastery.dart';
import 'package:encello/domain/usecases/family_quiz_builder.dart';
import 'package:encello/domain/usecases/study_queue_builder.dart';
import 'package:encello/providers/audio.dart';
import 'package:encello/providers/providers.dart';
import 'package:encello/ui/screens/choice_study_screen.dart';
import 'package:encello/ui/screens/spell_study_screen.dart';
import 'package:encello/ui/screens/word_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';
import '../helpers/study_fixture.dart';
import '../helpers/test_database.dart';

/// 語のつくり（[Docs/06_features/word_parts.md]）と
/// 語形変化（[Docs/06_features/word_families.md]）。
void main() {
  late AppDatabase db;
  late Profile me;

  setUp(() async {
    db = newTestDatabase();
    me = await createTestProfile(db, name: 'たろう');
  });

  Future<int> addPart(String form, String meaning, {String type = 'root'}) {
    return db
        .into(db.wordParts)
        .insert(
          WordPartsCompanion.insert(form: form, type: type, meaning: meaning),
        );
  }

  Future<void> link(int wordId, int partId, {int position = 0}) {
    return db
        .into(db.wordPartLinks)
        .insert(
          WordPartLinksCompanion.insert(
            wordId: wordId,
            partId: partId,
            position: Value(position),
          ),
        );
  }

  /// 部品4つに、それぞれ3語ずつ紐付ける。
  Future<Profile> seedParts() async {
    final seeded = await seedStudyTarget(
      db,
      me,
      headwords: {
        for (var i = 0; i < 12; i++) 'word${String.fromCharCode(97 + i)}': '訳$i',
      },
    );
    final words = await db.select(db.words).get();
    final parts = [
      await addPart('port', '運ぶ'),
      await addPart('spect', '見る'),
      await addPart('dict', '言う'),
      await addPart('duc', '導く'),
    ];
    for (var i = 0; i < words.length; i++) {
      await link(words[i].id, parts[i ~/ 3]);
    }
    return seeded.profile;
  }

  group('語のつくり', () {
    testWidgets('紐付いた語が3語以上ある部品が4つ以上あれば選べる', (tester) async {
      final profile = await seedParts();
      final container = await pumpWithProviders(
        tester,
        db: db,
        child: const ChoiceStudyScreen(),
        activeProfile: profile,
      );
      final modes = await container.read(
        availableModesProvider(profile).future,
      );
      expect(modes, contains(StudyMode.parts));
    });

    testWidgets('紐付いた語が2語の部品は出題されない', (tester) async {
      final seeded = await seedStudyTarget(
        db,
        me,
        headwords: const {'apple': 'りんご', 'banana': 'バナナ'},
      );
      final words = await db.select(db.words).get();
      final part = await addPart('port', '運ぶ');
      for (final w in words) {
        await link(w.id, part);
      }
      final container = await pumpWithProviders(
        tester,
        db: db,
        child: const ChoiceStudyScreen(),
        activeProfile: seeded.profile,
      );
      final modes = await container.read(
        availableModesProvider(seeded.profile).future,
      );
      expect(modes, isNot(contains(StudyMode.parts)));
    });

    testWidgets('解答すると part_reviews が更新され、word_reviews は増えない', (tester) async {
      final profile = await seedParts();
      final container = await pumpWithProviders(
        tester,
        db: db,
        child: const ChoiceStudyScreen(),
        activeProfile: profile,
      );
      await container
          .read(studyLauncherProvider)
          .start(
            profile: profile,
            mode: StudyMode.parts,
            policy: QueuePolicy.reviewFirst,
            limit: 2,
          );
      await tester.pumpAndSettle();

      final session = container.read(choiceSessionProvider)!;
      // 誤答選択肢は同じ種別（ここでは語根）から選ばれる。
      expect(session.current!.options, hasLength(4));
      await container
          .read(choiceSessionProvider.notifier)
          .answer(session.current!.answerIndex);
      await tester.pumpAndSettle();

      expect(await db.select(db.partReviews).get(), hasLength(1));
      expect(await db.select(db.wordReviews).get(), isEmpty);

      final log = await db.select(db.learningLogs).getSingle();
      expect(log.mode, StudyMode.parts.value);
      expect(log.partId, isNotNull);
      expect(log.wordId, isNull);
    });

    testWidgets('単語詳細で、部品の紐付けが無い語には語のつくりカードを出さない', (tester) async {
      final seeded = await seedStudyTarget(db, me);
      final word = await db.select(db.words).getSingle();

      await pumpWithProviders(
        tester,
        db: db,
        child: WordDetailScreen(wordId: word.id, profile: seeded.profile),
        activeProfile: seeded.profile,
      );
      await tester.pumpAndSettle();
      expect(find.text('語のつくり'), findsNothing);
    });

    testWidgets('紐付けがある語には語のつくりカードを出す', (tester) async {
      final seeded = await seedStudyTarget(db, me);
      final word = await db.select(db.words).getSingle();
      final part = await addPart('port', '運ぶ');
      await link(word.id, part);

      await pumpWithProviders(
        tester,
        db: db,
        child: WordDetailScreen(wordId: word.id, profile: seeded.profile),
        activeProfile: seeded.profile,
      );
      await tester.pumpAndSettle();
      expect(find.text('語のつくり'), findsOneWidget);
      expect(find.textContaining('port'), findsWidgets);
    });
  });

  group('語形変化', () {
    /// decide（動詞・既習）と decision（名詞・未学習）の語族を作る。
    Future<Profile> seedFamily() async {
      final seeded = await seedStudyTarget(db, me, headwords: const {});
      final bookId = seeded.wordbookId;
      final familyId = await db
          .into(db.wordFamilies)
          .insert(const WordFamiliesCompanion(baseForm: Value('decide')));
      final decide = await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              headword: 'decide',
              partOfSpeech: PartOfSpeech.verb.value,
              meaning: '決める',
              familyId: Value(familyId),
            ),
          );
      final decision = await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              headword: 'decision',
              partOfSpeech: PartOfSpeech.noun.value,
              meaning: '決定',
              familyId: Value(familyId),
            ),
          );
      await WordbookRepository(db).addWord(bookId, decide);
      await WordbookRepository(db).addWord(bookId, decision);
      // decide だけ既習にする。
      await db
          .into(db.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: me.id,
              wordId: decide,
              dueAt: DateTime(2026, 8, 4, 4),
              masteryLevel: const Value(1),
            ),
          );
      return seeded.profile;
    }

    testWidgets('答えが一意な語族があれば選べる', (tester) async {
      final profile = await seedFamily();
      final container = await pumpWithProviders(
        tester,
        db: db,
        child: const SpellStudyScreen(),
        activeProfile: profile,
      );
      final modes = await container.read(
        availableModesProvider(profile).future,
      );
      expect(modes, contains(StudyMode.family));
    });

    testWidgets('提示語と求める品詞が出て、答えた語だけが更新される', (tester) async {
      final profile = await seedFamily();
      final container = await pumpWithProviders(
        tester,
        db: db,
        child: const SpellStudyScreen(),
        activeProfile: profile,
        size: const Size(390, 900),
      );

      final members = await container
          .read(modeRepositoryProvider)
          .loadFamilyMembers(profile.id);
      await container
          .read(studySessionProvider.notifier)
          .startFamily(
            profile: profile,
            questions: FamilyQuizBuilder.build(members),
            limit: 1,
          );
      await tester.pumpAndSettle();

      // 「decide（動詞：決める）」＋「名詞形にしなさい」。
      expect(find.textContaining('decide'), findsOneWidget);
      expect(find.text('名詞形にしなさい'), findsOneWidget);

      final session = container.read(studySessionProvider)!;
      expect(session.currentWord!.headword, 'decision');

      for (final ch in 'decision'.split('')) {
        container.read(studySessionProvider.notifier).typeLetter(ch);
      }
      await container.read(studySessionProvider.notifier).submit();
      await tester.pumpAndSettle();

      // 答えた語（decision）だけが更新され、提示語（decide）は変わらない。
      final reviews = await db.select(db.wordReviews).get();
      final decision = await (db.select(db.words)
            ..where((t) => t.headword.equals('decision')))
          .getSingle();
      final decisionReview = reviews.firstWhere(
        (r) => r.wordId == decision.id,
      );
      expect(decisionReview.totalCorrect, 1);

      final decide = await (db.select(db.words)
            ..where((t) => t.headword.equals('decide')))
          .getSingle();
      final decideReview = reviews.firstWhere((r) => r.wordId == decide.id);
      expect(decideReview.totalCorrect, 0);
      expect(decideReview.masteryLevel, Mastery.learning.level);
    });

    testWidgets('語族に自分しかいない語の詳細に語族カードを出さない', (tester) async {
      final seeded = await seedStudyTarget(db, me);
      final word = await db.select(db.words).getSingle();
      final familyId = await db
          .into(db.wordFamilies)
          .insert(const WordFamiliesCompanion(baseForm: Value('apple')));
      await (db.update(db.words)..where((t) => t.id.equals(word.id))).write(
        WordsCompanion(familyId: Value(familyId)),
      );

      await pumpWithProviders(
        tester,
        db: db,
        child: WordDetailScreen(wordId: word.id, profile: seeded.profile),
        activeProfile: seeded.profile,
      );
      await tester.pumpAndSettle();
      expect(find.text('語族'), findsNothing);
    });
  });
}
