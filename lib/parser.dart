import 'package:danox/ast_definition.dart';
import 'package:danox/danox.dart';
import 'package:danox/token.dart';

class ParseError {}

class Parser {
  final List<Token> _tokens;
  int _current = 0;

  Parser(List<Token> tokens) : _tokens = [...tokens];

  bool get _isAtEnd => _peek().type == TokenType.eof;

  Expression? parse() {
    try {
      return _expression();
    } catch (error) {
      return null;
    }
  }

  Expression _expression() {
    return _equality();
  }

  Expression _equality() {
    var expr = _comparison();

    while (_match([TokenType.tBangEqual, TokenType.tEqualEqual])) {
      final op = _previous();
      final right = _comparison();
      expr = Binary(left: expr, operator: op, right: right);
    }

    return expr;
  }

  Expression _comparison() {
    var expr = _term();

    while (_match([
      TokenType.tLess,
      TokenType.tGreater,
      TokenType.tLessEqual,
      TokenType.tGreaterEqual
    ])) {
      final op = _previous();
      final right = _term();

      expr = Binary(left: expr, operator: op, right: right);
    }

    return expr;
  }

  Expression _term() {
    var expr = _factor();

    while (_match([TokenType.tPlus, TokenType.tMinus])) {
      final op = _previous();
      final right = _factor();

      expr = Binary(left: expr, operator: op, right: right);
    }

    return expr;
  }

  Expression _factor() {
    var expr = _unary();

    while (_match([TokenType.tStar, TokenType.tSlash])) {
      final op = _previous();
      final right = _unary();

      expr = Binary(left: expr, operator: op, right: right);
    }

    return expr;
  }

  Expression _unary() {
    return (_match([TokenType.tBang, TokenType.tMinus]))
        ? Unary(operator: _previous(), right: _unary())
        : _primary();
  }

  Expression _primary() {
    if (_match([TokenType.tTrue])) return Literal(value: true);
    if (_match([TokenType.tFalse])) return Literal(value: false);
    if (_match([TokenType.tNil])) return Literal(value: null);

    if (_match([TokenType.tString, TokenType.tNumber])) {
      return Literal(value: _previous().literal);
    }

    if (_match([TokenType.tLeftParen])) {
      var expr = _expression();
      _consume(TokenType.tRightParen, ') is missing after expression');
      return Grouping(expression: expr);
    }

    throw _error(_peek(), 'Expected expression');
  }

  /// Whether the next tokens matches one from the list
  bool _match(List<TokenType> tokens) {
    for (final token in tokens) {
      if (_check(token)) {
        _advance();
        return true;
      }
    }

    return false;
  }

  /// Check current token
  bool _check(TokenType token) {
    if (_isAtEnd) return false;
    return _peek().type == token;
  }

  /// Current token
  Token _peek() => _tokens[_current];

  /// Previous token
  Token _previous() => _tokens[_current - 1];

  /// Next token
  Token _advance() {
    if (!_isAtEnd) _current += 1;
    return _previous();
  }

  /// Consume the next token or throw an error
  Token _consume(TokenType token, String message) {
    if (_check(token)) return _advance();

    throw _error(_peek(), message);
  }

  ParseError _error(Token token, String message) {
    Danox.errorLine(token.line, message);
    return ParseError();
  }

  void synchronize() {
    _advance();

    while (!_isAtEnd) {
      if (_previous().type == TokenType.tSemicolon) return;

      switch (_peek().type) {
        case TokenType.tClass:
        case TokenType.tFun:
        case TokenType.tVar:
        case TokenType.tFor:
        case TokenType.tIf:
        case TokenType.tWhile:
        case TokenType.tPrint:
        case TokenType.tReturn:
          return;
        default:
      }

      _advance();
    }
  }
}
