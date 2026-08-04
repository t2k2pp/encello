/// 綴り入力の枠（[Docs/06_features/spell_mode.md] §1）。
///
/// ハイフン・スペース・アポストロフィを含む語（`well-known` / `a lot of` / `don't`）は、
/// その記号を**最初から表示**し、利用者が入力するのは英字だけにする。
/// 記号の位置を当てさせても綴りの学習にならない。
abstract final class SpellSlots {
  static bool isLetter(String ch) {
    final c = ch.codeUnitAt(0);
    // a-z / A-Z に加え、アクセント付きの英字（café の é）も入力対象にする。
    return (c >= 0x41 && c <= 0x5A) ||
        (c >= 0x61 && c <= 0x7A) ||
        (c >= 0xC0 && c <= 0x24F && c != 0xD7 && c != 0xF7);
  }

  /// 入力が必要な文字数（記号を除いた英字の数）。
  static int letterCount(String answer) =>
      answer.split('').where(isLetter).length;

  /// 正解の英字だけを順に並べたもの（ヒントの開示に使う）。
  static String lettersOf(String answer) =>
      answer.split('').where(isLetter).join();

  /// 入力済みの英字 [typed] を正解の枠へ流し込み、判定に使う文字列を組む。
  ///
  /// 英字の位置には [typed] を順に置き、記号の位置には正解の記号をそのまま置く。
  /// [typed] が尽きたらそこで打ち切る（未入力の枠を空白などで埋めない）。
  static String compose(String answer, String typed) {
    final buffer = StringBuffer();
    var cursor = 0;
    for (final ch in answer.split('')) {
      if (isLetter(ch)) {
        if (cursor >= typed.length) return buffer.toString();
        buffer.write(typed[cursor++]);
      } else {
        buffer.write(ch);
      }
    }
    return buffer.toString();
  }

  /// ヒントで開示したあとの入力文字列。未入力の先頭1文字を [typed] に足す。
  /// すべて埋まっていれば [typed] のまま返す。
  static String reveal(String answer, String typed) {
    final letters = lettersOf(answer);
    if (typed.length >= letters.length) return typed;
    return typed + letters[typed.length];
  }

  /// 表示用の枠。英字の位置は入力済みなら文字、未入力なら null。
  /// 記号の位置は記号そのものを持つ。
  static List<SpellSlot> slotsOf(String answer, String typed) {
    final slots = <SpellSlot>[];
    var cursor = 0;
    for (final ch in answer.split('')) {
      if (!isLetter(ch)) {
        slots.add(SpellSlot.symbol(ch));
        continue;
      }
      slots.add(
        cursor < typed.length
            ? SpellSlot.filled(typed[cursor++])
            : const SpellSlot.blank(),
      );
    }
    return slots;
  }
}

/// 綴り入力の枠1つ。
class SpellSlot {
  /// 表示する文字。未入力の英字枠では null。
  final String? character;

  /// 記号（ハイフン・スペース等）の枠か。
  final bool isSymbol;

  const SpellSlot.filled(String this.character) : isSymbol = false;

  const SpellSlot.blank() : character = null, isSymbol = false;

  const SpellSlot.symbol(String this.character) : isSymbol = true;

  bool get isBlank => character == null;
}
