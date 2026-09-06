import 'package:collectarr_app/core/api/api_client.dart';

import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/config/library_linked_metadata_capability.dart';
import 'package:collectarr_app/features/library/config/library_stats_capability.dart';
import 'package:collectarr_app/features/library/config/library_value_capability.dart';
import 'package:collectarr_app/features/library/config/library_relation_capability.dart';
import 'package:collectarr_app/features/library/config/library_kind_identity.dart';
import 'package:collectarr_app/features/library/config/library_metadata_capability.dart';
import 'package:collectarr_app/features/library/config/library_hierarchy_capability.dart';
import 'package:collectarr_app/features/library/config/library_inspector_capability.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/library_transfer_capability.dart';
import 'package:collectarr_app/features/library/config/library_ui_policy.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/config/owned_details_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/config/library_projection_capability.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/shared/library_media_adapter_builder.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';

import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';

export 'package:collectarr_app/features/library/config/library_edit_capability.dart';
export 'package:collectarr_app/features/library/config/library_kind_identity.dart';
export 'package:collectarr_app/features/library/config/library_metadata_capability.dart';
export 'package:collectarr_app/features/library/config/library_hierarchy_capability.dart';
export 'package:collectarr_app/features/library/config/library_inspector_capability.dart';
export 'package:collectarr_app/features/library/config/library_transfer_capability.dart';
export 'package:collectarr_app/features/library/config/library_ui_policy.dart';
export 'package:collectarr_app/features/library/config/library_facet_types.dart';
export 'package:collectarr_app/features/library/config/library_stats_capability.dart';
export 'package:collectarr_app/features/library/config/library_value_capability.dart';
export 'package:collectarr_app/features/library/config/library_relation_capability.dart';
export 'package:collectarr_app/features/library/config/library_linked_metadata_capability.dart';
export 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
export 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';
export 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';

typedef CatalogMetadataDecoder = Object? Function(
  Map<String, dynamic> payload,
);

/// Migration-only compatibility surface for existing generic callers.
///
/// Do not add members here. New dispatch contracts belong in
/// [LibraryKindRegistration] or in the concrete kind module that owns them.
abstract interface class LibraryKindRuntime {
  CatalogMediaKind get kind;
  LibraryKindIdentity get identity;
  LibraryMediaPresentation get presentation;
  LibraryMetadataCapability get metadata;
  MediaTrackingProfile get trackingProfile;
  LibraryHierarchyCapability get hierarchy;
  LibraryInspectorCapability get inspector;
  LibraryEditCapability get edit;
  LibraryTransferCapability get transfer;
  LibraryStatsCapability get stats;
  LibraryValueCapability? get value;
  LibraryRelationCapability? get relations;
  LibraryUiPolicy get uiPolicy;
  LibraryFieldRegistry<LibraryWorkspaceDto> get fields;
  LibraryLinkedMetadataCapability get linkedMetadata;
  LibraryWorkspaceProjector<LibraryWorkspaceDto> get projector;
  LibraryAddCapability get add;
  LibraryAddChromeConfig get addChrome => add.chrome;
  TitleProjectionCapability<LibraryWorkspaceDto> get titleCapability;
  ReleaseProjectionCapability<LibraryWorkspaceDto>? get releaseCapability;
  LibraryKindToolbarModule? get toolbar;
  LibraryKindProviderMapper? get providerMapper;
  LibraryFacetModule? get facets;
  CatalogMetadataDecoder? get catalogMetadataDecoder;
  List<LibrarySearchTarget> get searchTargetOptions;

  LibraryWorkspaceViewProfile get viewProfile;

  List<LibraryGroupIdRuntime> get availableGroupIds;
  List<LibraryGroupIdRuntime> availableGroupIdsForBrowserMode(
    LibraryWorkspaceBrowserMode browserMode,
  );
  List<LibrarySortIdRuntime> availableSortIdsForBrowserMode(
    LibraryWorkspaceBrowserMode browserMode,
  );

