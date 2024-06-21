import 'package:danox/danox.dart';
import 'package:danox/environment.dart';
import 'package:danox/token.dart';

import 'ast_definition.dart';

class RuntimeError implements Exception {
  final String message;
  final Token token;

  const RuntimeError(this.message, this.token);
}

final class AstInterpreter implements ExprVisitor<Object?>, StmtVisitor<void> {
  final _environment = Environment();

  void interpret(List<Stmt> statements) {
    try {
      for (final s in statements) {
        _execute(s);
      }
    } on RuntimeError catch (e) {
      Danox.runtimeError(e);
    }
  }

  @override
  Object? visitBinaryExpr(BinaryExpr expr) {
    final left = _evaluate(expr.left);
    final right = _evaluate(expr.right);

    switch (expr.operator.type) {
      // Arifmethic
      case TokenType.tMinus:
      case TokenType.tSlash:
      case TokenType.tStar:
        return _binaryArifmethic(left, right, expr.operator);
      case TokenType.tPlus:
        if (left is num && right is num) {
          return _binaryArifmethic(left, right, expr.operator);
        } else if (left is String && right is String) {
          return left + right;
        } else {
          throw RuntimeError(
              'Binary operator "+" cannot be used on operands of types ${left.runtimeType} and ${right.runtimeType}',
              expr.operator);
        }

      // Comparison
      case TokenType.tLess:
      case TokenType.tLessEqual:
      case TokenType.tGreater:
      case TokenType.tGreaterEqual:
      case TokenType.tEqualEqual:
      case TokenType.tBangEqual:
        return _binaryComparison(left, right, expr.operator);

      // Error
      default:
        throw RuntimeError('Invalid binary operator', expr.operator);
    }
  }

  @override
  Object? visitGroupingExpr(GroupingExpr expr) => _evaluate(expr.expression);

  @override
  Object? visitLiteralExpr(LiteralExpr expr) => expr.value;

  @override
  Object? visitUnaryExpr(UnaryExpr expr) {
    switch (expr.operator.type) {
      case TokenType.tBang:
        final val = _evaluate(expr);
        if (val is bool) {
          return !val;
        } else {
          throw RuntimeError(
              'Unary "!" operator was called on non-boolean value: $val',
              expr.operator);
        }
      case TokenType.tMinus:
        final val = _evaluate(expr);
        if (val is num) {
          return -val;
        } else {
          throw RuntimeError(
            'Unary "-" operator was called on non-numerical value: $val',
            expr.operator,
          );
        }
      default:
        throw RuntimeError('Unknown unary expression: $expr', expr.operator);
    }
  }

  Object? _evaluate(Expr expr) => expr.accept(this);

  num _binaryArifmethic(Object? left, Object? right, Token operator) {
    if (left is num && right is num) {
      switch (operator.type) {
        case TokenType.tPlus:
          return left + right;
        case TokenType.tMinus:
          return left - right;
        case TokenType.tSlash:
          if (right != 0) {
            return left / right;
          } else {
            throw RuntimeError(
                'Cannot divide by zero: $left / $right', operator);
          }
        case TokenType.tStar:
          return left * right;
        default:
          throw RuntimeError(
            'The operator "${operator.lexeme}" cannot be used to perform arifmethic.',
            operator,
          );
      }
    } else {
      throw RuntimeError(
        'Binary operator "${operator.lexeme}" does not support operands of types ${left.runtimeType} and ${right.runtimeType}',
        operator,
      );
    }
  }

  bool _binaryComparison(Object? left, Object? right, Token operator) {
    if (operator.type == TokenType.tEqualEqual) return left == right;
    if (operator.type == TokenType.tBangEqual) return left != right;

    if (left is num && right is num) {
      switch (operator.type) {
        case TokenType.tGreater:
          return left > right;
        case TokenType.tGreaterEqual:
          return left >= right;
        case TokenType.tLess:
          return left < right;
        case TokenType.tLessEqual:
          return left < right;
        default:
          throw RuntimeError(
              'The operator "${operator.lexeme}" cannot be used to perform comparison',
              operator);
      }
    } else {
      throw RuntimeError(
        'Binary operator "${operator.lexeme}" does not support operands of types ${left.runtimeType} and ${right.runtimeType}',
        operator,
      );
    }
  }

  String _stringify(Object? val) {
    if (val == null) return 'nil';

    return val.toString();
  }

  @override
  void visitExpressionStmt(ExpressionStmt stmt) {
    _evaluate(stmt.expression);
  }

  @override
  void visitPrintStmt(PrintStmt stmt) {
    print(_evaluate(stmt.expression));
  }

  void _execute(Stmt stmt) => stmt.accept(this);

  @override
  void visitVarStmt(VarStmt stmt) {
    _environment.define(stmt.name.lexeme, _evaluate(stmt.initializer));
  }

  @override
  Object? visitVariableExpr(VariableExpr expr) {
    return _environment.get(expr.name);
  }

  @override
  Object? visitAssignExpr(AssignExpr expr) {
    final value = _evaluate(expr.value);

    _environment.assign(expr.name, value);

    return value;
  }
}
