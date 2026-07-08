import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_comparisons.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

class LibraryKindModule {
  const LibraryKindModule({
    required this.type,
    required this.mediaAdapter,
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

class LibraryKindWorkspaceBehavior {
  const LibraryKindWorkspaceBehavior();
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
  const LibraryKindToolbarModule();
}

abstract class LibraryKindProviderMapper {
  const LibraryKindProviderMapper();

  LibraryMetadataItem metadataItemFromPreview(AdminProviderPreview preview);

  Map<String, Object?> buildCorrections({
    required LibraryMetadataItem preview,
    required LibraryMetadataItem edited,
  });
}

class CommonLibraryKindProviderMapper extends LibraryKindProviderMapper {
  const CommonLibraryKindProviderMapper();

  @override
  LibraryMetadataItem metadataItemFromPreview(AdminProviderPreview preview) {
    final series = preview.series;
    final publishing = preview.publishing;
    return LibraryMetadataItem(
      id: '',
      kind: preview.kind,
      title: preview.title,
      itemNumber: preview.itemNumber,
      synopsis: preview.synopsis,
      coverImageUrl: preview.coverImageUrl,
      thumbnailImageUrl: preview.coverImageUrl,
      editionTitle: preview.editionTitle,
      physicalFormat: preview.physicalFormat,
      physicalFormatLabel: preview.physicalFormatLabel,
      publisher: preview.publisher,
      releaseDate: preview.releaseDate,
      releaseYear: preview.releaseDate?.year ?? preview.series?.volumeStartYear,
      barcode: preview.barcode,
      variant: preview.variantName,
      series: series,
      publishing: publishing,
      country: preview.country,
      language: preview.language,
      ageRating: preview.ageRating,
      audienceRating: preview.audienceRating,
      creators: [
        for (final creator in preview.creators)
          {
            'name': creator.name,
            if (creator.role != null) 'role': creator.role,
            if (creator.imageUrl != null) 'image_url': creator.imageUrl,
          },
      ],
      characters: preview.characters,
      storyArcs: preview.storyArcs,
      genres: preview.genres,
    );
  }

  @override
  Map<String, Object?> buildCorrections({
    required LibraryMetadataItem preview,
    required LibraryMetadataItem edited,
  }) {
    final corrections = <String, Object?>{};
    if (edited.title != preview.title) corrections['title'] = edited.title;
    if (edited.titleExtension != preview.titleExtension) {
      corrections['title_extension'] = edited.titleExtension;
    }
    if (edited.sortKey != preview.sortKey) {
      corrections['sort_key'] = edited.sortKey;
    }
    if (edited.originalTitle != preview.originalTitle) {
      corrections['original_title'] = edited.originalTitle;
    }
    if (edited.localizedTitle != preview.localizedTitle) {
      corrections['localized_title'] = edited.localizedTitle;
    }
    if (!sameStringList(edited.searchAliases, preview.searchAliases)) {
      corrections['search_aliases'] = edited.searchAliases;
    }
    if (edited.itemNumber != preview.itemNumber) {
      corrections['item_number'] = edited.itemNumber;
    }
    if (edited.synopsis != preview.synopsis) {
      corrections['synopsis'] = edited.synopsis;
    }
    if (edited.crossover != preview.crossover) {
      corrections['crossover'] = edited.crossover;
    }
    if (edited.plotSummary != preview.plotSummary) {
      corrections['plot_summary'] = edited.plotSummary;
    }
    if (edited.plotDescription != preview.plotDescription) {
      corrections['plot_description'] = edited.plotDescription;
    }
    if (edited.publisher != preview.publisher) {
      corrections['publisher'] = edited.publisher;
    }
    if (edited.releaseDate != preview.releaseDate) {
      corrections['release_date'] = edited.releaseDate?.toIso8601String();
    }
    if (edited.barcode != preview.barcode) {
      corrections['barcode'] = edited.barcode;
    }
    if (edited.variant != preview.variant) {
      corrections['variant_name'] = edited.variant;
    }
    if (edited.editionTitle != preview.editionTitle) {
      corrections['edition_title'] = edited.editionTitle;
    }
    if (edited.publishing?.pageCount != preview.publishing?.pageCount) {
      corrections['page_count'] = edited.publishing?.pageCount;
    }
    if (edited.publishing?.imprint != preview.publishing?.imprint) {
      corrections['imprint'] = edited.publishing?.imprint;
    }
    if (edited.publishing?.subtitle != preview.publishing?.subtitle) {
      corrections['subtitle'] = edited.publishing?.subtitle;
    }
    if (edited.publishing?.seriesGroup != preview.publishing?.seriesGroup) {
      corrections['series_group'] = edited.publishing?.seriesGroup;
    }
    if (edited.physicalFormat != preview.physicalFormat) {
      corrections['physical_format'] = edited.physicalFormat;
    }
    if (edited.country != preview.country) {
      corrections['country'] = edited.country;
    }
    if (edited.language != preview.language) {
      corrections['language'] = edited.language;
    }
    if (edited.ageRating != preview.ageRating) {
      corrections['age_rating'] = edited.ageRating;
    }
    if (edited.audienceRating != preview.audienceRating) {
      corrections['audience_rating'] = edited.audienceRating;
    }
    if (!sameStringList(edited.genres, preview.genres)) {
      corrections['genres'] = edited.genres;
    }
    if (!sameCreators(edited.creators, preview.creators)) {
      corrections['creators'] = edited.creators;
    }
    if (!sameStringList(edited.characters, preview.characters)) {
      corrections['characters'] = edited.characters;
    }
    if (!sameStringList(edited.storyArcs, preview.storyArcs)) {
      corrections['story_arcs'] = edited.storyArcs;
    }
    if (!sameTrailerLinks(edited.trailerUrls, preview.trailerUrls)) {
      corrections['external_links'] = edited.trailerUrls;
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

class NoopLibraryKindProviderMapper extends CommonLibraryKindProviderMapper {
  const NoopLibraryKindProviderMapper();
}

class LibraryFacetModule {
  const LibraryFacetModule({
    required this.loadRows,
  });

  final LibraryFacetRowsLoader loadRows;
}

typedef LibraryFacetRowsLoader = Future<List<Map<String, dynamic>>> Function(
  LibraryFacetRequest request,
);

class LibraryFacetModuleProvider extends LibraryFacetProvider {
  const LibraryFacetModuleProvider(this.module);

  final LibraryFacetModule module;

  @override
  Future<FacetBuckets> load(LibraryFacetRequest request) async {
    final rows = await module.loadRows(request);
    final byBucket = LibraryPageUtilities.parseFacetRows(rows, request.itemIds);
    return LibraryPageUtilities.buildFacetBuckets(
      signature: request.signature,
      byBucket: byBucket,
      allBucketLabel: request.allBucketLabel,
      totalItemCount: request.itemIds.length,
    );
  }
}

Future<List<Map<String, dynamic>>> _emptyFacetRows(
  LibraryFacetRequest request,
) async {
  return const <Map<String, dynamic>>[];
}

class LibraryFacetRequest {
  const LibraryFacetRequest({
    required this.api,
    required this.type,
    required this.groupMode,
    required this.itemIds,
    required this.signature,
    this.allBucketLabel,
  });

  final ApiClient api;
  final LibraryTypeConfig type;
  final LibraryGroupMode groupMode;
  final Set<String> itemIds;
  final String signature;
  final String? allBucketLabel;
}

abstract class LibraryFacetProvider {
  const LibraryFacetProvider();

  Future<FacetBuckets> load(LibraryFacetRequest request);
}
