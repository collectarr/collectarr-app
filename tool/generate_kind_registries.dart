import 'dart:io';

const _kindsRoot = 'lib/features/library/kinds';
const _modulesOutput =
    'lib/features/library/kinds/registry/collectarr_kind_modules.g.dart';
const _registrationsOutput =
    'lib/features/library/kinds/registry/library_kind_registrations.g.dart';

Future<void> main() async {
  final descriptors = await _discoverKinds();
  if (descriptors.isEmpty) {
    throw StateError('No kind modules found under $_kindsRoot');
  }

  await File(_modulesOutput).writeAsString(_renderModules(descriptors));
  await File(_registrationsOutput)
      .writeAsString(_renderRegistrations(descriptors));
  stdout.writeln(
    'Generated ${descriptors.length} kind modules and registrations.',
  );
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

    descriptors.add(
      _KindDescriptor(
        folder: folder,
        moduleName: moduleName,
        pageClass: pageClass,
      ),
    );
  }
  descriptors.sort((left, right) => left.folder.compareTo(right.folder));
  return descriptors;
}

String _renderModules(List<_KindDescriptor> descriptors) {
  final buffer = StringBuffer('''// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run tool/generate_kind_registries.dart

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
''');
  for (final descriptor in descriptors) {
    buffer.writeln(
      "import 'package:collectarr_app/features/library/kinds/${descriptor.folder}/${descriptor.folder}_kind_module.dart';",
    );
    buffer.writeln(
      "export 'package:collectarr_app/features/library/kinds/${descriptor.folder}/${descriptor.folder}_kind_module.dart';",
    );
  }
  buffer.writeln();
  buffer.writeln('final List<LibraryKindModule> collectarrKindModules = [');
  for (final descriptor in descriptors) {
    buffer.writeln('  ${descriptor.moduleName},');
  }
  buffer.writeln('];');
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
  return buffer.toString();
}

String _renderRegistrations(List<_KindDescriptor> descriptors) {
  final buffer = StringBuffer('''// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run tool/generate_kind_registries.dart

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration_adapter.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/generic/generic_kind_module.dart';
import 'package:collectarr_app/features/library/generic/page.dart';
''');
  for (final descriptor in descriptors) {
    buffer.writeln(
      "import 'package:collectarr_app/features/library/kinds/${descriptor.folder}/${descriptor.folder}_kind_module.dart';",
    );
    buffer.writeln(
      "import 'package:collectarr_app/features/library/kinds/${descriptor.folder}/page.dart';",
    );
  }
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
  buffer.writeln('  if (kind == CatalogMediaKind.unknown) {');
  buffer.writeln('    return LibraryKindRegistrationAdapter(');
  buffer.writeln('      kind: CatalogMediaKind.unknown,');
  buffer.writeln('      module: genericKindModule,');
  buffer.writeln('      pageBuilder: ({');
  buffer.writeln('        required LibraryKindModule type,');
  buffer.writeln('        required Widget topBar,');
  buffer.writeln('        required Color accent,');
  buffer.writeln('        required Uri routeUri,');
  buffer.writeln('        LibraryLayoutSnapshot? switchLayoutSnapshot,');
  buffer.writeln('      }) => GenericLibraryPage(');
  buffer.writeln('        type: type,');
  buffer.writeln('        topBar: topBar,');
  buffer.writeln('        accent: accent,');
  buffer.writeln('        routeUri: routeUri,');
  buffer.writeln('        switchLayoutSnapshot: switchLayoutSnapshot,');
  buffer.writeln('      ),');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln('  throw ArgumentError(');
  buffer.writeln(
    "    'No LibraryKindRegistration registered for kind \"\$kind\"',",
  );
  buffer.writeln('  );');
  buffer.writeln('}');
  return buffer.toString();
}

final class _KindDescriptor {
  const _KindDescriptor({
    required this.folder,
    required this.moduleName,
    required this.pageClass,
  });

  final String folder;
  final String moduleName;
  final String pageClass;
}
