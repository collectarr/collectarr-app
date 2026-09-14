import 'package:collectarr_app/core/models/catalog_media_kind.dart';
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
    test('all 9 active registrations expose validated field registries', () {
      expect(collectarrKindRegistrationsList.length, 9);
      for (final registration in collectarrKindRegistrationsList) {
        final workspace = libraryKindWorkspaceForKind(registration.kind);
        expect(workspace.fields.kindNamespace, registration.kind.apiValue);
        expect(workspace.fields.columns, isNotEmpty);
        expect(workspace.fields.sorts, isNotEmpty);
      }
    });

    test('all active registrations have non-null required capabilities', () {
      for (final registration in collectarrKindRegistrationsList) {
        final workspace = libraryKindWorkspaceForKind(registration.kind);
        expect(registration.kind, isNotNull);
        expect(registration.identity, isNotNull);
        expect(registration.physicalMediaFormats, isNotEmpty);
        expect(registration.metadata, isNotNull);
        expect(registration.hierarchy, isNotNull);
        expect(registration.inspector, isNotNull);
        expect(registration.presentation, isNotNull);
        expect(registration.viewProfile, isNotNull);
        expect(workspace.fields, isNotNull);
        expect(workspace.projector, isNotNull);
        expect(registration.add, isNotNull);
      }
    });

    test(
        'optional capabilities are null when unsupported rather than dummy objects',
        () {
      // Comic has toolbar actions
      expect(comicKindModule.toolbar, isNotNull);
      expect(comicKindModule.toolbar!.actions, isNotEmpty);

      // Specs without custom toolbar actions have null toolbar
      final registrationsWithoutToolbar = collectarrKindRegistrationsList
          .where((registration) => registration.kind != CatalogMediaKind.comic);
      for (final registration in registrationsWithoutToolbar) {
        expect(registration.toolbar, isNull,
            reason:
                '${registration.kind} should have null toolbar when absent');
      }
    });

    test(
        'owned details codec encodes matching details and rejects invalid details',
        () {
      for (final registration in collectarrKindRegistrationsList) {
        final codec = ownedDetailsFixtureForTest(registration.kind);
        final defaultDetails = codec.defaultDetails();
        expect(defaultDetails, isNotNull);

        // Encoding valid details must succeed
        final encoded = defaultDetails.toJson();
        expect(encoded, isA<Map<String, dynamic>>());

        // Encoding an invalid details type must throw ArgumentError
        final invalidDetails = switch (registration.kind) {
          CatalogMediaKind.comic => const BookOwnedDetails(),
          CatalogMediaKind.movie => const ComicOwnedDetails(),
          _ => null,
        };
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
      // Creating a registry with a mismatched column namespace throws.
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
