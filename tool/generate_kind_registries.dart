import 'dart:io';

const _kindsRoot = 'lib/features/library/kinds';
const _registryOutput =
    'lib/features/library/kinds/registry/collectarr_kind_registry.g.dart';
const _databaseTablesOutput =
    'lib/features/library/kinds/registry/collectarr_kind_database_tables.g.dart';
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
  final devSeedDescriptors = await _discoverDevSeeds();
  if (devSeedDescriptors.isEmpty) {
    throw StateError('No dev seed contributors found under $_devSeedRoot');
  }
  await File(_devSeedRegistryOutput)
      .writeAsString(_renderDevSeedRegistry(devSeedDescriptors));

  await _formatGeneratedFile(_registryOutput);
  await _formatGeneratedFile(_databaseTablesOutput);
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
      r'(?:const|final)\s+(\w+DevSeedContributor)\s*=\s*'
      r'TypedDevSeedKindContributor<(\w+)>',
    ).firstMatch(source);
    if (contributorMatch == null) {
      throw StateError(
        'Dev seed ${entity.path} must declare a '
        'TypedDevSeedKindContributor<TOwned>',
      );
    }
    descriptors.add(
      _DevSeedDescriptor(
        importPath: _packageImportPath(entity),
        contributorName: contributorMatch.group(1)!,
        ownedType: contributorMatch.group(2)!,
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
    final localTables = _discoverLocalTables(entity);

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
        trackingLifecycleCodec: _discoverContributor(
          entity,
          'tracking',
          '${folder}_tracking_lifecycle_codec.dart',
          'TrackingLifecycleCodec',
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
          'TypedLibraryKindProviderMapper',
        ),
        facetModule: facetModule,
        ownedPersistence: _discoverOwnedPersistence(entity),
        catalogRepositoryCodec: _discoverContributor(
          entity,
          'data',
          '${folder}_catalog_transport_codec.dart',
          'CatalogKindTransportCodec',
        ),
        serialAuthorityContributor: _discoverContributor(
          entity,
          'integrations/serial',
          '${folder}_serial_authority_contributor.dart',
          'SerialAuthorityContributor',
        ),
        vocabularyModule: _discoverVocabularyModule(entity),
        localTables: localTables,
      ),
    );
  }
  descriptors.sort((left, right) => left.folder.compareTo(right.folder));
  return descriptors;
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
  final createPayloadFile = File(
    '${kindDirectory.path}/ownership/${folder}_owned_item_create_payload.dart',
  );
  final updatePayloadFile = File(
    '${kindDirectory.path}/ownership/${folder}_owned_item_update_payload.dart',
  );
  if (!repositoryFile.existsSync() ||
      !projectionFile.existsSync() ||
      !ownedModelFile.existsSync() ||
      !idsFile.existsSync() ||
      !createPayloadFile.existsSync() ||
      !updatePayloadFile.existsSync()) {
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
  final createPayloadClass = _findClass(
    createPayloadFile,
    RegExp(r'(?:final\s+class|class)\s+(\w+OwnedItemCreatePayload)'),
  );
  final updatePayloadClass = _findClass(
    updatePayloadFile,
    RegExp(r'(?:final\s+class|class)\s+(\w+OwnedItemUpdatePayload)'),
  );
  if (repositoryClass == null ||
      projectionClass == null ||
      ownedIdClass == null ||
      ownedModelClass == null ||
      createPayloadClass == null ||
      updatePayloadClass == null) {
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
    createPayload: _Contributor(
      importPath: _packageImportPath(createPayloadFile),
      className: createPayloadClass,
    ),
    updatePayload: _Contributor(
      importPath: _packageImportPath(updatePayloadFile),
      className: updatePayloadClass,
    ),
  );
}