  Set<LibraryFieldIdRuntime> defaultTableColumns();
  List<LibraryFieldIdRuntime> orderedTableColumns(
      Set<LibraryFieldIdRuntime> columns);
  double tableWidthForColumns(
    Set<LibraryFieldIdRuntime> columns,
    Map<LibraryFieldIdRuntime, double> customWidths,
  );
  double tableColumnWidth(
    LibraryFieldIdRuntime column,
    Map<LibraryFieldIdRuntime, double> customWidths,
  );
  double defaultTableColumnWidth(LibraryFieldIdRuntime column);
  String columnLabel(LibraryFieldIdRuntime column);
  String columnDisplayName(LibraryFieldIdRuntime column);
  LibraryTableColumnGroup columnGroup(LibraryFieldIdRuntime column);
  String columnGroupLabel(LibraryTableColumnGroup group);
  bool columnIsNumeric(LibraryFieldIdRuntime column);
  LibrarySortIdRuntime? columnSort(LibraryFieldIdRuntime column);
  Widget buildTableCell(
    LibraryProjectionRuntime item,
    LibraryFieldIdRuntime column,
  );
  int compareEntriesByRules(
    LibraryProjectionRuntime left,
    LibraryProjectionRuntime right,
    Iterable<LibrarySortRuleRuntime> rules,
  );
  String? subgroupKeyForEntry(
    LibraryProjectionRuntime item,
    LibraryGroupIdRuntime groupId,
  );
  int compareSubgroupKeys(
    String left,
    String right,
    LibraryGroupIdRuntime groupId,
  );

  OwnedItemDetails decodeOwnedDetails(Map<String, dynamic> json);
  OwnedItemDetails defaultOwnedDetails();
  OwnedDetailsDraft defaultOwnedDetailsDraft();
  OwnedDetailsDraft ownedDetailsDraftFromDetails(OwnedItemDetails details);
  OwnedDetailsDraft buildPersonalDetailsDraft(
      LibraryPersonalEditSelection personal);
  Map<String, dynamic> encodeOwnedDetails(OwnedItemDetails details);
  void validateOwnedDetails(OwnedItemDetails details);

  LibraryProjectionRuntime project({
    required ShelfEntry source,
    required LibraryNodeRef node,
  });

  LibraryCardPresentation buildCard(
    LibraryProjectionRuntime item, {
    required bool musicVertical,
  });

  LibraryCardPresentation? buildCardPresentation(
    LibraryProjectionRuntime item, {
    required bool musicVertical,
  });

  void sort(
    List<LibraryProjectionRuntime> items,
    LibrarySortIdRuntime sortId, {
    bool ascending = true,
  });

  int compare(
    LibraryProjectionRuntime left,
    LibraryProjectionRuntime right,
    LibrarySortIdRuntime sortId,
  );

  Object? groupValue(
    LibraryProjectionRuntime item,
    LibraryGroupIdRuntime groupId,
  );

  bool groupModeSupportsCompletion(LibraryGroupIdRuntime groupId);

  String? groupSequenceValueForEntry(
    LibraryProjectionRuntime item,
    LibraryGroupIdRuntime groupId,
  );

  Object? columnValue(
    LibraryProjectionRuntime item,
    LibraryFieldIdRuntime columnId,
  );

  void validateProjection(LibraryProjectionRuntime item);

  LibraryWorkspaceDto createWorkspaceDto({
    required ShelfEntry source,
    required LibraryNodeRef node,
  });

  LibraryKindRuntime withCatalogMetadata({
    required LibraryKindIdentity identity,
    required LibraryMetadataCapability metadata,
  });
}

