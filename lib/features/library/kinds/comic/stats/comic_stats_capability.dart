import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/remote/comic_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:flutter/material.dart';

class ComicStatsCapability implements LibraryStatsCapability {
  const ComicStatsCapability();

  @override
  LibraryOwnedFinancialSummary buildOwnedFinancialSummary(ShelfEntry entry) {
    final owned = entry.ownedItem;
    return LibraryOwnedFinancialSummary(
      pricePaidCents: owned?.pricePaidCents,
      sellPriceCents: owned?.sellPriceCents,
      currency: owned?.currency,
    );
  }

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryKindRuntime type,
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

  static int countKeyComics(Iterable<ShelfEntry> entries) {
    return entries.where((entry) => entry.isOwned).where((entry) {
      return _comicOwnedItem(entry)?.details.keyComic == true;
    }).length;
  }

  @override
  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryKindRuntime type,
  ) {
    final seriesGap = _seriesGapSummary(state.entries);
    final volumeGap = _numberedGapSummary(
      state.entries,
      (entry) {
        final metadata = _comicMetadata(entry);
        final rawVolume = metadata?.series?.volumeNumber;
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

  static Map<String, int> _topCreatorCounts(List<ShelfEntry> entries) {
    return _countMany(
      entries,
      _creatorNames,
    );
  }

  static Map<String, int> _topCharacterCounts(List<ShelfEntry> entries) {
    return _countMany(
      entries,
      (entry) =>
          _comicMetadata(entry)
              ?.characters
              .where((name) => name.trim().isNotEmpty) ??
          const <String>[],
    );
  }

  static Map<String, int> _topStoryArcCounts(List<ShelfEntry> entries) {
    return _countMany(
      entries,
      (entry) =>
          _comicMetadata(entry)
              ?.storyArcs
              .where((name) => name.trim().isNotEmpty) ??
          const <String>[],
    );
  }

  static Iterable<String> _creatorNames(ShelfEntry entry) {
    final meta = _comicMetadata(entry);
    if (meta == null) {
      return const <String>[];
    }
    if (meta.creatorCredits.isNotEmpty) {
      return meta.creatorCredits.map((credit) => credit.name);
    }
    return meta.creators.map((credit) => credit['name']?.toString() ?? '');
  }

  static Map<String, int> _countMany(
    Iterable<ShelfEntry> entries,
    Iterable<String> Function(ShelfEntry entry) valuesFor,
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

  static _SeriesGapSummary? _seriesGapSummary(List<ShelfEntry> entries) {
    _SeriesGapSummary? best;
    final seriesNumbers = <String, Set<int>>{};
    for (final entry in entries) {
      if (!entry.isOwned) {
        continue;
      }
      final metadata = _comicMetadata(entry);
      final seriesTitle =
          (metadata?.seriesTitle ?? metadata?.series?.seriesTitle)?.trim();
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
    List<ShelfEntry> entries,
    int? Function(ShelfEntry entry) numberFor,
  ) {
    _MissingNumberSummary? best;
    final seriesNumbers = <String, Set<int>>{};
    for (final entry in entries) {
      if (!entry.isOwned) {
        continue;
      }
      final metadata = _comicMetadata(entry);
      final seriesTitle =
          (metadata?.seriesTitle ?? metadata?.series?.seriesTitle)?.trim();
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

  static ComicOwnedItem? _comicOwnedItem(ShelfEntry entry) {
    final owned = entry.ownedItem;
    if (owned == null) {
      return null;
    }
    return ComicOwnedItemProjection.tryFromOwnedItem(owned);
  }

  static ComicMedia? _comicMetadata(ShelfEntry entry) {
    final catalog = entry.catalogItem;
    if (catalog == null || catalog.kind != 'comic') {
      return null;
    }
    return ComicCoreMapper.fromCatalogItem(catalog);
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