String? _findClass(File file, RegExp pattern) {
  return pattern.firstMatch(file.readAsStringSync())?.group(1);
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
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/config/owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/config/owned_item_mutation_result.dart';
import 'package:collectarr_app/features/library/config/owned_item_update_payload.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_contributor.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation.dart';
import 'package:collectarr_app/features/library/config/library_metadata_capability.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/config/library_hierarchy_capability.dart';
import 'package:collectarr_app/features/library/config/library_inspector_capability.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/library_transfer_capability.dart';
import 'package:collectarr_app/features/library/config/library_stats_capability.dart';
import 'package:collectarr_app/features/library/config/library_value_capability.dart';
import 'package:collectarr_app/features/library/config/library_relation_capability.dart';
import 'package:collectarr_app/features/library/config/library_ui_policy.dart';
import 'package:collectarr_app/features/library/config/library_linked_metadata_capability.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/workspace/config/library_projection_capability.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/config/library_kind_toolbar_module.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
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
      persistence.createPayload,
      persistence.updatePayload,
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
    "import 'package:collectarr_app/features/library/tracking/tracking_lifecycle_codec.dart';",
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
  buffer.writeln();
  buffer.writeln('final List<LibraryKindModule> collectarrKindModules = [');
  for (final descriptor in descriptors) {
    buffer.writeln('  ${descriptor.moduleName},');
  }
  buffer.writeln('];');
  buffer.writeln();
  buffer.writeln(
    'final Map<CatalogMediaKind, LibraryKindModule> '
    'collectarrKindModulesByKind = Map.unmodifiable({',
  );
  for (final descriptor in descriptors) {
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: ${descriptor.moduleName},',
    );
  }
  buffer.writeln('});');
  buffer.writeln();
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindPhysicalMediaFormats',
    field: 'physicalMediaFormats',
  );
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindPresentations',
    field: 'presentation',
  );
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindMetadata',
    field: 'metadata',
  );
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindTrackingProfiles',
    field: 'trackingProfile',
  );
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindHierarchies',
    field: 'hierarchy',
  );
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindInspectors',
    field: 'inspector',
  );
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindEdits',
    field: 'edit',
  );
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindTransfers',
    field: 'transfer',
  );
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindStats',
    field: 'stats',
  );
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindValues',
    field: 'value',
  );
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindRelations',
    field: 'relations',
  );
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindUiPolicies',
    field: 'uiPolicy',
  );
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindLinkedMetadata',
    field: 'linkedMetadata',
  );
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindAdds',
    field: 'add',
  );
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindTitleCapabilities',
    field: 'titleCapability',
  );
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindReleaseCapabilities',
    field: 'releaseCapability',
  );
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindToolbars',
    field: 'toolbar',
  );
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindSearchTargetOptions',
    field: 'searchTargetOptions',
  );
  _renderModuleCapabilityMap(
    buffer,
    descriptors,
    name: 'collectarrKindViewProfiles',
    field: 'viewProfile',
  );
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
    name: 'collectarrTrackingLifecycleCodecs',
    type: 'TrackingLifecycleCodec',
    field: (descriptor) => descriptor.trackingLifecycleCodec,
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
  _renderProviderMetadataMapperMap(buffer, descriptors);
  _renderProviderCorrectionBuilderMap(buffer, descriptors);
  _renderFacetMap(buffer, descriptors);
  _renderOwnedPersistenceMaps(buffer, descriptors);
  _renderCatalogTransportCodecs(buffer, descriptors);
  _renderSerialAuthorityContributors(buffer, descriptors);
  _renderPickListContributors(buffer, descriptors);
  buffer.writeln();
  buffer.writeln(
    'final Map<CatalogMediaKind, LibraryKindRegistration> '
    'collectarrKindRegistrations = Map.unmodifiable({',
  );
  for (final descriptor in descriptors) {
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: '
      '${_registrationClassName(descriptor)}(),',
    );
  }
  buffer.writeln('});');
  buffer.writeln();
  for (final descriptor in descriptors) {
    _renderRegistrationClass(buffer, descriptor);
  }
  buffer.writeln(
    'LibraryKindRegistration libraryKindRegistrationForKind(CatalogMediaKind kind) {',
  );
  buffer.writeln('  final registration = collectarrKindRegistrations[kind];');
  buffer.writeln('  if (registration != null) return registration;');
  buffer.writeln('  throw ArgumentError(');
  buffer.writeln(
    "    'No LibraryKindRegistration registered for kind \"\$kind\"',",
  );
  buffer.writeln('  );');
  buffer.writeln('}');
  return buffer.toString();
}

