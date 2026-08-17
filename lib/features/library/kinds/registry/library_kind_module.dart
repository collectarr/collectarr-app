import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';

import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';

export 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';

abstract interface class LibraryKindRuntime {
  CatalogMediaKind get kind;
  LibraryKindIdentity get identity;
  LibraryMetadataCapability get metadata;
  LibraryHierarchyCapability get hierarchy;
  LibraryInspectorCapability get inspector;
  LibraryEditCapability get edit;
  LibraryTransferCapability get transfer;
  LibraryTypeConfig get type;
  LibraryTypeCapabilities get capabilities;
  LibraryMediaAdapter get mediaAdapter;
  LibraryFieldRegistry<dynamic, LibraryWorkspaceDto> get fields;
  LibraryWorkspaceProjector<LibraryWorkspaceDto> get projector;
  LibraryAddCapability get add;

  LibraryKindWorkspaceBehavior get workspaceBehavior;
  LibraryKindToolbarModule? get toolbar;
  LibraryKindProviderMapper? get providerMapper;
  LibraryFacetModule? get facets;

  OwnedItemDetails decodeOwnedDetails(Map<String, dynamic> json);
  OwnedItemDetails defaultOwnedDetails();
  OwnedDetailsDraft defaultOwnedDetailsDraft();
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

  void sortEntries(
    List<LibraryProjectionRuntime> items,
    String sortId, {
    required bool ascending,
  });

  int compare(
    LibraryProjectionRuntime left,
    LibraryProjectionRuntime right,
    LibrarySortIdRuntime sortId,
  );

  int compareEntries(
    LibraryProjectionRuntime left,
    LibraryProjectionRuntime right,
    String sortId,
  );

  Object? groupValue(
    LibraryProjectionRuntime item,
    LibraryGroupIdRuntime groupId,
  );

  Object? getGroupValue(
    LibraryProjectionRuntime item,
    String groupId,
  );

  Object? columnValue(
    LibraryProjectionRuntime item,
    LibraryFieldIdRuntime columnId,
  );

