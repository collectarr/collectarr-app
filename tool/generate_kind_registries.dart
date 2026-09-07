import 'dart:io';

const _kindsRoot = 'lib/features/library/kinds';
const _registryOutput =
    'lib/features/library/kinds/registry/collectarr_kind_registry.g.dart';
const _databaseTablesOutput =
    'lib/features/library/kinds/registry/collectarr_kind_database_tables.g.dart';
const _ownedDetailsExportsOutput =
    'lib/features/library/kinds/registry/owned_details_exports.g.dart';
const _devSeedRoot = 'lib/dev/seeds';
const _devSeedRegistryOutput =
    'lib/dev/seeds/collectarr_dev_seed_registry.g.dart';

Future<void> main() async {
  final descriptors = await _discoverKinds();
  if (descriptors.isEmpty) {
    throw StateError('No kind modules found under $_kindsRoot');
  }

  await File(_registryOutput).writeAsString(_renderRegistry(descriptors));
  await File(_databaseTablesOutput)
      .writeAsString(_renderDatabaseTables(descriptors));
  await File(_ownedDetailsExportsOutput)
      .writeAsString(_renderOwnedDetailsExports(descriptors));
  final devSeedDescriptors = await _discoverDevSeeds();
  if (devSeedDescriptors.isEmpty) {
    throw StateError('No dev seed contributors found under $_devSeedRoot');
  }
  await File(_devSeedRegistryOutput)
      .writeAsString(_renderDevSeedRegistry(devSeedDescriptors));

  await _formatGeneratedFile(_registryOutput);
  await _formatGeneratedFile(_databaseTablesOutput);
  await _formatGeneratedFile(_ownedDetailsExportsOutput);
  await _formatGeneratedFile(_devSeedRegistryOutput);
  stdout.writeln('Generated ${descriptors.length} kind registrations.');
  stdout.writeln(
    'Generated ${devSeedDescriptors.length} dev seed contributors.',
  );
}

Future<void> _formatGeneratedFile(String path) async {
  final formatResult = await Process.run(
    Platform.resolvedExecutable,
    ['format', path],
  );
  if (formatResult.exitCode != 0) {
    throw ProcessException(
      Platform.resolvedExecutable,
      ['format', path],
      formatResult.stderr.toString(),
      formatResult.exitCode,
    );
  }
}

Future<List<_DevSeedDescriptor>> _discoverDevSeeds() async {
  final root = Directory(_devSeedRoot);
  final descriptors = <_DevSeedDescriptor>[];
  await for (final entity in root.list()) {
    if (entity is! File || !entity.path.endsWith('_seeds.dart')) continue;
    final source = await entity.readAsString();
    if (!source.contains('DevSeedKindContributor')) continue;
    final contributorMatch = RegExp(
      r'(?:const|final)\s+(\w+DevSeedContributor)\s*=',
    ).firstMatch(source);
    if (contributorMatch == null) {
      throw StateError(
        'Could not find a *DevSeedContributor in ${entity.path}',
      );
    }
    descriptors.add(
      _DevSeedDescriptor(
        importPath: _packageImportPath(entity),
        contributorName: contributorMatch.group(1)!,
      ),
    );
  }
  descriptors.sort(
    (left, right) => left.contributorName.compareTo(right.contributorName),
  );
  return descriptors;
}

