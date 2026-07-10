import 'package:collectarr_app/features/library/config/common_fields.dart';
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
  }) : _groups = groups,
       _sorts = sorts,
       _columns = columns;

  final List<LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>>? _groups;
  final List<LibrarySortDefinition<LibraryWorkspaceEntry>>? _sorts;
  final List<LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>>? _columns;

  List<LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>> get groups =>
      _groups ?? commonGroupDefinitions;

  List<LibrarySortDefinition<LibraryWorkspaceEntry>> get sorts =>
      _sorts ?? commonSortDefinitions;

  List<LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>> get columns =>
      _columns ?? commonColumnDefinitions;

  final Set<String> defaultVisibleColumnIds;
  final String? defaultSortId;
  final String? defaultGroupId;

  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>? columnDefinitionForId(String id) {
    final normalized = id.contains('.') ? id.split('.').last : id;
    final snakeCaseId = normalized
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match[1]}_${match[2]}',
        )
        .toLowerCase();

    for (final definition in columns) {
      final defVal = definition.id.value;
      final defNormalized = defVal.contains('.') ? defVal.split('.').last : defVal;
      final defSnake = defNormalized
          .replaceAllMapped(
            RegExp(r'([a-z0-9])([A-Z])'),
            (match) => '${match[1]}_${match[2]}',
          )
          .toLowerCase();
      if (defVal == id ||
          defVal == snakeCaseId ||
          defNormalized == normalized ||
          defSnake == snakeCaseId) {
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
    final normalized = id.contains('.') ? id.split('.').last : id;
    final snakeCaseId = normalized
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match[1]}_${match[2]}',
        )
        .toLowerCase();
    final alternativeSnakeCaseId = snakeCaseId == 'key_comic'
        ? 'key_issue'
        : (snakeCaseId == 'key_issue' ? 'key_comic' : snakeCaseId);

    for (final definition in sorts) {
      final defVal = definition.id;
      final defNormalized = defVal.contains('.') ? defVal.split('.').last : defVal;
      final defSnake = defNormalized
          .replaceAllMapped(
            RegExp(r'([a-z0-9])([A-Z])'),
            (match) => '${match[1]}_${match[2]}',
          )
          .toLowerCase();
      if (defVal == id ||
          defVal == snakeCaseId ||
          defVal == alternativeSnakeCaseId ||
          defNormalized == normalized ||
          defSnake == snakeCaseId ||
          defSnake == alternativeSnakeCaseId) {
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
    final normalized = id.contains('.') ? id.split('.').last : id;
    final snakeCaseId = normalized
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match[1]}_${match[2]}',
        )
        .toLowerCase();

    for (final definition in groups) {
      final defVal = definition.id.value;
      final defNormalized = defVal.contains('.') ? defVal.split('.').last : defVal;
      final defSnake = defNormalized
          .replaceAllMapped(
            RegExp(r'([a-z0-9])([A-Z])'),
            (match) => '${match[1]}_${match[2]}',
          )
          .toLowerCase();
      if (defVal == id ||
          defVal == snakeCaseId ||
          defNormalized == normalized ||
          defSnake == snakeCaseId) {
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
  });

  final LibraryFacetRowsLoader loadRows;
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
