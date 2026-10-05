import 'dart:io';

import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Core clients use only the canonical /api/v1 surface', () {
    final apiDirectory = Directory('lib/core/api');
    for (final file in _dartFiles(apiDirectory)) {
      final source = file.readAsStringSync();
      final paths = RegExp(r'''['"](/[^'"]*)['"]''')
          .allMatches(source)
          .map((match) => match.group(1)!)
          .where((path) => path.length > 1 && path.startsWith('/'));
      for (final path in paths) {
        expect(
          path,
          startsWith('/api/v1/'),
          reason: '${file.path} contains an unversioned Core path: $path',
        );
      }
    }
  });

  test('all nine kinds are registered as flat Catalog Item workspaces', () {
    expect(collectarrKindRegistrationsList, hasLength(9));
    expect(
      collectarrKindRegistrationsList
          .map((registration) => registration.kind)
          .toSet(),
      hasLength(9),
    );
  });

  test('production library code has no Work/Release target adapter', () {
    const removedNames = <String>[
      'CatalogEntityRef',
      'LibraryEntityScope',
      'LibraryReleaseRef',
      'WorkRef',
      'ReleaseRef',
      'rootId',
    ];
    final violations = <String>[];
    for (final file in _productionLibraryFiles()) {
      final source = file.readAsStringSync();
      for (final name in removedNames) {
        if (RegExp(r'\b' + RegExp.escape(name) + r'\b').hasMatch(source)) {
          violations.add('${file.path}: $name');
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'Core and local-entry identities must stay explicit and flat.',
    );
  });

  test('provider integration sources are absent from the active library', () {
    const removedProviderNames = <String>[
      'ProviderAdapter',
      'ProviderConnector',
      'ProviderIngest',
      'ProviderSearchResult',
      'provider_accounts_cache',
      'provider_item_links_cache',
    ];
    final providersDirectory = Directory('lib/features/providers');
    final sources = <File>[
      ..._productionLibraryFiles(),
      if (providersDirectory.existsSync()) ..._dartFiles(providersDirectory),
    ];
    final violations = <String>[];
    for (final file in sources) {
      final source = file.readAsStringSync();
      for (final name in removedProviderNames) {
        if (source.contains(name)) violations.add('${file.path}: $name');
      }
    }
    expect(violations, isEmpty);
  });
}

Iterable<File> _productionLibraryFiles() sync* {
  for (final root in const ['lib/core', 'lib/features', 'lib/ui']) {
    yield* _dartFiles(Directory(root));
  }
}

Iterable<File> _dartFiles(Directory directory) sync* {
  if (!directory.existsSync()) return;
  for (final entity in directory.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.endsWith('.g.dart')) continue;
    yield entity;
  }
}
