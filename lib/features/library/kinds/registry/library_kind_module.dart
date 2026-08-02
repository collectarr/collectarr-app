import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';

class AnyLibraryFieldRegistry<TDto extends LibraryWorkspaceDto> {
  const AnyLibraryFieldRegistry({
    List<LibraryGroupDefinition<dynamic, TDto, Object?>>? groups,
    List<LibrarySortDefinition<dynamic, TDto>>? sorts,
    List<LibraryColumnDefinition<dynamic, TDto, Object?>>? columns,
    this.defaultVisibleColumnIds = const {
      'status',
      'cover',
      'title',
      'publisher',
      'release_date',
      'barcode',
      'condition',
      'price',
      'location',
      'wishlist',
      'updated',
    },
    this.defaultSortId = 'title',
    this.defaultGroupId = 'series',
    this.preferenceCodec,
    this.customLinkedMetadataCandidates,
  })  : _groups = groups,
        _sorts = sorts,
        _columns = columns;

  final LibraryWorkspacePreferenceCodec<dynamic>? preferenceCodec;
  final List<LibraryGroupDefinition<dynamic, TDto, Object?>>? _groups;
  final List<LibrarySortDefinition<dynamic, TDto>>? _sorts;
  final List<LibraryColumnDefinition<dynamic, TDto, Object?>>? _columns;

  List<LibraryGroupDefinition<dynamic, TDto, Object?>> get groups =>
      _groups ?? const [];

  List<LibrarySortDefinition<dynamic, TDto>> get sorts => _sorts ?? const [];

  List<LibraryColumnDefinition<dynamic, TDto, Object?>> get columns =>
      _columns ?? const [];

  final Set<String> defaultVisibleColumnIds;
  final String? defaultSortId;
  final String? defaultGroupId;
  final Iterable<String> Function(ShelfEntry)? customLinkedMetadataCandidates;

  Iterable<String> linkedMetadataCandidates(ShelfEntry source) sync* {
    final item = source.catalogItem;
    if (item == null) return;
    final series = item.series?.seriesTitle?.trim();
    final country = item.country?.trim();
    final language = item.language?.trim();
    final publishing = item.publishing;

    yield* nonEmptyStrings([
      item.title,
      series,
      item.itemNumber,
      item.publisher,
      item.variant,
      publishing?.imprint,
      country,
      language,
    ]);
    yield* nonEmptyStrings(item.searchAliases);
    if (item.creators case final creators?) {
      for (final credit in creators) {
        final name = credit['name']?.toString()?.trim();
        if (name != null && name.isNotEmpty) {
          yield name;
        }
      }
    }
    yield* nonEmptyStrings(item.genres);

    if (customLinkedMetadataCandidates != null) {
      yield* customLinkedMetadataCandidates!(source);
    }
  }

  static Iterable<String> nonEmptyStrings(Iterable<String?>? values) sync* {
    if (values == null) {
      return;
    }
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        yield trimmed;
      }
    }
  }

  LibraryColumnDefinition<dynamic, TDto, Object?>? columnDefinitionForId(
      String id) {
    for (final definition in columns) {
      if (definition.id.value == id) {
        return definition;
      }
    }
    return null;
  }

  LibraryColumnDefinition<dynamic, TDto, Object?> columnDefinitionFor(
      String columnId) {
    final definition = columnDefinitionForId(columnId);
    if (definition != null) {
      return definition;
    }
    throw StateError(
      'Missing column definition for $columnId. '
      'Ensure columns declares every available table column.',
    );
  }

  LibrarySortDefinition<dynamic, TDto>? sortDefinitionForId(String id) {
    for (final definition in sorts) {
      if (definition.id.value == id) {
        return definition;
      }
    }
    return null;
  }

  LibrarySortDefinition<dynamic, TDto> sortDefinitionFor(String sortId) {
    final definition = findSortDefinition(sortId);
    if (definition != null) {
      return definition;
    }
    throw StateError(
      'Missing sort definition for $sortId. '
      'Ensure sorts declares every available sort field.',
    );
  }

  LibraryGroupDefinition<dynamic, TDto, Object?>? groupDefinitionForId(
      String id) {
    for (final definition in groups) {
      if (definition.id.value == id) {
        return definition;
      }
    }
    return null;
  }

  LibraryColumnDefinition<dynamic, TDto, Object?>? findColumnDefinition(
      String id) {
    final direct = columnDefinitionForId(id);
    if (direct != null) return direct;
    if (preferenceCodec != null) {
      final decoded = preferenceCodec!.decodeColumn(id);
      if (decoded != null) {
        return columnDefinitionForId(decoded.value);
      }
    }
    return null;
  }

  LibrarySortDefinition<dynamic, TDto>? findSortDefinition(String id) {
    final direct = sortDefinitionForId(id);
    if (direct != null) return direct;
    if (preferenceCodec != null) {
      final decoded = preferenceCodec!.decodeSort(id);
      if (decoded != null) {
        return sortDefinitionForId(decoded.value);
      }
    }
    return null;
  }

  LibraryGroupDefinition<dynamic, TDto, Object?>? findGroupDefinition(
      String id) {
    final direct = groupDefinitionForId(id);
    if (direct != null) return direct;
    if (preferenceCodec != null) {
      final decoded = preferenceCodec!.decodeGroup(id);
      if (decoded != null) {
        return groupDefinitionForId(decoded.value);
      }
    }
    return null;
  }

  LibraryGroupDefinition<dynamic, TDto, Object?> groupDefinitionFor(
      String groupId) {
    final definition = findGroupDefinition(groupId);
    if (definition != null) {
      return definition;
    }
    throw StateError(
      'Missing group definition for $groupId. '
      'Ensure groups declares every available group mode.',
    );
  }

  void sortEntries(
    List<LibraryProjectionRuntime> items,
    String sortId, {
    required bool ascending,
  }) {
    final sortDef = sortDefinitionFor(sortId);

    items.sort((l, r) {
      final leftContext = LibraryProjectionContext<TDto>(
        source: l.source,
        node: l.node,
        dto: l.dto as TDto,
      );
      final rightContext = LibraryProjectionContext<TDto>(
        source: r.source,
        node: r.node,
        dto: r.dto as TDto,
      );
      final result = sortDef.compare(leftContext, rightContext);
      if (result != 0) {
        return ascending ? result : -result;
      }
      final titleCmp = l.dto.title.compareTo(r.dto.title);
      if (titleCmp != 0) return titleCmp;
      return l.node.id.compareTo(r.node.id);
    });
  }
}

