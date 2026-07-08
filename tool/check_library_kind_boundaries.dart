import 'dart:io';

import 'package:path/path.dart' as p;

final _importPattern = RegExp(
  '^\\s*(import|export|part)\\s+["\\\']([^"\\\']+)["\\\']\\s*;',
);

final _boundaryRoots = <String>[
  'lib/features/library/generic/',
  'lib/features/library/config/',
  'lib/features/library/workspace/',
  'lib/features/library/add/',
  'lib/features/library/edit/',
];

const _kindsRoot = 'lib/features/library/kinds/';
const _registryRoot = 'lib/features/library/kinds/registry/';

void main(List<String> arguments) {
  final repoRoot = Directory.current.path;
  final libRoot = p.join(repoRoot, 'lib');
  final files = _dartFilesUnder(Directory(libRoot)).toList()
    ..sort();

  final violations = <String>[];

  for (final file in files) {
    final relativePath = p.relative(file, from: repoRoot).replaceAll('\\', '/');
    final isRegistryFile = relativePath.startsWith(_registryRoot);
    final kindName = _kindNameForPath(relativePath);

    final lines = File(file).readAsLinesSync();
    for (var index = 0; index < lines.length; index += 1) {
      final line = lines[index];
      final match = _importPattern.firstMatch(line);
      if (match == null) {
        continue;
      }

      final directive = match.group(1)!;
      final importPath = match.group(2)!;
      final importedPath = _resolveImportPath(repoRoot, file, importPath);
      if (importedPath == null) {
        continue;
      }

      if (isRegistryFile) {
        continue;
      }

      final importedRelativePath =
          p.relative(importedPath, from: repoRoot).replaceAll('\\', '/');
      if (!importedRelativePath.startsWith(_kindsRoot)) {
        continue;
      }

      if (_isBoundaryFile(relativePath)) {
        violations.add('$relativePath:${index + 1}: $directive $importPath');
        continue;
      }

      if (kindName == null) {
        continue;
      }

      final importedKind = _kindNameForPath(importedRelativePath);
      if (importedKind != null && importedKind != kindName) {
        violations.add('$relativePath:${index + 1}: $directive $importPath');
      }
    }
  }

  if (violations.isNotEmpty) {
    stderr.writeln('Library kind boundary violations:');
    for (final violation in violations) {
      stderr.writeln('  $violation');
    }
    exitCode = 1;
  } else {
    stdout.writeln('No library kind boundary violations found.');
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

String? _kindNameForPath(String relativePath) {
  final prefix = 'lib/features/library/kinds/';
  if (!relativePath.startsWith(prefix)) {
    return null;
  }
  final remainder = relativePath.substring(prefix.length);
  final kind = remainder.split('/').first;
  if (kind.isEmpty || kind == 'registry') {
    return null;
  }
  return kind;
}

String? _resolveImportPath(String repoRoot, String currentFile, String importPath) {
  if (importPath.startsWith('package:collectarr_app/')) {
    return p.join(repoRoot, 'lib', importPath.substring('package:collectarr_app/'.length));
  }
  if (importPath.startsWith('package:')) {
    return null;
  }
  if (importPath.startsWith('.')) {
    return p.normalize(p.join(p.dirname(currentFile), importPath));
  }
  return null;
}
