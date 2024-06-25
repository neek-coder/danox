import 'package:danox/ast_definition.dart';
import 'package:danox/danox.dart';
import 'package:danox/token.dart';

class ParseError {}

class Parser {
  final List<Token> _tokens;
  int _current = 0;

  Parser(List<Token> tokens) : _tokens = [...tokens];

  bool get _isAtEnd => _peek().type == TokenType.eof;

  List<Stmt> parse() {
    try {
      final List<Stmt> statements = [];

      while (!_isAtEnd) {
        statements.add(_declaration());
      }

      return statements;
    } catch (_) {
      return [];
    }
  }

  Stmt _declaration() {
    try {
      if (_match([TokenType.tVar])) return _varDeclaration();

      return _statement();
    } catch (e) {
      _synchronize();
      rethrow;
    }
  }

  Stmt _varDeclaration() {
    final name = _consume(TokenType.tIdentifier, 'Missing variable name.');

    Expr? initializer;

    if (_match([TokenType.tEqual])) initializer = _expression();

    _consume(TokenType.tSemicolon, 'Missinng ";" after variable declaration.');

    return VarStmt(
      name: name,
      initializer: initializer ?? LiteralExpr(value: null),
    );
  }

  Stmt _statement() {
    if (_match([TokenType.tIf])) return _ifStatement();
    if (_match([TokenType.tWhile])) return _whileStatement();
    if (_match([TokenType.tFor])) return _forStatement();
    if (_match([TokenType.tPrint])) return _printStatement();
    if (_match([TokenType.tLeftBrace])) return BlockStmt(statements: _block());

    return _expressionStatement();
  }

  Stmt _ifStatement() {
    _consume(TokenType.tLeftParen, 'Expected "(" in the if statement.');
    final condition = _expression();
    _consume(TokenType.tRightParen, 'Expected ")" in the if statement.');

    final thenBranch = _statement();
    Stmt? elseBranch;

    if (_match([TokenType.tElse])) {
      elseBranch = _statement();
    }

    return IfStmt(
      condition: condition,
      thenBranch: thenBranch,
      elseBranch: elseBranch,
    );
  }

  Stmt _whileStatement() {
    _consume(TokenType.tLeftParen, 'Expected "(" before condition.');
    final condition = _expression();
    _consume(TokenType.tRightParen, 'Expected ")" after condition.');

    final body = _statement();

    return WhileStmt(condition: condition, body: body);
  }

  Stmt _forStatement() {
    _consume(TokenType.tLeftParen, 'Expected "(" after "for".');

    Stmt? initializer;

    if (_match([TokenType.tVar])) {
      initializer = _varDeclaration();
    } else if (_match([TokenType.tSemicolon])) {
      initializer = null;
    } else {
      initializer = _expressionStatement();
    }

    Expr? condition;

    if (!_check(TokenType.tSemicolon)) {
      condition = _expression();
    }

    _consume(TokenType.tSemicolon, 'Expected ";" after condition');

    Expr? increment;

    if (!_check(TokenType.tRightParen)) {
      increment = _expression();
    }

    _consume(TokenType.tRightParen, 'Expected ")".');

    var body = _statement();

    if (increment != null) {
      body = BlockStmt(statements: [
        body,
        ExpressionStmt(expression: increment),
      ]);
    }

    body =
        WhileStmt(condition: condition ?? LiteralExpr(value: true), body: body);

    if (initializer != null) body = BlockStmt(statements: [initializer, body]);

    return body;
  }

  Stmt _printStatement() {
    final expr = _expression();

    _consume(TokenType.tSemicolon, "Expect ';' after value.");

    return PrintStmt(expression: expr);
  }

  List<Stmt> _block() {
    List<Stmt> statements = [];

    while (!_check(TokenType.tRightBrace) && !_isAtEnd) {
      statements.add(_declaration());
    }

    _consume(TokenType.tRightBrace, 'Expected "}" after block.');
    return statements;
  }

  Stmt _expressionStatement() {
    final expr = _expression();

    _consume(TokenType.tSemicolon, "Expect ';' after value.");

    return ExpressionStmt(expression: expr);
  }

  Expr _expression() {
    return _assignment();
  }

  Expr _assignment() {
    final expr = _or();

    if (_match([TokenType.tEqual])) {
      final equals = _previous();
      final value = _assignment();

      if (expr is VariableExpr) {
        final name = expr.name;
        return AssignExpr(name: name, value: value);
      }

      throw _error(equals, "Invalid assignment target.");
    }

    return expr;
  }

  Expr _or() {
    var expr = _and();

    while (_match([TokenType.tOr])) {
      final operator = _previous();
      final right = _and();

      expr = LogicalExpr(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr _and() {
    var expr = _equality();

    while (_match([TokenType.tAnd])) {
      final operator = _previous();
      final right = _equality();

      expr = LogicalExpr(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr _equality() {
    var expr = _comparison();

    while (_match([TokenType.tBangEqual, TokenType.tEqualEqual])) {
      final op = _previous();
      final right = _comparison();
      expr = BinaryExpr(left: expr, operator: op, right: right);
    }

    return expr;
  }

  Expr _comparison() {
    var expr = _term();

    while (_match([
      TokenType.tLess,
      TokenType.tGreater,
      TokenType.tLessEqual,
      TokenType.tGreaterEqual
    ])) {
      final op = _previous();
      final right = _term();

      expr = BinaryExpr(left: expr, operator: op, right: right);
    }

    return expr;
  }

  Expr _term() {
    var expr = _factor();

    while (_match([TokenType.tPlus, TokenType.tMinus])) {
      final op = _previous();
      final right = _factor();

      expr = BinaryExpr(left: expr, operator: op, right: right);
    }

    return expr;
  }

  Expr _factor() {
    var expr = _unary();

    while (_match([TokenType.tStar, TokenType.tSlash])) {
      final op = _previous();
      final right = _unary();

      expr = BinaryExpr(left: expr, operator: op, right: right);
    }

    return expr;
  }

  Expr _unary() {
    return (_match([TokenType.tBang, TokenType.tMinus]))
        ? UnaryExpr(operator: _previous(), right: _unary())
        : _primary();
  }

  Expr _primary() {
    if (_match([TokenType.tTrue])) return LiteralExpr(value: true);
    if (_match([TokenType.tFalse])) return LiteralExpr(value: false);
    if (_match([TokenType.tNil])) return LiteralExpr(value: null);

    if (_match([TokenType.tString, TokenType.tNumber])) {
      return LiteralExpr(value: _previous().literal);
    }

    if (_match([TokenType.tIdentifier])) {
      return VariableExpr(name: _previous());
    }

    if (_match([TokenType.tLeftParen])) {
      var expr = _expression();
      _consume(TokenType.tRightParen, ') is missing after Expr');
      return GroupingExpr(expression: expr);
    }

    throw _error(_peek(), 'Expected Expr');
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

  void _synchronize() {
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
