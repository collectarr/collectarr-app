import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_kind_codec.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';

export 'package:collectarr_app/core/api/dto/catalog/catalog_kind_codec.dart';
export 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_stats_capability.dart';
import 'package:collectarr_app/features/library/config/library_value_capability.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/shared/library_media_adapter_builder.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:flutter/material.dart';

import 'package:collectarr_app/features/providers/domain/mappers/provider_preview_mapper.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';

export 'package:collectarr_app/features/library/config/library_edit_capability.dart';
export 'package:collectarr_app/features/library/config/library_kind_identity.dart';
export 'package:collectarr_app/features/library/config/library_metadata_capability.dart';
export 'package:collectarr_app/features/library/config/library_hierarchy_capability.dart';
export 'package:collectarr_app/features/library/config/library_inspector_capability.dart';
export 'package:collectarr_app/features/library/config/library_transfer_capability.dart';
export 'package:collectarr_app/features/library/config/library_type_capabilities.dart';
export 'package:collectarr_app/features/library/config/library_facet_types.dart';
export 'package:collectarr_app/features/library/config/library_stats_capability.dart';
export 'package:collectarr_app/features/library/config/library_value_capability.dart';
export 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
export 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';

abstract interface class LibraryKindRuntime {
  CatalogMediaKind get kind;
  LibraryKindIdentity get identity;
  LibraryMetadataCapability get metadata;
  LibraryHierarchyCapability get hierarchy;
  LibraryInspectorCapability get inspector;
  LibraryEditCapability get edit;
  LibraryTransferCapability get transfer;
  LibraryStatsCapability get stats;
  LibraryValueCapability? get value;
  LibraryTypeConfig get type;
  LibraryTypeCapabilities get capabilities;
  LibraryUiPolicy get uiPolicy => type.uiPolicy;
  LibraryFieldRegistry<LibraryWorkspaceDto> get fields;
  LibraryWorkspaceProjector<LibraryWorkspaceDto> get projector;
  LibraryAddCapability get add;

  LibraryKindToolbarModule? get toolbar;
  LibraryKindProviderMapper? get providerMapper;
  LibraryFacetModule? get facets;
  CatalogKindCodec<LibraryKindMetadataRuntime>? get catalogCodec;

  LibraryWorkspaceViewProfile get viewProfile;

  Set<String> defaultTableColumns();
  List<String> orderedTableColumns(Set<String> columns);
  double tableWidthForColumns(
    Set<String> columns,
    Map<String, double> customWidths,
  );
  double tableColumnWidth(
    String column,
    Map<String, double> customWidths,
  );
  double defaultTableColumnWidth(String column);
  String columnLabel(String column);
  String columnDisplayName(String column);
  LibraryTableColumnGroup columnGroup(String column);
  String columnGroupLabel(LibraryTableColumnGroup group);
  bool columnIsNumeric(String column);
  String? columnSort(String column);
  Widget buildTableCell(LibraryProjectionRuntime item, String column);
  int compareEntriesByRules(
    LibraryProjectionRuntime left,
    LibraryProjectionRuntime right,
    Iterable<LibrarySortRule> rules,
  );
  LibraryEntryFilterValues filterValuesForEntry(ShelfEntry source);
  Iterable<String> linkedMetadataCandidatesForEntry(ShelfEntry source);
  String? subgroupKeyForEntry(
    LibraryProjectionRuntime item,
    String groupMode,
  );
  int compareSubgroupKeys(String left, String right, String groupMode);

  OwnedItemDetails decodeOwnedDetails(Map<String, dynamic> json);
  OwnedItemDetails defaultOwnedDetails();
  OwnedDetailsDraft defaultOwnedDetailsDraft();
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

  Object? columnValue(
    LibraryProjectionRuntime item,
    LibraryFieldIdRuntime columnId,
  );

  void validateProjection(LibraryProjectionRuntime item);

  LibraryWorkspaceDto createWorkspaceDto({
    required ShelfEntry source,
    required LibraryNodeRef node,
  });
}

