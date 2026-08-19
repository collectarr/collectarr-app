import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
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
        expect(runtime.type.workspace.kind, equals(kind),
            reason: '$kind workspace.kind must match declared kind');

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

        // Media Adapter & Hierarchy
        expect(runtime.mediaAdapter, isNotNull,
            reason: '$kind must have a media adapter');
        expect(runtime.hierarchy, isNotNull,
            reason: '$kind must have hierarchy capability');
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
  });
}
