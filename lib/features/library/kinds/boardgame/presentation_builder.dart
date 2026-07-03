import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_domain.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

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
    required LibraryWorkspaceEntry entry,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final series = entry.series;
    final boardGameWork = entry is BoardGameWorkspaceEntry
        ? entry.boardGameWork
        : null;
    final selectedEdition =
        boardGameWork == null || boardGameWork.editions.isEmpty
            ? null
            : boardGameWork.editions.first;
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryInspectorFactData('Kind', singularLabel),
          LibraryInspectorFactData('ID', entry.id),
          LibraryInspectorFactData('Title', entry.title),
        ],
        if (series?.seriesTitle != null)
          LibraryInspectorFactData(
            'Series',
            series!.seriesTitle!,
            onTap: tapFor(series.seriesTitle),
          ),
        LibraryInspectorFactData(
          mediaFields.numberLabel,
          genericLibraryDash(entry.itemNumber),
          onTap: tapFor(entry.itemNumber),
        ),
        LibraryInspectorFactData(
          releaseFields.variantLabel,
          genericLibraryDash(entry.variant),
          onTap: tapFor(entry.variant),
        ),
        LibraryInspectorFactData(
          releaseFields.barcodeLabel,
          genericLibraryDash(entry.barcode),
        ),
      ],
      contextFacts: [
        LibraryInspectorFactData(
          mediaFields.publisherLabel,
          genericLibraryDash(entry.publisher),
          onTap: tapFor(entry.publisher),
        ),
        LibraryInspectorFactData(
          'Released',
          genericLibraryDash(
            formatPresentationNullableDate(entry.releaseDate) ??
                entry.releaseYear?.toString(),
          ),
        ),
        if (selectedEdition?.minPlayers != null ||
            selectedEdition?.maxPlayers != null)
          LibraryInspectorFactData(
            'Players',
            _playersLabel(selectedEdition),
          ),
        if (selectedEdition?.playingTimeMinutes != null)
          LibraryInspectorFactData(
            'Playing Time',
            '${selectedEdition!.playingTimeMinutes} min',
          ),
        if (selectedEdition?.minAge != null)
          LibraryInspectorFactData('Age', '${selectedEdition!.minAge}+'),
        if (selectedEdition?.country != null)
          LibraryInspectorFactData('Country', selectedEdition!.country!),
        if (selectedEdition?.language != null)
          LibraryInspectorFactData('Language', selectedEdition!.language!),
        if (selectedEdition?.releaseStatus != null)
          LibraryInspectorFactData(
            'Release Status',
            selectedEdition!.releaseStatus!,
          ),
        if (boardGameWork?.contributors.isNotEmpty == true)
          LibraryInspectorFactData(
            'Designers',
            boardGameWork!.contributors.join(', '),
          ),
        if (boardGameWork?.categories.isNotEmpty == true)
          LibraryInspectorFactData(
            boardGameWork!.categories.length == 1 ? 'Category' : 'Categories',
            boardGameWork.categories.join(', '),
          ),
        if (boardGameWork?.mechanics.isNotEmpty == true)
          LibraryInspectorFactData(
            boardGameWork!.mechanics.length == 1 ? 'Mechanic' : 'Mechanics',
            boardGameWork.mechanics.join(', '),
          ),
        if (boardGameWork?.expansions.isNotEmpty == true)
          LibraryInspectorFactData(
            boardGameWork!.expansions.length == 1 ? 'Expansion' : 'Expansions',
            boardGameWork.expansions.join(', '),
          ),
        if (selectedEdition?.audienceRating != null)
          LibraryInspectorFactData(
            'Audience Rating',
            selectedEdition!.audienceRating!,
          ),
        if (entry.barcode?.trim().isNotEmpty == true)
          LibraryInspectorFactData('Barcode', entry.barcode!),
        LibraryInspectorFactData(
          'Cover',
          entry.hasMissingCover ? 'Missing' : 'Ready',
        ),
        LibraryInspectorFactData(
          'Metadata',
          entry.hasMissingMetadata ? 'Missing' : 'Ready',
        ),
      ],
      creators: entry.creators ?? const <Map<String, dynamic>>[],
      characters: entry.characters ?? const <String>[],
      storyArcs: entry.storyArcs ?? const <String>[],
      genres: entry.genres ?? const <String>[],
    );
  }
}

String _playersLabel(BoardGameEdition? edition) {
  if (edition == null) {
    return 'Players';
  }
  final minPlayers = edition.minPlayers;
  final maxPlayers = edition.maxPlayers;
  if (minPlayers != null && maxPlayers != null && minPlayers != maxPlayers) {
    return '$minPlayers-$maxPlayers';
  }
  if (minPlayers != null) {
    return '$minPlayers';
  }
  if (maxPlayers != null) {
    return '$maxPlayers';
  }
  return 'Players';
}