void _renderModuleCapabilityMap(
  StringBuffer buffer,
  List<_KindDescriptor> descriptors, {
  required String name,
  required String field,
}) {
  final type = switch (field) {
    'physicalMediaFormats' => 'List<PhysicalMediaFormat>',
    'presentation' => 'LibraryMediaPresentation',
    'metadata' => 'LibraryMetadataCapability',
    'trackingProfile' => 'MediaTrackingProfile',
    'hierarchy' => 'LibraryHierarchyCapability',
    'inspector' => 'LibraryInspectorCapability',
    'edit' => 'LibraryEditCapability',
    'transfer' => 'LibraryTransferCapability',
    'stats' => 'LibraryStatsCapability',
    'value' => 'LibraryValueCapability?',
    'relations' => 'LibraryRelationCapability?',
    'uiPolicy' => 'LibraryUiPolicy',
    'linkedMetadata' => 'LibraryLinkedMetadataCapability',
    'add' => 'LibraryAddCapability',
    'titleCapability' => 'TitleProjectionCapability<LibraryWorkspaceDto>',
    'releaseCapability' => 'ReleaseProjectionCapability<LibraryWorkspaceDto>?',
    'toolbar' => 'LibraryKindToolbarModule?',
    'searchTargetOptions' => 'List<LibrarySearchTarget>',
    'viewProfile' => 'LibraryWorkspaceViewProfile',
    _ => throw StateError('Unknown module capability field: $field'),
  };
  buffer.writeln(
    'final Map<CatalogMediaKind, $type> $name = '
    'Map.unmodifiable(<CatalogMediaKind, $type>{',
  );
  for (final descriptor in descriptors) {
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: '
      '${descriptor.moduleName}.$field,',
    );
  }
  buffer.writeln('});');
  buffer.writeln();
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
  buffer.writeln('      initialIdentifier: request.initialIdentifier,');
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

void _renderProviderMetadataMapperMap(
  StringBuffer buffer,
  List<_KindDescriptor> descriptors,
) {
  buffer.writeln(
    'final collectarrKindProviderMetadataMappers = '
    '<CatalogMediaKind, ProviderMetadataCandidateMapper>{',
  );
  for (final descriptor in descriptors) {
    final contributor = descriptor.providerMapper;
    if (contributor == null) continue;
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: '
      'const ${contributor.className}().catalogCandidateFromEnvelope,',
    );
  }
  buffer.writeln('};');
  buffer.writeln();
}