abstract interface class LibraryKindRuntime {
  CatalogMediaKind get kind;
  LibraryTypeConfig get type;
  LibraryTypeCapabilities get capabilities;
  LibraryMediaAdapter get mediaAdapter;
  AnyLibraryFieldRegistry<dynamic> get fields;
  LibraryWorkspaceProjector<LibraryWorkspaceDto> get projector;
  LibraryKindWorkspaceBehavior get workspaceBehavior;
  LibraryKindAddModule get add;
  LibraryKindEditModule get edit;
  LibraryKindDetailModule get detail;
  LibraryKindToolbarModule get toolbar;
  LibraryKindProviderMapper get providerMapper;
  LibraryFacetModule get facets;

  OwnedItemDetails decodeOwnedDetails(Map<String, dynamic> json);
  OwnedItemDetails defaultOwnedDetails();
  Map<String, dynamic> encodeOwnedDetails(OwnedItemDetails details);

  LibraryCardPresentation? buildCardPresentation(
    LibraryProjectionRuntime item, {
    required bool musicVertical,
  });

  void sortEntries(
    List<LibraryProjectionRuntime> items,
    String sortId, {
    required bool ascending,
  });

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
    this.workspaceBehavior = const LibraryKindWorkspaceBehavior(),
    this.add = const LibraryKindAddModule(),
    this.edit = const LibraryKindEditModule(),
    this.detail = const LibraryKindDetailModule(),
    this.toolbar = const LibraryKindToolbarModule(),
    this.providerMapper = const NoopLibraryKindProviderMapper(),
    this.facets = const LibraryFacetModule(
      loadRows: _emptyFacetRows,
    ),
    LibraryCardPresentation Function(
      LibraryProjectionRuntime item, {
      required bool musicVertical,
    })? buildCardPresentation,
  }) : _buildCardPresentation = buildCardPresentation;

  final OwnedDetailsCodec<TDetails> ownedDetailsCodec;

  @override
  OwnedItemDetails decodeOwnedDetails(Map<String, dynamic> json) =>
      ownedDetailsCodec.fromJson(json);

  @override
  OwnedItemDetails defaultOwnedDetails() => ownedDetailsCodec.defaultDetails();

  @override
  Map<String, dynamic> encodeOwnedDetails(OwnedItemDetails details) {
    if (details is TDetails) {
      return ownedDetailsCodec.toJson(details);
    }
    return details.toJson();
  }

  @override
  CatalogMediaKind get kind => type.workspace.kind;

  @override
  final LibraryTypeConfig type;

  @override
  LibraryTypeCapabilities get capabilities => type.capabilities;

  @override
  final LibraryMediaAdapter mediaAdapter;

  @override
  final AnyLibraryFieldRegistry<TDto> fields;

  @override
  final LibraryWorkspaceProjector<TDto> projector;

  @override
  final LibraryKindWorkspaceBehavior workspaceBehavior;
  @override
  final LibraryKindAddModule add;
  @override
  final LibraryKindEditModule edit;
  @override
  final LibraryKindDetailModule detail;
  @override
  final LibraryKindToolbarModule toolbar;
  @override
  final LibraryKindProviderMapper providerMapper;
  @override
  final LibraryFacetModule facets;

  final LibraryCardPresentation Function(
    LibraryProjectionRuntime item, {
    required bool musicVertical,
  })? _buildCardPresentation;

  @override
  LibraryCardPresentation? buildCardPresentation(
    LibraryProjectionRuntime item, {
    required bool musicVertical,
  }) {
    return _buildCardPresentation?.call(item, musicVertical: musicVertical);
  }

  @override
  void sortEntries(
    List<LibraryProjectionRuntime> items,
    String sortId, {
    required bool ascending,
  }) {
    fields.sortEntries(
      items,
      sortId,
      ascending: ascending,
    );
  }

  @override
  LibraryWorkspaceDto createWorkspaceDto({
    required ShelfEntry source,
    required LibraryNodeRef node,
  }) {
    if (node is LibraryTitleNodeRef) {
      return projector.projectTitle(source: source, node: node);
    } else if (node is LibraryReleaseNodeRef) {
      return projector.projectRelease(
        source: source,
        node: node,
        releaseState: LibraryReleaseState(
          isOwned: source.isOwned,
          isWishlisted: source.isWishlisted,
          isTracked: source.isTracked,
        ),
      );
    } else if (node is LibraryCopyNodeRef) {
      return projector.projectCopy(source: source, node: node);
    }
    return projector.projectTitle(
      source: source,
      node: LibraryTitleNodeRef(titleItemId: node.titleItemId),
    );
  }
}

