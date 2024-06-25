import 'dart:collection';

import 'package:danox/ast_interpreter.dart';
import 'package:danox/token.dart';

final class Environment {
  final HashMap<String, Object?> _values = HashMap();
  Environment? _enclosing = null;

  Environment();

  Environment.nest(Environment environment) {
    _enclosing = environment;
  }

  void define(String name, Object? value) {
    _values[name] = value;
  }

  Object? get(Token name) {
    if (_values.containsKey(name.lexeme)) {
      return _values[name.lexeme];
    }

    if (_enclosing != null) return _enclosing!.get(name);

    throw RuntimeError(
        'Failed to get variable value. Undefined variable: ${name.lexeme}',
        name);
  }

  void assign(Token name, Object? value) {
    if (_values.containsKey(name.lexeme)) {
      _values[name.lexeme] = value;
      return;
    }

    if (_enclosing != null) return _enclosing!.assign(name, value);

    throw RuntimeError(
        'Assignment failed. Undefined variable: ${name.lexeme}', name);
  }
}
