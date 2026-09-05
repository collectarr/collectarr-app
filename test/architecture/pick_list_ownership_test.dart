import 'dart:io';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production pick-list code uses the canonical pick_lists namespace', () {
    const legacyImports = [
      'package:collectarr_app/features/collection/pick_list/',
      'package:collectarr_app/features/collection/vocabulary/',
    ];
    final violations = <String>[];
    final lib = Directory('lib');
    for (final entity in lib.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final source = entity.readAsStringSync();
      for (final legacyImport in legacyImports) {
        if (source.contains(legacyImport)) {
          violations.add('${entity.path}: $legacyImport');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Legacy pick-list/vocabulary namespaces must remain only as '
          'filesystem compatibility shims, never as production imports.',
    );
  });

  test(
      'pick-list registry receives explicit contributors from the composition root',
      () {
    final registrySource =
        File('lib/features/pick_lists/pick_list_registry.dart')
            .readAsStringSync();
    expect(registrySource, isNot(contains('library_kind_registry.dart')));

    final expectedKinds =
        CatalogMediaKind.values.where((kind) => !kind.isUnknown).toSet();
    final contributors = defaultPickListDefinitionContributors;
    expect(
      contributors.map((contributor) => contributor.kind).toSet(),
      expectedKinds,
    );
    for (final contributor in contributors) {
      expect(contributor.definitions, isNotEmpty,
          reason: '${contributor.kind.apiValue} must contribute vocabularies');
    }
  });
}
