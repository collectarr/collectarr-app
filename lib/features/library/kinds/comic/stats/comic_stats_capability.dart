import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_stats_capability.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:flutter/material.dart';

class ComicStatsCapability implements LibraryStatsCapability {
  const ComicStatsCapability();

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryTypeConfig type,
  ) {
    return [
      if (state.keyComicCount > 0)
        LibraryStatsTileDescriptor(
          icon: Icons.label_important,
          label: 'Key items',
          value: state.keyComicCount.toString(),
        ),
    ];
  }

  @override
  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryTypeConfig type,
  ) {
    final seriesGap = _seriesGapSummary(state.entries);
    final volumeGap = _numberedGapSummary(
      state.entries,
      (entry) {
        final payload = entry.catalogItem?.kindMetadata.toSyncPayload();
        final rawVolume = payload?['volume_number'] ??
            (payload?['series'] as Map?)?['volume_number'];
        if (rawVolume == null) return null;
        final volume = double.tryParse(rawVolume.toString());
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
      (entry) => _creatorCredits(entry)
          .map((credit) => credit['name']?.toString() ?? '')
          .where((name) => name.trim().isNotEmpty),
    );
  }

  static Map<String, int> _topCharacterCounts(List<ShelfEntry> entries) {
    return _countMany(
      entries,
      (entry) =>
          _comicMetadata(entry)
              ?.characters
              .where((name) => name.trim().isNotEmpty) ??
          ((entry.catalogItem?.kindMetadata.toSyncPayload()['characters']
                  as List?)
              ?.cast<String>()
              .where((name) => name.trim().isNotEmpty)) ??
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
          ((entry.catalogItem?.kindMetadata.toSyncPayload()['story_arcs']
                  as List?)
              ?.cast<String>()
              .where((name) => name.trim().isNotEmpty)) ??
          const <String>[],
    );
  }

  static ComicCatalogMetadata? _comicMetadata(ShelfEntry entry) {
    final metadata = entry.catalogItem?.kindMetadata;
    return metadata is ComicCatalogMetadata ? metadata : null;
  }

  static Iterable<Map<String, dynamic>> _creatorCredits(ShelfEntry entry) {
    final meta = _comicMetadata(entry);
    if (meta != null) return meta.creators;
    final payload = entry.catalogItem?.kindMetadata.toSyncPayload();
    final creators = payload?['creators'] as List?;
    if (creators != null) {
      return creators.whereType<Map<String, dynamic>>();
    }
    return const <Map<String, dynamic>>[];
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
      final payload = entry.catalogItem?.kindMetadata.toSyncPayload();
      final seriesTitle = ((payload?['series_title'] ??
              (payload?['series'] as Map?)?['series_title']) as String?)
          ?.trim();
      final itemNumberStr = payload?['item_number'] as String?;
      final issueNumber = _wholeIssueNumber(itemNumberStr);
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
      final payload = entry.catalogItem?.kindMetadata.toSyncPayload();
      final seriesTitle = ((payload?['series_title'] ??
              (payload?['series'] as Map?)?['series_title']) as String?)
          ?.trim();
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