String _renderDevSeedRegistry(List<_DevSeedDescriptor> descriptors) {
  final buffer = StringBuffer('''// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run tool/generate_kind_registries.dart

import 'package:collectarr_app/dev/seeds/dev_seed_kind_contributor.dart';
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
  return buffer.toString();
}

Future<List<_KindDescriptor>> _discoverKinds() async {
  final root = Directory(_kindsRoot);
  final descriptors = <_KindDescriptor>[];
  await for (final entity in root.list()) {
    if (entity is! Directory) continue;
    final folder = entity.path.split(Platform.pathSeparator).last;
    if (folder == 'generic' || folder == 'registry' || folder == '_shared') {
      continue;
    }

    final moduleFile = File('${entity.path}/${folder}_kind_module.dart');
    final pageFile = File('${entity.path}/page.dart');
    if (!moduleFile.existsSync() || !pageFile.existsSync()) continue;

    final moduleSource = await moduleFile.readAsString();
    final moduleMatch =
        RegExp(r'final\s+(\w+KindModule)\s*=').firstMatch(moduleSource);
    final moduleName = moduleMatch?.group(1);
    if (moduleName == null) {
      throw StateError(
        'Could not find a *KindModule variable in ${moduleFile.path}',
      );
    }
    final pageSource = await pageFile.readAsString();
    final pageMatch =
        RegExp(r'class\s+(\w+LibraryPage)\s+extends').firstMatch(pageSource);
    final pageClass = pageMatch?.group(1);
    if (pageClass == null) {
      throw StateError(
        'Could not find a *LibraryPage class in ${pageFile.path}',
      );
    }

    final facetModule = RegExp(
      r'(?:const|final)\s+(\w+LibraryFacetModule)\s*=',
    ).firstMatch(moduleSource)?.group(1);
    final metadataDecoder = _discoverMetadataDecoder(entity);
    final localTables = _discoverLocalTables(entity);
    final ownedDetailsExports = _discoverOwnedDetailsExports(entity);

    descriptors.add(
      _KindDescriptor(
        folder: folder,
        moduleName: moduleName,
        pageClass: pageClass,
        calendarContributor: _discoverContributor(
          entity,
          'calendar',
          '${folder}_calendar_contributor.dart',
          'LibraryCalendarContributor',
        ),
        activityContributor: _discoverContributor(
          entity,
          'activity',
          '${folder}_activity_contributor.dart',
          'LibraryActivityContributor',
        ),
        adminContributor: _discoverContributor(
          entity,
          'admin',
          '${folder}_admin_contributor.dart',
          'LibraryAdminContributor',
        ),
        barcodeResolver: _discoverBarcodeResolver(entity),
        collectionCsvProjection: _discoverContributor(
          entity,
          'integrations/collection_csv',
          '${folder}_collection_csv_projection.dart',
          'LibraryCollectionCsvProjection',
        ),
        shelfExtension: _discoverContributor(
          entity,
          'integrations/collection_shelf',
          '${folder}_shelf_extension_contributor.dart',
          'LibraryShelfExtensionContributor',
        ),
        exportPreviewContributor: _discoverIntegrationContributor(
          entity,
          'LibraryExportPreviewContributor',
        ),
        catalogLookup: _discoverIntegrationContributor(
          entity,
          'CatalogKindLookup',
        ),
        routeContributor: _discoverIntegrationContributor(
          entity,
          'LibraryRouteContributor',
        ),
        trackingEntryCodec: _discoverContributor(
          entity,
          'tracking',
          '${folder}_tracking_entry_codec.dart',
          'TrackingEntryCodec',
        ),
        trackingUnitCodec: _discoverContributor(
          entity,
          'tracking',
          '${folder}_tracking_unit_codec.dart',
          'TrackingUnitCodec',
        ),
        watchSessionCodec: _discoverContributor(
          entity,
          'tracking',
          '${folder}_watch_session_codec.dart',
          'WatchSessionCodec',
        ),
        customEpisodeCodec: _discoverContributor(
          entity,
          'tracking',
          '${folder}_custom_episode_codec.dart',
          'CustomEpisodeCodec',
        ),
        providerMapper: _discoverContributor(
          entity,
          'provider',
          '${folder}_provider_mapper.dart',
          'LibraryKindProviderMapper',
        ),
        ownedDetailsCodec: _discoverContributor(
          entity,
          'ownership',
          '${folder}_owned_details_codec.dart',
          'OwnedDetailsCodec<',
        ),
        metadataDecoder: metadataDecoder,
        facetModule: facetModule,
        ownedPersistence: _discoverOwnedPersistence(entity),
        catalogRepositoryCodec: _discoverContributor(
          entity,
          'data',
          '${folder}_catalog_repository_codec.dart',
          'CatalogKindRepositoryCodec',
        ),
        serialAuthorityContributor: _discoverContributor(
          entity,
          'integrations/serial',
          '${folder}_serial_authority_contributor.dart',
          'SerialAuthorityContributor',
        ),
        vocabularyModule: _discoverVocabularyModule(entity),
        localTables: localTables,
        ownedDetailsExports: ownedDetailsExports,
      ),
    );
  }
  descriptors.sort((left, right) => left.folder.compareTo(right.folder));
  return descriptors;
}

List<String> _discoverOwnedDetailsExports(Directory kindDirectory) {
  final folder = kindDirectory.path.split(Platform.pathSeparator).last;
  final directory = Directory('${kindDirectory.path}/ownership');
  if (!directory.existsSync()) return const [];

  final files = [
    File('${directory.path}/${folder}_owned_details.dart'),
    File('${directory.path}/${folder}_owned_details_draft.dart'),
  ];
  return [
    for (final file in files)
      if (file.existsSync()) _packageImportPath(file),
  ];
}

_KindLocalTables? _discoverLocalTables(Directory kindDirectory) {
  final folder = kindDirectory.path.split(Platform.pathSeparator).last;
  final directory = Directory('${kindDirectory.path}/data/local');
  if (!directory.existsSync()) return null;

  final files = directory
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList()
    ..sort((left, right) => left.path.compareTo(right.path));
  final contributors = <_LocalTableFile>[];
  for (final file in files) {
    final source = file.readAsStringSync();
    final tableNames = RegExp(
      r'class\s+(\w+)\s+extends\s+Table\b',
    ).allMatches(source).map((match) => match.group(1)!).toList();
    if (tableNames.isEmpty) continue;
    contributors.add(
      _LocalTableFile(
        importPath: _packageImportPath(file),
        tableNames: tableNames,
      ),
    );
  }
  if (contributors.isEmpty) return null;
  return _KindLocalTables(kind: folder, files: contributors);
}

_OwnedPersistence? _discoverOwnedPersistence(Directory kindDirectory) {
  final folder = kindDirectory.path.split(Platform.pathSeparator).last;
  final repositoryFile =
      File('${kindDirectory.path}/data/${folder}_owned_repository.dart');
  final projectionFile = File(
    '${kindDirectory.path}/data/${folder}_owned_item_projection.dart',
  );
  final ownedModelFile = File(
    '${kindDirectory.path}/domain/${folder}_owned_item.dart',
  );
  final idsFile = File('${kindDirectory.path}/domain/${folder}_ids.dart');
  if (!repositoryFile.existsSync() ||
      !projectionFile.existsSync() ||
      !ownedModelFile.existsSync() ||
      !idsFile.existsSync()) {
    return null;
  }

  final repositoryClass = _findClass(
    repositoryFile,
    RegExp(r'(?:final\s+class|class)\s+(\w+OwnedRepository)'),
  );
  final projectionClass = _findClass(
    projectionFile,
    RegExp(r'(?:final\s+class|class)\s+(\w+OwnedItemProjection)'),
  );
  final ownedIdClass = _findClass(
    idsFile,
    RegExp(r'(?:final\s+class|class)\s+(\w+OwnedItemId)'),
  );
  final ownedModelClass = _findClass(
    ownedModelFile,
    RegExp(r'(?:final\s+class|class)\s+(\w+OwnedItem)'),
  );
  if (repositoryClass == null ||
      projectionClass == null ||
      ownedIdClass == null ||
      ownedModelClass == null) {
    throw StateError(
      'Could not discover complete owned persistence for $folder',
    );
  }
  return _OwnedPersistence(
    repository: _Contributor(
      importPath: _packageImportPath(repositoryFile),
      className: repositoryClass,
    ),
    projection: _Contributor(
      importPath: _packageImportPath(projectionFile),
      className: projectionClass,
    ),
    ownedId: _Contributor(
      importPath: _packageImportPath(idsFile),
      className: ownedIdClass,
    ),
    ownedModel: _Contributor(
      importPath: _packageImportPath(ownedModelFile),
      className: ownedModelClass,
    ),
  );
}

String? _findClass(File file, RegExp pattern) {
  return pattern.firstMatch(file.readAsStringSync())?.group(1);
}

_MetadataDecoder? _discoverMetadataDecoder(Directory kindDirectory) {
  final folder = kindDirectory.path.split(Platform.pathSeparator).last;
  final file = File('${kindDirectory.path}/domain/${folder}_metadata.dart');
  if (!file.existsSync()) return null;
  final source = file.readAsStringSync();
  final classNames = RegExp(
    r'(?:final\s+class|class)\s+(\w+)',
  ).allMatches(source).map((match) => match.group(1)!).toList();
  final candidates = [
    for (final className in classNames)
      if ((className.endsWith('Metadata') || className.endsWith('Media')) &&
          RegExp('factory\\s+$className\\.fromJson').hasMatch(source))
        className,
  ];
  candidates.sort((left, right) {
    final rightScore = _metadataClassScore(folder, right);
    final leftScore = _metadataClassScore(folder, left);
    return rightScore.compareTo(leftScore);
  });
  if (candidates.isNotEmpty) {
    final className = candidates.first;
    return _MetadataDecoder(
      importPath: _packageImportPath(file),
      expression: '$className.fromJson',
    );
  }
  return null;
}

_VocabularyModule? _discoverVocabularyModule(Directory kindDirectory) {
  final folder = kindDirectory.path.split(Platform.pathSeparator).last;
  final file = File(
    '${kindDirectory.path}/vocabulary/${folder}_vocabularies.dart',
  );
  if (!file.existsSync()) return null;
  final source = file.readAsStringSync();
  final className = RegExp(
    r'(?:abstract\s+final\s+class|final\s+class|class)\s+(\w+Vocabularies)',
  ).firstMatch(source)?.group(1);
  if (className == null ||
      !RegExp(r'static\s+const\s+all\s*=').hasMatch(source)) {
    throw StateError('Could not discover vocabulary module in ${file.path}');
  }
  return _VocabularyModule(
    importPath: _packageImportPath(file),
    className: className,
  );
}

int _metadataClassScore(String folder, String className) {
  final normalizedFolder = folder.replaceAll('_', '').toLowerCase();
  final normalizedClass = className.toLowerCase();
  if (normalizedClass == '$normalizedFolder metadata'.replaceAll(' ', '')) {
    return 100;
  }
  if (normalizedClass.endsWith('catalogmetadata')) return 95;
  if (normalizedClass.endsWith('seriesmetadata')) return 90;
  if (normalizedClass.endsWith('media')) return 85;
  return 10;
}

_Contributor? _discoverContributor(
  Directory kindDirectory,
  String relativeDirectory,
  String filename,
  String marker,
) {
  final file = File('${kindDirectory.path}/$relativeDirectory/$filename');
  if (!file.existsSync()) return null;
  final source = file.readAsStringSync();
  if (!source.contains(marker)) return null;
  final className = RegExp(
    r'(?:final\s+class|class)\s+(\w+)',
  ).firstMatch(source)?.group(1);
  if (className == null) {
    throw StateError('Could not find a contributor class in ${file.path}');
  }
  return _Contributor(
    importPath: _packageImportPath(file),
    className: className,
  );
}

_Contributor? _discoverBarcodeResolver(Directory kindDirectory) {
  final directory = Directory('${kindDirectory.path}/barcode');
  if (!directory.existsSync()) return null;
  for (final entity in directory.listSync()) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final source = entity.readAsStringSync();
    if (!source.contains('LibraryBarcodeResolver')) continue;
    final className = RegExp(
      r'(?:final\s+class|class)\s+(\w+)',
    ).firstMatch(source)?.group(1);
    if (className == null) {
      throw StateError('Could not find a barcode resolver in ${entity.path}');
    }
    return _Contributor(
      importPath: _packageImportPath(entity),
      className: className,
    );
  }
  return null;
}

_Contributor? _discoverIntegrationContributor(
  Directory kindDirectory,
  String marker,
) {
  for (final entity in kindDirectory.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final source = entity.readAsStringSync();
    if (!source.contains(marker)) continue;
    final className = RegExp(
      r'(?:final\s+class|class)\s+(\w+)',
    ).firstMatch(source)?.group(1);
    if (className == null) {
      throw StateError(
        'Could not find an integration contributor in ${entity.path}',
      );
    }
    return _Contributor(
      importPath: _packageImportPath(entity),
      className: className,
    );
  }
  return null;
}

String _renderRegistry(List<_KindDescriptor> descriptors) {
  final buffer = StringBuffer('''// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run tool/generate_kind_registries.dart

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_contributor.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
''');
  for (final descriptor in descriptors) {
    buffer.writeln(
      "import 'package:collectarr_app/features/library/kinds/${descriptor.folder}/${descriptor.folder}_kind_module.dart';",
    );
    buffer.writeln(
      "export 'package:collectarr_app/features/library/kinds/${descriptor.folder}/${descriptor.folder}_kind_module.dart';",
    );
    buffer.writeln(
      "import 'package:collectarr_app/features/library/kinds/${descriptor.folder}/page.dart';",
    );
  }
  final contributors = [
    for (final descriptor in descriptors)
      for (final contributor in descriptor.contributors) contributor,
  ];
  final importedContributorPaths = <String>{};
  for (final contributor in contributors) {
    if (importedContributorPaths.add(contributor.importPath)) {
      buffer.writeln(
        "import 'package:collectarr_app/${contributor.importPath}';",
      );
    }
  }
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    for (final contributor in [
      persistence.repository,
      persistence.projection,
      persistence.ownedId,
      persistence.ownedModel,
    ]) {
      if (importedContributorPaths.add(contributor.importPath)) {
        buffer.writeln(
          "import 'package:collectarr_app/${contributor.importPath}';",
        );
      }
    }
  }
  for (final descriptor in descriptors) {
    final codec = descriptor.catalogRepositoryCodec;
    if (codec == null || !importedContributorPaths.add(codec.importPath)) {
      continue;
    }
    buffer.writeln(
      "import 'package:collectarr_app/${codec.importPath}';",
    );
  }
  for (final descriptor in descriptors) {
    final contributor = descriptor.serialAuthorityContributor;
    if (contributor == null ||
        !importedContributorPaths.add(contributor.importPath)) {
      continue;
    }
    buffer.writeln(
      "import 'package:collectarr_app/${contributor.importPath}';",
    );
  }
  for (final descriptor in descriptors) {
    final vocabulary = descriptor.vocabularyModule;
    if (vocabulary == null ||
        !importedContributorPaths.add(vocabulary.importPath)) {
      continue;
    }
    buffer.writeln(
      "import 'package:collectarr_app/${vocabulary.importPath}';",
    );
  }
  buffer.writeln(
    "import 'package:collectarr_app/features/library/config/library_activity_contributor.dart';",
  );
  buffer.writeln(
    "import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';",
  );
  buffer.writeln(
    "import 'package:collectarr_app/features/library/config/library_barcode_resolver.dart';",
  );
  buffer.writeln(
    "import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';",
  );
  buffer.writeln(
    "import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';",
  );
  buffer.writeln(
    "import 'package:collectarr_app/features/library/config/library_shelf_extension_contributor.dart';",
  );
  buffer.writeln(
    "import 'package:collectarr_app/features/library/config/library_export_preview_contributor.dart';",
  );
  buffer.writeln(
    "import 'package:collectarr_app/features/library/tracking/tracking_entry_codec.dart';",
  );
  buffer.writeln(
    "import 'package:collectarr_app/features/library/tracking/tracking_unit_codec.dart';",
  );
  buffer.writeln(
    "import 'package:collectarr_app/features/library/tracking/watch_session_codec.dart';",
  );
  buffer.writeln(
    "import 'package:collectarr_app/features/library/tracking/custom_episode_codec.dart';",
  );
  buffer.writeln(
    "import 'package:collectarr_app/features/library/config/owned_details_codec.dart';",
  );
  for (final descriptor in descriptors) {
    final metadataDecoder = descriptor.metadataDecoder;
    if (metadataDecoder == null) continue;
    buffer.writeln(
      "import 'package:collectarr_app/${metadataDecoder.importPath}';",
    );
  }
  buffer.writeln();
  buffer.writeln('final List<LibraryKindModule> collectarrKindModules = [');
  for (final descriptor in descriptors) {
    buffer.writeln('  ${descriptor.moduleName},');
  }
  buffer.writeln('];');
  buffer.writeln();
  buffer.writeln(
    'final Map<CatalogMediaKind, LibraryKindWorkspace> '
    'collectarrKindWorkspaces = {',
  );
  for (final descriptor in descriptors) {
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: '
      '${descriptor.moduleName.replaceFirst('KindModule', 'KindWorkspace')},',
    );
  }
  buffer.writeln('};');
  buffer.writeln();
  _renderContributorMap(
    buffer,
    descriptors: descriptors,
    name: 'collectarrKindCalendarContributors',
    type: 'LibraryCalendarContributor',
    field: (descriptor) => descriptor.calendarContributor,
  );
  _renderContributorMap(
    buffer,
    descriptors: descriptors,
    name: 'collectarrKindActivityContributors',
    type: 'LibraryActivityContributor',
    field: (descriptor) => descriptor.activityContributor,
  );
  _renderContributorMap(
    buffer,
    descriptors: descriptors,
    name: 'collectarrKindAdminContributors',
    type: 'LibraryAdminContributor',
    field: (descriptor) => descriptor.adminContributor,
  );
  _renderContributorMap(
    buffer,
    descriptors: descriptors,
    name: 'collectarrKindBarcodeResolvers',
    type: 'LibraryBarcodeResolver',
    field: (descriptor) => descriptor.barcodeResolver,
  );
  _renderContributorMap(
    buffer,
    descriptors: descriptors,
    name: 'collectarrKindCollectionCsvProjections',
    type: 'LibraryCollectionCsvProjection',
    field: (descriptor) => descriptor.collectionCsvProjection,
  );
  _renderContributorMap(
    buffer,
    descriptors: descriptors,
    name: 'collectarrKindShelfExtensions',
    type: 'LibraryShelfExtensionContributor',
    field: (descriptor) => descriptor.shelfExtension,
  );
  _renderContributorMap(
    buffer,
    descriptors: descriptors,
    name: 'collectarrKindExportPreviewContributors',
    type: 'LibraryExportPreviewContributor',
    field: (descriptor) => descriptor.exportPreviewContributor,
  );
  _renderRouteContributors(buffer, descriptors);
  _renderCatalogKindLookups(buffer, descriptors);
  _renderCodecList(
    buffer,
    descriptors: descriptors,
    name: 'collectarrTrackingEntryCodecs',
    type: 'TrackingEntryCodec',
    field: (descriptor) => descriptor.trackingEntryCodec,
  );
  _renderCodecList(
    buffer,
    descriptors: descriptors,
    name: 'collectarrTrackingUnitCodecs',
    type: 'TrackingUnitCodec',
    field: (descriptor) => descriptor.trackingUnitCodec,
  );
  _renderCodecList(
    buffer,
    descriptors: descriptors,
    name: 'collectarrWatchSessionCodecs',
    type: 'WatchSessionCodec',
    field: (descriptor) => descriptor.watchSessionCodec,
  );
  _renderCodecList(
    buffer,
    descriptors: descriptors,
    name: 'collectarrCustomEpisodeCodecs',
    type: 'CustomEpisodeCodec',
    field: (descriptor) => descriptor.customEpisodeCodec,
  );
  _renderContributorMap(
    buffer,
    descriptors: descriptors,
    name: 'collectarrKindProviderMappers',
    type: 'LibraryKindProviderMapper',
    field: (descriptor) => descriptor.providerMapper,
  );
  _renderContributorMap(
    buffer,
    descriptors: descriptors,
    name: 'collectarrKindOwnedDetailsCodecs',
    type: 'OwnedDetailsPersistenceCodec',
    field: (descriptor) => descriptor.ownedDetailsCodec,
  );
  _renderFacetMap(buffer, descriptors);
  _renderMetadataDecoderMap(buffer, descriptors);
  _renderOwnedPersistenceMaps(buffer, descriptors);
  _renderCatalogRepositoryCodecs(buffer, descriptors);
  _renderSerialAuthorityContributors(buffer, descriptors);
  _renderPickListContributors(buffer, descriptors);
  buffer.writeln();
  buffer
      .writeln('LibraryKindModule? lookupLibraryKind(CatalogMediaKind kind) {');
  buffer.writeln('  for (final module in collectarrKindModules) {');
  buffer.writeln('    if (module.kind == kind) return module;');
  buffer.writeln('  }');
  buffer.writeln('  return null;');
  buffer.writeln('}');
  buffer.writeln();
  buffer.writeln('LibraryKindModule libraryKindFor(CatalogMediaKind kind) {');
  buffer.writeln('  final module = lookupLibraryKind(kind);');
  buffer.writeln('  if (module != null) return module;');
  buffer.writeln(
    "  throw ArgumentError('No LibraryKindModule registered for kind \"\$kind\"');",
  );
  buffer.writeln('}');
  buffer.writeln();
  buffer.writeln(
    'final List<LibraryKindRegistration> collectarrKindRegistrations = [',
  );
  for (final descriptor in descriptors) {
    buffer.writeln('  ${_registrationClassName(descriptor)}(),');
  }
  buffer.writeln('];');
  buffer.writeln();
  for (final descriptor in descriptors) {
    _renderRegistrationClass(buffer, descriptor);
  }
  buffer.writeln(
    'LibraryKindRegistration libraryKindRegistrationForKind(CatalogMediaKind kind) {',
  );
  buffer.writeln('  for (final registration in collectarrKindRegistrations) {');
  buffer.writeln('    if (registration.kind == kind) return registration;');
  buffer.writeln('  }');
  buffer.writeln('  throw ArgumentError(');
  buffer.writeln(
    "    'No LibraryKindRegistration registered for kind \"\$kind\"',",
  );
  buffer.writeln('  );');
  buffer.writeln('}');
  return buffer.toString();
}

String _renderDatabaseTables(List<_KindDescriptor> descriptors) {
  final buffer = StringBuffer('''// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run tool/generate_kind_registries.dart

''');
  final files = <String>{};
  for (final descriptor in descriptors) {
    final localTables = descriptor.localTables;
    if (localTables == null) continue;
    for (final file in localTables.files) {
      if (files.add(file.importPath)) {
        buffer.writeln(
          "import 'package:collectarr_app/${file.importPath}';",
        );
        buffer.writeln(
          "export 'package:collectarr_app/${file.importPath}';",
        );
      }
    }
  }
  buffer.writeln();
  buffer.writeln('const List<Type> collectarrKindTableTypes = <Type>[');
  for (final descriptor in descriptors) {
    final localTables = descriptor.localTables;
    if (localTables == null) continue;
    for (final file in localTables.files) {
      for (final tableName in file.tableNames) {
        buffer.writeln('  $tableName,');
      }
    }
  }
  buffer.writeln('];');
  return buffer.toString();
}

String _renderOwnedDetailsExports(List<_KindDescriptor> descriptors) {
  final buffer = StringBuffer('''// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run tool/generate_kind_registries.dart

''');
  for (final descriptor in descriptors) {
    for (final importPath in descriptor.ownedDetailsExports) {
      buffer.writeln("export 'package:collectarr_app/$importPath';");
    }
  }
  return buffer.toString();
}

String _registrationClassName(_KindDescriptor descriptor) {
  final name = descriptor.folder;
  return '${name[0].toUpperCase()}${name.substring(1)}Registration';
}

void _renderRegistrationClass(
  StringBuffer buffer,
  _KindDescriptor descriptor,
) {
  final className = _registrationClassName(descriptor);
  buffer.writeln('final class $className implements LibraryKindRegistration {');
  buffer.writeln('  const $className();');
  buffer.writeln();
  buffer.writeln('  @override');
  buffer.writeln(
    '  CatalogMediaKind get kind => CatalogMediaKind.${descriptor.folder};',
  );
  buffer.writeln();
  buffer.writeln('  @override');
  buffer.writeln(
    '  LibraryKindIdentity get identity => ${descriptor.moduleName}.identity;',
  );
  buffer.writeln();
  buffer.writeln('  @override');
  buffer.writeln('  Widget buildLibraryPage({');
  buffer.writeln('    required Widget topBar,');
  buffer.writeln('    required Color accent,');
  buffer.writeln('    required Uri routeUri,');
  buffer.writeln('    LibraryLayoutSnapshot? switchLayoutSnapshot,');
  buffer.writeln('  }) {');
  buffer.writeln('    return ${descriptor.pageClass}(');
  buffer.writeln('      type: ${descriptor.moduleName},');
  buffer.writeln('      topBar: topBar,');
  buffer.writeln('      accent: accent,');
  buffer.writeln('      routeUri: routeUri,');
  buffer.writeln('      switchLayoutSnapshot: switchLayoutSnapshot,');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();
  buffer.writeln('  @override');
  buffer.writeln('  Widget buildAdd({');
  buffer.writeln('    required BuildContext context,');
  buffer.writeln('    required LibraryAddDialogRequest request,');
  buffer.writeln('  }) {');
  buffer.writeln('    return LibraryAddDialog(');
  buffer.writeln('      type: ${descriptor.moduleName},');
  buffer.writeln('      accent: request.accent,');
  buffer.writeln('      initialQuery: request.initialQuery,');
  buffer.writeln('      initialBarcode: request.initialBarcode,');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();
  for (final scope in const [
    ('openMediaEdit', 'media'),
    ('openReleaseEdit', 'release'),
    ('openOwnedEdit', 'all'),
  ]) {
    buffer.writeln('  @override');
    buffer.writeln(
      '  Future<LibraryEditSelection?> ${scope.$1}({',
    );
    buffer.writeln('    required BuildContext context,');
    buffer.writeln('    required LibraryEditDialogRequest request,');
    buffer.writeln('  }) {');
    buffer.writeln('    return _openEdit(');
    buffer.writeln('      context: context,');
    buffer.writeln('      request: request,');
    buffer.writeln('      scope: LibraryEditScope.${scope.$2},');
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();
  }
  buffer.writeln('  Future<LibraryEditSelection?> _openEdit({');
  buffer.writeln('    required BuildContext context,');
  buffer.writeln('    required LibraryEditDialogRequest request,');
  buffer.writeln('    required LibraryEditScope scope,');
  buffer.writeln('  }) {');
  buffer.writeln('    return showLibraryEditDialog(');
  buffer.writeln('      context: context,');
  buffer.writeln('      request: request.copyWith(scope: scope),');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln('}');
  buffer.writeln();
}

void _renderContributorMap(
  StringBuffer buffer, {
  required List<_KindDescriptor> descriptors,
  required String name,
  required String type,
  required _Contributor? Function(_KindDescriptor) field,
}) {
  buffer.writeln('final $name = <CatalogMediaKind, $type>{');
  for (final descriptor in descriptors) {
    final contributor = field(descriptor);
    if (contributor == null) continue;
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: const ${contributor.className}(),',
    );
  }
  buffer.writeln('};');
  buffer.writeln();
}

void _renderCodecList(
  StringBuffer buffer, {
  required List<_KindDescriptor> descriptors,
  required String name,
  required String type,
  required _Contributor? Function(_KindDescriptor) field,
}) {
  buffer.writeln('const List<$type> $name = [');
  for (final descriptor in descriptors) {
    final contributor = field(descriptor);
    if (contributor == null) continue;
    buffer.writeln('  ${contributor.className}(),');
  }
  buffer.writeln('];');
  buffer.writeln();
}

void _renderFacetMap(
  StringBuffer buffer,
  List<_KindDescriptor> descriptors,
) {
  buffer.writeln(
    'final collectarrKindFacetModules = <CatalogMediaKind, LibraryFacetModule>{',
  );
  for (final descriptor in descriptors) {
    final variable = descriptor.facetModule;
    if (variable == null) continue;
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: $variable,',
    );
  }
  buffer.writeln('};');
}

void _renderMetadataDecoderMap(
  StringBuffer buffer,
  List<_KindDescriptor> descriptors,
) {
  buffer.writeln(
    'final collectarrKindMetadataDecoders = <CatalogMediaKind, Object? Function(Map<String, dynamic>)>{',
  );
  for (final descriptor in descriptors) {
    final decoder = descriptor.metadataDecoder;
    if (decoder == null) continue;
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: ${decoder.expression},',
    );
  }
  buffer.writeln('};');
}

void _renderOwnedPersistenceMaps(
  StringBuffer buffer,
  List<_KindDescriptor> descriptors,
) {
  buffer.writeln(
    'final collectarrTypedOwnedItemPersisters = '
    '<CatalogMediaKind, Future<void> Function(LocalDatabase, Object)>{',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final ownedModel = persistence.ownedModel.className;
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: (database, item) => '
      '$repository(database).upsert(item as $ownedModel),',
    );
  }
  buffer.writeln('};');
  buffer.writeln();

  buffer.writeln(
    'final collectarrOwnedItemPersisters = '
    '<CatalogMediaKind, Future<void> Function(LocalDatabase, OwnedItem)>{',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final projection = persistence.projection.className;
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: (database, item) => '
      '$repository(database).upsert($projection.fromOwnedItem(item)),',
    );
  }
  buffer.writeln('};');
  buffer.writeln();

  buffer.writeln(
    'final collectarrTypedOwnedLocationUpdaters = '
    '<CatalogMediaKind, Future<void> Function(LocalDatabase, String, String?)>{',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final ownedId = persistence.ownedId.className;
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: '
      '(database, id, locationId) async {',
    );
    buffer.writeln(
      '    final item = await $repository(database).findById($ownedId(id));',
    );
    buffer.writeln('    if (item == null) return;');
    buffer.writeln(
      '    await $repository(database).upsert('
      'item.copyWith(locationId: locationId));',
    );
    buffer.writeln('  },');
  }
  buffer.writeln('};');
  buffer.writeln();

  buffer.writeln(
    'final collectarrTypedOwnedItemFinders = '
    '<CatalogMediaKind, Future<Object?> Function(LocalDatabase, String)>{',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final ownedId = persistence.ownedId.className;
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: (database, id) => '
      '$repository(database).findById($ownedId(id)),',
    );
  }
  buffer.writeln('};');
  buffer.writeln();

  buffer.writeln(
    'final collectarrTypedOwnedItemDeleters = '
    '<CatalogMediaKind, Future<void> Function(LocalDatabase, Object, DateTime)>{',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final ownedModel = persistence.ownedModel.className;
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: (database, item, deletedAt) => '
      '$repository(database).markDeleted(item as $ownedModel, deletedAt),',
    );
  }
  buffer.writeln('};');
  buffer.writeln();

  buffer.writeln(
    'Future<(CatalogMediaKind kind, Object item)?> '
    'collectarrFindTypedOwnedItem(LocalDatabase database, String id) async {',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final ownedId = persistence.ownedId.className;
    buffer.writeln(
      '  final ${descriptor.folder}Item = await $repository(database)'
      '.findById($ownedId(id));',
    );
    buffer.writeln(
      '  if (${descriptor.folder}Item != null) return '
      '(CatalogMediaKind.${descriptor.folder}, ${descriptor.folder}Item);',
    );
  }
  buffer.writeln('  return null;');
  buffer.writeln('}');
  buffer.writeln();

  buffer.writeln(
    'final collectarrTypedOwnedItemSyncSerializers = '
    '<CatalogMediaKind, '
    '({Map<String, dynamic> payload, bool isDeleted}) Function(Object)>{',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final ownedModel = persistence.ownedModel.className;
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: (item) {',
    );
    buffer.writeln(
      '    final payload = Map<String, dynamic>.from('
      '(item as $ownedModel).toJson());',
    );
    buffer.writeln("    final isDeleted = payload['deleted_at'] != null;");
    buffer.writeln("    payload.remove('id');");
    buffer.writeln("    payload.remove('updated_at');");
    buffer.writeln("    payload.remove('deleted_at');");
    buffer.writeln("    payload.remove('reading');");
    buffer.writeln('    return (payload: payload, isDeleted: isDeleted);');
    buffer.writeln('  },');
  }
  buffer.writeln('};');
  buffer.writeln();

  buffer.writeln(
    'final collectarrOwnedItemSerializers = '
    '<CatalogMediaKind, OwnedItem Function(Object)>{',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final projection = persistence.projection.className;
    final ownedModel = persistence.ownedModel.className;
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: (item) => '
      '$projection.toOwnedItem(item as $ownedModel),',
    );
  }
  buffer.writeln('};');
  buffer.writeln();

  buffer.writeln(
    'final collectarrOwnedItemDeserializers = '
    '<CatalogMediaKind, Object Function(OwnedItem)>{',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final projection = persistence.projection.className;
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: '
      '$projection.fromOwnedItem,',
    );
  }
  buffer.writeln('};');
  buffer.writeln();

  buffer.writeln(
    'final collectarrOwnedItemReaders = '
    '<CatalogMediaKind, Future<List<OwnedItem>> Function(LocalDatabase)>{',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final projection = persistence.projection.className;
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: (database) async => '
      '(await $repository(database).listActive())'
      '.map($projection.toOwnedItem).toList(growable: false),',
    );
  }
  buffer.writeln('};');
  buffer.writeln();

  buffer.writeln(
    'final collectarrOwnedItemSummaryReaders = '
    '<CatalogMediaKind, Future<List<OwnedItemSummary>> Function(LocalDatabase)>{',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final projection = persistence.projection.className;
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: (database) async => '
      '(await $repository(database).listActive())'
      '.map($projection.toSummary).toList(growable: false),',
    );
  }
  buffer.writeln('};');
  buffer.writeln();

  buffer.writeln(
    'final collectarrOwnedItemFinders = '
    '<CatalogMediaKind, Future<OwnedItem?> Function(LocalDatabase, String)>{',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final projection = persistence.projection.className;
    final ownedId = persistence.ownedId.className;
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: (database, id) async => '
      '_collectarrOwnedToCommon('
      'await $repository(database).findById($ownedId(id)), '
      '$projection.toOwnedItem),',
    );
  }
  buffer.writeln('};');
  buffer.writeln();

  buffer.writeln(
    'final collectarrOwnedItemDeleters = '
    '<CatalogMediaKind, Future<void> Function(LocalDatabase, OwnedItem, DateTime)>{',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final projection = persistence.projection.className;
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: (database, item, deletedAt) => '
      '$repository(database).markDeleted('
      '$projection.fromOwnedItem(item), deletedAt),',
    );
  }
  buffer.writeln('};');
  buffer.writeln();
  buffer.writeln('OwnedItem? _collectarrOwnedToCommon<T>(');
  buffer.writeln('  T? item,');
  buffer.writeln('  OwnedItem Function(T item) project,');
  buffer.writeln(') {');
  buffer.writeln('  return item == null ? null : project(item);');
  buffer.writeln('}');
}

void _renderCatalogRepositoryCodecs(
  StringBuffer buffer,
  List<_KindDescriptor> descriptors,
) {
  buffer.writeln(
    'const List<CatalogKindRepositoryCodec> '
    'collectarrKindCatalogRepositoryCodecs = [',
  );
  for (final descriptor in descriptors) {
    final codec = descriptor.catalogRepositoryCodec;
    if (codec == null) continue;
    buffer.writeln('  ${codec.className}(),');
  }
  buffer.writeln('];');
}

void _renderCatalogKindLookups(
  StringBuffer buffer,
  List<_KindDescriptor> descriptors,
) {
  buffer.writeln(
    'List<CatalogKindLookup> collectarrCatalogKindLookups(LocalDatabase db) => [',
  );
  for (final descriptor in descriptors) {
    final lookup = descriptor.catalogLookup;
    if (lookup == null) continue;
    buffer.writeln('  ${lookup.className}(db),');
  }
  buffer.writeln('];');
  buffer.writeln();
}

void _renderRouteContributors(
  StringBuffer buffer,
  List<_KindDescriptor> descriptors,
) {
  buffer.writeln('final List<GoRoute> collectarrKindRoutes = [');
  for (final descriptor in descriptors) {
    final contributor = descriptor.routeContributor;
    if (contributor == null) continue;
    buffer.writeln('  ${contributor.className}().build(),');
  }
  buffer.writeln('];');
  buffer.writeln();
}

void _renderSerialAuthorityContributors(
  StringBuffer buffer,
  List<_KindDescriptor> descriptors,
) {
  buffer.writeln(
    'const List<SerialAuthorityContributor> '
    'collectarrKindSerialAuthorityContributors = [',
  );
  for (final descriptor in descriptors) {
    final contributor = descriptor.serialAuthorityContributor;
    if (contributor == null) continue;
    buffer.writeln('  ${contributor.className}(),');
  }
  buffer.writeln('];');
  buffer.writeln();
}

void _renderPickListContributors(
  StringBuffer buffer,
  List<_KindDescriptor> descriptors,
) {
  buffer.writeln(
    'const List<PickListDefinitionContributor> '
    'collectarrKindPickListDefinitionContributors = [',
  );
  for (final descriptor in descriptors) {
    final vocabulary = descriptor.vocabularyModule;
    if (vocabulary == null) continue;
    buffer.writeln(
      '  VocabularyPickListDefinitionContributor('
      'kind: CatalogMediaKind.${descriptor.folder}, '
      'vocabularies: ${vocabulary.className}.all, '
      'ownedValueCounter: ${vocabulary.className}.countOwnedValue, '
      'ownedMergePreviewer: ${vocabulary.className}.previewOwnedMerge, '
      'ownedMerger: ${vocabulary.className}.applyOwnedMerge),',
    );
  }
  buffer.writeln('];');
}

final class _KindDescriptor {
  const _KindDescriptor({
    required this.folder,
    required this.moduleName,
    required this.pageClass,
    this.calendarContributor,
    this.activityContributor,
    this.adminContributor,
    this.barcodeResolver,
    this.collectionCsvProjection,
    this.shelfExtension,
    this.exportPreviewContributor,
    this.catalogLookup,
    this.routeContributor,
    this.trackingEntryCodec,
    this.trackingUnitCodec,
    this.watchSessionCodec,
    this.customEpisodeCodec,
    this.providerMapper,
    this.ownedDetailsCodec,
    this.metadataDecoder,
    this.facetModule,
    this.ownedPersistence,
    this.catalogRepositoryCodec,
    this.serialAuthorityContributor,
    this.vocabularyModule,
    this.localTables,
    this.ownedDetailsExports = const [],
  });

  final String folder;
  final String moduleName;
  final String pageClass;
  final _Contributor? calendarContributor;
  final _Contributor? activityContributor;
  final _Contributor? adminContributor;
  final _Contributor? barcodeResolver;
  final _Contributor? collectionCsvProjection;
  final _Contributor? shelfExtension;
  final _Contributor? exportPreviewContributor;
  final _Contributor? catalogLookup;
  final _Contributor? routeContributor;
  final _Contributor? trackingEntryCodec;
  final _Contributor? trackingUnitCodec;
  final _Contributor? watchSessionCodec;
  final _Contributor? customEpisodeCodec;
  final _Contributor? providerMapper;
  final _Contributor? ownedDetailsCodec;
  final _MetadataDecoder? metadataDecoder;
  final String? facetModule;
  final _OwnedPersistence? ownedPersistence;
  final _Contributor? catalogRepositoryCodec;
  final _Contributor? serialAuthorityContributor;
  final _VocabularyModule? vocabularyModule;
  final _KindLocalTables? localTables;
  final List<String> ownedDetailsExports;

  Iterable<_Contributor> get contributors sync* {
    for (final contributor in [
      calendarContributor,
      activityContributor,
      adminContributor,
      barcodeResolver,
      collectionCsvProjection,
      shelfExtension,
      exportPreviewContributor,
      catalogLookup,
      routeContributor,
      trackingEntryCodec,
      trackingUnitCodec,
      watchSessionCodec,
      customEpisodeCodec,
      providerMapper,
      ownedDetailsCodec,
    ]) {
      if (contributor != null) yield contributor;
    }
  }
}

final class _Contributor {
  const _Contributor({required this.importPath, required this.className});

  final String importPath;
  final String className;
}

final class _MetadataDecoder {
  const _MetadataDecoder({required this.importPath, required this.expression});

  final String importPath;
  final String expression;
}

final class _OwnedPersistence {
  const _OwnedPersistence({
    required this.repository,
    required this.projection,
    required this.ownedId,
    required this.ownedModel,
  });

  final _Contributor repository;
  final _Contributor projection;
  final _Contributor ownedId;
  final _Contributor ownedModel;
}

final class _VocabularyModule {
  const _VocabularyModule({required this.importPath, required this.className});

  final String importPath;
  final String className;
}

final class _KindLocalTables {
  const _KindLocalTables({required this.kind, required this.files});

  final String kind;
  final List<_LocalTableFile> files;
}

final class _LocalTableFile {
  const _LocalTableFile({required this.importPath, required this.tableNames});

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
}

String _packageImportPath(File file) {
  final normalized = file.path.replaceAll('\\', '/');
  final marker = '/lib/';
  final markerIndex = normalized.lastIndexOf(marker);
  if (markerIndex >= 0) {
    return normalized.substring(markerIndex + marker.length);
  }
  if (normalized.startsWith('lib/')) {
    return normalized.substring('lib/'.length);
  }
  throw StateError('Expected a file under lib/: ${file.path}');
}
