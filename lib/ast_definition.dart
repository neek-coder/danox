import 'package:danox/token.dart';

abstract class Expr {
  const Expr();

  R accept<R>(ExprVisitor<R> visitor);
}
abstract interface class ExprVisitor<R> {
    
  R visitAssignExpr(AssignExpr expr);
  R visitBinaryExpr(BinaryExpr expr);
  R visitGroupingExpr(GroupingExpr expr);
  R visitLiteralExpr(LiteralExpr expr);
  R visitLogicalExpr(LogicalExpr expr);
  R visitUnaryExpr(UnaryExpr expr);
  R visitVariableExpr(VariableExpr expr);
}

final class AssignExpr extends Expr {
  final Token name;
  final Expr value;

  const AssignExpr({
    required this.name,
    required this.value,
  });

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitAssignExpr(this);
  }
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

final class LogicalExpr extends Expr {
  final Expr left;
  final Token operator;
  final Expr right;

  const LogicalExpr({
    required this.left,
    required this.operator,
    required this.right,
  });

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitLogicalExpr(this);
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

final class VariableExpr extends Expr {
  final Token name;

  const VariableExpr({
    required this.name,
  });

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitVariableExpr(this);
  }
}

abstract class Stmt {
  const Stmt();

  R accept<R>(StmtVisitor<R> visitor);
}
abstract interface class StmtVisitor<R> {
    
  R visitBlockStmt(BlockStmt stmt);
  R visitExpressionStmt(ExpressionStmt stmt);
  R visitIfStmt(IfStmt stmt);
  R visitPrintStmt(PrintStmt stmt);
  R visitVarStmt(VarStmt stmt);
}

final class BlockStmt extends Stmt {
  final List<Stmt> statements;

  const BlockStmt({
    required this.statements,
  });

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitBlockStmt(this);
  }
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

final class IfStmt extends Stmt {
  final Expr condition;
  final Stmt thenBranch;
  final Stmt? elseBranch;

  const IfStmt({
    required this.condition,
    required this.thenBranch,
    required this.elseBranch,
  });

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitIfStmt(this);
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

final class VarStmt extends Stmt {
  final Token name;
  final Expr initializer;

  const VarStmt({
    required this.name,
    required this.initializer,
  });

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitVarStmt(this);
  }
}