class LibraryKindSpec<
    TDto extends LibraryWorkspaceDto,
    TDetails extends OwnedItemDetails,
    TDetailsDraft extends OwnedDetailsDraft> implements LibraryKindRuntime {
  const LibraryKindSpec({
    required this.fields,
    required this.projector,
    required this.ownedDetailsCodec,
    required this.add,
    required this.edit,
    required this.identity,
    required this.metadata,
    required this.hierarchy,
    required this.inspector,
    required this.presentation,
    required this.trackingProfile,
    this.uiPolicy = const LibraryUiPolicy(),
    this.titleCapability = const DefaultTitleProjectionCapability(),
    this.releaseCapability,
    this.linkedMetadata = const DefaultLibraryLinkedMetadataCapability(),
    required this.transfer,
    this.stats = const DefaultLibraryStatsCapability(),
    this.value,
    this.relations,
    this.toolbar,
    this.providerMapper,
    this.facets,
    this.catalogMetadataDecoder,
    this.searchTargetOptions = const [],
    LibraryWorkspaceViewProfile? viewProfile,
    LibraryCardPresentation Function(
      LibraryProjectionRuntime item, {
      required bool musicVertical,
    })? buildCardPresentation,
  })  : _viewProfile = viewProfile,
        _buildCardPresentation = buildCardPresentation;

  final OwnedDetailsCodec<TDetails, TDetailsDraft> ownedDetailsCodec;
  @override
  final CatalogMetadataDecoder? catalogMetadataDecoder;
  @override
  final LibraryKindIdentity identity;

  @override
  final LibraryMediaPresentation presentation;
  @override
  final LibraryMetadataCapability metadata;
  @override
  final LibraryHierarchyCapability hierarchy;
  @override
  final LibraryInspectorCapability inspector;
  @override
  final LibraryLinkedMetadataCapability linkedMetadata;
  @override
  final LibraryTransferCapability transfer;
  @override
  final LibraryStatsCapability stats;
  @override
  final LibraryValueCapability? value;
  @override
  final LibraryRelationCapability? relations;
  @override
  final LibraryEditCapability edit;
  @override
  final MediaTrackingProfile trackingProfile;
  @override
  final LibraryUiPolicy uiPolicy;
  @override
  final TitleProjectionCapability<LibraryWorkspaceDto> titleCapability;
  @override
  final ReleaseProjectionCapability<LibraryWorkspaceDto>? releaseCapability;

  @override
  LibraryAddChromeConfig get addChrome => add.chrome;

  @override
  LibraryKindRuntime withCatalogMetadata({
    required LibraryKindIdentity identity,
    required LibraryMetadataCapability metadata,
  }) {
    return LibraryKindSpec<TDto, TDetails, TDetailsDraft>(
      fields: fields,
      projector: projector,
      ownedDetailsCodec: ownedDetailsCodec,
      add: add,
      edit: edit,
      identity: identity,
      metadata: metadata,
      hierarchy: hierarchy,
      inspector: inspector,
      presentation: presentation,
      trackingProfile: trackingProfile,
      uiPolicy: uiPolicy,
      titleCapability: titleCapability,
      releaseCapability: releaseCapability,
      linkedMetadata: linkedMetadata,
      transfer: transfer,
      stats: stats,
      value: value,
      relations: relations,
      toolbar: toolbar,
      providerMapper: providerMapper,
      facets: facets,
      catalogMetadataDecoder: catalogMetadataDecoder,
      searchTargetOptions: searchTargetOptions,
      viewProfile: _viewProfile,
      buildCardPresentation: _buildCardPresentation,
    );
  }

  @override
  OwnedItemDetails decodeOwnedDetails(Map<String, dynamic> json) =>
      ownedDetailsCodec.fromJson(json);

  @override
  OwnedItemDetails defaultOwnedDetails() => ownedDetailsCodec.defaultDetails();

  @override
  OwnedDetailsDraft defaultOwnedDetailsDraft() =>
      ownedDetailsCodec.defaultDraft();

  @override
  OwnedDetailsDraft ownedDetailsDraftFromDetails(OwnedItemDetails details) {
    validateOwnedDetails(details);
    return ownedDetailsCodec.draftFromDetails(details as TDetails);
  }

  @override
  OwnedDetailsDraft buildPersonalDetailsDraft(
          LibraryPersonalEditSelection personal) =>
      ownedDetailsCodec.buildDraft(personal);

  @override
  Map<String, dynamic> encodeOwnedDetails(OwnedItemDetails details) {
    validateOwnedDetails(details);
    return ownedDetailsCodec.toJson(details as TDetails);
  }

  @override
  void validateOwnedDetails(OwnedItemDetails details) {
    ownedDetailsCodec.validate(details);
  }

  @override
  CatalogMediaKind get kind => identity.kind;

  final LibraryWorkspaceViewProfile? _viewProfile;

  @override
  LibraryWorkspaceViewProfile get viewProfile =>
      _viewProfile ?? plannedMediaWorkspaceViewProfile(this);

  @override
  List<LibraryGroupIdRuntime> get availableGroupIds => [
        for (final definition in fields.groups) definition.id,
      ];

  @override
  List<LibraryGroupIdRuntime> availableGroupIdsForBrowserMode(
    LibraryWorkspaceBrowserMode browserMode,
  ) {
    final allGroups = availableGroupIds;
    final hierarchyCapability = hierarchy;
    if (!hierarchyCapability.scopesOptionsByBrowserMode) {
      return allGroups;
    }
    final scopedGroups = browserMode == LibraryWorkspaceBrowserMode.releases
        ? hierarchyCapability.releaseScopeGroupIds
        : hierarchyCapability.mediaScopeGroupIds;
    if (scopedGroups == null) {
      return allGroups;
    }
    return [
      for (final groupId in allGroups)
        if (scopedGroups.any((scopedId) => scopedId.sameIdentityAs(groupId)))
          groupId,
    ];
  }

  @override
  List<LibrarySortIdRuntime> availableSortIdsForBrowserMode(
    LibraryWorkspaceBrowserMode browserMode,
  ) {
    final allSorts = [
      for (final definition in fields.sorts) definition.id,
    ];
    final hierarchyCapability = hierarchy;
    if (!hierarchyCapability.scopesOptionsByBrowserMode) {
      return allSorts;
    }
    final scopedSorts = browserMode == LibraryWorkspaceBrowserMode.releases
        ? hierarchyCapability.releaseScopeSortIds
        : hierarchyCapability.mediaScopeSortIds;
    if (scopedSorts == null) {
      return allSorts;
    }
    return [
      for (final sortId in allSorts)
        if (scopedSorts.any((scopedId) => scopedId.sameIdentityAs(sortId)))
          sortId,
    ];
  }

  @override
  Set<LibraryFieldIdRuntime> defaultTableColumns() =>
      fields.defaultVisibleColumns;

  @override
  List<LibraryFieldIdRuntime> orderedTableColumns(
          Set<LibraryFieldIdRuntime> columns) =>
      orderedLibraryTableColumns(
        columns: columns,
        defaultColumns: fields.defaultVisibleColumns,
      );

  @override
  double tableWidthForColumns(
    Set<LibraryFieldIdRuntime> columns,
    Map<LibraryFieldIdRuntime, double> customWidths,
  ) =>
      plannedMediaTableWidthForColumns(
        type: this,
        columns: columns,
        customWidths: customWidths,
      );

  @override
  double tableColumnWidth(
    LibraryFieldIdRuntime column,
    Map<LibraryFieldIdRuntime, double> customWidths,
  ) =>
      plannedMediaTableColumnWidth(this, column, customWidths);

  @override
  double defaultTableColumnWidth(LibraryFieldIdRuntime column) =>
      defaultPlannedMediaTableColumnWidth(this, column);

  @override
  String columnLabel(LibraryFieldIdRuntime column) =>
      plannedMediaTableColumnLabelForType(this, column);

  @override
  String columnDisplayName(LibraryFieldIdRuntime column) =>
      plannedMediaTableColumnDisplayNameForType(this, column);

  @override
  LibraryTableColumnGroup columnGroup(LibraryFieldIdRuntime column) =>
      plannedMediaTableColumnGroup(this, column);

  @override
  String columnGroupLabel(LibraryTableColumnGroup group) =>
      plannedMediaTableColumnGroupLabel(group);

  @override
  bool columnIsNumeric(LibraryFieldIdRuntime column) =>
      plannedMediaTableColumnIsNumeric(this, column);

  @override
  LibrarySortIdRuntime? columnSort(LibraryFieldIdRuntime column) =>
      plannedMediaTableColumnSort(this, column);

  @override
  Widget buildTableCell(
    LibraryProjectionRuntime item,
    LibraryFieldIdRuntime column,
  ) {
    validateProjection(item);
    return plannedMediaTableCellTyped(fields, item, column);
  }

  @override
  int compareEntriesByRules(
    LibraryProjectionRuntime left,
    LibraryProjectionRuntime right,
    Iterable<LibrarySortRuleRuntime> rules,
  ) {
    for (final rule in rules) {
      final sortDef = fields.findSortDefinition(rule.sortId);
      if (sortDef != null) {
        final result = sortDef.compare(
          LibraryProjectionContext(
              source: left.source, node: left.node, dto: left.dto as TDto),
          LibraryProjectionContext(
              source: right.source, node: right.node, dto: right.dto as TDto),
        );
        if (result != 0) {
          return rule.ascending ? result : -result;
        }
      }
    }
    return left.dto.title.toLowerCase().compareTo(
          right.dto.title.toLowerCase(),
        );
  }

  @override
  String? subgroupKeyForEntry(
    LibraryProjectionRuntime item,
    LibraryGroupIdRuntime groupId,
  ) {
    validateProjection(item);
    final groupDef = fields.findGroupDefinition(groupId);
    final subgroupKey = groupDef?.subgroupKey;
    if (subgroupKey == null) {
      return null;
    }
    final context = LibraryProjectionContext<TDto>(
      source: item.source,
      node: item.node,
      dto: item.dto as TDto,
    );
    return subgroupKey(context);
  }

  @override
  int compareSubgroupKeys(
    String left,
    String right,
    LibraryGroupIdRuntime groupId,
  ) {
    final groupDefinition = fields.findGroupDefinition(groupId);
    if (groupDefinition?.subgroupKey == null) {
      return left.compareTo(right);
    }
    return plannedMediaCompareSubgroupKeys(left, right);
  }

  @override
  final LibraryFieldRegistry<TDto> fields;

  @override
  final LibraryWorkspaceProjector<TDto> projector;

  @override
  final LibraryAddCapability add;
  @override
  final LibraryKindToolbarModule? toolbar;
  @override
  final LibraryKindProviderMapper? providerMapper;
  @override
  final LibraryFacetModule? facets;
  @override
  final List<LibrarySearchTarget> searchTargetOptions;

  final LibraryCardPresentation Function(
    LibraryProjectionRuntime item, {
    required bool musicVertical,
  })? _buildCardPresentation;

  @override
  LibraryProjectionRuntime project({
    required ShelfEntry source,
    required LibraryNodeRef node,
  }) {
    final dto = createWorkspaceDto(source: source, node: node);
    return LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );
  }

  @override
  LibraryCardPresentation buildCard(
    LibraryProjectionRuntime item, {
    required bool musicVertical,
  }) {
    validateProjection(item);
    final custom =
        _buildCardPresentation?.call(item, musicVertical: musicVertical);
    if (custom != null) return custom;
    return const LibraryCardPresentation();
  }

  @override
  LibraryCardPresentation? buildCardPresentation(
    LibraryProjectionRuntime item, {
    required bool musicVertical,
  }) {
    return buildCard(item, musicVertical: musicVertical);
  }

  @override
  void sort(
    List<LibraryProjectionRuntime> items,
    LibrarySortIdRuntime sortId, {
    bool ascending = true,
  }) {
    for (final item in items) {
      validateProjection(item);
    }
    fields.sortEntries(
      items,
      sortId,
      ascending: ascending,
    );
  }

  @override
  int compare(
    LibraryProjectionRuntime left,
    LibraryProjectionRuntime right,
    LibrarySortIdRuntime sortId,
  ) {
    validateProjection(left);
    validateProjection(right);
    return fields.compareEntries(left, right, sortId);
  }

  @override
  Object? groupValue(
    LibraryProjectionRuntime item,
    LibraryGroupIdRuntime groupId,
  ) {
    validateProjection(item);
    return fields.getGroupValue(item, groupId);
  }

  @override
  bool groupModeSupportsCompletion(LibraryGroupIdRuntime groupId) {
    return fields.findGroupDefinition(groupId)?.sequenceValue != null;
  }

  @override
  String? groupSequenceValueForEntry(
    LibraryProjectionRuntime item,
    LibraryGroupIdRuntime groupId,
  ) {
    return fields.getGroupSequenceValue(
      item,
      groupId,
    );
  }

  @override
  Object? columnValue(
    LibraryProjectionRuntime item,
    LibraryFieldIdRuntime columnId,
  ) {
    validateProjection(item);
    return fields.getColumnValue(item, columnId);
  }

  @override
  void validateProjection(LibraryProjectionRuntime item) {
    if (item.dto is! TDto) {
      throw ArgumentError(
        'Incompatible projection item DTO "${item.dto.runtimeType}" for media kind "${kind.apiValue}". Expected "$TDto".',
      );
    }
  }

  @override
  LibraryWorkspaceDto createWorkspaceDto({
    required ShelfEntry source,
    required LibraryNodeRef node,
  }) {
    return switch (node) {
      LibraryTitleNodeRef() => projector.projectTitle(
          source: source,
          node: node,
        ),
      LibraryReleaseNodeRef() => projector.projectRelease(
          source: source,
          node: node,
          releaseState: LibraryReleaseState(
            isOwned: source.isOwned,
            isWishlisted: source.isWishlisted,
            isTracked: source.isTracked,
          ),
        ),
      LibraryCopyNodeRef() => projector.projectCopy(
          source: source,
          node: node,
        ),
    };
  }
}

