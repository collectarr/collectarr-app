import 'dart:io';

import 'kind_registry/ast_source.dart';

// This script deliberately does not discover or generate application
// composition roots. Those registrations are explicit source under the owning
// feature. Code generation remains only for repetitive mechanical artifacts:
// Drift table composition and development seed contributor lists.
const _kindRoot = 'lib/features/library/kinds';
const _databaseTablesOutput =
    'lib/features/library/kinds/registry/collectarr_kind_database_tables.g.dart';
const _devSeedRoot = 'lib/dev/seeds';
const _devSeedRegistryOutput =
    'lib/dev/seeds/collectarr_dev_seed_registry.g.dart';

const _requiredKinds = {
  'anime',
  'boardgame',
  'book',
  'comic',
  'game',
  'manga',
  'movie',
  'music',
  'tv',
};

Future<void> main() async {
  final tableFiles = await _discoverKindTableFiles();
  await File(_databaseTablesOutput)
      .writeAsString(_renderDatabaseTables(tableFiles));

  final seedDescriptors = await _discoverDevSeeds();
  await File(_devSeedRegistryOutput)
      .writeAsString(_renderDevSeedRegistry(seedDescriptors));

  await _formatGeneratedFile(_databaseTablesOutput);
  await _formatGeneratedFile(_devSeedRegistryOutput);
  stdout.writeln(
    'Generated table composition for ${tableFiles.length} kind modules.',
  );
  stdout.writeln('Generated ${seedDescriptors.length} dev seed contributors.');
}

Future<List<_KindTableFile>> _discoverKindTableFiles() async {
  final files = <_KindTableFile>[];
  for (final kind in _requiredKinds.toList()..sort()) {
    final directory = Directory('$_kindRoot/$kind/data/local');
    if (!directory.existsSync()) {
      throw StateError('Missing local table directory for $kind');
    }
    final kindFiles = directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList()
      ..sort((left, right) => left.path.compareTo(right.path));
    final tableFiles = kindFiles
        .map(
          (file) => _KindTableFile(
            kind: kind,
            importPath: _packageImportPath(file),
            tableNames: findTableClasses(file),
          ),
        )
        .where((file) => file.tableNames.isNotEmpty)
        .toList(growable: false);
    if (tableFiles.isEmpty) {
      throw StateError('No Drift tables found for $kind');
    }
    files.addAll(tableFiles);
  }
  return files;
}

Future<List<_DevSeedDescriptor>> _discoverDevSeeds() async {
  final root = Directory(_devSeedRoot);
  final descriptors = <_DevSeedDescriptor>[];
  await for (final entity in root.list()) {
    if (entity is! File || !entity.path.endsWith('_seeds.dart')) continue;
    final contributor = findTopLevelVariable(
      entity,
      nameWhere: (name) => name.endsWith('DevSeedContributor'),
    );
    if (contributor == null) continue;
    if (contributor.declaredType == null ||
        !contributor.declaredType!.startsWith('TypedDevSeedKindContributor<')) {
      throw StateError(
        'Dev seed ${entity.path} must declare a '
        'TypedDevSeedKindContributor<TOwned>; found '
        '${contributor.declaredType}',
      );
    }
    descriptors.add(
      _DevSeedDescriptor(
        importPath: _packageImportPath(entity),
        contributorName: contributor.name,
      ),
    );
  }
  descriptors.sort(
    (left, right) => left.contributorName.compareTo(right.contributorName),
  );
  final discoveredKinds =
      descriptors.map((descriptor) => descriptor.kind).toSet();
  if (discoveredKinds.length != _requiredKinds.length ||
      !discoveredKinds.containsAll(_requiredKinds)) {
    throw StateError(
      'Dev seed registry must cover exactly $_requiredKinds; '
      'found $discoveredKinds',
    );
  }
  return descriptors;
}

String _renderDatabaseTables(List<_KindTableFile> files) {
  final buffer = StringBuffer('''// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run tool/generate_kind_registries.dart

''');
  final imports = <String>{};
  for (final file in files) {
    if (!imports.add(file.importPath)) continue;
    buffer.writeln("import 'package:collectarr_app/${file.importPath}';");
    buffer.writeln("export 'package:collectarr_app/${file.importPath}';");
  }
  buffer.writeln();
  buffer.writeln('const List<Type> collectarrKindTableTypes = <Type>[');
  for (final file in files) {
    for (final tableName in file.tableNames) {
      buffer.writeln('  $tableName,');
    }
  }
  buffer.writeln('];');
  return buffer.toString();
}

String _renderDevSeedRegistry(List<_DevSeedDescriptor> descriptors) {
  final buffer = StringBuffer('''// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run tool/generate_kind_registries.dart

import 'package:collectarr_app/dev/seeds/dev_seed_kind_contributor.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
''');
  for (final descriptor in descriptors) {
    buffer.writeln(
      "import 'package:collectarr_app/${descriptor.importPath}';",
    );
  }
  for (final descriptor in descriptors) {
    buffer.writeln(
      "export 'package:collectarr_app/${descriptor.importPath}';",
    );
  }
  buffer.writeln();
  buffer.writeln(
    'final List<DevSeedKindContributor> collectarrDevSeedContributors = [',
  );
  for (final descriptor in descriptors) {
    buffer.writeln('  ${descriptor.contributorName},');
  }
  buffer.writeln('];');
  buffer.writeln();
  buffer.writeln(
    'final Map<CatalogMediaKind, DevSeedKindContributor> '
    'collectarrDevSeedContributorsByKind = {',
  );
  for (final descriptor in descriptors) {
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.kind}: ${descriptor.contributorName},',
    );
  }
  buffer.writeln('};');
  return buffer.toString();
}

Future<void> _formatGeneratedFile(String path) async {
  final result = await Process.run(
    Platform.resolvedExecutable,
    ['format', path],
  );
  if (result.exitCode != 0) {
    throw ProcessException(
      Platform.resolvedExecutable,
      ['format', path],
      result.stderr.toString(),
      result.exitCode,
    );
  }
}

String _packageImportPath(File file) {
  final normalized = file.path.replaceAll('\\', '/');
  final marker = '/lib/';
  final markerIndex = normalized.lastIndexOf(marker);
  if (markerIndex >= 0) {
    return normalized.substring(markerIndex + marker.length);
  }
  if (normalized.startsWith('lib/')) return normalized.substring(4);
  throw StateError('Cannot derive package import path from ${file.path}');
}

final class _KindTableFile {
  const _KindTableFile({
    required this.kind,
    required this.importPath,
    required this.tableNames,
  });

  final String kind;
  final String importPath;
  final List<String> tableNames;
}

final class _DevSeedDescriptor {
  const _DevSeedDescriptor({
    required this.importPath,
    required this.contributorName,
  });

  final String importPath;
  final String contributorName;

  String get kind => contributorName
      .replaceFirst(RegExp(r'DevSeedContributor$'), '')
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match.group(1)}_${match.group(2)!.toLowerCase()}',
      )
      .toLowerCase();
}
