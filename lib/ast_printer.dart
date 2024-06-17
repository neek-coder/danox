import 'ast_definition.dart';

class AstPrinter implements Visitor<String> {
  String print(Expression expr) {
    return expr.accept(this);
  }

  @override
  String visitBinary(Binary expr) {
    return parenthesize(expr.operator.lexeme, [expr.left, expr.right]);
  }

  @override
  String visitGrouping(Grouping expr) {
    return parenthesize('group', [expr.expression]);
  }

  @override
  String visitLiteral(Literal expr) {
    return expr.value.toString();
  }

  @override
  String visitUnary(Unary expr) {
    return parenthesize(expr.operator.lexeme, [expr.right]);
  }

  String parenthesize(String name, List<Expression> expressions) {
    var out = '';

    out += '($name';

    for (final e in expressions) {
      out += ' ${e.accept(this)}';
    }

    out += ')';

    return out;
  }
}
