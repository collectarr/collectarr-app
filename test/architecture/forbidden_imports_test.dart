import 'dart:io';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/owned_details_exports.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/generic/generic_kind_module.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/kinds/generic/add/generic_add_draft.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/generic/ownership/generic_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_profile.dart';
import 'package:collectarr_app/features/library/kinds/generic/workspace/generic_fields.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';

import '../../tool/check_library_kind_boundaries.dart';

void main() {
  test('source tree does not import obsolete catalog_item_types.dart', () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue);

    final filesWithObsoleteImport = <String>[];

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = entity.readAsStringSync();
        if (content.contains('catalog_item_types.dart')) {
          filesWithObsoleteImport.add(entity.path);
        }
      }
    }

    expect(
      filesWithObsoleteImport,
      isEmpty,
      reason:
          'The obsolete file catalog_item_types.dart should not be imported. '
          'Import canonical domain/DTO models directly instead.',
    );
  });

  test(
      'kind domain metadata models do not import UI widgets or edit dialog shells',
      () {
    final kindsDir = Directory('lib/features/library/kinds');
    expect(kindsDir.existsSync(), isTrue);

    final domainViolations = <String>[];

    for (final entity in kindsDir.listSync(recursive: true)) {
      if (entity is File &&
          entity.path.endsWith('.dart') &&
          entity.path.contains(
              '${Platform.pathSeparator}domain${Platform.pathSeparator}')) {
        final content = entity.readAsStringSync();
        if (content.contains('library_edit_dialog.dart') ||
            content.contains('package:flutter/material.dart')) {
          domainViolations.add(entity.path);
        }
      }
    }

    expect(
      domainViolations,
      isEmpty,
      reason:
          'Domain metadata files must remain pure models and not import UI shells.',
    );
  });

  test(
      'architecture boundary checker rejects stats importing concrete comic metadata',
      () {
    final repoRoot = Directory.current.path;
    const testCode = '''
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';

class TestStats {}
''';
    final parseResult = parseString(
      content: testCode,
      path: p.join(
          repoRoot, 'lib', 'features', 'library', 'stats', 'stats_test.dart'),
      throwIfDiagnostics: false,
    );
    final visitor = ArchitectureRuleVisitor(
      filePath: p.join(
          repoRoot, 'lib', 'features', 'library', 'stats', 'stats_test.dart'),
      relativePath: 'lib/features/library/stats/stats_test.dart',
      lineInfo: parseResult.lineInfo,
      isBoundaryFile:
          isBoundaryFile('lib/features/library/stats/stats_test.dart'),
      isRegistryFile: false,
      kindName: null,
      repoRoot: repoRoot,
    );
    parseResult.unit.accept(visitor);
    expect(visitor.violations, isNotEmpty);
    expect(
      visitor.violations.first,
      contains('Forbidden import of kind-specific module'),
    );
  });

  test('architecture boundary checker allows structural owned projections', () {
    final repoRoot = Directory.current.path;
    const testCode = '''
class OwnedItemSummary {
  final String? subtitle;
  const OwnedItemSummary(this.subtitle);
}
''';
    final relativePath = 'lib/core/models/owned_item_projection.dart';
    final parseResult = parseString(
      content: testCode,
      path: p.join(repoRoot, relativePath),
      throwIfDiagnostics: false,
    );
    final visitor = ArchitectureRuleVisitor(
      filePath: p.join(repoRoot, relativePath),
      relativePath: relativePath,
      lineInfo: parseResult.lineInfo,
      isBoundaryFile: isBoundaryFile(relativePath),
      isRegistryFile: false,
      kindName: null,
      repoRoot: repoRoot,
      sourceContent: testCode,
    );
    parseResult.unit.accept(visitor);
    expect(visitor.violations, isEmpty);
  });

  test('architecture boundary checker allows structural event kind switches',
      () {
    const testCode = '''
enum ActivityEventKind { added, removed }

String label(ActivityEventKind kind) => switch (kind) {
  ActivityEventKind.added => 'Added',
  ActivityEventKind.removed => 'Removed',
};
''';
    final relativePath = 'lib/core/models/activity_event.dart';
    final parseResult = parseString(
      content: testCode,
      path: p.join(Directory.current.path, relativePath),
      throwIfDiagnostics: false,
    );
    final visitor = ArchitectureRuleVisitor(
      filePath: p.join(Directory.current.path, relativePath),
      relativePath: relativePath,
      lineInfo: parseResult.lineInfo,
      isBoundaryFile: isBoundaryFile(relativePath),
      isRegistryFile: false,
      kindName: null,
      repoRoot: Directory.current.path,
      sourceContent: testCode,
    );
    parseResult.unit.accept(visitor);
    expect(visitor.violations, isEmpty);
  });

  test(
      'architecture boundary checker rejects value importing concrete comic metadata',
      () {
    final repoRoot = Directory.current.path;
    const testCode = '''
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';

class TestValue {}
''';
    final parseResult = parseString(
      content: testCode,
      path: p.join(
          repoRoot, 'lib', 'features', 'library', 'value', 'value_test.dart'),
      throwIfDiagnostics: false,
    );
    final visitor = ArchitectureRuleVisitor(
      filePath: p.join(
          repoRoot, 'lib', 'features', 'library', 'value', 'value_test.dart'),
      relativePath: 'lib/features/library/value/value_test.dart',
      lineInfo: parseResult.lineInfo,
      isBoundaryFile:
          isBoundaryFile('lib/features/library/value/value_test.dart'),
      isRegistryFile: false,
      kindName: null,
      repoRoot: repoRoot,
    );
    parseResult.unit.accept(visitor);
    expect(visitor.violations, isNotEmpty);
    expect(
      visitor.violations.first,
      contains('Forbidden import of kind-specific module'),
    );
  });
  test(
      'architecture boundary checker rejects generic referencing concrete ComicMedia',
      () {
    final repoRoot = Directory.current.path;
    const testCode = '''
class GenericClass {
  void doSomething(ComicMedia metadata) {}
}
''';
    final parseResult = parseString(
      content: testCode,
      path: p.join(repoRoot, 'lib', 'features', 'library', 'generic',
          'generic_test.dart'),
      throwIfDiagnostics: false,
    );
    final visitor = ArchitectureRuleVisitor(
      filePath: p.join(repoRoot, 'lib', 'features', 'library', 'generic',
          'generic_test.dart'),
      relativePath: 'lib/features/library/generic/generic_test.dart',
      lineInfo: parseResult.lineInfo,
      isBoundaryFile:
          isBoundaryFile('lib/features/library/generic/generic_test.dart'),
      isRegistryFile: false,
      kindName: null,
      repoRoot: repoRoot,
    );
    parseResult.unit.accept(visitor);
    expect(visitor.violations, isNotEmpty);
    expect(
      visitor.violations.any((v) => v.contains('Forbidden concrete kind')),
      isTrue,
    );
  });

  test(
      'architecture boundary checker rejects value referencing concrete ComicOwnedDetails',
      () {
    final repoRoot = Directory.current.path;
    const testCode = '''
class ValueClass {
  void calculate(ComicOwnedDetails details) {}
}
''';
    final parseResult = parseString(
      content: testCode,
      path: p.join(
          repoRoot, 'lib', 'features', 'library', 'value', 'value_test.dart'),
      throwIfDiagnostics: false,
    );
    final visitor = ArchitectureRuleVisitor(
      filePath: p.join(
          repoRoot, 'lib', 'features', 'library', 'value', 'value_test.dart'),
      relativePath: 'lib/features/library/value/value_test.dart',
      lineInfo: parseResult.lineInfo,
      isBoundaryFile:
          isBoundaryFile('lib/features/library/value/value_test.dart'),
      isRegistryFile: false,
      kindName: null,
      repoRoot: repoRoot,
    );
    parseResult.unit.accept(visitor);
    expect(visitor.violations, isNotEmpty);
    expect(
      visitor.violations.any((v) => v.contains('ComicOwnedDetails')),
      isTrue,
    );
  });

  test(
      'architecture boundary checker rejects generic CatalogMediaKind.movie switch or branch',
      () {
    final repoRoot = Directory.current.path;
    const testCode = '''
void checkKind(CatalogMediaKind kind) {
  if (kind == CatalogMediaKind.movie) {}
}
''';
    final parseResult = parseString(
      content: testCode,
      path: p.join(repoRoot, 'lib', 'features', 'library', 'generic',
          'generic_test.dart'),
      throwIfDiagnostics: false,
    );
    final visitor = ArchitectureRuleVisitor(
      filePath: p.join(repoRoot, 'lib', 'features', 'library', 'generic',
          'generic_test.dart'),
      relativePath: 'lib/features/library/generic/generic_test.dart',
      lineInfo: parseResult.lineInfo,
      isBoundaryFile:
          isBoundaryFile('lib/features/library/generic/generic_test.dart'),
      isRegistryFile: false,
      kindName: null,
      repoRoot: repoRoot,
    );
    parseResult.unit.accept(visitor);
    expect(visitor.violations, isNotEmpty);
    expect(
      visitor.violations.any((v) => v.contains('CatalogMediaKind')),
      isTrue,
    );
  });

  test(
      'architecture boundary checker rejects dynamic registry in generic boundary code',
      () {
    final repoRoot = Directory.current.path;
    const testCode = '''
class GenericFieldHandler {
  final LibraryFieldRegistry<dynamic> registry;
  GenericFieldHandler(this.registry);
}
''';
    final parseResult = parseString(
      content: testCode,
      path: p.join(repoRoot, 'lib', 'features', 'library', 'generic',
          'generic_test.dart'),
      throwIfDiagnostics: false,
    );
    final visitor = ArchitectureRuleVisitor(
      filePath: p.join(repoRoot, 'lib', 'features', 'library', 'generic',
          'generic_test.dart'),
      relativePath: 'lib/features/library/generic/generic_test.dart',
      lineInfo: parseResult.lineInfo,
      isBoundaryFile:
          isBoundaryFile('lib/features/library/generic/generic_test.dart'),
      isRegistryFile: false,
      kindName: null,
      repoRoot: repoRoot,
    );
    parseResult.unit.accept(visitor);
    expect(visitor.violations, isNotEmpty);
    expect(
      visitor.violations
          .any((v) => v.contains('LibraryFieldRegistry<dynamic>')),
      isTrue,
    );
  });

  test('architecture boundary checker rejects provider importing a kind', () {
    const testCode = '''
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';

class TestProvider {}
''';
    final visitor = _visitorForArchitectureTest(
      code: testCode,
      relativePath: 'lib/features/providers/domain/test_provider.dart',
    );

    visitor.unit.accept(visitor.visitor);
    expect(
      visitor.visitor.violations,
      contains(
        contains('Provider code must not import kind-specific modules'),
      ),
    );
  });

  test(
      'architecture boundary checker rejects generated DTO in shared kind code',
      () {
    const testCode = '''
import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';

class SharedProvider {}
''';
    final visitor = _visitorForArchitectureTest(
      code: testCode,
      relativePath:
          'lib/features/library/kinds/_shared/video/providers/test_provider.dart',
    );

    visitor.unit.accept(visitor.visitor);
    expect(
      visitor.visitor.violations,
      contains(
        contains('Generated Core DTO import must stay inside the owning kind'),
      ),
    );
  });

  test('architecture boundary checker rejects generic metadata maps', () {
    const testCode = '''
final Map<String, dynamic> metadata = <String, dynamic>{};
''';
    final visitor = _visitorForArchitectureTest(
      code: testCode,
      relativePath: 'lib/features/library/generic/test_metadata.dart',
    );

    visitor.unit.accept(visitor.visitor);
    expect(
      visitor.visitor.violations,
      contains(
        contains('Generic metadata map must be classified'),
      ),
    );
  });

  test('architecture boundary checker rejects dynamic catalog objects', () {
    const testCode = '''
dynamic catalogItem;
''';
    final visitor = _visitorForArchitectureTest(
      code: testCode,
      relativePath: 'lib/features/library/generic/test_catalog.dart',
    );

    visitor.unit.accept(visitor.visitor);
    expect(
      visitor.visitor.violations,
      contains(
        contains('Dynamic catalog/metadata object must be replaced'),
      ),
    );
  });

  test(
      'whole-repository boundary checker rejects kind imports from feature hosts',
      () {
    const testCode = '''
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';

class CalendarHost {}
''';
    final visitor = _visitorForArchitectureTest(
      code: testCode,
      relativePath: 'lib/features/calendar/calendar_host.dart',
    );

    visitor.unit.accept(visitor.visitor);

    expect(
      visitor.visitor.violations,
      contains(contains('Forbidden import of kind-specific module')),
    );
  });

  test(
      'whole-repository boundary checker rejects Core DTOs from generic mappers',
      () {
    const testCode = '''
import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';

class GenericMapper {}
''';
    final visitor = _visitorForArchitectureTest(
      code: testCode,
      relativePath: 'lib/core/api/mappers/generic_mapper.dart',
    );

    visitor.unit.accept(visitor.visitor);

    expect(
      visitor.visitor.violations,
      contains(contains('Generated Core DTO import must stay inside')),
    );
  });

  test('whole-repository boundary checker rejects semantic fields in settings',
      () {
    const testCode = '''
class SettingsMetadata {
  String? get isbn => null;
}
''';
    final visitor = _visitorForArchitectureTest(
      code: testCode,
      relativePath: 'lib/features/settings/settings_metadata.dart',
    );

    visitor.unit.accept(visitor.visitor);

    expect(
      visitor.visitor.violations,
      contains(contains('Forbidden contextual semantic declaration "isbn"')),
    );
  });

  test('composition roots may wire kind modules', () {
    const testCode = '''
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_media.dart';

class DatabaseCompositionRoot {}
''';
    final visitor = _visitorForArchitectureTest(
      code: testCode,
      relativePath: 'lib/core/db/local_database.dart',
    );

    visitor.unit.accept(visitor.visitor);

    expect(visitor.visitor.violations, isEmpty);
  });

  test('architecture boundary checker rejects erased runtime types', () {
    const testCode = '''
CatalogItemDto item;
LibraryMetadataItem metadata;
LibraryCatalogItemView view;
''';
    final visitor = _visitorForArchitectureTest(
      code: testCode,
      relativePath: 'lib/features/library/generic/test_runtime_types.dart',
    );

    visitor.unit.accept(visitor.visitor);

    expect(
      visitor.visitor.violations,
      contains(
        contains('Erased runtime type "CatalogItemDto"'),
      ),
    );
    expect(
      visitor.visitor.violations,
      contains(
        contains('Erased runtime type "LibraryMetadataItem"'),
      ),
    );
    expect(
      visitor.visitor.violations,
      contains(
        contains('Erased runtime type "LibraryCatalogItemView"'),
      ),
    );
  });

  test(
      'architecture boundary checker rejects cross-kind concrete import (comic -> manga)',
      () {
    final repoRoot = Directory.current.path;
    const testCode = '''
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';

class ComicFeature {}
''';
    final parseResult = parseString(
      content: testCode,
      path: p.join(repoRoot, 'lib', 'features', 'library', 'kinds', 'comic',
          'comic_test.dart'),
      throwIfDiagnostics: false,
    );
    final visitor = ArchitectureRuleVisitor(
      filePath: p.join(repoRoot, 'lib', 'features', 'library', 'kinds', 'comic',
          'comic_test.dart'),
      relativePath: 'lib/features/library/kinds/comic/comic_test.dart',
      lineInfo: parseResult.lineInfo,
      isBoundaryFile:
          isBoundaryFile('lib/features/library/kinds/comic/comic_test.dart'),
      isRegistryFile: false,
      kindName: 'comic',
      repoRoot: repoRoot,
    );
    parseResult.unit.accept(visitor);
    expect(visitor.violations, isNotEmpty);
    expect(
      visitor.violations.any((v) => v.contains('Cross-kind import violation')),
      isTrue,
    );
  });

  test(
      'extensibility: custom fake kind "foo" registers and operates without generic library edits',
      () {
    final fooKindModule = LibraryKindSpec<GenericWorkspaceDto,
        GenericOwnedDetails, GenericOwnedDetailsDraft>(
      projector: const GenericWorkspaceProjector(),
      ownedDetailsCodec: const GenericOwnedDetailsCodec(),
      fields: genericLibraryKindSchema.toRegistry(),
      identity: const LibraryKindIdentity(
        kind: CatalogMediaKind.unknown,
        singularLabel: 'Foo',
        pluralLabel: 'Foos',
        title: 'Foo',
        icon: Icons.extension,
        accent: Color(0xFF673AB7),
        preferencePrefix: 'foo',
      ),
      metadata: const LibraryMetadataCapability(
        defaultProviderId: '',
        providers: [],
      ),
      hierarchy: const LibraryHierarchyCapability(),
      inspector: const LibraryInspectorCapability(),
      transfer: const LibraryTransferCapability(),
      presentation: genericLibraryMediaPresentation,
      trackingProfile: bookTrackingProfile,
      add: StandardLibraryAddCapability<GenericAddDraft>(
        kind: CatalogMediaKind.unknown,
        initialDraftBuilder: GenericAddDraft.new,
        search: genericKindModule.add.search,
      ),
      edit: LibraryEditCapability(
        presentation: genericKindModule.edit.presentation,
        conditions: genericKindModule.edit.conditions,
        defaultCondition: genericKindModule.edit.defaultCondition,
        defaultGrade: genericKindModule.edit.defaultGrade,
        createDraft: genericKindModule.edit.createDraft,
        ownedDigitalFlagResolver:
            genericKindModule.edit.ownedDigitalFlagResolver,
      ),
      buildCardPresentation: (item, {required musicVertical}) =>
          const LibraryCardPresentation(),
    );

    // Verify operations through the generic interface
    expect(fooKindModule.identity.title, equals('Foo'));
    expect(fooKindModule.identity.singularLabel, equals('Foo'));
    expect(fooKindModule.identity.pluralLabel, equals('Foos'));

    final entry = ShelfEntry(
      itemId: 'foo-1',
      catalogItem: CatalogItem.fromJson({
        'id': 'foo-1',
        'kind': 'unknown',
        'title': 'Foo Item 1',
      }),
      ownedItem: OwnedItem(
        id: 'owned-foo-1',
        catalogRef: const CatalogEntityRef(
          entityType: CatalogEntityType.work,
          kind: 'unknown',
          id: 'foo-1',
        ),
        details: const GenericOwnedDetails(),
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    );

    final projection = fooKindModule.workspace.project(
      source: entry,
      node: const LibraryTitleNodeRef(titleItemId: 'foo-1'),
    );

    expect(projection.dto.title, equals('Foo Item 1'));
    expect(
      fooKindModule.stats.buildSummaryTiles(
        const ShelfState(
          entries: [],
          ownedCount: 0,
          wishlistCount: 0,
          missingGradeCount: 0,
          pricedCount: 0,
          totalPaidCents: 0,
          primaryCurrency: 'USD',
          hasMixedCurrencies: false,
          soldCount: 0,
          totalSellCents: 0,
        ),
        fooKindModule,
      ),
      isEmpty,
    );
  });
}

({ArchitectureRuleVisitor visitor, CompilationUnit unit})
    _visitorForArchitectureTest({
  required String code,
  required String relativePath,
}) {
  final repoRoot = Directory.current.path;
  final filePath = p.join(repoRoot, relativePath);
  final parseResult = parseString(
    content: code,
    path: filePath,
    throwIfDiagnostics: false,
  );
  final visitor = ArchitectureRuleVisitor(
    filePath: filePath,
    relativePath: relativePath,
    lineInfo: parseResult.lineInfo,
    isBoundaryFile: isBoundaryFile(relativePath),
    isRegistryFile:
        relativePath.startsWith('lib/features/library/kinds/registry/'),
    kindName: null,
    repoRoot: repoRoot,
    sourceContent: code,
  );
  return (visitor: visitor, unit: parseResult.unit);
}
