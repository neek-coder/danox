import 'dart:io';

void main(List<String> args) async {
  if (args.length != 1) {
    print('Invalid arguments - pass only the path of output file');
    exit(64);
  }

  await _ASTDefinitionGenerator.main(args[0]);
}

abstract class _ASTDefinitionGenerator {
  static const Map<String, String> scheme = {
    'Binary': 'Expression left, Token operator, Expression right',
    'Grouping': 'Expression expression',
    'Literal': 'Object value',
    'Unary': 'Token operator, Expression right',
  };

  static Future<void> main(String path) async {
    final file = File(path);

    final content = generate(scheme);

    await file.writeAsString(content);
  }

  static String generate(Map<String, String> scheme) {
    var content = '''import 'package:danox/token.dart';

abstract class Expression {
  const Expression();

  R accept<R>(Visitor<R> visitor);
}

abstract interface class Visitor<R> {
''';

    for (final c in scheme.entries) {
      content += '  R visit${c.key}(${c.key} expr);\n';
    }

    content += '}\n\n';

    // Classes
    for (final c in scheme.entries) {
      content += 'final class ${c.key} extends Expression {\n';

      for (final field in c.value.split(', ')) {
        content += '  final $field;\n';
      }

      content += '\n  const ${c.key}({\n';

      for (final field in c.value.split(', ')) {
        content += '    required this.${field.split(' ')[1]},\n';
      }

      content += '  });\n\n';

      content += '  @override\n';
      content += '  R accept<R>(Visitor<R> visitor) {\n';
      content += '    return visitor.visit${c.key}(this);\n';
      content += '  }\n';

      content += '}\n\n';
    }

    return content;
  }
}