typedef LibraryKindModule<TDto extends LibraryWorkspaceDto>
    = LibraryKindSpec<TDto, OwnedItemDetails>;

void validateKindRuntime(LibraryKindRuntime module) {
  final columnIds = <String>{};
  for (final col in module.fields.columns) {
    if (!columnIds.add(col.id.value)) {
      throw StateError(
        'Duplicate column ID "${col.id.value}" in kind spec "${module.type.workspace.title}"',
      );
    }
  }

  final sortIds = <String>{};
  for (final sort in module.fields.sorts) {
    if (!sortIds.add(sort.id.value)) {
      throw StateError(
        'Duplicate sort ID "${sort.id.value}" in kind spec "${module.type.workspace.title}"',
      );
    }
  }

  final groupIds = <String>{};
  for (final group in module.fields.groups) {
    if (!groupIds.add(group.id.value)) {
      throw StateError(
        'Duplicate group ID "${group.id.value}" in kind spec "${module.type.workspace.title}"',
      );
    }
  }
}

void validateKindModule(LibraryKindRuntime module) =>
    validateKindRuntime(module);

class LibraryKindAddModule {
  const LibraryKindAddModule({
    this.registerBuilders = _noop,
  });

  final void Function() registerBuilders;

  static void _noop() {}
}

class LibraryKindEditModule {
  const LibraryKindEditModule();
}

class LibraryKindDetailModule {
  const LibraryKindDetailModule();
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

class NoopLibraryKindProviderMapper extends LibraryKindProviderMapper {
  const NoopLibraryKindProviderMapper();

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

class CommonLibraryKindProviderMapper extends NoopLibraryKindProviderMapper {
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

class LibraryFacetModuleProvider extends LibraryFacetProvider {
  const LibraryFacetModuleProvider(this.module);

  final LibraryFacetModule module;

  @override
  Future<FacetBuckets> load(LibraryFacetRequest request) async {
    final rows = await module.loadRows(
      api: request.api,
      facetId: request.facetId,
      itemIds: request.itemIds,
    );
    final byBucket = LibraryPageUtilities.parseFacetRows(rows, request.itemIds);
    return LibraryPageUtilities.buildFacetBuckets(
      signature: request.signature,
      byBucket: byBucket,
      allBucketLabel: request.allBucketLabel,
      totalItemCount: request.itemIds.length,
    );
  }
}

Future<List<Map<String, dynamic>>> _emptyFacetRows({
  required ApiClient api,
  required String facetId,
  required Set<String> itemIds,
}) async {
  return const <Map<String, dynamic>>[];
}

class LibraryFacetRequest {
  const LibraryFacetRequest({
    required this.api,
    required this.type,
    required this.facetId,
    required this.itemIds,
    required this.signature,
    this.allBucketLabel,
  });

  final ApiClient api;
  final LibraryTypeConfig type;
  final String facetId;
  final Set<String> itemIds;
  final String signature;
  final String? allBucketLabel;
}

abstract class LibraryFacetProvider {
  const LibraryFacetProvider();

  Future<FacetBuckets> load(LibraryFacetRequest request);
}
