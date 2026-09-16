import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/workspace/config/library_projection_capability.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/anime/release/anime_release_detail_source.dart';

final class AnimeReleaseProjectionCapability<TDto extends LibraryWorkspaceDto>
    implements ReleaseProjectionCapability<TDto> {
  const AnimeReleaseProjectionCapability();

  @override
  List<LibraryProjectionItem<TDto>> projectReleases({
    required LibraryWorkspaceSource source,
    required LibraryKindRegistration type,
    required LibraryEntityWorkspaceProjector<TDto> projector,
    required List<CustomFieldDefinition> customFieldDefinitions,
    required Map<String, Map<String, String>>
        customFieldValuesByDefinitionByItem,
    required Map<String, List<String>> customFieldValuesByItem,
    String? requestedWorkId,
  }) {
    const releaseSource = AnimeReleaseDetailSource();
    final catalogData = source.catalogData;
    if (catalogData == null || catalogData.kind != type.kind) return const [];
    final requestedId = requestedWorkId?.trim();
    if (requestedId != null &&
        requestedId.isNotEmpty &&
        catalogData.ref.id != requestedId) {
      return const [];
    }

    final resolvedEditions = releaseSource.resolveCatalogData(
      catalogData,
      ownedItems:
          source.ownedSummary == null ? const [] : [source.ownedSummary!],
      wishlistItems:
          source.wishlistItem == null ? const [] : [source.wishlistItem!],
    );
    if (resolvedEditions.isEmpty) {
      return const [];
    }

    final items = <LibraryProjectionItem<TDto>>[];
    for (final edition in resolvedEditions) {
      final ownedTargetRef = source.ownedSummary?.targetRef;
      final ownedMatches = ownedTargetRef == null
          ? false
          : releaseSource.matchesTarget(ownedTargetRef, edition);
      final wishlistMatches = source.wishlistItem == null
          ? false
          : releaseSource.matchesTarget(
              source.wishlistItem!.catalogRef,
              edition,
            );

      final releaseNode = LibraryReleaseRef(
        workId: catalogData.ref.id,
        releaseId: edition.id,
        release: releaseSource.workspaceSummaryForEdition(edition),
      );
      final releaseState = LibraryReleaseState(
        isOwned: ownedMatches,
        isWishlisted: wishlistMatches,
        isTracked: source.isTracked,
        trackingSummary: source.trackingSummary,
      );

      final dto = projector.project(
        source: source,
        entity: releaseNode,
        releaseState: releaseState,
      );

      items.add(
        LibraryProjectionItem<TDto>(
          source: source,
          node: releaseNode,
          dto: dto,
          customFieldBadges: customFieldBadgesForNode(
            source: source,
            node: releaseNode,
            customFieldDefinitions: customFieldDefinitions,
            customFieldValuesByDefinitionByItem:
                customFieldValuesByDefinitionByItem,
            customFieldValuesByItem: customFieldValuesByItem,
          ),
        ),
      );
    }
    return items;
  }
}
