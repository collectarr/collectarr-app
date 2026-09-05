import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('removed typed-kind compatibility names stay out of production', () {
    const removedNames = [
      'LibraryMetadataItem',
      'LibraryCatalogItemView',
      'LibraryKindMetadataRuntime',
      'CatalogKindCodec',
      'KindEditDraft',
      'LibrarySectionRegistry',
      'DefaultLibraryEditPresentationBuilder',
      'CatalogCache',
    ];

    final violations = <String>[];
    for (final file in _productionDartFiles()) {
      final path = _normalized(file.path);
      final source = file.readAsStringSync();
      for (final name in removedNames) {
        if (RegExp(r'\b' + RegExp.escape(name) + r'\b').hasMatch(source)) {
          violations.add('$path: $name');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Removed catalog, edit, section, and cache compatibility names '
          'must not return to production code.',
    );
  });

  test('remaining migration bridges are confined to named boundaries', () {
    const allowed = <String, List<String>>{
      'CatalogItemDto': [
        'lib/core/api/dto/catalog/',
        'lib/core/api/mappers/',
      ],
      'GenericEditDraft': [
        'lib/features/library/kinds/generic/',
      ],
      'VideoEditDraftContract': [
        'lib/features/library/edit/video/',
        'lib/features/library/kinds/anime/edit/',
        'lib/features/library/kinds/movie/edit/',
        'lib/features/library/kinds/tv/edit/',
      ],
      'TrackingUnit': [
        'lib/core/models/tracking_unit.dart',
        'lib/features/collection/',
        'lib/features/library/kinds/',
      ],
    };

    final violations = <String>[];
    for (final file in _productionDartFiles()) {
      final path = _normalized(file.path);
      final source = file.readAsStringSync();
      for (final entry in allowed.entries) {
        if (!RegExp(r'\b' + RegExp.escape(entry.key) + r'\b')
            .hasMatch(source)) {
          continue;
        }
        if (!entry.value.any(path.startsWith)) {
          violations.add('$path: ${entry.key}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Known migration bridges must remain inside their explicit '
          'transport, kind, or personal-state boundaries.',
    );
  });
}

Iterable<File> _productionDartFiles() sync* {
  for (final root in const ['lib/core', 'lib/features', 'lib/ui']) {
    for (final entity in Directory(root).listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('.g.dart')) continue;
      yield entity;
    }
  }
}

String _normalized(String path) => path.replaceAll('\\', '/');
