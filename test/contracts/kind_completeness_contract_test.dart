import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const activeKinds = [
    CatalogMediaKind.comic,
    CatalogMediaKind.manga,
    CatalogMediaKind.anime,
    CatalogMediaKind.book,
    CatalogMediaKind.game,
    CatalogMediaKind.boardgame,
    CatalogMediaKind.movie,
    CatalogMediaKind.tv,
    CatalogMediaKind.music,
  ];

  group('KindCompletenessContract Tests', () {
    test('all 9 production kinds are registered and have explicit capabilities',
        () {
      for (final kind in activeKinds) {
        final runtime = libraryKindRuntimeForKind(kind);
        expect(runtime, isNotNull,
            reason: '$kind must be registered in LibraryKindRegistry');

        // Kind and identity
        expect(runtime.kind, equals(kind),
            reason: '$kind runtime.kind must match declared kind');
        expect(runtime.identity.kind, equals(kind),
            reason: '$kind identity.kind must match declared kind');
        // Add capability
        final addCap = runtime.add;
        expect(addCap, isNotNull,
            reason: '$kind must have explicit add capability');
        expect(addCap.kind, equals(kind),
            reason: '$kind add capability must have matching kind');
        final initialDraft = addCap.createInitialDraft();
        expect(initialDraft, isNotNull,
            reason: '$kind initial add draft must be non-null');

        // Edit capability
        final editCap = runtime.edit;
        expect(editCap, isNotNull,
            reason: '$kind must have explicit edit capability');
        expect(editCap.createDraft, isNotNull,
            reason: '$kind must have explicit edit draft factory');

        // Owned details and codec
        expect(runtime.defaultOwnedDetails(), isNotNull,
            reason: '$kind defaultOwnedDetails must not be null');
        expect(runtime.defaultOwnedDetailsDraft(), isNotNull,
            reason: '$kind defaultOwnedDetailsDraft must not be null');

        // Fields & Schema
        expect(runtime.fields, isNotNull,
            reason: '$kind must have a field registry');
        expect(runtime.fields.kindNamespace, equals(kind.apiValue),
            reason: '$kind field registry namespace must match kind');
        expect(runtime.fields.columns.isNotEmpty, isTrue,
            reason: '$kind field registry must declare columns');
        expect(runtime.fields.sorts.isNotEmpty, isTrue,
            reason: '$kind field registry must declare sorts');
        expect(runtime.fields.groups.isNotEmpty, isTrue,
            reason: '$kind field registry must declare groups');

        // Projector
        expect(runtime.projector, isNotNull,
            reason: '$kind must have a workspace projector');

        // View Profile, Hierarchy, Metadata, Inspector, Transfer
        expect(runtime.viewProfile, isNotNull,
            reason: '$kind must have a view profile');
        expect(runtime.hierarchy, isNotNull,
            reason: '$kind must have hierarchy capability');
        expect(runtime.metadata, isNotNull,
            reason: '$kind must have metadata capability');
        expect(runtime.inspector, isNotNull,
            reason: '$kind must have inspector capability');
        expect(runtime.transfer, isNotNull,
            reason: '$kind must have transfer capability');
        expect(runtime.identity, isNotNull,
            reason: '$kind must have identity capability');
      }
    });

    test('no production kind uses generic fallback for core capabilities', () {
      for (final kind in activeKinds) {
        final runtime = libraryKindRuntimeForKind(kind);
        expect(runtime.kind, isNot(equals(CatalogMediaKind.unknown)));
        expect(runtime.identity.singularLabel.isNotEmpty, isTrue);
        expect(runtime.identity.pluralLabel.isNotEmpty, isTrue);
      }
    });

    test(
        'all 9 production kinds have distinct kind-owned details runtime types',
        () {
      final detailsTypes = <Type>{};
      for (final kind in activeKinds) {
        final runtime = libraryKindRuntimeForKind(kind);
        final defaultDetails = runtime.defaultOwnedDetails();
        expect(defaultDetails, isNotNull);
        expect(defaultDetails.runtimeType, isNot(equals(GenericOwnedDetails)));
        detailsTypes.add(defaultDetails.runtimeType);
      }
      expect(detailsTypes.length, equals(9),
          reason:
              'Every production kind must have its own distinct owned details type');
    });

    test('add draft identity contract matches kind exactly for all 9 kinds',
        () {
      final addDraftTypes = <Type>{};
      for (final kind in activeKinds) {
        final runtime = libraryKindRuntimeForKind(kind);
        final initialDraft = runtime.add.createInitialDraft();
        expect(initialDraft.kind, equals(runtime.kind),
            reason: '$kind add draft kind must match runtime.kind');
        expect(initialDraft.kind, isNot(equals(CatalogMediaKind.unknown)),
            reason: '$kind add draft must not be unknown');
        addDraftTypes.add(initialDraft.runtimeType);
      }
      expect(addDraftTypes.length, equals(9),
          reason:
              'Every production kind must have its own distinct add draft type');
    });

    test(
        'all fields are explicitly and strictly classified into correct scopes (Plan D)',
        () {
      for (final kind in activeKinds) {
        final runtime = libraryKindRuntimeForKind(kind);
        for (final field in runtime.fields.fields) {
          final id = field.id.value.toLowerCase();

          // 1. Copy / Personal fields
          if (id.contains('condition') ||
              id.contains('location') ||
              id.contains('price_paid') ||
              id.contains('pricepaid') ||
              id.endsWith('.rating') ||
              id.contains('wishlist') ||
              id.endsWith('.grade') ||
              id.contains('.grading_') ||
              id.contains('signed_by') ||
              id.contains('last_bag_board_date') ||
              id.contains('last_cleaned') ||
              id.contains('watch_status') ||
              id.contains('read_status') ||
              id.contains('updated_at') ||
              id.contains('added_at') ||
              id.contains('completeness')) {
            expect(field.scope, equals(LibraryFieldScope.copy),
                reason: '$kind field ${field.id.value} must have copy scope');
          }

          // 2. Release / Edition fields
          if (id.contains('barcode') ||
              id.contains('isbn') ||
              id.endsWith('.region') ||
              id.contains('.hdr') ||
              id.contains('catalog_number') ||
              id.endsWith('.edition') ||
              id.endsWith('.variant')) {
            expect(field.scope, equals(LibraryFieldScope.release),
                reason:
                    '$kind field ${field.id.value} must have release scope');
          }

          // 3. Media / Work fields
          if (id.contains('runtime') ||
              id.contains('genre') ||
              id.contains('mechanic') ||
              id.endsWith('.title') ||
              id.endsWith('.publisher') ||
              id.endsWith('.author') ||
              id.endsWith('.artist') ||
              id.endsWith('.writer') ||
              id.endsWith('.director') ||
              id.endsWith('.developer')) {
            expect(field.scope, equals(LibraryFieldScope.media),
                reason: '$kind field ${field.id.value} must have media scope');
          }
        }
      }
    });

    test(
        'edit draft creation produces kind-owned edit drafts with non-null factories',
        () {
      for (final kind in activeKinds) {
        final runtime = libraryKindRuntimeForKind(kind);
        expect(runtime.edit, isNotNull);
        expect(runtime.edit.createDraft, isNotNull);
      }
    });
  });
}
