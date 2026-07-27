import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';

class AnyLibraryFieldRegistry<TDto> {
  const AnyLibraryFieldRegistry({
    List<LibraryGroupDefinition<TDto, Object?>>? groups,
    List<LibrarySortDefinition<TDto>>? sorts,
    List<LibraryColumnDefinition<TDto, Object?>>? columns,
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
    this.customLinkedMetadataCandidates,
  }) : _groups = groups,
       _sorts = sorts,
       _columns = columns;

  final List<LibraryGroupDefinition<TDto, Object?>>? _groups;
  final List<LibrarySortDefinition<TDto>>? _sorts;
  final List<LibraryColumnDefinition<TDto, Object?>>? _columns;

  List<LibraryGroupDefinition<TDto, Object?>> get groups =>
      _groups ?? const [];

  List<LibrarySortDefinition<TDto>> get sorts =>
      _sorts ?? const [];

  List<LibraryColumnDefinition<TDto, Object?>> get columns =>
      _columns ?? const [];

  final Set<String> defaultVisibleColumnIds;
  final String? defaultSortId;
  final String? defaultGroupId;
  final Iterable<String> Function(LibraryWorkspaceEntry)? customLinkedMetadataCandidates;

  Iterable<String> linkedMetadataCandidates(LibraryWorkspaceEntry entry) sync* {
    final series = entry.series?.seriesTitle?.trim();
    final country = entry.country?.trim();
    final language = entry.language?.trim();
    final publishing = entry.publishing;

    yield* nonEmptyStrings([
      entry.resolvedTitle,
      entry.title,
      entry.localizedTitle,
      entry.originalTitle,
      series,
      entry.itemNumber,
      entry.publisher,
      entry.variant,
      publishing?.imprint,
      country,
      language,
      entry.ageRating,
    ]);
    yield* nonEmptyStrings(entry.searchAliases);
    if (entry.creators case final creators?) {
      for (final credit in creators) {
        final name = credit['name']?.toString()?.trim();
        if (name != null && name.isNotEmpty) {
          yield name;
        }
      }
    }
    yield* nonEmptyStrings(entry.genres);

    if (customLinkedMetadataCandidates != null) {
      yield* customLinkedMetadataCandidates!(entry);
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

  LibraryColumnDefinition<TDto, Object?>? columnDefinitionForId(String id) {
    for (final definition in columns) {
      if (definition.id.value == id) {
        return definition;
      }
    }
    return null;
  }

  LibraryColumnDefinition<TDto, Object?> columnDefinitionFor(String columnId) {
    final definition = columnDefinitionForId(columnId);
    if (definition != null) {
      return definition;
    }
    throw StateError(
      'Missing column definition for $columnId. '
      'Ensure columns declares every available table column.',
    );
  }

  LibrarySortDefinition<TDto>? sortDefinitionForId(String id) {
    for (final definition in sorts) {
      if (definition.id == id) {
        return definition;
      }
    }
    return null;
  }

  LibrarySortDefinition<TDto> sortDefinitionFor(String sortId) {
    final definition = findSortDefinition(sortId);
    if (definition != null) {
      return definition;
    }
    throw StateError(
      'Missing sort definition for $sortId. '
      'Ensure sorts declares every available sort field.',
    );
  }

  LibraryGroupDefinition<TDto, Object?>? groupDefinitionForId(String id) {
    for (final definition in groups) {
      if (definition.id.value == id) {
        return definition;
      }
    }
    return null;
  }

  LibraryColumnDefinition<TDto, Object?>? findColumnDefinition(String id) {
    final direct = columnDefinitionForId(id);
    if (direct != null) return direct;
    for (final col in columns) {
      if (col.id.value.endsWith('.$id')) return col;
    }
    return null;
  }

  LibrarySortDefinition<TDto>? findSortDefinition(String id) {
    final direct = sortDefinitionForId(id);
    if (direct != null) return direct;
    for (final sort in sorts) {
      if (sort.id.endsWith('.$id')) return sort;
    }
    return null;
  }

  LibraryGroupDefinition<TDto, Object?>? findGroupDefinition(String id) {
    final direct = groupDefinitionForId(id);
    if (direct != null) return direct;
    for (final grp in groups) {
      if (grp.id.value.endsWith('.$id')) return grp;
    }
    return null;
  }

  LibraryGroupDefinition<TDto, Object?> groupDefinitionFor(String groupId) {
    final definition = findGroupDefinition(groupId);
    if (definition != null) {
      return definition;
    }
    throw StateError(
      'Missing group definition for $groupId. '
      'Ensure groups declares every available group mode.',
    );
  }

  /// Sorts [entries] in-place using the comparator for [sortId].
  ///
  /// Each [LibraryWorkspaceEntry] is projected to a DTO exactly **once** before
  /// sorting begins via [dtoFactory], guaranteeing stable performance:
  ///
  /// ```
  /// O(N) DTO constructions + O(N log N) comparisons
  /// ```
  void sortEntries(
    List<LibraryWorkspaceEntry> entries,
    String sortId, {
    required bool ascending,
    required TDto Function(LibraryWorkspaceEntry entry) dtoFactory,
  }) {
    final sortDef = sortDefinitionFor(sortId);

    // Build a DTO for every entry once, keyed by identity.
    final dtos = <LibraryWorkspaceEntry, TDto>{};
    for (final entry in entries) {
      dtos[entry] = dtoFactory(entry);
    }

    entries.sort((l, r) {
      final result = sortDef.compare(dtos[l]!, dtos[r]!);
      if (result != 0) {
        return ascending ? result : -result;
      }
      // Stable tie-breaking using resolved title & id
      final titleCmp = l.resolvedTitle.compareTo(r.resolvedTitle);
      if (titleCmp != 0) return titleCmp;
      return l.id.compareTo(r.id);
    });
  }
}

abstract interface class LibraryKindRuntime {
  CatalogMediaKind get kind;
  LibraryTypeConfig get type;
  LibraryMediaAdapter get mediaAdapter;
  AnyLibraryFieldRegistry<dynamic> get fields;
  Object Function(LibraryWorkspaceEntry entry) get workspaceDtoFactory;
  LibraryKindWorkspaceBehavior get workspaceBehavior;
  LibraryKindAddModule get add;
  LibraryKindEditModule get edit;
  LibraryKindDetailModule get detail;
  LibraryKindToolbarModule get toolbar;
  LibraryKindProviderMapper get providerMapper;
  LibraryFacetModule get facets;

  LibraryCardPresentation? buildCardPresentation(
    LibraryWorkspaceEntry entry, {
    required bool musicVertical,
  });

  void sortEntries(
    List<LibraryWorkspaceEntry> entries,
    String sortId, {
    required bool ascending,
  });

  Object createWorkspaceDto(LibraryWorkspaceEntry entry);
}

class LibraryKindSpec<TDto extends Object, TDetails extends OwnedItemDetails>
    implements LibraryKindRuntime {
  const LibraryKindSpec({
    required this.type,
    required this.mediaAdapter,
    required this.fields,
    required this.workspaceDtoFactory,
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
      LibraryWorkspaceEntry entry, {
      required bool musicVertical,
    })? buildCardPresentation,
  }) : _buildCardPresentation = buildCardPresentation;

  @override
  CatalogMediaKind get kind => type.workspace.kind;

  @override
  final LibraryTypeConfig type;

  @override
  final LibraryMediaAdapter mediaAdapter;

  @override
  final AnyLibraryFieldRegistry<TDto> fields;

  @override
  final TDto Function(LibraryWorkspaceEntry entry) workspaceDtoFactory;

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

  /// Returns the card presentation for a given entry.
  final LibraryCardPresentation Function(
    LibraryWorkspaceEntry entry, {
    required bool musicVertical,
  })? _buildCardPresentation;

  @override
  LibraryCardPresentation? buildCardPresentation(
    LibraryWorkspaceEntry entry, {
    required bool musicVertical,
  }) {
    return _buildCardPresentation?.call(entry, musicVertical: musicVertical);
  }

  @override
  void sortEntries(
    List<LibraryWorkspaceEntry> entries,
    String sortId, {
    required bool ascending,
  }) {
    fields.sortEntries(
      entries,
      sortId,
      ascending: ascending,
      dtoFactory: workspaceDtoFactory,
    );
  }

  @override
  TDto createWorkspaceDto(LibraryWorkspaceEntry entry) =>
      workspaceDtoFactory(entry);
}

typedef LibraryKindModule<TDto extends Object> = LibraryKindSpec<TDto, OwnedItemDetails>;

/// Validates a [LibraryKindRuntime] for schema completeness, duplicate IDs,
/// and required fields upon registration.
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
    if (!sortIds.add(sort.id)) {
      throw StateError(
        'Duplicate sort ID "${sort.id}" in kind spec "${module.type.workspace.title}"',
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

void validateKindModule(LibraryKindRuntime module) => validateKindRuntime(module);

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
  final Iterable<String> Function(LibraryWorkspaceEntry entry, String facetId)? getFacetValues;
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
