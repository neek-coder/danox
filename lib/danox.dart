import 'dart:io';

import 'ast_interpreter.dart';
import 'scanner.dart';
import 'ast_printer.dart';
import 'token.dart';
import 'parser.dart';

abstract class Danox {
  /// Shows whether an error has occured in runtime.
  static bool _hasError = false;
  static bool _hasRuntimeError = false;

  static final _interpreter = AstInterpreter();

  static void main(List<String> args) {
    if (args.isEmpty) {
      _runPrompt();
    } else if (args.length == 1) {
      _runFile(args[0]);
    } else {
      print(
          'Nah, invalid arguments. Use Danox like this: danox your_programm_file.dnx');
      exit(64);
    }
  }

  static void _runFile(String path) {
    final programFile = File(path);

    String? sourceCode;

    try {
      sourceCode = programFile.readAsStringSync();
    } catch (e) {
      print('Oops, can\'t open the file with the following path - $path\n');
      exit(1);
    }

    _run(sourceCode);

    if (_hasError) exit(65);
    if (_hasRuntimeError) exit(70);
  }

  static void _runPrompt() {
    while (true) {
      stdout.write('> ');

      final line = stdin.readLineSync();

      if (line == null || line.trim() == '') {
        print('Wow, there is absolutely nothing to execute!');
        continue;
      }

      _run(line);
    }
  }

  static void _run(String source) {
    final scanner = Scanner(source);
    final tokens = scanner.scanTokens();

    final parser = Parser(tokens);

    final expr = parser.parse();

    if (_hasError) return;

    _interpreter.interpret(expr);
  }

  static void errorLine(int line, String message) {
    _report(line: line, message: message);
  }

  static void errorToken(Token token, String message) {
    if (token.type == TokenType.eof) {
      _report(line: token.line, where: ' at end', message: message);
    } else {
      _report(
          line: token.line, where: ' at \'${token.lexeme}\'', message: message);
    }
  }

  static void _report({
    required int line,
    String where = '',
    required String message,
  }) {
    print('[Line $line] Error$where: $message');

    _hasError = true;
  }

  static void runtimeError(RuntimeError error) {
    print('${error.message}\n[line ${error.token.line}]');
    _hasRuntimeError = true;
  }
}
