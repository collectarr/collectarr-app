import 'dart:io';

import 'package:path/path.dart' as p;

final _importPattern = RegExp(
  r'^\s*(import|export|part)\s+["\x27]([^"\x27]+)["\x27]\s*;',
);

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

const _kindsRoot = 'lib/features/library/kinds/';
const _registryRoot = 'lib/features/library/kinds/registry/';

void main(List<String> arguments) {
  final repoRoot = Directory.current.path;
  final libRoot = p.join(repoRoot, 'lib');
  final files = _dartFilesUnder(Directory(libRoot)).toList()..sort();

  final violations = <String>[];

  for (final file in files) {
    final relativePath = p.relative(file, from: repoRoot).replaceAll('\\', '/');
    final isRegistryFile = relativePath.startsWith(_registryRoot);
    final kindName = _kindNameForPath(relativePath);

    final lines = File(file).readAsLinesSync();
    for (var index = 0; index < lines.length; index += 1) {
      final line = lines[index];

      // Check for forbidden CatalogMediaKind branching in generic/shared boundary code.
      if (_isBoundaryFile(relativePath)) {
        if (RegExp(r'switch\s*\(\s*.*kind\s*\)').hasMatch(line) &&
            line.contains('CatalogMediaKind.')) {
          violations.add(
            '$relativePath:${index + 1}: Forbidden CatalogMediaKind switch in generic boundary code',
          );
        }
        if (RegExp(
                r'if\s*\(\s*.*kind\s*==\s*CatalogMediaKind\.(comic|movie|tv|game|music|book|boardgame|manga|anime)\b\)')
            .hasMatch(line)) {
          violations.add(
            '$relativePath:${index + 1}: Forbidden CatalogMediaKind comparison in generic boundary code',
          );
        }
      }

      if (line.contains(r"endsWith('.$id')") ||
          line.contains(r'endsWith(".$id")')) {
        violations.add(
          '$relativePath:${index + 1}: Forbidden endsWith substring matching fallback in schema lookup',
        );
      }

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
      if (importedRelativePath.startsWith(_registryRoot)) {
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
      if (importedKind != null &&
          importedKind != kindName &&
          !_isAllowedKindImport(kindName, importedKind)) {
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

bool _isAllowedKindImport(String sourceKind, String importedKind) {
  if (importedKind == 'video' &&
      (sourceKind == 'movie' || sourceKind == 'tv' || sourceKind == 'anime')) {
    return true;
  }
  if (importedKind == 'book' && sourceKind == 'manga') {
    return true;
  }
  if (importedKind == 'movie' && sourceKind == 'anime') {
    return true;
  }
  return false;
}

String? _kindNameForPath(String relativePath) {
  const prefix = 'lib/features/library/kinds/';
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

String? _resolveImportPath(
    String repoRoot, String currentFile, String importPath) {
  if (importPath.startsWith('package:collectarr_app/')) {
    return p.join(
      repoRoot,
      'lib',
      importPath.substring('package:collectarr_app/'.length),
    );
  }
  if (importPath.startsWith('package:')) {
    return null;
  }
  if (importPath.startsWith('.')) {
    return p.normalize(p.join(p.dirname(currentFile), importPath));
  }
  return null;
}
