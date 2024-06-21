import 'ast_definition.dart';

class AstPrinter implements ExprVisitor<String> {
  String print(Expr expr) {
    return expr.accept(this);
  }

  @override
  String visitBinaryExpr(BinaryExpr expr) {
    return parenthesize(expr.operator.lexeme, [expr.left, expr.right]);
  }

  @override
  String visitGroupingExpr(GroupingExpr expr) {
    return parenthesize('group', [expr.expression]);
  }

  @override
  String visitLiteralExpr(LiteralExpr expr) {
    return expr.value.toString();
  }

  @override
  String visitUnaryExpr(UnaryExpr expr) {
    return parenthesize(expr.operator.lexeme, [expr.right]);
  }

  String parenthesize(String name, List<Expr> expressions) {
    var out = '';

    out += '($name';

    for (final e in expressions) {
      out += ' ${e.accept(this)}';
    }

    out += ')';

    return out;
  }
}
