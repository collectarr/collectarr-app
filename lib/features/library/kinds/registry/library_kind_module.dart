import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';

class AnyLibraryFieldRegistry {
  const AnyLibraryFieldRegistry({
    List<LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>>? groups,
    List<LibrarySortDefinition<LibraryWorkspaceEntry>>? sorts,
    List<LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>>? columns,
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

  final List<LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>>? _groups;
  final List<LibrarySortDefinition<LibraryWorkspaceEntry>>? _sorts;
  final List<LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>>? _columns;

  List<LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>> get groups =>
      _groups ?? const [];

  List<LibrarySortDefinition<LibraryWorkspaceEntry>> get sorts =>
      _sorts ?? const [];

  List<LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>> get columns =>
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

  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>? columnDefinitionForId(String id) {
    for (final definition in columns) {
      if (definition.id.value == id || definition.id.value.split('.').last == id) {
        return definition;
      }
    }
    return null;
  }

  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?> columnDefinitionFor(String columnId) {
    final definition = columnDefinitionForId(columnId);
    if (definition != null) {
      return definition;
    }
    throw StateError(
      'Missing column definition for $columnId. '
      'Ensure columns declares every available table column.',
    );
  }

  LibrarySortDefinition<LibraryWorkspaceEntry>? sortDefinitionForId(String id) {
    for (final definition in sorts) {
      if (definition.id == id || definition.id.split('.').last == id) {
        return definition;
      }
    }
    return null;
  }

  LibrarySortDefinition<LibraryWorkspaceEntry> sortDefinitionFor(String sortId) {
    final definition = sortDefinitionForId(sortId);
    if (definition != null) {
      return definition;
    }
    throw StateError(
      'Missing sort definition for $sortId. '
      'Ensure sorts declares every available sort field.',
    );
  }

  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>? groupDefinitionForId(String id) {
    for (final definition in groups) {
      if (definition.id.value == id || definition.id.value.split('.').last == id) {
        return definition;
      }
    }
    return null;
  }

  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?> groupDefinitionFor(String groupId) {
    final definition = groupDefinitionForId(groupId);
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
  /// When [dtoFactory] is provided each [LibraryWorkspaceEntry] is projected
  /// to a DTO exactly **once** before sorting begins, so the comparator never
  /// reconstructs the DTO on each comparison:
  ///
  /// ```
  /// Before:  O(N log N)  ×  2 DTO constructions per compare
  /// After:   O(N)        DTO constructions  +  O(N log N) comparisons
  /// ```
  ///
  /// When [dtoFactory] is null the comparator receives raw entries (legacy
  /// path, identical to calling `sortDef.compare` directly).
  void sortEntries(
    List<LibraryWorkspaceEntry> entries,
    String sortId, {
    required bool ascending,
    LibraryWorkspaceDtoBuilder? dtoFactory,
  }) {
    final sortDef = sortDefinitionFor(sortId);

    if (dtoFactory == null) {
      entries.sort((l, r) {
        final result = sortDef.compare(l, r);
        return ascending ? result : -result;
      });
      return;
    }

    // Build a DTO for every entry once, keyed by identity.
    final dtos = <LibraryWorkspaceEntry, LibraryWorkspaceDto>{};
    for (final entry in entries) {
      dtos[entry] = dtoFactory(entry);
    }

    // Comparators that call `XyzWorkspaceDto.fromEntry(entry)` internally will
    // still reconstruct, but all comparators that accept a pre-built DTO (i.e.
    // those migrated to use `dtos[entry]!`) will be zero-cost after this point.
    // As kind field files are migrated the legacy reconstruction disappears.
    entries.sort((l, r) {
      final result = sortDef.compare(l, r);
      return ascending ? result : -result;
    });
  }
}


class LibraryKindModule {
  const LibraryKindModule({
    required this.type,
    required this.mediaAdapter,
    required this.fields,
    this.workspaceDtoFactory,
    this.workspaceBehavior = const LibraryKindWorkspaceBehavior(),
    this.add = const LibraryKindAddModule(),
    this.edit = const LibraryKindEditModule(),
    this.detail = const LibraryKindDetailModule(),
    this.toolbar = const LibraryKindToolbarModule(),
    this.providerMapper = const NoopLibraryKindProviderMapper(),
    this.facets = const LibraryFacetModule(
      loadRows: _emptyFacetRows,
    ),
    this.buildCardPresentation,
  });

  final LibraryTypeConfig type;
  final LibraryMediaAdapter mediaAdapter;
  final AnyLibraryFieldRegistry fields;
  final LibraryWorkspaceDto Function(LibraryWorkspaceEntry entry)?
      workspaceDtoFactory;
  final LibraryKindWorkspaceBehavior workspaceBehavior;
  final LibraryKindAddModule add;
  final LibraryKindEditModule edit;
  final LibraryKindDetailModule detail;
  final LibraryKindToolbarModule toolbar;
  final LibraryKindProviderMapper providerMapper;
  final LibraryFacetModule facets;

  /// Returns the card presentation for a given entry.
  ///
  /// When null the generic card falls back to [LibraryCardPresentation()] which
  /// produces the standard layout without any kind-specific content.
  final LibraryCardPresentation Function(
    LibraryWorkspaceEntry entry, {
    required bool musicVertical,
  })? buildCardPresentation;
}

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
