import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:collectarr_app/features/library/stats/library_stats_style.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:flutter/material.dart';

/// Shows a rich statistics dashboard dialog for any media type.
Future<void> showStatsDashboardDialog(
  BuildContext context, {
  required LibraryTypeConfig type,
  required ShelfState state,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _GenericStatsDashboard(type: type, state: state),
  );
}

class _GenericStatsDashboard extends StatelessWidget {
  const _GenericStatsDashboard({required this.type, required this.state});

  final LibraryTypeConfig type;
  final ShelfState state;

  LibraryMediaStatsLabels get _statsLabels => type.presentation.statsLabels;

  @override
  Widget build(BuildContext context) {
    final colors = libraryStatsColors(context);
    final totalValue = state.totalPaidCents == null
        ? '-'
        : formatMoney(state.totalPaidCents, state.primaryCurrency);
    final netValue = state.totalPaidCents == null || state.totalSellCents == null
        ? null
        : formatMoney(
            state.totalSellCents! - state.totalPaidCents!,
            state.primaryCurrency,
          );
    final collectionValue = state.hasMixedCoverPriceCurrencies
      ? '${state.coverPricedCount} valued'
      : state.totalCoverPriceCents == null || state.totalCoverPriceCents == 0
        ? null
        : formatMoney(state.totalCoverPriceCents, state.coverPriceCurrency);
    final sellValue = state.totalSellCents == null || state.totalSellCents == 0
        ? null
        : formatMoney(state.totalSellCents, state.primaryCurrency);
    final missingCovers =
        state.entries.where((e) => e.catalogItem?.coverImageUrl == null).length;
    final missingMetadata = _missingMetadataCount(state.entries);
    final valueCoverage =
        state.ownedCount == 0 ? 0.0 : state.pricedCount / state.ownedCount;
    final metadataQualityBands = _metadataQualityBands(state.entries);
    final metadataAlertCounts = _metadataAlertCounts(state.entries, type);
    final seriesGapSummary =
      _seriesGapSummary(state.entries, type.workspace.kind.apiValue);
    final volumeGapSummary = _numberedGapSummary(
      state.entries,
      (entry) {
        final volume = entry.catalogItem?.series?.volumeNumber;
        if (volume == null || volume % 1 != 0) {
          return null;
        }
        return volume.toInt();
      },
    );
    final seasonGapSummary = _numberedGapSummary(
      state.entries,
      (entry) => entry.catalogItem?.series?.seasonNumber,
    );

    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980, maxHeight: 760),
        child: ColoredBox(
          color: colors.canvas,
          child: Column(
            children: [
              AccentDialogHeader(
                title: '${type.pluralLabel} Statistics',
                icon: type.workspace.icon,
                onClose: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Summary tiles
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          LibraryStatsTile(
                            icon: type.workspace.icon,
                            label: 'Total',
                            value: state.entries.length.toString(),
                          ),
                          LibraryStatsTile(
                            icon: Icons.check_box,
                            label: 'Owned',
                            value: state.ownedCount.toString(),
                          ),
                          LibraryStatsTile(
                            icon: Icons.label_important,
                            label: 'Key items',
                            value: state.keyComicCount.toString(),
                          ),
                          LibraryStatsTile(
                            icon: Icons.star,
                            label: 'Wishlist',
                            value: state.wishlistCount.toString(),
                          ),
                          LibraryStatsTile(
                            icon: Icons.attach_money,
                            label: 'Total paid',
                            value: state.hasMixedCurrencies
                                ? '$totalValue +'
                                : totalValue,
                          ),
                          if (collectionValue != null)
                            LibraryStatsTile(
                              icon: Icons.inventory_2_outlined,
                              label: 'Collection value',
                              value: collectionValue,
                            ),
                          if (sellValue != null)
                            LibraryStatsTile(
                              icon: Icons.sell_outlined,
                              label: 'Sold total',
                              value: sellValue,
                            ),
                          if (state.soldCount > 0)
                            LibraryStatsTile(
                              icon: Icons.local_offer_outlined,
                              label: 'Sold copies',
                              value: state.soldCount.toString(),
                            ),
                          if (netValue != null)
                            LibraryStatsTile(
                              icon: Icons.trending_up,
                              label: 'Net',
                              value: netValue,
                            ),
                          LibraryStatsTile(
                            icon: Icons.image_not_supported_outlined,
                            label: 'Missing covers',
                            value: missingCovers.toString(),
                          ),
                          LibraryStatsTile(
                            icon: Icons.cloud_off,
                            label: 'Missing metadata',
                            value: missingMetadata.toString(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Detail cards
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >=
                              kLibraryStatsDialogWideBreakpoint;
                          final children = <Widget>[
                            LibraryStatsRankedCard(
                              title: _seriesLabel,
                              values: _topSeriesCounts(state.entries),
                            ),
                            LibraryStatsRankedCard(
                              title: _publisherLabel,
                              values: _topPublisherCounts(state.entries),
                            ),
                            if (state.gradeCounts.isNotEmpty)
                              LibraryStatsDistributionCard(
                                title: 'Grades',
                                values: state.gradeCounts,
                              ),
                            if (state.conditionCounts.isNotEmpty)
                              LibraryStatsDistributionCard(
                                title: 'Conditions',
                                values: state.conditionCounts,
                              ),
                            if (!state.hasMixedCurrencies &&
                                state.primaryCurrency != null)
                              LibraryStatsMoneyRankedCard(
                                title: 'Most Invested Locations',
                                values: _topInvestedLocations(state.entries),
                                currency: state.primaryCurrency,
                              ),
                            if (!state.hasMixedCurrencies &&
                                state.primaryCurrency != null)
                              LibraryStatsMoneyRankedCard(
                                title: 'Most Invested Series',
                                values: _topInvestedSeries(state.entries),
                                currency: state.primaryCurrency,
                              ),
                            if (!state.hasMixedCurrencies &&
                                state.primaryCurrency != null)
                              LibraryStatsMoneyRankedCard(
                                title: 'Top Buyers',
                                values: _topBuyerSales(state.entries),
                                currency: state.primaryCurrency,
                              ),
                            if (!state.hasMixedCurrencies &&
                                state.primaryCurrency != null)
                              LibraryStatsMoneyRankedCard(
                                title: 'Top Sales Series',
                                values: _topSalesSeries(state.entries),
                                currency: state.primaryCurrency,
                              ),
                            _TrackingStatusCard(entries: state.entries),
                            LibraryStatsHealthCard(
                              title: 'Data Health',
                              rows: [
                                ComicsStatsHealthRow(
                                  label: 'Value coverage',
                                  fraction: valueCoverage,
                                ),
                                ComicsStatsHealthRow(
                                  label: 'Graded coverage',
                                  fraction: state.ownedCount == 0
                                      ? 0.0
                                      : (state.ownedCount -
                                              state.missingGradeCount) /
                                          state.ownedCount,
                                ),
                                ComicsStatsHealthRow(
                                  label: 'Metadata coverage',
                                  fraction: state.entries.isEmpty
                                      ? 0.0
                                      : (state.entries.length -
                                              missingMetadata) /
                                          state.entries.length,
                                ),
                                ComicsStatsHealthRow(
                                  label: 'Cover coverage',
                                  fraction: state.entries.isEmpty
                                      ? 0.0
                                      : (state.entries.length -
                                              missingCovers) /
                                          state.entries.length,
                                ),
                              ],
                            ),
                            LibraryStatsDistributionCard(
                              title: 'Metadata Quality',
                              values: metadataQualityBands,
                            ),
                            LibraryStatsRankedCard(
                              title: 'Metadata Alerts',
                              values: metadataAlertCounts,
                            ),
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
                            if (seriesGapSummary != null)
                              LibraryMissingIssuesCard(
                                selectedSeries: seriesGapSummary.seriesTitle,
                                missingIssues: seriesGapSummary.missingIssues,
                              ),
                            if (volumeGapSummary != null)
                              LibraryMissingSequenceCard(
                                title: 'Missing volumes',
                                selectedSeries: volumeGapSummary.seriesTitle,
                                missingValues: volumeGapSummary.missingNumbers,
                                valueLabelBuilder: (value) => 'Vol. $value',
                              ),
                            if (seasonGapSummary != null)
                              LibraryMissingSequenceCard(
                                title: 'Missing seasons',
                                selectedSeries: seasonGapSummary.seriesTitle,
                                missingValues: seasonGapSummary.missingNumbers,
                                valueLabelBuilder: (value) => 'Season $value',
                              ),
                          ];
                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final child in children)
                                SizedBox(
                                  width: wide
                                      ? (constraints.maxWidth - 20) / 3
                                      : constraints.maxWidth,
                                  child: child,
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _seriesLabel {
    return _statsLabels.topSeries;
  }

  String get _publisherLabel {
    return _statsLabels.topPublisher;
  }

  static Map<String, int> _topSeriesCounts(List<ShelfEntry> entries) {
    return _countBy(
      entries,
      (e) =>
          e.catalogItem?.series?.seriesTitle ??
          e.catalogItem?.title ??
          'Unknown',
    );
  }

  static Map<String, int> _topPublisherCounts(List<ShelfEntry> entries) {
    return _countBy(
      entries,
      (e) => e.catalogItem?.publisher ?? 'Unknown',
    );
  }

  static int _missingMetadataCount(List<ShelfEntry> entries) {
    var count = 0;
    for (final entry in entries) {
      final cat = entry.catalogItem;
      if (cat == null ||
          (cat.synopsis == null || cat.synopsis!.trim().isEmpty) &&
              (cat.publisher == null || cat.publisher!.trim().isEmpty)) {
        count++;
      }
    }
    return count;
  }

  static Map<String, int> _topCreatorCounts(List<ShelfEntry> entries) {
    return _countMany(
      entries,
      (entry) => (entry.catalogItem?.creators ?? const <Map<String, dynamic>>[])
          .map((credit) => credit['name']?.toString() ?? '')
          .where((name) => name.trim().isNotEmpty),
    );
  }

  static Map<String, int> _topCharacterCounts(List<ShelfEntry> entries) {
    return _countMany(
      entries,
      (entry) => (entry.catalogItem?.characters ?? const <String>[])
          .where((name) => name.trim().isNotEmpty),
    );
  }

  static Map<String, int> _topStoryArcCounts(List<ShelfEntry> entries) {
    return _countMany(
      entries,
      (entry) => (entry.catalogItem?.storyArcs ?? const <String>[])
          .where((name) => name.trim().isNotEmpty),
    );
  }

  static Map<String, int> _topInvestedLocations(List<ShelfEntry> entries) {
    return _sumBy(
      entries,
      (entry) => entry.locationPath ?? 'No location',
      (entry) => entry.ownedItem?.pricePaidCents,
    );
  }

  static Map<String, int> _topInvestedSeries(List<ShelfEntry> entries) {
    return _sumBy(
      entries,
      (entry) =>
          entry.catalogItem?.series?.seriesTitle ??
          entry.catalogItem?.title ??
          'Unknown',
      (entry) => entry.ownedItem?.pricePaidCents,
    );
  }

  static Map<String, int> _topBuyerSales(List<ShelfEntry> entries) {
    return _sumBy(
      entries,
      (entry) => entry.ownedItem?.soldTo ?? 'Unknown buyer',
      (entry) => entry.ownedItem?.sellPriceCents,
    );
  }

  static Map<String, int> _topSalesSeries(List<ShelfEntry> entries) {
    return _sumBy(
      entries,
      (entry) =>
          entry.catalogItem?.series?.seriesTitle ??
          entry.catalogItem?.title ??
          'Unknown',
      (entry) => entry.ownedItem?.sellPriceCents,
    );
  }

  static Map<String, int> _metadataQualityBands(List<ShelfEntry> entries) {
    final counts = <String, int>{
      'Strong': 0,
      'Usable': 0,
      'Thin': 0,
      'Needs work': 0,
    };
    for (final entry in entries) {
      final band = _metadataBand(entry);
      counts[band] = (counts[band] ?? 0) + 1;
    }
    return counts;
  }

  static Map<String, int> _metadataAlertCounts(
    List<ShelfEntry> entries,
    LibraryTypeConfig type,
  ) {
    final labels = libraryMediaGroupLabels(type);
    final missingPublisherLabel = 'Missing ${labels.publisher.toLowerCase()}';
    final missingSeriesLabel = 'Missing ${labels.series.toLowerCase()}';
    final counts = <String, int>{};
    for (final entry in entries) {
      final item = entry.catalogItem;
      if (item == null) {
        counts['No catalog snapshot'] = (counts['No catalog snapshot'] ?? 0) + 1;
        continue;
      }
      if (item.displayCoverUrl == null || item.displayCoverUrl!.trim().isEmpty) {
        counts['Missing cover'] = (counts['Missing cover'] ?? 0) + 1;
      }
      if (item.synopsis == null || item.synopsis!.trim().isEmpty) {
        counts['Missing synopsis'] = (counts['Missing synopsis'] ?? 0) + 1;
      }
      if (item.publisher == null || item.publisher!.trim().isEmpty) {
        counts[missingPublisherLabel] =
            (counts[missingPublisherLabel] ?? 0) + 1;
      }
      if ((item.creators ?? const <Map<String, dynamic>>[]).isEmpty) {
        counts['Missing creators'] = (counts['Missing creators'] ?? 0) + 1;
      }
      final seriesTitle = item.series?.seriesTitle;
      if (seriesTitle == null || seriesTitle.trim().isEmpty) {
        counts[missingSeriesLabel] = (counts[missingSeriesLabel] ?? 0) + 1;
      }
      if (item.id.startsWith('provider:')) {
        counts['Provider placeholder'] = (counts['Provider placeholder'] ?? 0) + 1;
      }
    }
    return counts;
  }

  static String _metadataBand(ShelfEntry entry) {
    final item = entry.catalogItem;
    if (item == null) {
      return 'Needs work';
    }
    var score = 0;
    void add(bool present, int weight) {
      if (present) {
        score += weight;
      }
    }

    add(item.displayCoverUrl != null && item.displayCoverUrl!.trim().isNotEmpty, 18);
    add(item.synopsis != null && item.synopsis!.trim().isNotEmpty, 16);
    add(item.publisher != null && item.publisher!.trim().isNotEmpty, 10);
    add(item.releaseDate != null || item.releaseYear != null, 10);
    add(
      item.series?.seriesTitle != null &&
          item.series!.seriesTitle!.trim().isNotEmpty,
      10,
    );
    add(item.itemNumber != null && item.itemNumber!.trim().isNotEmpty, 6);
    add((item.creators ?? const <Map<String, dynamic>>[]).isNotEmpty, 12);
    add((item.characters ?? const <String>[]).isNotEmpty, 6);
    add((item.storyArcs ?? const <String>[]).isNotEmpty, 4);
    add((item.genres ?? const <String>[]).isNotEmpty, 4);
    add(!itemHasMissingCover(item) && !itemHasMissingDetails(item), 4);

    if (score >= 85) {
      return 'Strong';
    }
    if (score >= 65) {
      return 'Usable';
    }
    if (score >= 45) {
      return 'Thin';
    }
    return 'Needs work';
  }

  static Map<String, int> _countBy(
    Iterable<ShelfEntry> entries,
    String Function(ShelfEntry entry) keyFor,
  ) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final key = keyFor(entry).trim();
      final normalized = key.isEmpty ? 'Unknown' : key;
      counts[normalized] = (counts[normalized] ?? 0) + 1;
    }
    return counts;
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

  static Map<String, int> _sumBy(
    Iterable<ShelfEntry> entries,
    String Function(ShelfEntry entry) keyFor,
    int? Function(ShelfEntry entry) amountFor,
  ) {
    final totals = <String, int>{};
    for (final entry in entries) {
      final amount = amountFor(entry);
      if (amount == null || amount <= 0) {
        continue;
      }
      final key = keyFor(entry).trim();
      final normalized = key.isEmpty ? 'Unknown' : key;
      totals[normalized] = (totals[normalized] ?? 0) + amount;
    }
    return totals;
  }

  static _SeriesGapSummary? _seriesGapSummary(
    List<ShelfEntry> entries,
    String mediaKind,
  ) {
    if (mediaKind != 'comic') {
      return null;
    }
    _SeriesGapSummary? best;
    final seriesNumbers = <String, Set<int>>{};
    for (final entry in entries) {
      if (!entry.isOwned) {
        continue;
      }
      final seriesTitle = entry.catalogItem?.series?.seriesTitle?.trim();
      final issueNumber = _wholeIssueNumber(entry.catalogItem?.itemNumber);
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
      if (best == null || summary.missingIssues.length > best.missingIssues.length) {
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
      final seriesTitle = entry.catalogItem?.series?.seriesTitle?.trim();
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
      if (best == null || summary.missingNumbers.length > best.missingNumbers.length) {
        best = summary;
      }
    }
    return best;
  }

  static int? _wholeIssueNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final match = RegExp(r'^\s*(\d+)').firstMatch(value);
    return match == null ? null : int.tryParse(match.group(1)!);
  }
}

/// Card showing tracking status distribution.
class _TrackingStatusCard extends StatelessWidget {
  const _TrackingStatusCard({required this.entries});

  final List<ShelfEntry> entries;

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final status = entry.ownedItem?.readStatus?.trim();
      if (status != null && status.isNotEmpty) {
        counts[status] = (counts[status] ?? 0) + 1;
      }
    }
    return LibraryStatsDistributionCard(title: 'Tracking', values: counts);
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
