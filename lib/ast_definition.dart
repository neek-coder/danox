import 'package:danox/token.dart';

abstract class Expression {
  const Expression();

  R accept<R>(Visitor<R> visitor);
}

abstract interface class Visitor<R> {
  R visitBinary(Binary expr);
  R visitGrouping(Grouping expr);
  R visitLiteral(Literal expr);
  R visitUnary(Unary expr);
}

final class Binary extends Expression {
  final Expression left;
  final Token operator;
  final Expression right;

  const Binary({
    required this.left,
    required this.operator,
    required this.right,
  });

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitBinary(this);
  }
}

final class Grouping extends Expression {
  final Expression expression;

  const Grouping({
    required this.expression,
  });

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitGrouping(this);
  }
}

final class Literal extends Expression {
  final Object? value;

  const Literal({
    required this.value,
  });

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitLiteral(this);
  }
}

final class Unary extends Expression {
  final Token operator;
  final Expression right;

  const Unary({
    required this.operator,
    required this.right,
  });

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitUnary(this);
  }
}