void _renderProviderCorrectionBuilderMap(
  StringBuffer buffer,
  List<_KindDescriptor> descriptors,
) {
  buffer.writeln(
    'final collectarrKindProviderCorrectionBuilders = '
    '<CatalogMediaKind, ProviderCorrectionBuilder>{',
  );
  for (final descriptor in descriptors) {
    final contributor = descriptor.providerMapper;
    if (contributor == null) continue;
    buffer.writeln(
      '  CatalogMediaKind.${descriptor.folder}: '
      'const ${contributor.className}().buildCorrections,',
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

void _renderOwnedPersistenceMaps(
  StringBuffer buffer,
  List<_KindDescriptor> descriptors,
) {
  buffer.writeln(
    'Future<OwnedItemMutationResult> collectarrCreateOwnedItem('
    'LocalDatabase database, CatalogMediaKind kind, '
    'OwnedItemCreatePayload payload, {',
  );
  buffer.writeln('  required CatalogEntityRef resolvedCatalogRef,');
  buffer.writeln('  required String id,');
  buffer.writeln('  required DateTime createdAt,');
  buffer.writeln('  required bool? existingIsDigital,');
  buffer.writeln('  required String? ownerUserId,');
  buffer.writeln('  required String? ownerLabel,');
  buffer.writeln('}) async {');
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final createPayload = persistence.createPayload.className;
    buffer.writeln(
      '  if (kind == CatalogMediaKind.${descriptor.folder}) {',
    );
    buffer.writeln(
      '    if (payload is! $createPayload) throw ArgumentError.value('
      "payload, 'payload', 'Expected $createPayload for ${descriptor.folder}');",
    );
    buffer.writeln(
      '    final item = payload.toOwnedItem('
      'resolvedCatalogRef: resolvedCatalogRef, id: id, createdAt: createdAt, '
      'existingIsDigital: existingIsDigital, ownerUserId: ownerUserId, '
      'ownerLabel: ownerLabel);',
    );
    buffer.writeln('    await $repository(database).upsert(item);');
    buffer.writeln(
      '    final serialized = collectarrTypedOwnedItemSyncPayload('
      'CatalogMediaKind.${descriptor.folder}, item);',
    );
    buffer.writeln(
      '    return OwnedItemMutationResult('
      'ref: OwnedItemRef(kind: CatalogMediaKind.${descriptor.folder}, '
      'id: OwnedItemId(item.id.value)), '
      'syncPayload: serialized.payload, isDeleted: serialized.isDeleted);',
    );
    buffer.writeln('  }');
  }
  buffer.writeln(
    "  throw ArgumentError.value(kind, 'kind', 'Unsupported owned kind');",
  );
  buffer.writeln('}');
  buffer.writeln();

  buffer.writeln(
    'Future<OwnedItemMutationResult> collectarrUpdateOwnedItem('
    'LocalDatabase database, OwnedItemRef ref, '
    'OwnedItemUpdatePayload payload, {',
  );
  buffer.writeln('  required DateTime updatedAt,');
  buffer.writeln('  required String? fallbackOwnerUserId,');
  buffer.writeln('  required String? fallbackOwnerLabel,');
  buffer.writeln('}) async {');
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final ownedId = persistence.ownedId.className;
    final updatePayload = persistence.updatePayload.className;
    buffer.writeln(
      '  if (ref.kind == CatalogMediaKind.${descriptor.folder}) {',
    );
    buffer.writeln(
      '    final existing = await $repository(database).findById('
      '$ownedId(ref.id.value));',
    );
    buffer.writeln(
      "    if (existing == null) throw StateError('Owned item not found');",
    );
    buffer.writeln(
      '    if (payload is! $updatePayload) throw ArgumentError.value('
      "payload, 'payload', 'Expected $updatePayload for ${descriptor.folder}');",
    );
    buffer.writeln(
      "    if (!payload.canApplyTo(existing)) throw StateError('Owned update "
      "payload does not belong to ${descriptor.folder}');",
    );
    buffer.writeln(
      '    final updated = payload.applyTo(existing, updatedAt: updatedAt, '
      'fallbackOwnerUserId: fallbackOwnerUserId, '
      'fallbackOwnerLabel: fallbackOwnerLabel);',
    );
    buffer.writeln('    await $repository(database).upsert(updated);');
    buffer.writeln(
      '    final serialized = collectarrTypedOwnedItemSyncPayload('
      'CatalogMediaKind.${descriptor.folder}, updated);',
    );
    buffer.writeln(
      '    return OwnedItemMutationResult('
      'ref: OwnedItemRef(kind: CatalogMediaKind.${descriptor.folder}, '
      'id: OwnedItemId(updated.id.value)), '
      'syncPayload: serialized.payload, isDeleted: serialized.isDeleted);',
    );
    buffer.writeln('  }');
  }
  buffer.writeln(
    "  throw ArgumentError.value(ref.kind, 'ref', 'Unsupported owned kind');",
  );
  buffer.writeln('}');
  buffer.writeln();

  buffer.writeln(
    'Future<void> collectarrUpdateTypedOwnedLocation('
    'LocalDatabase database, CatalogMediaKind kind, String id, '
    'String? locationId) async {',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final ownedId = persistence.ownedId.className;
    buffer.writeln(
      '  if (kind == CatalogMediaKind.${descriptor.folder}) {',
    );
    buffer.writeln(
      '    final item = await $repository(database).findById($ownedId(id));',
    );
    buffer.writeln('    if (item == null) return;');
    buffer.writeln(
      '    await $repository(database).upsert('
      'item.copyWith(locationId: locationId));',
    );
    buffer.writeln('    return;');
    buffer.writeln('  }');
  }
  buffer.writeln(
    "  throw ArgumentError.value(kind, 'kind', 'Unsupported owned kind');",
  );
  buffer.writeln('}');
  buffer.writeln();

  buffer.writeln(
    'Future<LibraryOwnedItemDispatch?> '
    'collectarrOwnedItemForLibraryByRef('
    'LocalDatabase database, OwnedItemRef ref) async {',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final ownedId = persistence.ownedId.className;
    buffer.writeln(
      '  if (ref.kind == CatalogMediaKind.${descriptor.folder}) {',
    );
    buffer.writeln(
      '    final item = await $repository(database)'
      '.findById($ownedId(ref.id.value));',
    );
    buffer.writeln('    if (item == null) return null;');
    final dispatch = switch (descriptor.folder) {
      'anime' => 'AnimeOwnedItemDispatch',
      'boardgame' => 'BoardGameOwnedItemDispatch',
      'book' => 'BookOwnedItemDispatch',
      'comic' => 'ComicOwnedItemDispatch',
      'game' => 'GameOwnedItemDispatch',
      'manga' => 'MangaOwnedItemDispatch',
      'movie' => 'MovieOwnedItemDispatch',
      'music' => 'MusicOwnedItemDispatch',
      'tv' => 'TvOwnedItemDispatch',
      _ => throw StateError(
          'Unsupported owned dispatch kind ${descriptor.folder}'),
    };
    buffer.writeln(
      '    return $dispatch(ref: ref, value: item);',
    );
    buffer.writeln('  }');
  }
  buffer.writeln('  return null;');
  buffer.writeln('}');
  buffer.writeln();

  buffer.writeln(
    'Future<JsonMap?> collectarrOwnedItemJsonByRef('
    'LocalDatabase database, OwnedItemRef ref) async {',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final ownedId = persistence.ownedId.className;
    buffer.writeln(
      '  if (ref.kind == CatalogMediaKind.${descriptor.folder}) {',
    );
    buffer.writeln(
      '    final item = await $repository(database)'
      '.findById($ownedId(ref.id.value));',
    );
    buffer.writeln('    return item?.toJson();');
    buffer.writeln('  }');
  }
  buffer.writeln('  return null;');
  buffer.writeln('}');
  buffer.writeln();

  buffer.writeln(
    'Future<({JsonMap payload, bool isDeleted})?> '
    'collectarrOwnedItemSyncPayloadByRef('
    'LocalDatabase database, OwnedItemRef ref) async {',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final ownedId = persistence.ownedId.className;
    buffer.writeln(
      '  if (ref.kind == CatalogMediaKind.${descriptor.folder}) {',
    );
    buffer.writeln(
      '    final item = await $repository(database)'
      '.findById($ownedId(ref.id.value));',
    );
    buffer.writeln('    if (item == null) return null;');
    buffer.writeln(
      '    final serialized = collectarrTypedOwnedItemSyncPayload('
      'CatalogMediaKind.${descriptor.folder}, item);',
    );
    buffer.writeln(
      '    return (payload: serialized.payload, '
      'isDeleted: serialized.isDeleted);',
    );
    buffer.writeln('  }');
  }
  buffer.writeln('  return null;');
  buffer.writeln('}');
  buffer.writeln();

  buffer.writeln(
    'Future<OwnedItemMutationResult> collectarrReplaceOwnedFromJson('
    'LocalDatabase database, CatalogMediaKind kind, '
    'JsonMap payload) async {',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final ownedModel = persistence.ownedModel.className;
    buffer.writeln(
      '  if (kind == CatalogMediaKind.${descriptor.folder}) {',
    );
    buffer.writeln('    final item = $ownedModel.fromJson(payload);');
    buffer.writeln('    await $repository(database).upsert(item);');
    buffer.writeln(
      '    final serialized = collectarrTypedOwnedItemSyncPayload('
      'CatalogMediaKind.${descriptor.folder}, item);',
    );
    buffer.writeln(
      '    return OwnedItemMutationResult('
      'ref: OwnedItemRef(kind: CatalogMediaKind.${descriptor.folder}, '
      'id: OwnedItemId(item.id.value)), '
      'syncPayload: serialized.payload, isDeleted: serialized.isDeleted);',
    );
    buffer.writeln('  }');
  }
  buffer.writeln(
    "  throw ArgumentError.value(kind, 'kind', 'Unsupported owned kind');",
  );
  buffer.writeln('}');
  buffer.writeln();

  buffer.writeln(
    'Future<OwnedItemMutationResult?> collectarrMarkTypedOwnedItemDeleted('
    'LocalDatabase database, CatalogMediaKind kind, Object item, '
    'DateTime deletedAt) async {',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final ownedModel = persistence.ownedModel.className;
    buffer.writeln(
      '  if (kind == CatalogMediaKind.${descriptor.folder}) {',
    );
    buffer.writeln(
      '    if (item is! $ownedModel) throw ArgumentError.value('
      "item, 'item', 'Expected $ownedModel for ${descriptor.folder}');",
    );
    buffer.writeln(
      '    await $repository(database).markDeleted(item, deletedAt);',
    );
    buffer.writeln(
      '    final deleted = item.copyWith('
      'updatedAt: deletedAt, deletedAt: deletedAt);',
    );
    buffer.writeln(
      '    final serialized = collectarrTypedOwnedItemSyncPayload('
      'CatalogMediaKind.${descriptor.folder}, deleted);',
    );
    buffer.writeln(
      '    return OwnedItemMutationResult('
      'ref: OwnedItemRef(kind: CatalogMediaKind.${descriptor.folder}, '
      'id: OwnedItemId(deleted.id.value)), '
      'syncPayload: serialized.payload, isDeleted: true);',
    );
    buffer.writeln('  }');
  }
  buffer.writeln('  return null;');
  buffer.writeln('}');
  buffer.writeln();

  buffer.writeln(
    'Future<OwnedItemMutationResult?> collectarrMarkOwnedItemDeletedByRef('
    'LocalDatabase database, OwnedItemRef ref, DateTime deletedAt) async {',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final ownedId = persistence.ownedId.className;
    buffer.writeln(
      '  if (ref.kind == CatalogMediaKind.${descriptor.folder}) {',
    );
    buffer.writeln(
      '    final item = await $repository(database)'
      '.findById($ownedId(ref.id.value));',
    );
    buffer.writeln('    if (item == null) return null;');
    buffer.writeln(
      '    await $repository(database).markDeleted(item, deletedAt);',
    );
    buffer.writeln(
      '    final deleted = item.copyWith('
      'updatedAt: deletedAt, deletedAt: deletedAt);',
    );
    buffer.writeln(
      '    final serialized = collectarrTypedOwnedItemSyncPayload('
      'CatalogMediaKind.${descriptor.folder}, deleted);',
    );
    buffer.writeln(
      '    return OwnedItemMutationResult('
      'ref: OwnedItemRef(kind: CatalogMediaKind.${descriptor.folder}, '
      'id: OwnedItemId(deleted.id.value)), '
      'syncPayload: serialized.payload, isDeleted: true);',
    );
    buffer.writeln('  }');
  }
  buffer.writeln('  return null;');
  buffer.writeln('}');
  buffer.writeln();

  buffer.writeln(
    'Future<OwnedItemCreatePayload?> collectarrOwnedCreatePayloadByRef('
    'LocalDatabase database, OwnedItemRef ref) async {',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final repository = persistence.repository.className;
    final ownedId = persistence.ownedId.className;
    final createPayload = persistence.createPayload.className;
    buffer.writeln(
      '  if (ref.kind == CatalogMediaKind.${descriptor.folder}) {',
    );
    buffer.writeln(
      '    final item = await $repository(database).findById('
      '$ownedId(ref.id.value));',
    );
    buffer.writeln('    if (item == null) return null;');
    buffer.writeln(
      '    return $createPayload.fromTypedItem(item);',
    );
    buffer.writeln('  }');
  }
  buffer.writeln('  return null;');
  buffer.writeln('}');
  buffer.writeln();

  buffer.writeln(
    'OwnedItemRef collectarrTypedOwnedItemRef(Object item) {',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final ownedModel = persistence.ownedModel.className;
    buffer.writeln(
      '  if (item is $ownedModel) return OwnedItemRef('
      'kind: CatalogMediaKind.${descriptor.folder}, '
      'id: OwnedItemId(item.id.value));',
    );
  }
  buffer.writeln(
    "  throw ArgumentError.value(item, 'item', 'Unsupported typed Owned seed');",
  );
  buffer.writeln('}');
  buffer.writeln();

  buffer.writeln(
    'Map<String, dynamic> collectarrTypedOwnedItemJson(Object item) {',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final ownedModel = persistence.ownedModel.className;
    buffer.writeln(
      '  if (item is $ownedModel) return item.toJson();',
    );
  }
  buffer.writeln(
    "  throw ArgumentError.value(item, 'item', 'Unsupported typed Owned seed');",
  );
  buffer.writeln('}');
  buffer.writeln();

  buffer.writeln(
    '({Map<String, dynamic> payload, bool isDeleted}) '
    'collectarrTypedOwnedItemSyncPayload('
    'CatalogMediaKind kind, Object item) {',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final ownedModel = persistence.ownedModel.className;
    buffer.writeln(
      '  if (kind == CatalogMediaKind.${descriptor.folder}) {',
    );
    buffer.writeln(
      '    if (item is! $ownedModel) throw ArgumentError.value('
      "item, 'item', 'Expected $ownedModel for ${descriptor.folder}');",
    );
    buffer.writeln(
      '    final payload = Map<String, dynamic>.from('
      'item.toJson());',
    );
    buffer.writeln("    final isDeleted = payload['deleted_at'] != null;");
    buffer.writeln("    payload.remove('id');");
    buffer.writeln("    payload.remove('updated_at');");
    buffer.writeln("    payload.remove('deleted_at');");
    buffer.writeln("    payload.remove('reading');");
    buffer.writeln('    return (payload: payload, isDeleted: isDeleted);');
    buffer.writeln('  }');
  }
  buffer.writeln(
    "  throw ArgumentError.value(kind, 'kind', 'Unsupported owned kind');",
  );
  buffer.writeln('}');
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
    'OwnedItemCreatePayload collectarrOwnedCreatePayloadFromTyped('
    'CatalogMediaKind kind, Object item) {',
  );
  for (final descriptor in descriptors) {
    final persistence = descriptor.ownedPersistence;
    if (persistence == null) continue;
    final ownedModel = persistence.ownedModel.className;
    final createPayload = persistence.createPayload.className;
    buffer.writeln(
      '  if (kind == CatalogMediaKind.${descriptor.folder}) {',
    );
    buffer.writeln(
      '    if (item is! $ownedModel) throw ArgumentError.value('
      "item, 'item', 'Expected $ownedModel for ${descriptor.folder}');",
    );
    buffer.writeln('    return $createPayload.fromTypedItem(item);');
    buffer.writeln('  }');
  }
  buffer.writeln(
    "  throw ArgumentError.value(kind, 'kind', 'Unsupported owned kind');",
  );
  buffer.writeln('}');
  buffer.writeln();
}

