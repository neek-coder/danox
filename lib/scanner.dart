import 'danox.dart';
import 'token.dart';

final class Scanner {
  static const _identifierTokens = {
    'and': TokenType.tAnd,
    'class': TokenType.tClass,
    'else': TokenType.tElse,
    'false': TokenType.tFalse,
    'for': TokenType.tFor,
    'fun': TokenType.tFun,
    'if': TokenType.tIf,
    'nil': TokenType.tNil,
    'or': TokenType.tOr,
    'print': TokenType.tPrint,
    'return': TokenType.tReturn,
    'super': TokenType.tSuper,
    'this': TokenType.tThis,
    'true': TokenType.tTrue,
    'var': TokenType.tVar,
    'while': TokenType.tWhile,
  };

  final String source;
  final List<Token> _tokens = [];

  int _start = 0;
  int _current = 0;
  int _line = 1;

  Scanner(this.source);

  bool get _isAtEnd => _current >= source.length;

  List<String> tokenize() => [];

  List<Token> scanTokens() {
    while (!_isAtEnd) {
      _start = _current;

      _scanToken();
    }

    _tokens.add(Token(
      type: TokenType.eof,
      lexeme: '',
      literal: null,
      line: _line,
    ));

    return _tokens;
  }

  void _scanToken() {
    final char = _advance();

    switch (char) {
      case '(':
        _addToken(TokenType.tLeftParen);
        break;
      case ')':
        _addToken(TokenType.tRightParen);
        break;
      case '{':
        _addToken(TokenType.tLeftBrace);
        break;
      case '}':
        _addToken(TokenType.tRightBrace);
        break;
      case ',':
        _addToken(TokenType.tComma);
        break;
      case '.':
        _addToken(TokenType.tDot);
        break;
      case '-':
        _addToken(TokenType.tMinus);
        break;
      case '+':
        _addToken(TokenType.tPlus);
        break;
      case ';':
        _addToken(TokenType.tSemicolon);
        break;
      case '*':
        _addToken(TokenType.tStar);
        break;
      case '!':
        _addToken(_match('=') ? TokenType.tBangEqual : TokenType.tBang);
        break;
      case '=':
        _addToken(_match('=') ? TokenType.tEqualEqual : TokenType.tEqual);
        break;
      case '<':
        _addToken(_match('=') ? TokenType.tLessEqual : TokenType.tLess);
        break;
      case '>':
        _addToken(_match('=') ? TokenType.tGreaterEqual : TokenType.tGreater);
        break;
      case '/':
        if (_match('/')) {
          while (_peek() != '\n' && !_isAtEnd) {
            _advance();
          }
        } else {
          _addToken(TokenType.tSlash);
        }

      case '"':
        _string();
        break;

      case ' ':
      case '\r':
      case '\t':
        // Ignore whitespace.
        break;
      case '\n':
        _line++;
        break;

      default:
        if (_isDigit(char)) {
          _number();
        } else if (_isAlpha(char)) {
          _identifier();
        } else {
          Danox.errorLine(_line, 'Unsupported charaster: $char');
        }
    }
  }

  String _advance() => source[_current++];

  bool _match(String expected) {
    if (_isAtEnd) return false;
    if (source[_current] != expected) return false;

    _current += 1;
    return true;
  }

  String _peek() => _isAtEnd ? '\\0' : source[_current];

  String _peekNext() =>
      _current + 1 >= source.length ? '\\0' : source[_current + 1];

  void _string() {
    while (_peek() != '"' && !_isAtEnd) {
      if (_peek() == '\n') _line++;

      _advance();
    }

    if (_isAtEnd) {
      Danox.errorLine(_line, 'Undetermined string');
      return;
    }

    _advance();

    var content = source.substring(_start + 1, _current - 1);

    _addToken(TokenType.tString, content);
  }

  void _number() {
    while (_isDigit(_peek())) {
      _advance();
    }

    // Look for a fractional part.
    if (_peek() == '.' && _isDigit(_peekNext())) {
      // Consume the "."
      _advance();

      while (_isDigit(_peek())) {
        _advance();
      }
    }

    double content = double.parse(source.substring(_start, _current));

    _addToken(TokenType.tNumber, content);
  }

  void _identifier() {
    while (_isAlpha(_peek())) {
      _advance();
    }

    final identifier = _identifierTokens[source.substring(_start, _current)];

    _addToken(identifier ?? TokenType.tIdentifier);
  }

  void _addToken(TokenType type, [Object? literal]) {
    final lexeme = source.substring(_start, _current);

    _tokens.add(
      Token(
        type: type,
        lexeme: lexeme,
        literal: literal,
        line: _line,
      ),
    );
  }

  int _charCode(String char) => char.codeUnitAt(0);

  bool _isDigit(String char) => (_charCode(char) ^ 0x30) <= 9;

  bool _isAlpha(String char) =>
      (_charCode('a') <= _charCode(char) &&
          _charCode(char) <= _charCode('z')) ||
      (_charCode('A') <= _charCode(char) &&
          _charCode(char) <= _charCode('Z')) ||
      char == '_';
}
