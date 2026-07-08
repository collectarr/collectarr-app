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

void main(List<String> arguments) {
  final repoRoot = Directory.current.path;
  final libRoot = p.join(repoRoot, 'lib');
  final files = _dartFilesUnder(Directory(libRoot)).toList()
    ..sort();

  final violations = <String>[];

  for (final file in files) {
    final relativePath = p.relative(file, from: repoRoot).replaceAll('\\', '/');
    final isRegistryFile =
        relativePath.startsWith('lib/features/library/kinds/registry/');
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

      if (!_isKindPackageImport(importPath)) {
        continue;
      }

      if (isRegistryFile) {
        continue;
      }

      if (_isBoundaryFile(relativePath)) {
        violations.add(
          '$relativePath:${index + 1}: $directive $importPath',
        );
        continue;
      }

      if (kindName == null) {
        continue;
      }

      final importedKind = _kindNameFromPackageImport(importPath);
      if (importedKind == null) {
        continue;
      }

      if (importedKind != kindName && importedKind != 'shared') {
        violations.add(
          '$relativePath:${index + 1}: $directive $importPath',
        );
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

bool _isKindPackageImport(String importPath) {
  return importPath.startsWith('package:collectarr_app/features/library/kinds/');
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

String? _kindNameFromPackageImport(String importPath) {
  const prefix = 'package:collectarr_app/features/library/kinds/';
  if (!importPath.startsWith(prefix)) {
    return null;
  }
  final remainder = importPath.substring(prefix.length);
  return remainder.split('/').first;
}
