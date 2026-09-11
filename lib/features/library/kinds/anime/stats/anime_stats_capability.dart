import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
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
  LibraryOwnedFinancialSummary buildOwnedFinancialSummary(
      LibraryWorkspaceSource entry) {
    return LibraryOwnedFinancialSummary(
      pricePaidCents: entry.pricePaidCents,
      sellPriceCents: entry.sellPriceCents,
      currency: entry.currency,
    );
  }

  @override
  LibraryStatsMetadataProjection? buildMetadataProjection(
      LibraryWorkspaceSource entry) {
    final catalog = entry.catalogItem;
    final metadata = _metadata(entry);
    if (catalog == null || metadata == null) return null;
    final secondary =
        (metadata.publisher ?? metadata.studios.firstOrNull)?.trim();
    return LibraryStatsMetadataProjection(
      primaryGroup: (metadata.seriesTitle ?? metadata.title).trim(),
      secondaryGroup: secondary,
      hasCover: catalog.displayCoverUrl?.trim().isNotEmpty == true,
      hasSynopsis: catalog.synopsis?.trim().isNotEmpty == true,
      hasSecondaryMetadata: secondary?.isNotEmpty == true ||
          metadata.physicalFormat?.trim().isNotEmpty == true,
      hasReleaseDate: metadata.startDate != null || catalog.releaseDate != null,
      hasItemNumber: metadata.itemNumber?.trim().isNotEmpty == true,
    );
  }

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryKindModule type,
  ) {
    final episodes = totalEpisodes(state.resolvedWorkspaceEntries);
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
    LibraryKindModule type,
  ) {
    return [
      LibraryStatsRankedCard(
        title: 'Top Genres',
        values: countGenres(state.resolvedWorkspaceEntries),
      ),
      LibraryStatsRankedCard(
        title: 'Top Studios',
        values: countStudios(state.resolvedWorkspaceEntries),
      ),
      LibraryStatsDistributionCard(
        title: 'Formats',
        values: countFormats(state.resolvedWorkspaceEntries),
      ),
      LibraryStatsDistributionCard(
        title: 'Source Material',
        values: countSourceMaterial(state.resolvedWorkspaceEntries),
      ),
    ];
  }

  static int totalEpisodes(Iterable<LibraryWorkspaceSource> entries) {
    return entries.fold<int>(
      0,
      (total, entry) => total + (_metadata(entry)?.episodeCount ?? 0),
    );
  }

  static Map<String, int> countGenres(
      Iterable<LibraryWorkspaceSource> entries) {
    return _countMany(entries, (metadata) => metadata.genres);
  }

  static Map<String, int> countStudios(
      Iterable<LibraryWorkspaceSource> entries) {
    return _countMany(entries, (metadata) => metadata.studios);
  }

  static Map<String, int> countFormats(
      Iterable<LibraryWorkspaceSource> entries) {
    return _countMany(entries, (metadata) => [metadata.format.label]);
  }

  static Map<String, int> countSourceMaterial(
      Iterable<LibraryWorkspaceSource> entries) {
    return _countMany(entries, (metadata) => [metadata.sourceMaterial.label]);
  }

  static AnimeMetadata? _metadata(LibraryWorkspaceSource entry) {
    final metadata = entry.catalogItem?.kindMetadata;
    return metadata is AnimeMetadata ? metadata : null;
  }

  static Map<String, int> _countMany(
    Iterable<LibraryWorkspaceSource> entries,
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