void validateKindRuntime(LibraryKindRuntime runtime) {
  if (runtime.fields.kindNamespace != runtime.kind.apiValue) {
    throw StateError(
      'Namespace mismatch in spec for "${runtime.identity.title}": fields.kindNamespace=${runtime.fields.kindNamespace}, expected=${runtime.kind.apiValue}',
    );
  }

  final columnIds = <String>{};
  for (final col in runtime.fields.columns) {
    if (!columnIds.add(col.id.value)) {
      throw StateError(
        'Duplicate column ID "${col.id.value}" in kind spec "${runtime.identity.title}"',
      );
    }
  }

  final sortIds = <String>{};
  for (final sort in runtime.fields.sorts) {
    if (!sortIds.add(sort.id.value)) {
      throw StateError(
        'Duplicate sort ID "${sort.id.value}" in kind spec "${runtime.identity.title}"',
      );
    }
  }

  final groupIds = <String>{};
  for (final group in runtime.fields.groups) {
    if (!groupIds.add(group.id.value)) {
      throw StateError(
        'Duplicate group ID "${group.id.value}" in kind spec "${runtime.identity.title}"',
      );
    }
  }

  for (final colId in runtime.fields.defaultVisibleColumns) {
    if (runtime.fields.findColumnDefinition(colId) == null) {
      throw StateError(
        'Default visible column ID "$colId" not found in columns for kind spec "${runtime.identity.title}"',
      );
    }
  }

  if (runtime.fields.findSortDefinition(runtime.fields.defaultSort) == null) {
    throw StateError(
      'Default sort ID "${runtime.fields.defaultSort.value}" not found in sorts for kind spec "${runtime.identity.title}"',
    );
  }

  if (runtime.fields.defaultGroup != null &&
      runtime.fields.findGroupDefinition(runtime.fields.defaultGroup!) ==
          null) {
    throw StateError(
      'Default group ID "${runtime.fields.defaultGroup!.value}" not found in groups for kind spec "${runtime.identity.title}"',
    );
  }

  runtime.validateOwnedDetails(runtime.defaultOwnedDetails());
}

