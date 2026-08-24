import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';

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
    final kindMetadata = item.source.catalogItem?.kindMetadata;
    final metadata = kindMetadata is BoardGameMetadata ? kindMetadata : null;
    final series = metadata?.series;

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
        if (metadata?.minPlayers != null || metadata?.maxPlayers != null)
          LibraryDetailField(
            label: 'Players',
            value: (metadata?.minPlayers != null &&
                    metadata?.maxPlayers != null &&
                    metadata!.minPlayers != metadata.maxPlayers)
                ? '${metadata.minPlayers}–${metadata.maxPlayers}'
                : '${metadata?.maxPlayers ?? metadata?.minPlayers}',
          ),
        if (metadata?.minPlaytimeMinutes != null ||
            metadata?.maxPlaytimeMinutes != null)
          LibraryDetailField(
            label: 'Playtime',
            value: (metadata?.minPlaytimeMinutes != null &&
                    metadata?.maxPlaytimeMinutes != null &&
                    metadata!.minPlaytimeMinutes != metadata.maxPlaytimeMinutes)
                ? '${metadata.minPlaytimeMinutes}-${metadata.maxPlaytimeMinutes} min'
                : '${metadata?.maxPlaytimeMinutes ?? metadata?.minPlaytimeMinutes} min',
          ),
        if (metadata?.minimumAge != null)
          LibraryDetailField(
            label: 'Min Age',
            value: '${metadata!.minimumAge}+',
          ),
        if (metadata?.complexityWeight != null)
          LibraryDetailField(
            label: 'Complexity',
            value: '${metadata!.complexityWeight!.toStringAsFixed(2)} / 5.0',
          ),
        if (metadata?.bggRank != null)
          LibraryDetailField(label: 'BGG Rank', value: '#${metadata!.bggRank}'),
        if (metadata?.bggRating != null)
          LibraryDetailField(
              label: 'BGG Rating',
              value: metadata!.bggRating!.toStringAsFixed(1)),
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
      creators: metadata?.creators ?? const <Map<String, dynamic>>[],
      characters: const <String>[],
      storyArcs: const <String>[],
      genres: metadata?.categories ?? const <String>[],
    );
  }
}
