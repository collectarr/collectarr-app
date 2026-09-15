import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/workspace/config/library_projection_capability.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';

/// Projects MusicBrainz release groups into their concrete releases.
///
/// Music's media scope is a [MusicReleaseGroup]. The release scope contains
/// only [MusicRelease] rows; mediums and tracks remain inside the selected
/// release's typed workspace DTO.
final class MusicReleaseProjectionCapability<TDto extends LibraryWorkspaceDto>
    implements ReleaseProjectionCapability<TDto> {
  const MusicReleaseProjectionCapability();

  @override
  List<LibraryProjectionItem<TDto>> projectReleases({
    required LibraryWorkspaceSource source,
    required LibraryKindRegistration type,
    required LibraryWorkspaceProjector<TDto> projector,
    required List<CustomFieldDefinition> customFieldDefinitions,
    required Map<String, Map<String, String>>
        customFieldValuesByDefinitionByItem,
    required Map<String, List<String>> customFieldValuesByItem,
    String? requestedTitleId,
  }) {
    final catalogData = source.catalogData;
    if (catalogData is! MusicWorkspaceCatalogData ||
        catalogData.kind != type.kind) {
      return const [];
    }
    final requestedId = requestedTitleId?.trim();
    if (requestedId != null &&
        requestedId.isNotEmpty &&
        catalogData.ref.id != requestedId) {
      return const [];
    }

    return [
      for (final release in catalogData.music.releases)
        _projectRelease(
          source: source,
          type: type,
          projector: projector,
          catalogData: catalogData,
          release: release,
          customFieldDefinitions: customFieldDefinitions,
          customFieldValuesByDefinitionByItem:
              customFieldValuesByDefinitionByItem,
          customFieldValuesByItem: customFieldValuesByItem,
        ),
    ];
  }

  LibraryProjectionItem<TDto> _projectRelease({
    required LibraryWorkspaceSource source,
    required LibraryKindRegistration type,
    required LibraryWorkspaceProjector<TDto> projector,
    required MusicWorkspaceCatalogData catalogData,
    required MusicRelease release,
    required List<CustomFieldDefinition> customFieldDefinitions,
    required Map<String, Map<String, String>>
        customFieldValuesByDefinitionByItem,
    required Map<String, List<String>> customFieldValuesByItem,
  }) {
    final releaseNode = LibraryReleaseNodeRef(
      titleItemId: catalogData.ref.id,
      releaseId: release.id.value,
      release: _summaryFor(release),
    );
    final releaseState = LibraryReleaseState(
      isOwned: _targetMatches(
        source.ownedSummary?.targetRef,
        root: catalogData.ref,
        release: release,
      ),
      isWishlisted: _targetMatches(
        source.wishlistItem?.catalogRef,
        root: catalogData.ref,
        release: release,
      ),
      isTracked: source.isTracked,
    );
    final dto = projector.projectRelease(
      source: source,
      node: releaseNode,
      releaseState: releaseState,
    );
    return LibraryProjectionItem<TDto>(
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
    );
  }
}

LibraryWorkspaceReleaseSummary _summaryFor(MusicRelease release) {
  return LibraryWorkspaceReleaseSummary(
    id: release.id.value,
    title: release.title,
    formatLabel: release.mediums.isEmpty
        ? release.releaseType
        : release.mediums.first.mediumType ?? release.releaseType,
    releaseDate: release.releaseDate,
    mediaLabels: [
      for (final medium in release.mediums)
        medium.title ?? 'Medium ${medium.mediumNumber}',
    ],
  );
}

bool _targetMatches(
  CatalogEntityRef? target, {
  required CatalogEntityRef root,
  required MusicRelease release,
}) {
  if (target == null || target.kind != CatalogMediaKind.music) return false;
  if (target.rootScope.id != root.rootScope.id) return false;

  final releaseId = release.id.value;
  if (target.id == releaseId || target.parentId == releaseId) return true;

  // A root target means the complete release group is owned/wishlisted.
  return target.entityType == CatalogEntityTypeId.root;
}
