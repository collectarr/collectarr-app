import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:path/path.dart' as p;

class ArchitectureRuleVisitor extends RecursiveAstVisitor<void> {
  ArchitectureRuleVisitor({
    required this.filePath,
    required this.relativePath,
    required this.lineInfo,
    required this.isBoundaryFile,
    required this.isRegistryFile,
    required this.kindName,
    required this.repoRoot,
  });

  final String filePath;
  final String relativePath;
  final LineInfo lineInfo;
  final bool isBoundaryFile;
  final bool isRegistryFile;
  final String? kindName;
  final String repoRoot;

  final List<String> violations = [];
  final List<String> complexityWarnings = [];

  @override
  void visitImportDirective(ImportDirective node) {
    _checkDirective(node.uri.stringValue, node.offset, 'import');
    super.visitImportDirective(node);
  }

  @override
  void visitExportDirective(ExportDirective node) {
    _checkDirective(node.uri.stringValue, node.offset, 'export');
    super.visitExportDirective(node);
  }

  void _checkDirective(String? uriString, int offset, String directive) {
    if (uriString == null) return;
    if (isRegistryFile) return;

    final lineNumber = lineInfo.getLocation(offset).lineNumber;
    final importedPath = _resolveImportPath(repoRoot, filePath, uriString);
    if (importedPath == null) return;

    final importedRelativePath =
        p.relative(importedPath, from: repoRoot).replaceAll('\\', '/');

    if (!importedRelativePath.startsWith('lib/features/library/kinds/')) {
      return;
    }
    if (importedRelativePath
        .startsWith('lib/features/library/kinds/registry/')) {
      return;
    }

    if (isBoundaryFile) {
      violations.add(
        '$relativePath:$lineNumber: Forbidden import of kind-specific module ($uriString) from generic boundary code',
      );
      return;
    }

    if (kindName != null) {
      final importedKind = _kindNameForPath(importedRelativePath);
      if (importedKind != null &&
          importedKind != kindName &&
          !_isAllowedKindImport(kindName!, importedKind)) {
        violations.add(
          '$relativePath:$lineNumber: Cross-kind import violation ($directive $uriString)',
        );
      }
    }
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    if (isBoundaryFile) {
      final expr = node.expression.toSource();
      if (expr.contains('kind') || expr.contains('CatalogMediaKind')) {
        final line = lineInfo.getLocation(node.offset).lineNumber;
        violations.add(
          '$relativePath:$line: Forbidden CatalogMediaKind switch statement in generic boundary code',
        );
      }
    }
    super.visitSwitchStatement(node);
  }

