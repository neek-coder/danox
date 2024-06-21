import 'package:danox/token.dart';

abstract class Expr {
  const Expr();

  R accept<R>(ExprVisitor<R> visitor);
}
abstract interface class ExprVisitor<R> {
    
  R visitBinaryExpr(BinaryExpr expr);
  R visitGroupingExpr(GroupingExpr expr);
  R visitLiteralExpr(LiteralExpr expr);
  R visitUnaryExpr(UnaryExpr expr);
}

final class BinaryExpr extends Expr {
  final Expr left;
  final Token operator;
  final Expr right;

  const BinaryExpr({
    required this.left,
    required this.operator,
    required this.right,
  });

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitBinaryExpr(this);
  }
}

final class GroupingExpr extends Expr {
  final Expr expression;

  const GroupingExpr({
    required this.expression,
  });

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitGroupingExpr(this);
  }
}

final class LiteralExpr extends Expr {
  final Object? value;

  const LiteralExpr({
    required this.value,
  });

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitLiteralExpr(this);
  }
}

final class UnaryExpr extends Expr {
  final Token operator;
  final Expr right;

  const UnaryExpr({
    required this.operator,
    required this.right,
  });

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitUnaryExpr(this);
  }
}

abstract class Stmt {
  const Stmt();

  R accept<R>(StmtVisitor<R> visitor);
}
abstract interface class StmtVisitor<R> {
    
  R visitExpressionStmt(ExpressionStmt stmt);
  R visitPrintStmt(PrintStmt stmt);
}

final class ExpressionStmt extends Stmt {
  final Expr expression;

  const ExpressionStmt({
    required this.expression,
  });

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitExpressionStmt(this);
  }
}

final class PrintStmt extends Stmt {
  final Expr expression;

  const PrintStmt({
    required this.expression,
  });

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitPrintStmt(this);
  }
}

