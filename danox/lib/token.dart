enum TokenType {
  // Single-character tokens
  tLeftParen,
  tRightParen,
  tLeftBrace,
  tRightBrace,
  tComma,
  tDot,
  tMinus,
  tPlus,
  tSemicolon,
  tSlash,
  tStar,

  // One or two character tokens
  tBang,
  tBangEqual,
  tEqual,
  tEqualEqual,
  tGreater,
  tGreaterEqual,
  tLess,
  tLessEqual,

  // Literals
  tIdentifier,
  tString,
  tNumber,

  // Keywords
  tAnd,
  tClass,
  tElse,
  tFalse,
  tFun,
  tFor,
  tIf,
  tNil,
  tOr,
  tPrint,
  tReturn,
  tSuper,
  tThis,
  tTrue,
  tVar,
  tWhile,

  eof,
}

final class Token {
  final TokenType type;
  final String lexeme;
  final Object? literal;
  final int line;

  const Token({
    required this.type,
    required this.lexeme,
    required this.literal,
    required this.line,
  });

  @override
  String toString() {
    return '$type $lexeme $literal';
  }
}
