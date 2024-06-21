import 'dart:collection';

import 'package:danox/ast_interpreter.dart';
import 'package:danox/token.dart';

final class Environment {
  final HashMap<String, Object?> _values = HashMap();

  void define(String name, Object? value) {
    _values[name] = value;
  }

  Object? get(Token name) {
    if (_values.containsKey(name.lexeme)) {
      return _values[name.lexeme];
    }

    throw RuntimeError('Undefined variable: ${name.lexeme}', name);
  }

  void assign(Token name, Object? value) {
    if (_values.containsKey(name.lexeme)) {
      _values[name.lexeme] = value;
      return;
    }

    throw RuntimeError('Undefined variable: ${name.lexeme}', name);
  }
}
