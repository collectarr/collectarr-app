import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:path/path.dart' as p;

final class KindDuplicationOccurrence {
  const KindDuplicationOccurrence({
    required this.kind,
    required this.path,
    required this.line,
    required this.nodeKind,
    required this.name,
  });

  final String kind;
  final String path;
  final int line;
  final String nodeKind;
  final String name;
}

final class KindDuplicationCluster {
  const KindDuplicationCluster({
    required this.fingerprint,
    required this.occurrences,
  });

  final String fingerprint;
  final List<KindDuplicationOccurrence> occurrences;

  Set<String> get kinds => occurrences.map((item) => item.kind).toSet();
}

List<KindDuplicationCluster> findKindDuplicationClusters(
  String repoRoot, {
  int minimumBodyLines = 5,
  int minimumFingerprintLength = 180,
}) {
  final kindsRoot = Directory(
    p.join(repoRoot, 'lib', 'features', 'library', 'kinds'),
  );
  if (!kindsRoot.existsSync()) return const [];

  final kindNames = kindsRoot
      .listSync(followLinks: false)
      .whereType<Directory>()
      .map((directory) => p.basename(directory.path))
      .where((name) => name != 'registry' && name != '_shared')
      .toList()
    ..sort();

  final occurrencesByFingerprint = <String, List<KindDuplicationOccurrence>>{};
  for (final kind in kindNames) {
    final kindRoot = Directory(p.join(kindsRoot.path, kind));
    for (final entity
        in kindRoot.listSync(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final relativePath =
          p.relative(entity.path, from: repoRoot).replaceAll('\\', '/');
      if (_isGenerated(relativePath)) continue;

      final content = entity.readAsStringSync();
      final parsed = parseString(
        content: content,
        path: entity.path,
        throwIfDiagnostics: false,
      );
      final lineInfo = parsed.lineInfo;
      final visitor = _DuplicationVisitor(
        kind: kind,
        relativePath: relativePath,
        lineInfo: lineInfo,
        kindNames: kindNames,
        minimumBodyLines: minimumBodyLines,
        minimumFingerprintLength: minimumFingerprintLength,
        onOccurrence: (occurrence, fingerprint) {
          occurrencesByFingerprint
              .putIfAbsent(fingerprint, () => <KindDuplicationOccurrence>[])
              .add(occurrence);
        },
      );
      parsed.unit.accept(visitor);
    }
  }

  final clusters = <KindDuplicationCluster>[];
  for (final entry in occurrencesByFingerprint.entries) {
    final distinctKinds = entry.value.map((item) => item.kind).toSet();
    if (distinctKinds.length < 2) continue;

    final occurrences = [...entry.value]..sort((left, right) {
        final kindOrder = left.kind.compareTo(right.kind);
        if (kindOrder != 0) return kindOrder;
        return left.path.compareTo(right.path);
      });
    clusters.add(
      KindDuplicationCluster(
        fingerprint: entry.key,
        occurrences: occurrences,
      ),
    );
  }

  clusters.sort((left, right) {
    final kindOrder = right.kinds.length.compareTo(left.kinds.length);
    if (kindOrder != 0) return kindOrder;
    return right.fingerprint.length.compareTo(left.fingerprint.length);
  });
  return clusters;
}

void runKindDuplicationChecker([List<String> arguments = const []]) {
  final repoRoot = Directory.current.path;
  final clusters = findKindDuplicationClusters(repoRoot);
  if (clusters.isEmpty) {
    stdout.writeln('No repeated kind implementation clusters found.');
    return;
  }

  stdout.writeln(
    'Kind duplication audit (informational): ${clusters.length} clusters',
  );
  for (var index = 0; index < clusters.length; index++) {
    final cluster = clusters[index];
    stdout.writeln(
      '  KD001 #${index + 1}: ${cluster.kinds.length} kinds, '
      '${cluster.fingerprint.length} normalized chars',
    );
    for (final occurrence in cluster.occurrences) {
      stdout.writeln(
        '    ${occurrence.kind} ${occurrence.path}:${occurrence.line} '
        '${occurrence.nodeKind} ${occurrence.name}',
      );
    }
  }
}

final class _DuplicationVisitor extends RecursiveAstVisitor<void> {
  _DuplicationVisitor({
    required this.kind,
    required this.relativePath,
    required this.lineInfo,
    required this.kindNames,
    required this.minimumBodyLines,
    required this.minimumFingerprintLength,
    required this.onOccurrence,
  });

  final String kind;
  final String relativePath;
  final LineInfo lineInfo;
  final List<String> kindNames;
  final int minimumBodyLines;
  final int minimumFingerprintLength;
  final void Function(KindDuplicationOccurrence occurrence, String fingerprint)
      onOccurrence;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _recordBody(
      node,
      node.body,
      node.name.lexeme,
      'method',
    );
    super.visitMethodDeclaration(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _recordBody(
      node,
      node.functionExpression.body,
      node.name.lexeme,
      'function',
    );
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _recordBody(node, node, node.namePart.toSource(), 'class');
    super.visitClassDeclaration(node);
  }

  void _recordBody(AstNode node, AstNode body, String name, String nodeKind) {
    final source = body.toSource();
    final lineCount = _lineCount(source);
    if (lineCount < minimumBodyLines ||
        source.length < minimumFingerprintLength ||
        _isTrivialName(name)) {
      return;
    }

    final fingerprint = _normalize(source);
    if (fingerprint.length < minimumFingerprintLength) return;

    onOccurrence(
      KindDuplicationOccurrence(
        kind: kind,
        path: relativePath,
        line: lineInfo.getLocation(node.offset).lineNumber,
        nodeKind: nodeKind,
        name: name,
      ),
      fingerprint,
    );
  }

  String _normalize(String source) {
    var normalized = source.replaceAll(RegExp(r'\s+'), ' ').trim();
    for (final kindName in kindNames) {
      final escaped = RegExp.escape(kindName);
      normalized = normalized.replaceAll(
        RegExp('\b[A-Za-z_][A-Za-z0-9_]*$escaped[A-Za-z0-9_]*\b',
            caseSensitive: false),
        '<KIND_IDENTIFIER>',
      );
    }
    return normalized;
  }

  int _lineCount(String source) => '\n'.allMatches(source).length + 1;

  bool _isTrivialName(String name) =>
      name == 'toString' || name == 'hashCode' || name == 'operator ==';
}

bool _isGenerated(String relativePath) =>
    relativePath.endsWith('.g.dart') ||
    relativePath.endsWith('.freezed.dart') ||
    relativePath.endsWith('.drift.dart');
