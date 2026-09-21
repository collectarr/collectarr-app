import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/release/library_release_detail_option.dart';
import 'package:collectarr_app/features/library/release/library_release_detail_source.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/config/library_projection_capability.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

typedef LibraryReleaseSummariesBuilder
    = Iterable<LibraryWorkspaceReleaseSummary> Function(
  LibraryWorkspaceCatalogData catalogData,
);

typedef LibraryReleaseTargetBuilder = CatalogEntityRef Function(
  CatalogEntityRef rootRef,
  LibraryWorkspaceReleaseSummary summary,
);

typedef LibraryReleaseCandidateBuilder = CatalogSearchCandidate Function(
  LibraryWorkspaceCatalogData catalogData,
);

/// Generic host adapter for a kind-owned canonical Work -> Release graph.
///
/// The callbacks are deliberately structural. The owning kind still decides
/// which concrete releases exist and how a release maps to a catalog target;
/// this class only performs the repeated projection bookkeeping.
final class LibraryCatalogReleaseProjectionCapability<
        TDto extends LibraryWorkspaceDto>
    implements ReleaseProjectionCapability<TDto> {
  const LibraryCatalogReleaseProjectionCapability({
    required this.kind,
    required this.summariesFor,
    this.targetFor = defaultLibraryReleaseTarget,
  });

  final CatalogMediaKind kind;
  final LibraryReleaseSummariesBuilder summariesFor;
  final LibraryReleaseTargetBuilder targetFor;

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
    final catalogData = source.catalogData;
    if (catalogData == null || catalogData.kind != kind || type.kind != kind) {
      return const [];
    }
    final rootRef = catalogData.ref.rootScope;
    final requestedId = requestedWorkId?.trim();
    if (requestedId != null &&
        requestedId.isNotEmpty &&
        rootRef.id != requestedId) {
      return const [];
    }

    return [
      for (final summary in summariesFor(catalogData))
        _projectRelease(
          source: source,
          type: type,
          projector: projector,
          rootRef: rootRef,
          summary: summary,
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
    required LibraryEntityWorkspaceProjector<TDto> projector,
    required CatalogEntityRef rootRef,
    required LibraryWorkspaceReleaseSummary summary,
    required List<CustomFieldDefinition> customFieldDefinitions,
    required Map<String, Map<String, String>>
        customFieldValuesByDefinitionByItem,
    required Map<String, List<String>> customFieldValuesByItem,
  }) {
    final releaseTarget = targetFor(rootRef, summary);
    final releaseNode = LibraryReleaseRef(
      workId: rootRef.id,
      releaseId: summary.id,
      release: summary,
    );
    final releaseState = LibraryReleaseState(
      isOwned: _targetMatches(source.ownedSummary?.targetRef, rootRef, summary),
      isWishlisted:
          _targetMatches(source.wishlistItem?.catalogRef, rootRef, summary),
      isTracked: source.trackingSummaryFor(releaseTarget) != null,
      trackingSummary: source.trackingSummaryFor(releaseTarget),
    );
    final dto = projector.project(
      source: source,
      entity: releaseNode,
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

/// Release-detail adapter for kinds whose release graph is already fully
/// represented by [LibraryWorkspaceReleaseSummary].
final class LibraryCatalogReleaseDetailSource
    implements LibraryReleaseDetailSource {
  const LibraryCatalogReleaseDetailSource({
    required this.summariesFor,
    required this.candidateFor,
    this.targetFor = defaultLibraryReleaseTarget,
    this.sourceLabel = 'Catalog release',
  });

  final LibraryReleaseSummariesBuilder summariesFor;
  final LibraryReleaseCandidateBuilder candidateFor;
  final LibraryReleaseTargetBuilder targetFor;
  final String sourceLabel;

  @override
  CatalogSearchCandidate candidateForCatalogData(
    LibraryWorkspaceCatalogData catalogData,
  ) =>
      candidateFor(catalogData);

  @override
  List<LibraryReleaseDetailOption> detailOptionsForCatalogData(
    LibraryWorkspaceCatalogData catalogData,
    CatalogEntityRef rootRef, {
    Iterable<OwnedItemSummary> ownedItems = const <OwnedItemSummary>[],
    Iterable<WishlistItem> wishlistItems = const <WishlistItem>[],
  }) {
    return [
      for (final summary in summariesFor(catalogData))
        LibraryReleaseDetailOption(
          targetRef: targetFor(rootRef, summary),
          summary: summary,
          sourceLabel: sourceLabel,
          isCatalogRelease: true,
        ),
    ];
  }
}

CatalogEntityRef defaultLibraryReleaseTarget(
  CatalogEntityRef rootRef,
  LibraryWorkspaceReleaseSummary summary,
) {
  return CatalogEntityRef(
    kind: rootRef.kind,
    entityType: const CatalogEntityTypeId('edition'),
    id: summary.id,
    rootId: rootRef.rootScope.id,
  );
}

bool _targetMatches(
  CatalogEntityRef? target,
  CatalogEntityRef rootRef,
  LibraryWorkspaceReleaseSummary summary,
) {
  if (target == null || target.kind != rootRef.kind) return false;
  if (target.rootScope != rootRef.rootScope) return false;
  if (target.id == summary.id || target.parentId == summary.id) return true;
  return target.entityType == CatalogEntityTypeId.root;
}
