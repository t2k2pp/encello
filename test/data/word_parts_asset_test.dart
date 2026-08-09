import 'dart:convert';
import 'dart:io';

import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/seeds/preset_word_parts.dart';
import 'package:flutter_test/flutter_test.dart';

/// 出荷する `assets/word_parts.json` が規則を満たしていることを確かめる
/// （[Docs/06_features/word_parts.md] §9、[Docs/06_features/word_families.md] §8）。
///
/// ビルドツール（`tool/build_wordparts.dart`）を通さずにアセットを直接触った場合にも
/// 気付けるようにするため、同じ規則をここでも当てる。
void main() {
  final asset = PresetWordParts.fromJson(
    jsonDecode(File('assets/word_parts.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  /// 出荷6冊の見出し語。紐付けと語族はここにある語しか指せない。
  final headwords = _readShippedHeadwords();

  group('語の部品', () {
    test('種別ごとに収録されている（§2.3 の目安）', () {
      final byType = <WordPartType, int>{};
      for (final p in asset.parts) {
        byType[p.type] = (byType[p.type] ?? 0) + 1;
      }
      expect(byType[WordPartType.prefix], greaterThanOrEqualTo(40));
      expect(byType[WordPartType.root], greaterThanOrEqualTo(60));
      expect(byType[WordPartType.suffix], greaterThanOrEqualTo(25));
    });

    test('form が種別ごとのハイフンの位置に従う（§2.1）', () {
      for (final p in asset.parts) {
        final ok = switch (p.type) {
          WordPartType.prefix =>
            p.form.endsWith('-') && !p.form.startsWith('-'),
          WordPartType.suffix =>
            p.form.startsWith('-') && !p.form.endsWith('-'),
          WordPartType.root => !p.form.startsWith('-') && !p.form.endsWith('-'),
        };
        expect(ok, isTrue, reason: '${p.form}（${p.type.value}）');
      }
    });

    test('form が重複しない', () {
      final forms = asset.parts.map((p) => p.form).toList();
      expect(forms.toSet().length, forms.length);
    });

    test('意味が日本語で入り、丸括弧を使っていない', () {
      final japanese = RegExp(r'[぀-ヿ㐀-鿿]');
      for (final p in asset.parts) {
        expect(japanese.hasMatch(p.meaning), isTrue, reason: p.form);
        expect(p.meaning.contains('（'), isFalse, reason: p.form);
      }
    });

    test('level が 1〜5 に収まる', () {
      for (final p in asset.parts) {
        expect(p.level, inInclusiveRange(1, 5), reason: p.form);
      }
    });
  });

  group('紐付け', () {
    test('単語帳にある見出し語だけを指す', () {
      for (final link in asset.links) {
        expect(headwords, contains(link.headword));
      }
    });

    test('見出し語が重複しない', () {
      final words = asset.links.map((l) => l.headword).toList();
      expect(words.toSet().length, words.length);
    });

    test('知らない部品を指さない / 同じ部品を2回使わない', () {
      final forms = asset.parts.map((p) => p.form).toSet();
      for (final link in asset.links) {
        expect(
          link.parts.toSet().length,
          link.parts.length,
          reason: link.headword,
        );
        for (final f in link.parts) {
          expect(forms, contains(f), reason: '${link.headword} -> $f');
        }
      }
    });

    test('3語以上に紐付いた部品が十分にある（§5.3 の出題条件）', () {
      final count = <String, int>{};
      for (final link in asset.links) {
        for (final f in link.parts) {
          count[f] = (count[f] ?? 0) + 1;
        }
      }
      // 出題対象は「紐付いた語が3語以上」の部品だけ。
      // 誤答選択肢を同じ種別から3つ選ぶため、種別ごとに4つ以上必要。
      final quizzable = asset.parts
          .where((p) => (count[p.form] ?? 0) >= 3)
          .toList();
      for (final type in WordPartType.values) {
        expect(
          quizzable.where((p) => p.type == type).length,
          greaterThanOrEqualTo(4),
          reason: type.value,
        );
      }
    });

    test('partsNote が日本語で、丸括弧を使っていない', () {
      final japanese = RegExp(r'[぀-ヿ㐀-鿿]');
      for (final link in asset.links.where((l) => l.partsNote != null)) {
        expect(
          japanese.hasMatch(link.partsNote!),
          isTrue,
          reason: link.headword,
        );
        expect(link.partsNote!.contains('（'), isFalse, reason: link.headword);
      }
    });
  });

  group('派生語ファミリー', () {
    test('2語以上で、baseForm を含む', () {
      for (final f in asset.families) {
        expect(f.members.length, greaterThanOrEqualTo(2), reason: f.baseForm);
        expect(f.members, contains(f.baseForm));
      }
    });

    test('単語帳にある見出し語だけを束ねる', () {
      for (final f in asset.families) {
        for (final m in f.members) {
          expect(headwords, contains(m), reason: '${f.baseForm} -> $m');
        }
      }
    });

    test('1語が2つの語族に入らない（words.familyId は1つしか持てない）', () {
      final owner = <String, String>{};
      for (final f in asset.families) {
        for (final m in f.members) {
          expect(owner[m], isNull, reason: '$m: ${owner[m]} と ${f.baseForm}');
          owner[m] = f.baseForm;
        }
      }
    });

    test('baseForm が重複しない', () {
      final bases = asset.families.map((f) => f.baseForm).toList();
      expect(bases.toSet().length, bases.length);
    });
  });

  test('seedVersion が単語帳とそろっている（wordbooks.md §3.1）', () {
    final versions = <int>{};
    for (final file in Directory('assets/wordbooks').listSync()) {
      if (!file.path.endsWith('.json')) continue;
      final book =
          jsonDecode(File(file.path).readAsStringSync())
              as Map<String, Object?>;
      versions.add(book['seedVersion'] as int);
    }
    expect(versions.length, 1, reason: '単語帳の seedVersion がそろっていない');
    expect(asset.seedVersion, versions.single);
  });
}

Set<String> _readShippedHeadwords() {
  final result = <String>{};
  for (final file in Directory('assets/wordbooks').listSync()) {
    if (!file.path.endsWith('.json')) continue;
    final book =
        jsonDecode(File(file.path).readAsStringSync()) as Map<String, Object?>;
    for (final w in (book['words'] as List).cast<Map<String, Object?>>()) {
      result.add(w['headword'] as String);
    }
  }
  return result;
}
