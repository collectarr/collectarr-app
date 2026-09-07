import 'dart:io';

const _kindsRoot = 'lib/features/library/kinds';
const _registryOutput =
    'lib/features/library/kinds/registry/collectarr_kind_registry.g.dart';

Future<void> main() async {
  final descriptors = await _discoverKinds();
  if (descriptors.isEmpty) {
    throw StateError('No kind modules found under $_kindsRoot');
  }

  await File(_registryOutput).writeAsString(_renderRegistry(descriptors));
  stdout.writeln('Generated ${descriptors.length} kind registrations.');
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
        facetModule: facetModule,
      ),
    );
  }
  descriptors.sort((left, right) => left.folder.compareTo(right.folder));
  return descriptors;
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

String _renderRegistry(List<_KindDescriptor> descriptors) {
  final buffer = StringBuffer('''// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run tool/generate_kind_registries.dart

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration_adapter.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot.dart';
import 'package:flutter/material.dart';
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
    "import 'package:collectarr_app/features/library/config/owned_details_codec.dart';",
  );
  buffer.writeln();
  buffer.writeln('final List<LibraryKindModule> collectarrKindModules = [');
  for (final descriptor in descriptors) {
    buffer.writeln('  ${descriptor.moduleName},');
  }
  buffer.writeln('];');
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
    buffer.writeln('  LibraryKindRegistrationAdapter(');
    buffer.writeln('    kind: CatalogMediaKind.${descriptor.folder},');
    buffer.writeln('    module: ${descriptor.moduleName},');
    buffer.writeln('    pageBuilder: ({');
    buffer.writeln('      required LibraryKindModule type,');
    buffer.writeln('      required Widget topBar,');
    buffer.writeln('      required Color accent,');
    buffer.writeln('      required Uri routeUri,');
    buffer.writeln('      LibraryLayoutSnapshot? switchLayoutSnapshot,');
    buffer.writeln('    }) => ${descriptor.pageClass}(');
    buffer.writeln('      type: type,');
    buffer.writeln('      topBar: topBar,');
    buffer.writeln('      accent: accent,');
    buffer.writeln('      routeUri: routeUri,');
    buffer.writeln('      switchLayoutSnapshot: switchLayoutSnapshot,');
    buffer.writeln('    ),');
    buffer.writeln('  ),');
  }
  buffer.writeln('];');
  buffer.writeln();
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
    this.providerMapper,
    this.ownedDetailsCodec,
    this.facetModule,
  });

  final String folder;
  final String moduleName;
  final String pageClass;
  final _Contributor? calendarContributor;
  final _Contributor? activityContributor;
  final _Contributor? adminContributor;
  final _Contributor? barcodeResolver;
  final _Contributor? collectionCsvProjection;
  final _Contributor? providerMapper;
  final _Contributor? ownedDetailsCodec;
  final String? facetModule;

  Iterable<_Contributor> get contributors sync* {
    for (final contributor in [
      calendarContributor,
      activityContributor,
      adminContributor,
      barcodeResolver,
      collectionCsvProjection,
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