class LibraryKindToolbarModule {
  const LibraryKindToolbarModule({
    this.actions = const [],
  });

  final List<LibraryToolbarActionDescriptor> actions;
}

abstract interface class LibraryKindProviderMapper {
  CatalogItem metadataItemFromEnvelope(NormalizedProviderEnvelopeV1 envelope);

  Map<String, Object?> buildCorrections({
    required CatalogItem preview,
    required CatalogItem edited,
  });
}

abstract interface class TypedLibraryKindProviderMapper<TCatalog>
    implements LibraryKindProviderMapper {
  TCatalog catalogFromEnvelope(NormalizedProviderEnvelopeV1 envelope);
}

class LibraryFacetModule {
  const LibraryFacetModule({
    this.loadRows,
    this.getFacetValues,
    this.definitions = const [],
    this.externalFacetBucketIdsByMode = const {},
  });

  final LibraryFacetRowsLoader? loadRows;
  final Iterable<String> Function(
          LibraryProjectionRuntime item, LibraryFacetIdRuntime facetId)?
      getFacetValues;
  final List<LibraryFacetDefinition<dynamic, dynamic, dynamic>> definitions;
  final Map<String, LibraryFacetIdRuntime> externalFacetBucketIdsByMode;
}

typedef LibraryFacetRowsLoader = Future<List<Map<String, dynamic>>> Function({
  required LibraryFacetIdRuntime facetId,
  required Set<String> itemIds,
  required ApiClient api,
});
