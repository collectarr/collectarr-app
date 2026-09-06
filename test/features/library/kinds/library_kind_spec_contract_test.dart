import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/kinds/registry/owned_details_exports.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LibraryKindSpec Contract & Capability Tests', () {
    test('all 9 active kind specs pass runtime validation', () {
      expect(collectarrKindModules.length, 9);
      for (final spec in collectarrKindModules) {
        expect(() => validateKindRuntime(spec), returnsNormally,
            reason: 'Spec for ${spec.kind} must pass validation');
      }
    });

    test('all active kind specs have non-null required core properties', () {
      for (final spec in collectarrKindModules) {
        expect(spec.kind, isNotNull);
        expect(spec.identity, isNotNull);
        expect(spec.metadata, isNotNull);
        expect(spec.hierarchy, isNotNull);
        expect(spec.inspector, isNotNull);
        expect(spec.presentation, isNotNull);
        expect(spec.viewProfile, isNotNull);
        expect(spec.fields, isNotNull);
        expect(spec.projector, isNotNull);
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
      final specsWithoutToolbar =
          collectarrKindModules.where((s) => s.kind != CatalogMediaKind.comic);
      for (final spec in specsWithoutToolbar) {
        expect(spec.toolbar, isNull,
            reason: '${spec.kind} should have null toolbar when absent');
      }
    });

    test(
        'owned details codec encodes matching details and rejects mismatched details',
        () {
      for (final spec in collectarrKindModules) {
        final defaultDetails = spec.defaultOwnedDetails();
        expect(defaultDetails, isNotNull);

        // Encoding valid details must succeed
        final encoded = spec.encodeOwnedDetails(defaultDetails);
        expect(encoded, isA<Map<String, dynamic>>());

        // Encoding an incompatible details type must throw ArgumentError
        if (spec.kind == CatalogMediaKind.comic) {
          expect(
            () => spec.encodeOwnedDetails(const BookOwnedDetails()),
            throwsArgumentError,
          );
        } else if (spec.kind == CatalogMediaKind.movie) {
          expect(
            () => spec.encodeOwnedDetails(const ComicOwnedDetails()),
            throwsArgumentError,
          );
        }
      }
    });

    test('immutable registry requires and tryGets specs correctly', () {
      final registry = LibraryKindRegistry(collectarrKindModules);
      expect(registry.allRuntimes.length, 9);
      expect(registry.require(CatalogMediaKind.comic), comicKindModule);
      expect(registry.tryGet(CatalogMediaKind.comic), comicKindModule);
      expect(registry.tryGet(CatalogMediaKind.unknown), isNull);
      expect(
        () => registry.require(CatalogMediaKind.unknown),
        throwsArgumentError,
      );
    });

    test('registry throws StateError on duplicate registration', () {
      expect(
        () => LibraryKindRegistry([comicKindModule, comicKindModule]),
        throwsStateError,
      );
    });

    test('validation detects kind and namespace mismatches', () {
      // Create an invalid spec with a kind/field namespace mismatch.
      final mismatchedTypeSpec =
          LibraryKindSpec<ComicWorkspaceDto, ComicOwnedDetails>(
        identity: LibraryKindIdentity(
          kind: bookKindModule.identity.kind,
          singularLabel: comicKindModule.identity.singularLabel,
          pluralLabel: comicKindModule.identity.pluralLabel,
          title: bookKindModule.identity.title,
          icon: bookKindModule.identity.icon,
          accent: bookKindModule.identity.accent,
          preferencePrefix: bookKindModule.identity.preferencePrefix,
          defaultDensityPreset: bookKindModule.identity.defaultDensityPreset,
          availableDensityPresets:
              bookKindModule.identity.availableDensityPresets,
          toolbarActions: bookKindModule.identity.toolbarActions,
        ),
        viewProfile: comicKindModule.viewProfile,
        fields: comicKindModule.fields,
        projector: comicKindModule.projector,
        ownedDetailsCodec: comicKindModule.ownedDetailsCodec,
        metadata: comicKindModule.metadata,
        hierarchy: comicKindModule.hierarchy,
        inspector: comicKindModule.inspector,
        presentation: comicKindModule.presentation,
        trackingProfile: comicKindModule.trackingProfile,
        transfer: comicKindModule.transfer,
        add: comicKindModule.add,
        edit: comicKindModule.edit,
      );
      expect(
        () => validateKindRuntime(mismatchedTypeSpec),
        throwsStateError,
      );

      // Creating registry with mismatched column namespace throws StateError
      expect(
        () => LibraryFieldRegistry<BookWorkspaceDto>(
          kindNamespace: 'comic', // Mismatched namespace for book columns
          columns: bookKindModule.fields.columns,
          sorts: bookKindModule.fields.sorts,
          groups: bookKindModule.fields.groups,
          defaultVisibleColumns: bookKindModule.fields.defaultVisibleColumns,
          defaultSort: bookKindModule.fields.defaultSort,
          defaultGroup: bookKindModule.fields.defaultGroup,
          preferenceCodec: bookKindModule.fields.preferenceCodec,
        ),
        throwsStateError,
      );
    });
  });
}
