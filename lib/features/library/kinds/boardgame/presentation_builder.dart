import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

class BoardGameLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const BoardGameLibraryMediaPresentationBuilder({
    this.metadataLabels = const LibraryMetadataLabels(),
  });

  final LibraryMetadataLabels metadataLabels;

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required LibraryProjectionRuntime item,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final dto = item.dto;
    final adapter = dto is WorkspaceDtoAdapter ? dto : null;
    final itemNumber = adapter?.itemNumber;
    final variant = adapter?.variant;
    final barcode = adapter?.barcode;
    final publisher = adapter?.publisher;
    final releaseDate = adapter?.releaseDate;
    final country = adapter?.country;
    final language = adapter?.language;

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
            label: 'Edition',
            value: genericLibraryDash(itemNumber),
            onTap: tapFor(itemNumber)),
        LibraryDetailField(
            label: 'Expansion / Edition',
            value: genericLibraryDash(variant),
            onTap: tapFor(variant)),
        LibraryDetailField(
            label: 'Barcode', value: genericLibraryDash(barcode)),
      ],
      contextFacts: [
        LibraryDetailField(
            label: 'Publisher / Designer',
            value: genericLibraryDash(publisher),
            onTap: tapFor(publisher)),
        LibraryDetailField(
            label: 'Released',
            value: genericLibraryDash(
              formatPresentationNullableDate(releaseDate) ??
                  releaseDate?.year.toString(),
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
        if (country != null)
          LibraryDetailField(
              label: 'Country', value: country, onTap: tapFor(country)),
        if (language != null)
          LibraryDetailField(
              label: 'Language', value: language, onTap: tapFor(language)),
      ],
      sections: {
        'creators': LibraryMetadataSection(
          values: metadata?.creators ?? const <Map<String, dynamic>>[],
          placement: LibraryMetadataSectionPlacement.credits,
          renderer: LibraryMetadataSectionRenderer.credits,
          completenessWeight: 12,
        ),
        'genres': LibraryMetadataSection(
          values: metadata?.categories ?? const <String>[],
        ),
      },
    );
  }
}
