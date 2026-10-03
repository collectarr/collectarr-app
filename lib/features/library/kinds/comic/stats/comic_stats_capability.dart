import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:flutter/material.dart';

class ComicStatsCapability implements LibraryStatsCapability {
  const ComicStatsCapability();

  @override
  LibraryEntryFinancialSummary buildEntryFinancialSummary(
      LibraryWorkspaceSource entry) {
    return LibraryEntryFinancialSummary(
      pricePaidCents: entry.pricePaidCents,
      sellPriceCents: entry.sellPriceCents,
      currency: entry.currency,
    );
  }

  @override
  LibraryStatsMetadataProjection? buildMetadataProjection(
      LibraryWorkspaceSource entry) {
    final catalog = entry.catalogData;
    final metadata = _comicMetadata(entry);
    if (catalog == null || metadata == null) return null;
    final primary = (metadata.seriesTitle ?? catalog.title).trim();
    final secondary = (metadata.publisher ?? metadata.imprint)?.trim();
    return LibraryStatsMetadataProjection(
      primaryGroup: primary,
      secondaryGroup: secondary,
      hasCover: catalog.coverImageUrl?.trim().isNotEmpty == true,
      hasSynopsis: metadata.synopsis?.trim().isNotEmpty == true ||
          libraryWorkspaceCatalogSynopsis(catalog)?.trim().isNotEmpty == true,
      hasSecondaryMetadata: secondary?.isNotEmpty == true ||
          metadata.physicalFormat?.trim().isNotEmpty == true,
      hasReleaseDate:
          metadata.releaseDate != null || catalog.releaseDate != null,
      hasItemNumber: metadata.issueNumber?.trim().isNotEmpty == true,
    );
  }

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryKindRegistration type,
  ) {
    final keyComicCount = countKeyComics(state.entries);
    return [
      if (keyComicCount > 0)
        LibraryStatsTileDescriptor(
          icon: Icons.label_important,
          label: 'Key items',
          value: keyComicCount.toString(),
        ),
    ];
  }

  static int countKeyComics(Iterable<LibraryWorkspaceSource> entries) {
    return entries.where((entry) => entry.isEntry).where((entry) {
      return _comicLibraryEntry(entry)?.personal.details.keyComic == true;
    }).length;
  }

  @override
  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryKindRegistration type,
  ) {
    final seriesGap = _seriesGapSummary(state.entries);
    final volumeGap = _numberedGapSummary(
      state.entries,
      (entry) {
        final metadata = _comicMetadata(entry);
        final rawVolume = metadata?.volumeNumber;
        if (rawVolume == null) return null;
        final volume = double.tryParse(rawVolume);
        if (volume == null || volume % 1 != 0) {
          return null;
        }
        return volume.toInt();
      },
    );

    return [
      LibraryStatsRankedCard(
        title: 'Top Creators',
        values: _topCreatorCounts(state.entries),
      ),
      LibraryStatsRankedCard(
        title: 'Top Characters',
        values: _topCharacterCounts(state.entries),
      ),
      LibraryStatsRankedCard(
        title: 'Top Story Arcs',
        values: _topStoryArcCounts(state.entries),
      ),
      if (seriesGap != null)
        LibraryMissingIssuesCard(
          selectedSeries: seriesGap.seriesTitle,
          missingIssues: seriesGap.missingIssues,
        ),
      if (volumeGap != null)
        LibraryMissingSequenceCard(
          title: 'Missing volumes',
          selectedSeries: volumeGap.seriesTitle,
          missingValues: volumeGap.missingNumbers,
          valueLabelBuilder: (value) => 'Vol. $value',
        ),
    ];
  }

  static Map<String, int> _topCreatorCounts(
      List<LibraryWorkspaceSource> entries) {
    return _countMany(
      entries,
      _creatorNames,
    );
  }

  static Map<String, int> _topCharacterCounts(
      List<LibraryWorkspaceSource> entries) {
    return _countMany(
      entries,
      (entry) =>
          _comicMetadata(entry)
              ?.characters
              .map((character) => character.name?.trim())
              .whereType<String>()
              .where((name) => name.isNotEmpty) ??
          const <String>[],
    );
  }

  static Map<String, int> _topStoryArcCounts(
      List<LibraryWorkspaceSource> entries) {
    return _countMany(
      entries,
      (entry) =>
          _comicMetadata(entry)
              ?.storyArcs
              .map((arc) => arc.name?.trim())
              .whereType<String>()
              .where((name) => name.isNotEmpty) ??
          const <String>[],
    );
  }

  static Iterable<String> _creatorNames(LibraryWorkspaceSource entry) {
    final meta = _comicMetadata(entry);
    if (meta == null) {
      return const <String>[];
    }
    return [
      ...meta.contributors.map((credit) => credit.name ?? ''),
      ...meta.creators.map((credit) => credit.name ?? ''),
    ];
  }

  static Map<String, int> _countMany(
    Iterable<LibraryWorkspaceSource> entries,
    Iterable<String> Function(LibraryWorkspaceSource entry) valuesFor,
  ) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final seen = <String>{};
      for (final raw in valuesFor(entry)) {
        final normalized = raw.trim();
        if (normalized.isEmpty) {
          continue;
        }
        final key = normalized.toLowerCase();
        if (!seen.add(key)) {
          continue;
        }
        counts[normalized] = (counts[normalized] ?? 0) + 1;
      }
    }
    return counts;
  }

  static _SeriesGapSummary? _seriesGapSummary(
      List<LibraryWorkspaceSource> entries) {
    _SeriesGapSummary? best;
    final seriesNumbers = <String, Set<int>>{};
    for (final entry in entries) {
      if (!entry.isEntry) {
        continue;
      }
      final metadata = _comicMetadata(entry);
      final seriesTitle = metadata?.seriesTitle?.trim();
      final issueNumber = _wholeIssueNumber(metadata?.issueNumber);
      if (seriesTitle == null || seriesTitle.isEmpty || issueNumber == null) {
        continue;
      }
      seriesNumbers.putIfAbsent(seriesTitle, () => <int>{}).add(issueNumber);
    }
    for (final series in seriesNumbers.entries) {
      final sorted = series.value.toList(growable: false)..sort();
      if (sorted.length < 2) {
        continue;
      }
      final missing = <int>[];
      for (var number = sorted.first; number <= sorted.last; number++) {
        if (!series.value.contains(number)) {
          missing.add(number);
        }
      }
      if (missing.isEmpty) {
        continue;
      }
      final summary = _SeriesGapSummary(series.key, missing);
      if (best == null ||
          summary.missingIssues.length > best.missingIssues.length) {
        best = summary;
      }
    }
    return best;
  }

  static _MissingNumberSummary? _numberedGapSummary(
    List<LibraryWorkspaceSource> entries,
    int? Function(LibraryWorkspaceSource entry) numberFor,
  ) {
    _MissingNumberSummary? best;
    final seriesNumbers = <String, Set<int>>{};
    for (final entry in entries) {
      if (!entry.isEntry) {
        continue;
      }
      final metadata = _comicMetadata(entry);
      final seriesTitle = metadata?.seriesTitle?.trim();
      final number = numberFor(entry);
      if (seriesTitle == null || seriesTitle.isEmpty || number == null) {
        continue;
      }
      seriesNumbers.putIfAbsent(seriesTitle, () => <int>{}).add(number);
    }
    for (final series in seriesNumbers.entries) {
      final sorted = series.value.toList(growable: false)..sort();
      if (sorted.length < 2) {
        continue;
      }
      final missing = <int>[];
      for (var number = sorted.first; number <= sorted.last; number++) {
        if (!series.value.contains(number)) {
          missing.add(number);
        }
      }
      if (missing.isEmpty) {
        continue;
      }
      final summary = _MissingNumberSummary(series.key, missing);
      if (best == null ||
          summary.missingNumbers.length > best.missingNumbers.length) {
        best = summary;
      }
    }
    return best;
  }

  static int? _wholeIssueNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final match = RegExp(r"^\s*(\d+)").firstMatch(value);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  static ComicLibraryEntry? _comicLibraryEntry(LibraryWorkspaceSource entry) {
    return ComicLibraryEntryProjection.fromDispatch(entry.libraryEntryDispatch);
  }

  static ComicCatalogItem? _comicMetadata(LibraryWorkspaceSource entry) {
    final catalog = entry.catalogData;
    return catalog is ComicWorkspaceCatalogData ? catalog.comic : null;
  }
}

class _SeriesGapSummary {
  const _SeriesGapSummary(this.seriesTitle, this.missingIssues);

  final String seriesTitle;
  final List<int> missingIssues;
}

class _MissingNumberSummary {
  const _MissingNumberSummary(this.seriesTitle, this.missingNumbers);

  final String seriesTitle;
  final List<int> missingNumbers;
}
