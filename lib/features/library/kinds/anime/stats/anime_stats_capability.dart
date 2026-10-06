import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:flutter/material.dart';

/// Anime-specific collection statistics.
///
/// Anime is represented as a series with episode metadata, so the useful
/// aggregate is episode volume and not the runtime/season semantics of the
/// generic video capability.
final class AnimeStatsCapability implements LibraryStatsCapability {
  const AnimeStatsCapability();

  @override
  LibraryEntryFinancialSummary buildEntryFinancialSummary(
      LibraryWorkspaceContext entry) {
    return LibraryEntryFinancialSummary(
      pricePaidCents: entry.pricePaidCents,
      sellPriceCents: entry.sellPriceCents,
      currency: entry.currency,
    );
  }

  @override
  LibraryStatsMetadataProjection? buildMetadataProjection(
      LibraryWorkspaceContext entry) {
    final metadata = _metadata(entry);
    if (metadata == null) return null;
    final secondary =
        (metadata.publisher ?? metadata.studios.firstOrNull)?.trim();
    return LibraryStatsMetadataProjection(
      primaryGroup: (metadata.seriesTitle ?? metadata.title).trim(),
      secondaryGroup: secondary,
      hasCover: metadata.coverImageUrl?.trim().isNotEmpty == true,
      hasSynopsis: metadata.synopsis?.trim().isNotEmpty == true,
      hasSecondaryMetadata: secondary?.isNotEmpty == true ||
          metadata.physicalFormat?.trim().isNotEmpty == true,
      hasReleaseDate:
          metadata.startDate != null || metadata.releaseDate != null,
      hasItemNumber: metadata.itemNumber?.trim().isNotEmpty == true,
    );
  }

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryKindRegistration type,
  ) {
    final episodes = totalEpisodes(state.entries);
    return [
      if (episodes > 0)
        LibraryStatsTileDescriptor(
          icon: Icons.format_list_numbered_outlined,
          label: 'Episodes',
          value: episodes.toString(),
        ),
    ];
  }

  @override
  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryKindRegistration type,
  ) {
    return [
      LibraryStatsRankedCard(
        title: 'Top Genres',
        values: countGenres(state.entries),
      ),
      LibraryStatsRankedCard(
        title: 'Top Studios',
        values: countStudios(state.entries),
      ),
      LibraryStatsDistributionCard(
        title: 'Formats',
        values: countFormats(state.entries),
      ),
      LibraryStatsDistributionCard(
        title: 'Source Material',
        values: countSourceMaterial(state.entries),
      ),
    ];
  }

  @override
  Widget? buildCustomHeader(
    BuildContext context,
    ShelfState state,
    LibraryKindRegistration type,
  ) =>
      null;

  @override
  Widget? buildCustomStatsPage(
    BuildContext context,
    ShelfState state,
    LibraryKindRegistration type,
  ) =>
      null;

  static int totalEpisodes(Iterable<LibraryWorkspaceContext> entries) {
    return entries.fold<int>(
      0,
      (total, entry) => total + (_metadata(entry)?.episodeCount ?? 0),
    );
  }

  static Map<String, int> countGenres(
      Iterable<LibraryWorkspaceContext> entries) {
    return _countMany(entries, (metadata) => metadata.genres);
  }

  static Map<String, int> countStudios(
      Iterable<LibraryWorkspaceContext> entries) {
    return _countMany(entries, (metadata) => metadata.studios);
  }

  static Map<String, int> countFormats(
      Iterable<LibraryWorkspaceContext> entries) {
    return _countMany(entries, (metadata) => [metadata.format.label]);
  }

  static Map<String, int> countSourceMaterial(
      Iterable<LibraryWorkspaceContext> entries) {
    return _countMany(entries, (metadata) => [metadata.sourceMaterial.label]);
  }

  static AnimeMetadata? _metadata(LibraryWorkspaceContext entry) {
    final catalog = entry.kindPresentationData;
    return catalog is AnimeWorkspaceData ? catalog.metadata : null;
  }

  static Map<String, int> _countMany(
    Iterable<LibraryWorkspaceContext> entries,
    Iterable<String> Function(AnimeMetadata metadata) valuesFor,
  ) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final metadata = _metadata(entry);
      if (metadata == null) continue;
      final seen = <String>{};
      for (final raw in valuesFor(metadata)) {
        final value = raw.trim();
        if (value.isEmpty) continue;
        final key = value.toLowerCase();
        if (!seen.add(key)) continue;
        counts[value] = (counts[value] ?? 0) + 1;
      }
    }
    return counts;
  }
}