void _renderCatalogTransportCodecs(
  StringBuffer buffer,
  List<_KindDescriptor> descriptors,
) {
  buffer.writeln(
    'const List<CatalogKindTransportBoundary> '
    'collectarrKindCatalogTransportCodecs = [',
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
    this.trackingLifecycleCodec,
    this.trackingUnitCodec,
    this.watchSessionCodec,
    this.customEpisodeCodec,
    this.providerMapper,
    this.facetModule,
    this.ownedPersistence,
    this.catalogRepositoryCodec,
    this.serialAuthorityContributor,
    this.vocabularyModule,
    this.localTables,
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
  final _Contributor? trackingLifecycleCodec;
  final _Contributor? trackingUnitCodec;
  final _Contributor? watchSessionCodec;
  final _Contributor? customEpisodeCodec;
  final _Contributor? providerMapper;
  final String? facetModule;
  final _OwnedPersistence? ownedPersistence;
  final _Contributor? catalogRepositoryCodec;
  final _Contributor? serialAuthorityContributor;
  final _VocabularyModule? vocabularyModule;
  final _KindLocalTables? localTables;

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
      trackingLifecycleCodec,
      trackingUnitCodec,
      watchSessionCodec,
      customEpisodeCodec,
      providerMapper,
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

final class _OwnedPersistence {
  const _OwnedPersistence({
    required this.repository,
    required this.projection,
    required this.ownedId,
    required this.ownedModel,
    required this.createPayload,
    required this.updatePayload,
  });

  final _Contributor repository;
  final _Contributor projection;
  final _Contributor ownedId;
  final _Contributor ownedModel;
  final _Contributor createPayload;
  final _Contributor updatePayload;
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
    required this.ownedType,
  });

  final String importPath;
  final String contributorName;
  final String ownedType;

  String get kind => contributorName
      .replaceFirst(RegExp(r'DevSeedContributor$'), '')
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match.group(1)}_${match.group(2)!.toLowerCase()}',
      )
      .toLowerCase();
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