  @override
  void visitSwitchExpression(SwitchExpression node) {
    if (isBoundaryFile) {
      final expr = node.expression.toSource();
      if (expr.contains('kind') || expr.contains('CatalogMediaKind')) {
        final line = lineInfo.getLocation(node.offset).lineNumber;
        violations.add(
          '$relativePath:$line: Forbidden CatalogMediaKind switch expression in generic boundary code',
        );
      }
    }
    super.visitSwitchExpression(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (isBoundaryFile &&
        (node.operator.lexeme == '==' || node.operator.lexeme == '!=')) {
      final left = node.leftOperand.toSource();
      final right = node.rightOperand.toSource();
      if ((left.contains('kind') && right.contains('CatalogMediaKind.')) ||
          (right.contains('kind') && left.contains('CatalogMediaKind.'))) {
        final line = lineInfo.getLocation(node.offset).lineNumber;
        violations.add(
          '$relativePath:$line: Forbidden CatalogMediaKind comparison in generic boundary code',
        );
      }
    }
    super.visitBinaryExpression(node);
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final startLine = lineInfo.getLocation(node.offset).lineNumber;
    final endLine = lineInfo.getLocation(node.end).lineNumber;
    final classLength = endLine - startLine + 1;
    final className = node.namePart.toSource();
    if (classLength > 500 && !_isExempt(relativePath)) {
      complexityWarnings.add(
        '$relativePath:$startLine: Class "$className" exceeds complexity budget ($classLength > 500 lines)',
      );
    }
    super.visitClassDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final startLine = lineInfo.getLocation(node.offset).lineNumber;
    final endLine = lineInfo.getLocation(node.end).lineNumber;
    final methodLength = endLine - startLine + 1;
    if (methodLength > 100 && !_isExempt(relativePath)) {
      complexityWarnings.add(
        '$relativePath:$startLine: Method "${node.name.lexeme}" exceeds complexity budget ($methodLength > 100 lines)',
      );
    }
    _checkParameters(node.parameters, node.name.lexeme, startLine);
    super.visitMethodDeclaration(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final startLine = lineInfo.getLocation(node.offset).lineNumber;
    final endLine = lineInfo.getLocation(node.end).lineNumber;
    final funcLength = endLine - startLine + 1;
    if (funcLength > 100 && !_isExempt(relativePath)) {
      complexityWarnings.add(
        '$relativePath:$startLine: Function "${node.name.lexeme}" exceeds complexity budget ($funcLength > 100 lines)',
      );
    }
    _checkParameters(
      node.functionExpression.parameters,
      node.name.lexeme,
      startLine,
    );
    super.visitFunctionDeclaration(node);
  }

  void _checkParameters(
    FormalParameterList? parameters,
    String callableName,
    int line,
  ) {
    if (parameters != null && parameters.parameters.length > 18) {
      complexityWarnings.add(
        '$relativePath:$line: Callable "$callableName" exceeds parameter budget (${parameters.parameters.length} > 18 params)',
      );
    }
  }

  bool _isExempt(String path) {
    return path.endsWith('.g.dart') ||
        path.endsWith('.freezed.dart') ||
        path.endsWith('.drift.dart') ||
        path.contains('/generated/');
  }
}

final _boundaryRoots = <String>[
  'lib/features/library/generic/',
  'lib/features/library/config/',
  'lib/features/library/workspace/',
  'lib/features/library/add/',
  'lib/features/library/edit/',
  'lib/features/library/detail/',
  'lib/features/library/details/',
  'lib/features/library/inspector/',
  'lib/features/library/ui/',
  'lib/features/library/widgets/',
  'lib/features/library/stats/',
  'lib/features/library/reports/',
  'lib/features/library/tracking/',
];

const _registryRoot = 'lib/features/library/kinds/registry/';

void main(List<String> arguments) {
  final repoRoot = Directory.current.path;
  final libRoot = p.join(repoRoot, 'lib');
  final files = _dartFilesUnder(Directory(libRoot)).toList()..sort();

  final allViolations = <String>[];
  final allComplexityWarnings = <String>[];

  for (final file in files) {
    final relativePath = p.relative(file, from: repoRoot).replaceAll('\\', '/');
    if (relativePath.endsWith('.g.dart') ||
        relativePath.endsWith('.freezed.dart') ||
        relativePath.endsWith('.drift.dart')) {
      continue;
    }

    final isRegistryFile = relativePath.startsWith(_registryRoot);
    final kindName = _kindNameForPath(relativePath);
    final isBoundary = _isBoundaryFile(relativePath);

    final content = File(file).readAsStringSync();
    final lineCount = content.split('\n').length;
    if (lineCount > 800) {
      allComplexityWarnings.add(
        '$relativePath: File exceeds complexity budget ($lineCount > 800 lines)',
      );
    }

    final parseResult = parseString(
      content: content,
      path: file,
      throwIfDiagnostics: false,
    );

    final visitor = ArchitectureRuleVisitor(
      filePath: file,
      relativePath: relativePath,
      lineInfo: parseResult.lineInfo,
      isBoundaryFile: isBoundary,
      isRegistryFile: isRegistryFile,
      kindName: kindName,
      repoRoot: repoRoot,
    );

    parseResult.unit.accept(visitor);
    allViolations.addAll(visitor.violations);
    allComplexityWarnings.addAll(visitor.complexityWarnings);
  }

  if (allViolations.isNotEmpty) {
    stderr.writeln('AST Architecture violations (${allViolations.length}):');
    for (final violation in allViolations) {
      stderr.writeln('  $violation');
    }
    exitCode = 1;
  } else {
    stdout.writeln('No AST architecture boundary violations found.');
  }

  if (allComplexityWarnings.isNotEmpty) {
    stdout.writeln(
      'Complexity budget reports (${allComplexityWarnings.length}):',
    );
    for (final warning in allComplexityWarnings.take(15)) {
      stdout.writeln('  $warning');
    }
    if (allComplexityWarnings.length > 15) {
      stdout.writeln('  ... and ${allComplexityWarnings.length - 15} more');
    }
  }
}

Iterable<String> _dartFilesUnder(Directory root) sync* {
  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.toLowerCase().endsWith('.dart')) {
      yield entity.path;
    }
  }
}

bool _isBoundaryFile(String relativePath) {
  return _boundaryRoots.any(relativePath.startsWith);
}

bool _isAllowedKindImport(String sourceKind, String importedKind) {
  return false;
}

String? _kindNameForPath(String relativePath) {
  const prefix = 'lib/features/library/kinds/';
  if (!relativePath.startsWith(prefix)) {
    return null;
  }
  final rest = relativePath.substring(prefix.length);
  final parts = rest.split('/');
  if (parts.isEmpty ||
      parts.first.isEmpty ||
      parts.first == 'registry' ||
      parts.first == '_shared') {
    return null;
  }
  return parts.first;
}

String? _resolveImportPath(
  String repoRoot,
  String sourceFilePath,
  String uriString,
) {
  if (uriString.startsWith('package:collectarr_app/')) {
    final packagePath = uriString.substring('package:collectarr_app/'.length);
    return p.normalize(p.join(repoRoot, 'lib', packagePath));
  }
  if (uriString.startsWith('package:') || uriString.startsWith('dart:')) {
    return null;
  }
  final sourceDir = p.dirname(sourceFilePath);
  return p.normalize(p.join(sourceDir, uriString));
}
