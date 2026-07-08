import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_domain.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_row.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
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
    final playStats = boardGameWork?.playStats;
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: entry.id),
          LibraryDetailField(label: 'Title', value: entry.title),
        ],
        if (series?.seriesTitle != null)
          LibraryDetailField(label: 'Series', value: series!.seriesTitle!, onTap: tapFor(series.seriesTitle)),
        LibraryDetailField(label: mediaFields.numberLabel, value: genericLibraryDash(entry.itemNumber), onTap: tapFor(entry.itemNumber)),
        LibraryDetailField(label: releaseFields.variantLabel, value: genericLibraryDash(entry.variant), onTap: tapFor(entry.variant)),
        LibraryDetailField(label: releaseFields.barcodeLabel, value: genericLibraryDash(entry.barcode)),
      ],
      contextFacts: [
        LibraryDetailField(label: mediaFields.publisherLabel, value: genericLibraryDash(entry.publisher), onTap: tapFor(entry.publisher)),
        LibraryDetailField(label: 'Released', value: genericLibraryDash(
            formatPresentationNullableDate(entry.releaseDate) ??
                entry.releaseYear?.toString(),
          )),
        if (selectedEdition?.minPlayers != null ||
            selectedEdition?.maxPlayers != null)
          LibraryDetailField(label: 'Players', value: _playersLabel(selectedEdition)),
        if (selectedEdition?.playingTimeMinutes != null)
          LibraryDetailField(label: 'Playing Time', value: '${selectedEdition!.playingTimeMinutes} min'),
        if (selectedEdition?.minAge != null)
          LibraryDetailField(label: 'Age', value: '${selectedEdition!.minAge}+'),
        if (selectedEdition?.country != null)
          LibraryDetailField(label: 'Country', value: selectedEdition!.country!),
        if (selectedEdition?.language != null)
          LibraryDetailField(label: 'Language', value: selectedEdition!.language!),
        if (selectedEdition?.releaseStatus != null)
          LibraryDetailField(label: 'Release Status', value: selectedEdition!.releaseStatus!),
        if (boardGameWork?.contributors.isNotEmpty == true)
          LibraryDetailField(label: 'Designers', value: boardGameWork!.contributors.join(', ')),
        if (boardGameWork?.categories.isNotEmpty == true)
          LibraryDetailField(label: boardGameWork!.categories.length == 1 ? 'Category' : 'Categories', value: boardGameWork.categories.join(', ')),
        if (boardGameWork?.mechanics.isNotEmpty == true)
          LibraryDetailField(label: boardGameWork!.mechanics.length == 1 ? 'Mechanic' : 'Mechanics', value: boardGameWork.mechanics.join(', ')),
        if (boardGameWork?.expansions.isNotEmpty == true)
          LibraryDetailField(label: boardGameWork!.expansions.length == 1 ? 'Expansion' : 'Expansions', value: boardGameWork.expansions.join(', ')),
        if (selectedEdition?.audienceRating != null)
          LibraryDetailField(label: 'Audience Rating', value: selectedEdition!.audienceRating!),
        if (playStats?.bggRank != null)
          LibraryDetailField(label: 'BGG Rank', value: '#${playStats!.bggRank}'),
        if (playStats?.bggRating != null)
          LibraryDetailField(label: 'BGG Rating', value: playStats!.bggRating!.toStringAsFixed(2)),
        if (playStats?.playCount != null)
          LibraryDetailField(label: 'Play Count', value: playStats!.playCount.toString()),
        if (playStats?.lastPlayed != null)
          LibraryDetailField(label: 'Last Played', value: _dateLabel(playStats!.lastPlayed!)),
        if (playStats?.favoritePlayerCount != null)
          LibraryDetailField(label: 'Favorite Players', value: playStats!.favoritePlayerCount.toString()),
        if (entry.barcode?.trim().isNotEmpty == true)
          LibraryDetailField(label: 'Barcode', value: entry.barcode!),
        LibraryDetailField(label: 'Cover', value: entry.hasMissingCover ? 'Missing' : 'Ready'),
        LibraryDetailField(label: 'Metadata', value: entry.hasMissingMetadata ? 'Missing' : 'Ready'),
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

String _dateLabel(DateTime value) {
  final y = value.year.toString().padLeft(4, '0');
  final m = value.month.toString().padLeft(2, '0');
  final d = value.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

