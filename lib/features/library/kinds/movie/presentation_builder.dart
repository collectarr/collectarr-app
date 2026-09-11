import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/movie/release/movie_shelf_drilldown.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

class MovieLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const MovieLibraryMediaPresentationBuilder({
    this.showSummary = false,
    this.metadataLabels = const LibraryMetadataLabels(),
  });

  final bool showSummary;
  final LibraryMetadataLabels metadataLabels;

  @override
  List<LibraryDuplicateCandidate> buildDuplicateCandidates(
    LibraryWorkspaceSource entry,
  ) {
    final item = entry.catalogTransport;
    final identifier =
        normalizeLibraryDuplicateIdentifier(item?.identifierCode);
    if (item == null || identifier == null) return const [];
    return [
      LibraryDuplicateCandidate(
        key: 'identifier:$identifier',
        label: 'Identifier ${item.identifierCode!.trim()}',
        reason: 'Same identifier',
        confidenceScore: 78,
      ),
    ];
  }

  @override
  List<CatalogEditionDto> buildReleaseEditions({
    required LibraryAddCatalogTransport item,
  }) {
    return item.editions;
  }

  @override
  LibraryAddSearchResultDisplay? buildSearchResultDisplay({
    required LibraryAddCatalogTransport item,
  }) =>
      _buildMovieSearchResultDisplay(item);

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required LibraryProjectionView item,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final dto = item.dto;
    final adapter = dto is WorkspaceDtoAdapter ? dto : null;
    final movieDto = dto is MovieWorkspaceDto ? dto : null;
    final itemNumber = adapter?.itemNumber;
    final variant = adapter?.variant;
    final barcode = movieDto?.barcode;
    final publisher = movieDto?.publisher;
    final releaseDate = adapter?.releaseDate;
    final country = adapter?.country;
    final language = adapter?.language;

    final movie = item.source.catalogTransport?.kindMetadata;
    final metadata = movie is MovieCatalogMetadata ? movie : null;
    final series = metadata?.series;
    final video = metadata?.video;
    final hasVolume = series?.hasVolume ?? false;
    final hasSeason = series?.hasSeason ?? false;
    final hasEpisode = series?.hasEpisode ?? false;
    final runtime = metadata?.runtimeMinutes ??
        (video?['runtime_minutes'] as num?)?.toInt();
    final screenRatio = (video?['screen_ratio'] as String?)?.trim();
    final audioTracks = (video?['audio_tracks'] as String?)?.trim();
    final subtitles = (video?['subtitles'] as String?)?.trim();
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.titleItemId),
          LibraryDetailField(label: 'Title', value: dto.title),
        ],
        if (metadata?.editionTitle != null)
          LibraryDetailField(label: 'Edition', value: metadata!.editionTitle!),
        if (metadata?.originalTitle != null)
          LibraryDetailField(
              label: 'Original Title', value: metadata!.originalTitle!),
        if (metadata?.sortTitle != null)
          LibraryDetailField(label: 'Sort Title', value: metadata!.sortTitle!),
        if (series?.seriesTitle != null)
          LibraryDetailField(
              label: 'Series',
              value: series!.seriesTitle!,
              onTap: tapFor(series.seriesTitle)),
        if (hasVolume && !hasSeason)
          LibraryDetailField(
              label: 'Volume',
              value: series!.volumeName ??
                  libraryVolumeLabel(series.volumeNumber != null
                      ? double.tryParse(series.volumeNumber!)
                      : null)),
        if (hasSeason && hasEpisode)
          LibraryDetailField(
              label: 'Season / Episode',
              value:
                  'Season ${series!.seasonNumber}, Ep. ${series.episodeNumber}'),
        if (hasSeason && !hasEpisode)
          LibraryDetailField(
              label: 'Season', value: 'Season ${series!.seasonNumber}'),
        if (hasEpisode && !hasSeason)
          LibraryDetailField(
              label: 'Episode', value: 'Ep. ${series!.episodeNumber}'),
        LibraryDetailField(
            label: 'Edition no.',
            value: genericLibraryDash(itemNumber),
            onTap: tapFor(itemNumber)),
        LibraryDetailField(
            label: 'Format / Edition',
            value: genericLibraryDash(variant),
            onTap: tapFor(variant)),
        LibraryDetailField(
            label: 'UPC / Barcode', value: genericLibraryDash(barcode)),
      ],
      contextFacts: [
        LibraryDetailField(
            label: 'Studio',
            value: genericLibraryDash(publisher),
            onTap: tapFor(publisher)),
        LibraryDetailField(
            label: 'Released',
            value: genericLibraryDash(
              formatPresentationNullableDate(releaseDate) ??
                  releaseDate?.year.toString(),
            )),
        if (runtime != null)
          LibraryDetailField(label: 'Runtime', value: '$runtime min'),
        if (screenRatio != null && screenRatio.isNotEmpty)
          LibraryDetailField(label: 'Aspect Ratio', value: screenRatio),
        if (audioTracks != null && audioTracks.isNotEmpty)
          LibraryDetailField(label: 'Audio', value: audioTracks),
        if (subtitles != null && subtitles.isNotEmpty)
          LibraryDetailField(label: 'Subtitles', value: subtitles),
        if (country != null)
          LibraryDetailField(
              label: 'Country', value: country, onTap: tapFor(country)),
        if (language != null)
          LibraryDetailField(
              label: 'Language', value: language, onTap: tapFor(language)),
        if (metadata?.ageRating != null)
          LibraryDetailField(
              label: 'Age Rating',
              value: metadata!.ageRating!,
              onTap: tapFor(metadata.ageRating)),
        if (metadata?.audienceRating != null)
          LibraryDetailField(
              label: 'Audience Rating',
              value: metadata!.audienceRating!,
              onTap: tapFor(metadata.audienceRating)),
        LibraryDetailField(
            label: 'Cover',
            value: dto.coverImageUrl == null || dto.coverImageUrl!.isEmpty
                ? 'Missing'
                : 'Ready'),
        LibraryDetailField(
            label: 'Metadata',
            value:
                publisher == null || publisher.isEmpty ? 'Missing' : 'Ready'),
      ],
      sections: {
        'creators': LibraryMetadataSection(
          values: metadata?.creators ?? const <Map<String, dynamic>>[],
          placement: LibraryMetadataSectionPlacement.credits,
          renderer: LibraryMetadataSectionRenderer.credits,
          completenessWeight: 12,
        ),
        'genres': LibraryMetadataSection(
          values: metadata?.genres ?? const <String>[],
        ),
      },
    );
  }

  @override
  List<Widget> buildInspectorSections({
    required BuildContext context,
    required LibraryProjectionView item,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    final synopsis = item.source.catalogTransport?.synopsis;
    if (!showSummary || synopsis == null || synopsis.trim().isEmpty) {
      return const [];
    }
    return [
      LibraryDetailSection(
        title: 'Summary',
        accentColor: accent,
        children: [
          Text(
            synopsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ];
  }

  @override
  bool canOpenKindDrilldown(LibraryProjectionView item) {
    final kind = item.source.catalogTransport?.mediaKind;
    return item.node.scope == LibraryBrowserScope.title &&
        kind != null &&
        const {
          CatalogMediaKind.movie,
          CatalogMediaKind.tv,
          CatalogMediaKind.anime,
        }.contains(kind);
  }

  @override
  Widget? buildKindDrilldown({
    required BuildContext context,
    required LibraryProjectionView selectedItem,
    required Color accent,
    required double coverSize,
    required VoidCallback onBack,
    required Future<void> Function() onRefreshFromCore,
    required VoidCallback onOpenTitleDetails,
    required List<OwnedItemSummary> ownedCopies,
    required List<WishlistItem> wishlistItems,
    required String? selectedReleaseId,
    required void Function(String releaseId) onSelectRelease,
    required LibraryWorkspaceProjector projector,
  }) {
    final drilldownItems = buildMovieShelfReleaseItems(
      titleItem: selectedItem,
      ownedCopies: ownedCopies,
      wishlistItems: wishlistItems,
      projector: projector,
    );
    return MovieShelfReleaseDrilldown(
      titleItem: selectedItem,
      items: drilldownItems,
      selectedReleaseId: selectedReleaseId,
      coverSize: coverSize,
      accent: accent,
      onBack: onBack,
      onRefreshFromCore: onRefreshFromCore,
      onOpenTitleDetails: onOpenTitleDetails,
      onSelectRelease: onSelectRelease,
    );
  }
}

LibraryAddSearchResultDisplay _buildMovieSearchResultDisplay(
  LibraryAddCatalogTransport item,
) {
  final itemNumber = item.itemNumber?.trim();
  final subtitle = [
    if (item.publisher?.trim() case final value? when value.isNotEmpty) value,
    if ((item.releaseYear ?? item.releaseDate?.year) case final year?)
      year.toString(),
    if (item.physicalFormatLabel?.trim() case final value?
        when value.isNotEmpty)
      value,
    if (item.identifierCode?.trim() case final value? when value.isNotEmpty)
      value,
  ].join(' | ');
  return LibraryAddSearchResultDisplay(
    title: itemNumber == null || itemNumber.isEmpty
        ? item.title
        : '${item.title} #$itemNumber',
    secondaryLine: subtitle.isEmpty ? null : subtitle,
    detailLine: null,
  );
}
