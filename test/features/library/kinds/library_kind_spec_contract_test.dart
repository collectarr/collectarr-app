import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/test/helpers/owned_details_codec_fixtures.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LibraryKind capability contract tests', () {
    test('all 9 active kind specs expose validated field registries', () {
      expect(collectarrKindRegistrationsList.length, 9);
      for (final spec in collectarrKindRegistrationsList) {
        final workspace = libraryKindWorkspaceForKind(spec.kind);
        expect(workspace.fields.kindNamespace, spec.kind.apiValue);
        expect(workspace.fields.columns, isNotEmpty);
        expect(workspace.fields.sorts, isNotEmpty);
      }
    });

    test('all active kind specs have non-null required core properties', () {
      for (final spec in collectarrKindRegistrationsList) {
        final workspace = libraryKindWorkspaceForKind(spec.kind);
        expect(spec.kind, isNotNull);
        expect(spec.identity, isNotNull);
        expect(spec.physicalMediaFormats, isNotEmpty);
        expect(spec.metadata, isNotNull);
        expect(spec.hierarchy, isNotNull);
        expect(spec.inspector, isNotNull);
        expect(spec.presentation, isNotNull);
        expect(spec.viewProfile, isNotNull);
        expect(workspace.fields, isNotNull);
        expect(workspace.projector, isNotNull);
        expect(spec.add, isNotNull);
      }
    });

    test(
        'optional capabilities are null when unsupported rather than dummy objects',
        () {
      // Comic has toolbar actions
      expect(comicKindModule.toolbar, isNotNull);
      expect(comicKindModule.toolbar!.actions, isNotEmpty);

      // Specs without custom toolbar actions have null toolbar
      final specsWithoutToolbar = collectarrKindRegistrationsList
          .where((s) => s.kind != CatalogMediaKind.comic);
      for (final spec in specsWithoutToolbar) {
        expect(spec.toolbar, isNull,
            reason: '${spec.kind} should have null toolbar when absent');
      }
    });

    test(
        'owned details codec encodes matching details and rejects invalid details',
        () {
      const invalidDetailsByKind = <CatalogMediaKind, JsonEncodable>{
        CatalogMediaKind.comic: BookOwnedDetails(),
        CatalogMediaKind.movie: ComicOwnedDetails(),
      };
      for (final spec in collectarrKindRegistrationsList) {
        final codec = ownedDetailsCodecForTest(spec.kind);
        final defaultDetails = codec.defaultDetails();
        expect(defaultDetails, isNotNull);

        // Encoding valid details must succeed
        final encoded = defaultDetails.toJson();
        expect(encoded, isA<Map<String, dynamic>>());

        // Encoding an invalid details type must throw ArgumentError
        final invalidDetails = invalidDetailsByKind[spec.kind];
        if (invalidDetails != null) {
          expect(
            () => codec.validate(invalidDetails),
            throwsArgumentError,
          );
        }
      }
    });

    test('immutable registry requires and tryGets specs correctly', () {
      final registry = LibraryKindRegistry(collectarrKindRegistrationsList);
      expect(registry.allModules.length, 9);
      expect(
        registry.require(CatalogMediaKind.comic),
        isA<LibraryKindRegistration>(),
      );
      expect(registry.tryGet(CatalogMediaKind.comic)?.kind,
          CatalogMediaKind.comic);
      expect(registry.tryGet(CatalogMediaKind.unknown), isNull);
      expect(
        () => registry.require(CatalogMediaKind.unknown),
        throwsArgumentError,
      );
    });

    test('registry throws StateError on duplicate registration', () {
      expect(
        () => LibraryKindRegistry([
          const ComicRegistration(),
          const ComicRegistration(),
        ]),
        throwsStateError,
      );
    });

    test('field registry rejects mismatched namespaces', () {
      // Creating registry with mismatched column namespace throws StateError
      expect(
        () => LibraryFieldRegistry<BookWorkspaceDto>(
          kindNamespace: 'comic', // Mismatched namespace for book columns
          columns: bookKindWorkspace.fields.columns,
          sorts: bookKindWorkspace.fields.sorts,
          groups: bookKindWorkspace.fields.groups,
          defaultVisibleColumns: bookKindWorkspace.fields.defaultVisibleColumns,
          defaultSort: bookKindWorkspace.fields.defaultSort,
          defaultGroup: bookKindWorkspace.fields.defaultGroup,
          preferenceCodec: bookKindWorkspace.fields.preferenceCodec,
        ),
        throwsStateError,
      );
    });
  });
}
