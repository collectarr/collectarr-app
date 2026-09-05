import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('concrete declarative schemas stay in kind-owned modules', () {
    const structuralFiles = {
      'lib/features/library/add/schema/add_schema.dart',
      'lib/features/library/add/schema/add_schema_renderer.dart',
      'lib/features/library/edit/schema/edit_schema.dart',
      'lib/features/library/edit/schema/edit_schema_renderer.dart',
      'lib/features/library/config/library_facet_types.dart',
      'lib/features/library/config/library_kind_vocabulary_capability.dart',
      'lib/features/library/workspace/config/library_typed_field_definition.dart',
      'lib/features/library/workspace/schema/field_factories.dart',
      'lib/features/library/workspace/schema/library_field_registry.dart',
      'lib/features/library/workspace/schema/library_kind_schema.dart',
      'lib/features/library/workspace/table/media_table_columns.dart',
      'lib/features/collection/vocabulary/universal_vocabularies.dart',
      'lib/features/collection/vocabulary/vocabulary_definition.dart',
      'lib/features/collection/vocabulary/vocabulary_repository.dart',
      'lib/features/pick_lists/models/pick_list_definition.dart',
      'lib/features/library/generic/projection.dart',
      'lib/features/library/kinds/registry/library_kind_module.dart',
    };
    const declarativeTokens = [
      'EditSchema<',
      'AddSchema<',
      'LibraryFacetDefinition<',
      'VocabularyDefinition<',
      'LibraryFieldDefinition<',
      'LibraryGroupDefinition<',
      'LibrarySortDefinition<',
      'LibraryColumnDefinition<',
    ];

    final violations = <String>[];
    final libraryRoot = Directory('lib/features');
    for (final entity in libraryRoot.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path.replaceAll('\\', '/');
      if (structuralFiles.contains(path) || path.contains('/kinds/')) {
        continue;
      }
      final source = entity.readAsStringSync();
      for (final token in declarativeTokens) {
        if (source.contains(token)) {
          violations.add('$path: $token');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Concrete Add/Edit, field, facet, group, and vocabulary '
          'declarations must remain kind-owned; structural consumers belong '
          'to the explicit allowlist.',
    );
  });
}