class LibraryKindSpec<TDto extends LibraryWorkspaceDto,
    TDetails extends OwnedItemDetails> implements LibraryKindRuntime {
  const LibraryKindSpec({
    required this.type,
    required this.fields,
    required this.projector,
    required this.ownedDetailsCodec,
    required this.add,
    required this.edit,
    required this.identity,
    required this.metadata,
    required this.hierarchy,
    required this.inspector,
    required this.transfer,
    this.stats = const DefaultLibraryStatsCapability(),
    this.value,
    this.toolbar,
    this.providerMapper,
    this.facets,
    this.catalogCodec,
    LibraryWorkspaceViewProfile? viewProfile,
    LibraryCardPresentation Function(
      LibraryProjectionRuntime item, {
      required bool musicVertical,
    })? buildCardPresentation,
  })  : _viewProfile = viewProfile,
        _buildCardPresentation = buildCardPresentation;

  final OwnedDetailsCodec<TDetails> ownedDetailsCodec;
  @override
  final CatalogKindCodec<LibraryKindMetadataRuntime>? catalogCodec;
  @override
  final LibraryKindIdentity identity;
  @override
  final LibraryMetadataCapability metadata;
  @override
  final LibraryHierarchyCapability hierarchy;
  @override
  final LibraryInspectorCapability inspector;
  @override
  final LibraryTransferCapability transfer;
  @override
  final LibraryStatsCapability stats;
  @override
  final LibraryValueCapability? value;
  @override
  final LibraryEditCapability edit;

  @override
  OwnedItemDetails decodeOwnedDetails(Map<String, dynamic> json) =>
      ownedDetailsCodec.fromJson(json);

  @override
  OwnedItemDetails defaultOwnedDetails() => ownedDetailsCodec.defaultDetails();

  @override
  OwnedDetailsDraft defaultOwnedDetailsDraft() =>
      ownedDetailsCodec.defaultDraft();

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
    if (details is! TDetails) {
      throw ArgumentError(
        'Incompatible owned details type "${details.runtimeType}" for media kind "${kind.apiValue}". Expected "$TDetails".',
      );
    }
  }

  @override
  CatalogMediaKind get kind => identity.kind;

  @override
  final LibraryTypeConfig type;

  @override
  LibraryTypeCapabilities get capabilities => type.capabilities;

  @override
  LibraryUiPolicy get uiPolicy => type.uiPolicy;

  final LibraryWorkspaceViewProfile? _viewProfile;

  @override
  LibraryWorkspaceViewProfile get viewProfile =>
      _viewProfile ?? plannedMediaWorkspaceViewProfile(type);

  @override
  Set<String> defaultTableColumns() => Set.of(fields.defaultVisibleColumnIds);

  @override
  List<String> orderedTableColumns(Set<String> columns) =>
      orderedLibraryTableColumns(
        columns: columns,
        defaultColumns: fields.defaultVisibleColumnIds,
      );

  @override
  double tableWidthForColumns(
    Set<String> columns,
    Map<String, double> customWidths,
  ) =>
      plannedMediaTableWidthForColumns(
        type: type,
        columns: columns,
        customWidths: customWidths,
      );

  @override
  double tableColumnWidth(
    String column,
    Map<String, double> customWidths,
  ) =>
      plannedMediaTableColumnWidth(type, column, customWidths);

  @override
  double defaultTableColumnWidth(String column) =>
      defaultPlannedMediaTableColumnWidth(type, column);

  @override
  String columnLabel(String column) =>
      plannedMediaTableColumnLabelForType(type, column);

  @override
  String columnDisplayName(String column) =>
      plannedMediaTableColumnDisplayNameForType(type, column);

  @override
  LibraryTableColumnGroup columnGroup(String column) =>
      plannedMediaTableColumnGroup(type, column);

  @override
  String columnGroupLabel(LibraryTableColumnGroup group) =>
      plannedMediaTableColumnGroupLabel(group);

  @override
  bool columnIsNumeric(String column) =>
      plannedMediaTableColumnIsNumeric(type, column);

  @override
  String? columnSort(String column) =>
      plannedMediaTableColumnSort(type, column);

  @override
  Widget buildTableCell(LibraryProjectionRuntime item, String column) =>
      plannedMediaTableCell(type, item, column);

  @override
  int compareEntriesByRules(
    LibraryProjectionRuntime left,
    LibraryProjectionRuntime right,
    Iterable<LibrarySortRule> rules,
  ) {
    for (final rule in rules) {
      final sortDef = fields.findSortDefinition(rule.column);
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
  LibraryEntryFilterValues filterValuesForEntry(ShelfEntry source) =>
      plannedMediaFilterValuesForEntry(source);

  @override
  Iterable<String> linkedMetadataCandidatesForEntry(ShelfEntry source) =>
      plannedMediaLinkedMetadataCandidatesForEntry(type, source);

  @override
  String? subgroupKeyForEntry(
    LibraryProjectionRuntime item,
    String groupMode,
  ) =>
      plannedMediaSubgroupKeyForEntry(type, item, groupMode);

  @override
  int compareSubgroupKeys(String left, String right, String groupMode) =>
      plannedMediaCompareSubgroupKeys(left, right, groupMode);

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
      sortId.value,
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
    return fields.compareEntries(left, right, sortId.value);
  }

  @override
  Object? groupValue(
    LibraryProjectionRuntime item,
    LibraryGroupIdRuntime groupId,
  ) {
    validateProjection(item);
    return fields.getGroupValue(item, groupId.value);
  }

  @override
  Object? columnValue(
    LibraryProjectionRuntime item,
    LibraryFieldIdRuntime columnId,
  ) {
    validateProjection(item);
    return fields.getColumnValue(item, columnId.value);
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
  if (runtime.kind != runtime.type.workspace.kind) {
    throw StateError(
      'Kind mismatch in spec for "${runtime.type.workspace.title}": runtime.kind=${runtime.kind}, type.kind=${runtime.type.workspace.kind}',
    );
  }

  if (runtime.fields.kindNamespace != runtime.kind.apiValue) {
    throw StateError(
      'Namespace mismatch in spec for "${runtime.type.workspace.title}": fields.kindNamespace=${runtime.fields.kindNamespace}, expected=${runtime.kind.apiValue}',
    );
  }

  final columnIds = <String>{};
  for (final col in runtime.fields.columns) {
    if (!columnIds.add(col.id.value)) {
      throw StateError(
        'Duplicate column ID "${col.id.value}" in kind spec "${runtime.type.workspace.title}"',
      );
    }
  }

  final sortIds = <String>{};
  for (final sort in runtime.fields.sorts) {
    if (!sortIds.add(sort.id.value)) {
      throw StateError(
        'Duplicate sort ID "${sort.id.value}" in kind spec "${runtime.type.workspace.title}"',
      );
    }
  }

  final groupIds = <String>{};
  for (final group in runtime.fields.groups) {
    if (!groupIds.add(group.id.value)) {
      throw StateError(
        'Duplicate group ID "${group.id.value}" in kind spec "${runtime.type.workspace.title}"',
      );
    }
  }

  for (final colId in runtime.fields.defaultVisibleColumnIds) {
    if (runtime.fields.findColumnDefinition(colId) == null) {
      throw StateError(
        'Default visible column ID "$colId" not found in columns for kind spec "${runtime.type.workspace.title}"',
      );
    }
  }

  if (runtime.fields.findSortDefinition(runtime.fields.defaultSortId) == null) {
    throw StateError(
      'Default sort ID "${runtime.fields.defaultSortId}" not found in sorts for kind spec "${runtime.type.workspace.title}"',
    );
  }

  if (runtime.fields.defaultGroupId != null &&
      runtime.fields.findGroupDefinition(runtime.fields.defaultGroupId!) ==
          null) {
    throw StateError(
      'Default group ID "${runtime.fields.defaultGroupId}" not found in groups for kind spec "${runtime.type.workspace.title}"',
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
  LibraryMetadataItem metadataItemFromEnvelope(
      NormalizedProviderEnvelopeV1 envelope);

  Map<String, Object?> buildCorrections({
    required LibraryMetadataItem preview,
    required LibraryMetadataItem edited,
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
  });

  final LibraryFacetRowsLoader? loadRows;
  final Iterable<String> Function(
      LibraryProjectionRuntime item, LibraryFacetIdRuntime facetId)? getFacetValues;
  final List<LibraryFacetDefinition<dynamic, dynamic, dynamic>> definitions;
}

typedef LibraryFacetQueryExecutor = Future<List<Map<String, dynamic>>>
    Function({
  required LibraryFacetIdRuntime facetId,
  required Set<String> itemIds,
});

typedef LibraryFacetRowsLoader = Future<List<Map<String, dynamic>>> Function({
  required LibraryFacetIdRuntime facetId,
  required Set<String> itemIds,
  LibraryFacetQueryExecutor? queryExecutor,
});
