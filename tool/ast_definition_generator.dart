import 'dart:io';

void main(List<String> args) async {
  if (args.length != 1) {
    print('Invalid arguments - pass only the path of output file');
    exit(64);
  }

  await _ASTDefinitionGenerator.main(args[0]);
}

abstract class _ASTDefinitionGenerator {
  static Future<void> main(String path) async {
    final file = File(path);

    var content = '''import 'package:danox/token.dart';

''';

    content += _defineAST('Expr', {
      'Binary': 'Expr left, Token operator, Expr right',
      'Grouping': 'Expr expression',
      'Literal': 'Object? value',
      'Unary': 'Token operator, Expr right',
    });

    content += _defineAST('Stmt', {
      'Expression': 'Expr expression',
      'Print': 'Expr expression',
    });

    await file.writeAsString(content);
  }

  static String _defineAST(String baseName, Map<String, String> scheme) {
    var content = '''abstract class $baseName {
  const $baseName();

  R accept<R>(${baseName}Visitor<R> visitor);
}
''';

    content += _generateVisitor(baseName, scheme.keys.toList());

    // Classes
    for (final c in scheme.entries) {
      content += 'final class ${c.key}$baseName extends $baseName {\n';

      for (final field in c.value.split(', ')) {
        content += '  final $field;\n';
      }

      content += '\n  const ${c.key}$baseName({\n';

      for (final field in c.value.split(', ')) {
        content += '    required this.${field.split(' ')[1]},\n';
      }

      content += '  });\n\n';

      content += '  @override\n';
      content += '  R accept<R>(${baseName}Visitor<R> visitor) {\n';
      content += '    return visitor.visit${c.key}$baseName(this);\n';
      content += '  }\n';

      content += '}\n\n';
    }

    return content;
  }

  static String _generateVisitor(String baseName, List<String> types) {
    var content = '''abstract interface class ${baseName}Visitor<R> {
    
''';

    for (final c in types) {
      content +=
          '  R visit$c$baseName($c$baseName ${baseName.toLowerCase()});\n';
    }

    content += '}\n\n';

    return content;
  }
}