  Object? getColumnValue(
    LibraryProjectionRuntime item,
    String columnId,
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
    required this.mediaAdapter,
    required this.fields,
    required this.projector,
    required this.ownedDetailsCodec,
    required this.add,
    LibraryKindIdentity? identity,
    LibraryMetadataCapability? metadata,
    LibraryHierarchyCapability? hierarchy,
    LibraryInspectorCapability? inspector,
    LibraryEditCapability? edit,
    LibraryTransferCapability? transfer,
    this.workspaceBehavior = const LibraryKindWorkspaceBehavior(),
    this.toolbar,
    this.providerMapper,
    this.facets,
    LibraryCardPresentation Function(
      LibraryProjectionRuntime item, {
      required bool musicVertical,
    })? buildCardPresentation,
  })  : _identity = identity,
        _metadata = metadata,
        _hierarchy = hierarchy,
        _inspector = inspector,
        _edit = edit,
        _transfer = transfer,
        _buildCardPresentation = buildCardPresentation;

  final OwnedDetailsCodec<TDetails> ownedDetailsCodec;
  final LibraryKindIdentity? _identity;
  final LibraryMetadataCapability? _metadata;
  final LibraryHierarchyCapability? _hierarchy;
  final LibraryInspectorCapability? _inspector;
  final LibraryEditCapability? _edit;
  final LibraryTransferCapability? _transfer;

  @override
  LibraryKindIdentity get identity =>
      _identity ??
      LibraryKindIdentity.fromWorkspaceConfig(
        workspace: type.workspace,
        singularLabel: type.singularLabel,
        pluralLabel: type.pluralLabel,
      );

  @override
  LibraryMetadataCapability get metadata =>
      _metadata ??
      LibraryMetadataCapability(
        defaultProviderId: type.defaultMetadataProvider,
        providers: type.metadataProviders,
        supportsServerCompare: type.supportsMetadataCompareWithServer,
      );

  @override
  LibraryHierarchyCapability get hierarchy =>
      _hierarchy ??
      LibraryHierarchyCapability(
        contentHierarchy: type.capabilities.contentHierarchy,
        supportsSeriesSubgroups: type.capabilities.supportsSeriesSubgroups,
        supportsMediaReleaseSplit: type.capabilities.supportsMediaReleaseSplit,
        supportsIndexReassignment: type.capabilities.supportsIndexReassignment,
        showsReadingQueue: type.capabilities.showsReadingQueue,
        collectionExportTitleLabel: type.collectionExportTitleLabel,
        mediaReleaseScopeLabel: type.mediaReleaseScopeLabel,
      );

  @override
  LibraryInspectorCapability get inspector =>
      _inspector ??
      LibraryInspectorCapability(
        heroBuilder: type.inspectorHeroBuilder,
        sectionsBuilder: type.inspectorSectionsBuilder,
        detailPageBuilder: type.detailPageBuilder,
        showsDefaultPersonalSection: type.showsDefaultInspectorPersonalSection,
      );

  @override
  LibraryEditCapability get edit =>
      _edit ??
      LibraryEditCapability(
        editDialogBuilder: type.editDialogBuilder,
        mediaEditDialogBuilder: type.mediaEditDialogBuilder,
        releaseEditDialogBuilder: type.releaseEditDialogBuilder,
        presentation: type.editPresentation,
        editChrome: type.editChrome,
        mediaFields: type.mediaFields,
        releaseFields: type.releaseFields,
        conditions: type.conditions,
        grades: type.grades,
        defaultCondition: type.defaultCondition,
        defaultGrade: type.defaultGrade,
        manualAddUsesTitleAsSeries: type.manualAddUsesTitleAsSeries,
        editUsesTitleAsSeries: type.editUsesTitleAsSeries,
      );

  @override
  LibraryTransferCapability get transfer =>
      _transfer ??
      LibraryTransferCapability(
        transferableFieldKeys: type.transferableFieldKeys,
      );

  @override
  OwnedItemDetails decodeOwnedDetails(Map<String, dynamic> json) =>
      ownedDetailsCodec.fromJson(json);

  @override
  OwnedItemDetails defaultOwnedDetails() => ownedDetailsCodec.defaultDetails();

  @override
  OwnedDetailsDraft defaultOwnedDetailsDraft() =>
      ownedDetailsCodec.defaultDraft();

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
  final LibraryMediaAdapter mediaAdapter;

  @override
  final LibraryFieldRegistry<dynamic, TDto> fields;

  @override
  final LibraryWorkspaceProjector<TDto> projector;

  @override
  final LibraryKindWorkspaceBehavior workspaceBehavior;
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
  void sortEntries(
    List<LibraryProjectionRuntime> items,
    String sortId, {
    required bool ascending,
  }) {
    sort(items, fields.decodeSortId(sortId), ascending: ascending);
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
  int compareEntries(
    LibraryProjectionRuntime left,
    LibraryProjectionRuntime right,
    String sortId,
  ) {
    return compare(left, right, fields.decodeSortId(sortId));
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
  Object? getGroupValue(
    LibraryProjectionRuntime item,
    String groupId,
  ) {
    return groupValue(item, fields.decodeGroupId(groupId));
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
  Object? getColumnValue(
    LibraryProjectionRuntime item,
    String columnId,
  ) {
    return columnValue(item, fields.decodeColumnId(columnId));
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

abstract class LibraryKindProviderMapper {
  const LibraryKindProviderMapper();

  LibraryMetadataItem metadataItemFromPreview(AdminProviderPreview preview);

  Map<String, Object?> buildCorrections({
    required LibraryMetadataItem preview,
    required LibraryMetadataItem edited,
  });
}

class DefaultLibraryKindProviderMapper extends LibraryKindProviderMapper {
  const DefaultLibraryKindProviderMapper();

  @override
  LibraryMetadataItem metadataItemFromPreview(AdminProviderPreview preview) {
    return LibraryMetadataItem(
      id: '',
      kind: preview.kind,
      title: preview.title,
      synopsis: preview.synopsis,
      coverImageUrl: preview.coverImageUrl,
      thumbnailImageUrl: preview.coverImageUrl,
      releaseDate: preview.releaseDate,
      barcode: preview.barcode,
    );
  }

  @override
  Map<String, Object?> buildCorrections({
    required LibraryMetadataItem preview,
    required LibraryMetadataItem edited,
  }) {
    final corrections = <String, Object?>{};
    if (edited.title != preview.title) corrections['title'] = edited.title;
    if (edited.synopsis != preview.synopsis) {
      corrections['synopsis'] = edited.synopsis;
    }
    if (edited.releaseDate != preview.releaseDate) {
      corrections['release_date'] = edited.releaseDate?.toIso8601String();
    }
    if (edited.barcode != preview.barcode) {
      corrections['barcode'] = edited.barcode;
    }
    if (edited.coverImageUrl != preview.coverImageUrl) {
      corrections['cover_image_url'] = edited.coverImageUrl;
    }
    if (edited.thumbnailImageUrl != preview.thumbnailImageUrl) {
      corrections['thumbnail_image_url'] = edited.thumbnailImageUrl;
    }
    return corrections;
  }
}

class CommonLibraryKindProviderMapper extends DefaultLibraryKindProviderMapper {
  const CommonLibraryKindProviderMapper();
}

class LibraryFacetModule {
  const LibraryFacetModule({
    required this.loadRows,
    this.getFacetValues,
  });

  final LibraryFacetRowsLoader loadRows;
  final Iterable<String> Function(
      LibraryProjectionRuntime item, String facetId)? getFacetValues;
}

typedef LibraryFacetRowsLoader = Future<List<Map<String, dynamic>>> Function({
  required ApiClient api,
  required String facetId,
  required Set<String> itemIds,
});
