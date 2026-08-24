import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';

class BoardGameLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const BoardGameLibraryMediaPresentationBuilder({
    this.metadataLabels = const LibraryMetadataLabels(),
  });

  final LibraryMetadataLabels metadataLabels;

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryProjectionRuntime item,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final dto = item.dto;
    final catalogItem = item.source.catalogItem?.toCatalogItem();
    final series = catalogItem?.series;
    final boardGameStats = catalogItem?.boardGameStats;

    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.titleItemId),
          LibraryDetailField(label: 'Title', value: dto.title),
        ],
        if (series?.seriesTitle != null)
          LibraryDetailField(
              label: 'Series',
              value: series!.seriesTitle!,
              onTap: tapFor(series.seriesTitle)),
        LibraryDetailField(
            label: mediaFields.numberLabel,
            value: genericLibraryDash(dto.itemNumber),
            onTap: tapFor(dto.itemNumber)),
        LibraryDetailField(
            label: releaseFields.variantLabel,
            value: genericLibraryDash(dto.variant),
            onTap: tapFor(dto.variant)),
        LibraryDetailField(
            label: releaseFields.barcodeLabel,
            value: genericLibraryDash(dto.barcode)),
      ],
      contextFacts: [
        LibraryDetailField(
            label: mediaFields.publisherLabel,
            value: genericLibraryDash(dto.publisher),
            onTap: tapFor(dto.publisher)),
        LibraryDetailField(
            label: 'Released',
            value: genericLibraryDash(
              formatPresentationNullableDate(dto.releaseDate) ??
                  dto.releaseDate?.year.toString(),
            )),
        if (boardGameStats?.minPlayers != null ||
            boardGameStats?.maxPlayers != null)
          LibraryDetailField(
            label: 'Players',
            value: (boardGameStats?.minPlayers != null &&
                    boardGameStats?.maxPlayers != null &&
                    boardGameStats!.minPlayers != boardGameStats.maxPlayers)
                ? '${boardGameStats.minPlayers}–${boardGameStats.maxPlayers}'
                : '${boardGameStats?.maxPlayers ?? boardGameStats?.minPlayers}',
          ),
        if (boardGameStats?.playingTimeMinutes != null ||
            boardGameStats?.minPlayingTimeMinutes != null ||
            boardGameStats?.maxPlayingTimeMinutes != null)
          LibraryDetailField(
            label: 'Playtime',
            value: (boardGameStats?.minPlayingTimeMinutes != null &&
                    boardGameStats?.maxPlayingTimeMinutes != null &&
                    boardGameStats!.minPlayingTimeMinutes !=
                        boardGameStats.maxPlayingTimeMinutes)
                ? '${boardGameStats.minPlayingTimeMinutes}–${boardGameStats.maxPlayingTimeMinutes} min'
                : '${boardGameStats?.playingTimeMinutes ?? boardGameStats?.maxPlayingTimeMinutes ?? boardGameStats?.minPlayingTimeMinutes} min',
          ),
        if (boardGameStats?.minAgeYears != null)
          LibraryDetailField(
            label: 'Min Age',
            value: '${boardGameStats!.minAgeYears}+',
          ),
        if (boardGameStats?.complexityRating != null ||
            boardGameStats?.bggWeight != null)
          LibraryDetailField(
            label: 'Complexity',
            value:
                '${(boardGameStats?.complexityRating ?? boardGameStats?.bggWeight)!.toStringAsFixed(2)} / 5.0',
          ),
        if (boardGameStats?.bggRank != null)
          LibraryDetailField(
              label: 'BGG Rank', value: '#${boardGameStats!.bggRank}'),
        if (boardGameStats?.bggRating != null)
          LibraryDetailField(
              label: 'BGG Rating',
              value: boardGameStats!.bggRating!.toStringAsFixed(1)),
        if (dto.country != null)
          LibraryDetailField(
              label: 'Country',
              value: dto.country!,
              onTap: tapFor(dto.country)),
        if (dto.language != null)
          LibraryDetailField(
              label: 'Language',
              value: dto.language!,
              onTap: tapFor(dto.language)),
      ],
      creators: catalogItem?.creators ?? const <Map<String, dynamic>>[],
      characters: catalogItem?.characters ?? const <String>[],
      storyArcs: catalogItem?.storyArcs ?? const <String>[],
      genres: catalogItem?.genres ?? const <String>[],
    );
  }
}
