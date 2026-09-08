import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:collectarr_app/features/library/stats/library_stats_style.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:flutter/material.dart';

/// Shows a rich statistics dashboard dialog for any media type.
Future<void> showStatsDashboardDialog(
  BuildContext context, {
  required LibraryKindModule type,
  required ShelfState state,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _GenericStatsDashboard(type: type, state: state),
  );
}

class _GenericStatsDashboard extends StatelessWidget {
  const _GenericStatsDashboard({required this.type, required this.state});

  final LibraryKindModule type;
  final ShelfState state;

  LibraryMediaStatsLabels get _statsLabels => type.presentation.statsLabels;

  @override
  Widget build(BuildContext context) {
    final colors = libraryStatsColors(context);
    final totalValue = state.totalPaidCents == null
        ? '-'
        : formatMoney(state.totalPaidCents, state.primaryCurrency);
    final netValue =
        state.totalPaidCents == null || state.totalSellCents == null
            ? null
            : formatMoney(
                state.totalSellCents! - state.totalPaidCents!,
                state.primaryCurrency,
              );
    final collectionValueSummary = type.value?.resolveCollectionValueSummary(
      state.resolvedWorkspaceEntries,
    );
    final collectionValue = collectionValueSummary == null
        ? null
        : collectionValueSummary.hasMixedCurrencies
            ? '${collectionValueSummary.valuedCount} valued'
            : collectionValueSummary.totalValueCents == null ||
                    collectionValueSummary.totalValueCents == 0
                ? null
                : formatMoney(
                    collectionValueSummary.totalValueCents,
                    collectionValueSummary.currency,
                  );
    final sellValue = state.totalSellCents == null || state.totalSellCents == 0
        ? null
        : formatMoney(state.totalSellCents, state.primaryCurrency);
    final module = type;
    final missingCovers = state.resolvedWorkspaceEntries
        .where((e) => _metadataDto(e, module)?.coverImageUrl == null)
        .length;
    final missingMetadata =
        _missingMetadataCount(state.resolvedWorkspaceEntries, module);
    final valueCoverage =
        state.ownedCount == 0 ? 0.0 : state.pricedCount / state.ownedCount;
    final metadataQualityBands =
        _metadataQualityBands(state.resolvedWorkspaceEntries, module);
    final metadataAlertCounts =
        _metadataAlertCounts(state.resolvedWorkspaceEntries, type, module);

    final kindSummaryTiles = module.stats.buildSummaryTiles(state, type);
    final kindCustomCards = module.stats.buildCustomCards(context, state, type);

    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980, maxHeight: 760),
        child: ColoredBox(
          color: colors.canvas,
          child: Column(
            children: [
              AccentDialogHeader(
                title: '${type.identity.pluralLabel} Statistics',
                icon: type.identity.icon,
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
                            icon: type.identity.icon,
                            label: 'Total',
                            value: state.resolvedWorkspaceEntries.length
                                .toString(),
                          ),
                          LibraryStatsTile(
                            icon: Icons.check_box,
                            label: 'Owned',
                            value: state.ownedCount.toString(),
                          ),
                          for (final tile in kindSummaryTiles)
                            LibraryStatsTile(
                              icon: tile.icon,
                              label: tile.label,
                              value: tile.value,
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
                              values: _topSeriesCounts(
                                state.resolvedWorkspaceEntries,
                                module,
                              ),
                            ),
                            LibraryStatsRankedCard(
                              title: _publisherLabel,
                              values: _topPublisherCounts(
                                state.resolvedWorkspaceEntries,
                                module,
                              ),
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
                                values: _topInvestedLocations(
                                  state.resolvedWorkspaceEntries,
                                ),
                                currency: state.primaryCurrency,
                              ),
                            if (!state.hasMixedCurrencies &&
                                state.primaryCurrency != null)
                              LibraryStatsMoneyRankedCard(
                                title: 'Most Invested Series',
                                values: _topInvestedSeries(
                                  state.resolvedWorkspaceEntries,
                                  module,
                                ),
                                currency: state.primaryCurrency,
                              ),
                            if (!state.hasMixedCurrencies &&
                                state.primaryCurrency != null)
                              LibraryStatsMoneyRankedCard(
                                title: 'Top Buyers',
                                values: _topBuyerSales(
                                  state.resolvedWorkspaceEntries,
                                ),
                                currency: state.primaryCurrency,
                              ),
                            if (!state.hasMixedCurrencies &&
                                state.primaryCurrency != null)
                              LibraryStatsMoneyRankedCard(
                                title: 'Top Sales Series',
                                values: _topSalesSeries(
                                  state.resolvedWorkspaceEntries,
                                  module,
                                ),
                                currency: state.primaryCurrency,
                              ),
                            _TrackingStatusCard(
                              entries: state.resolvedWorkspaceEntries,
                            ),
                            LibraryStatsHealthCard(
                              title: 'Data Health',
                              rows: [
                                LibraryStatsHealthRow(
                                  label: 'Value coverage',
                                  fraction: valueCoverage,
                                ),
                                LibraryStatsHealthRow(
                                  label: 'Graded coverage',
                                  fraction: state.ownedCount == 0
                                      ? 0.0
                                      : (state.ownedCount -
                                              state.missingGradeCount) /
                                          state.ownedCount,
                                ),
                                LibraryStatsHealthRow(
                                  label: 'Metadata coverage',
                                  fraction: state
                                          .resolvedWorkspaceEntries.isEmpty
                                      ? 0.0
                                      : (state.resolvedWorkspaceEntries.length -
                                              missingMetadata) /
                                          state.resolvedWorkspaceEntries.length,
                                ),
                                LibraryStatsHealthRow(
                                  label: 'Cover coverage',
                                  fraction: state
                                          .resolvedWorkspaceEntries.isEmpty
                                      ? 0.0
                                      : (state.resolvedWorkspaceEntries.length -
                                              missingCovers) /
                                          state.resolvedWorkspaceEntries.length,
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
                            ...kindCustomCards,
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
    return _statsLabels.labelFor('top_series', fallback: 'Top Series');
  }

  String get _publisherLabel {
    return _statsLabels.labelFor(
      'top_publisher',
      fallback: 'Top Publishers',
    );
  }

  static LibraryWorkspaceDto? _metadataDto(
    ShelfEntry entry,
    LibraryKindModule module,
  ) {
    final catalog = entry.catalogItem;
    if (catalog == null) return null;
    return libraryKindWorkspaceForKind(module.kind)
        .project(
          source: entry,
          node: LibraryTitleNodeRef(
            titleItemId: entry.catalogRef?.id ?? catalog.id,
          ),
        )
        .dto;
  }

  static Map<String, int> _topSeriesCounts(
    List<ShelfEntry> entries,
    LibraryKindModule module,
  ) {
    return _countBy(
      entries,
      (e) {
        final dto = _metadataDto(e, module);
        if (dto == null) return 'Unknown';
        final adapter = dto is WorkspaceDtoAdapter ? dto : null;
        return adapter?.seriesTitle ?? dto.title;
      },
    );
  }

  static Map<String, int> _topPublisherCounts(
    List<ShelfEntry> entries,
    LibraryKindModule module,
  ) {
    return _countBy(
      entries,
      (e) {
        final dto = _metadataDto(e, module);
        final adapter = dto is WorkspaceDtoAdapter ? dto : null;
        final raw = adapter?.publisher;
        if (raw != null && raw.trim().isNotEmpty) {
          return raw.trim();
        }
        return 'Unknown';
      },
    );
  }

  static int _missingMetadataCount(
    List<ShelfEntry> entries,
    LibraryKindModule module,
  ) {
    var count = 0;
    for (final entry in entries) {
      final dto = _metadataDto(entry, module);
      if (dto == null) {
        count++;
        continue;
      }
      final adapter = dto is WorkspaceDtoAdapter ? dto : null;
      final hasSynopsis = adapter?.synopsis?.trim().isNotEmpty == true;
      final format = adapter?.format?.trim();
      final hasPublisher =
          adapter?.publisher?.trim().isNotEmpty == true || format != null;
      if (!hasSynopsis && !hasPublisher) {
        count++;
      }
    }
    return count;
  }

  static Map<String, int> _topInvestedLocations(List<ShelfEntry> entries) {
    return _sumBy(
      entries,
      (entry) => entry.locationPath ?? 'No location',
      (entry) => entry.pricePaidCents,
    );
  }

  static Map<String, int> _topInvestedSeries(
    List<ShelfEntry> entries,
    LibraryKindModule module,
  ) {
    return _sumBy(
      entries,
      (entry) {
        final dto = _metadataDto(entry, module);
        if (dto == null) return 'Unknown';
        final adapter = dto is WorkspaceDtoAdapter ? dto : null;
        return adapter?.seriesTitle ?? dto.title;
      },
      (entry) => entry.pricePaidCents,
    );
  }

  static Map<String, int> _topBuyerSales(List<ShelfEntry> entries) {
    return _sumBy(
      entries,
      (entry) => entry.soldTo ?? 'Unknown buyer',
      (entry) => entry.sellPriceCents,
    );
  }

  static Map<String, int> _topSalesSeries(
    List<ShelfEntry> entries,
    LibraryKindModule module,
  ) {
    return _sumBy(
      entries,
      (entry) {
        final dto = _metadataDto(entry, module);
        if (dto == null) return 'Unknown';
        final adapter = dto is WorkspaceDtoAdapter ? dto : null;
        return adapter?.seriesTitle ?? dto.title;
      },
      (entry) => entry.sellPriceCents,
    );
  }

  static Map<String, int> _metadataQualityBands(
    List<ShelfEntry> entries,
    LibraryKindModule module,
  ) {
    final counts = <String, int>{
      'Strong': 0,
      'Usable': 0,
      'Thin': 0,
      'Needs work': 0,
    };
    for (final entry in entries) {
      final band = _metadataBand(entry, module);
      counts[band] = (counts[band] ?? 0) + 1;
    }
    return counts;
  }

  static Map<String, int> _metadataAlertCounts(
    List<ShelfEntry> entries,
    LibraryKindModule type,
    LibraryKindModule module,
  ) {
    final labels = libraryMediaGroupLabels(type);
    final missingPublisherLabel =
        'Missing ${labels.labelFor('publisher', fallback: 'publisher').toLowerCase()}';
    final missingSeriesLabel =
        'Missing ${labels.labelFor('series', fallback: 'series').toLowerCase()}';
    final counts = <String, int>{};
    for (final entry in entries) {
      final dto = _metadataDto(entry, module);
      if (dto == null) {
        counts['No catalog snapshot'] =
            (counts['No catalog snapshot'] ?? 0) + 1;
        continue;
      }
      final adapter = dto is WorkspaceDtoAdapter ? dto : null;
      if (dto.coverImageUrl == null || dto.coverImageUrl!.trim().isEmpty) {
        counts['Missing cover'] = (counts['Missing cover'] ?? 0) + 1;
      }
      if (adapter?.synopsis?.trim().isNotEmpty != true) {
        counts['Missing synopsis'] = (counts['Missing synopsis'] ?? 0) + 1;
      }
      final hasPublisher = adapter?.publisher?.trim().isNotEmpty == true ||
          adapter?.format?.trim().isNotEmpty == true;
      if (!hasPublisher) {
        counts[missingPublisherLabel] =
            (counts[missingPublisherLabel] ?? 0) + 1;
      }
      if (adapter?.seriesTitle == null || adapter!.seriesTitle!.isEmpty) {
        counts[missingSeriesLabel] = (counts[missingSeriesLabel] ?? 0) + 1;
      }
      if (entry.itemId.startsWith('provider:')) {
        counts['Provider placeholder'] =
            (counts['Provider placeholder'] ?? 0) + 1;
      }
    }
    return counts;
  }

  static String _metadataBand(ShelfEntry entry, LibraryKindModule module) {
    final dto = _metadataDto(entry, module);
    if (dto == null) {
      return 'Needs work';
    }
    var score = 0;
    void add(bool present, int weight) {
      if (present) {
        score += weight;
      }
    }

    final adapter = dto is WorkspaceDtoAdapter ? dto : null;

    add(
      dto.coverImageUrl != null && dto.coverImageUrl!.trim().isNotEmpty,
      25,
    );
    add(
      adapter?.synopsis?.trim().isNotEmpty == true,
      25,
    );
    final hasPublisher = adapter?.publisher?.trim().isNotEmpty == true ||
        adapter?.format?.trim().isNotEmpty == true;
    add(hasPublisher, 15);
    add(adapter?.releaseDate != null, 15);
    add(adapter?.seriesTitle != null && adapter!.seriesTitle!.isNotEmpty, 10);
    add(adapter?.itemNumber != null && adapter!.itemNumber!.trim().isNotEmpty,
        10);

    if (score >= 80) {
      return 'Strong';
    }
    if (score >= 60) {
      return 'Usable';
    }
    if (score >= 40) {
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
}

/// Card showing tracking status distribution.
class _TrackingStatusCard extends StatelessWidget {
  const _TrackingStatusCard({required this.entries});

  final List<ShelfEntry> entries;

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final status = entry.tracking.statusLabel.trim();
      if (status.isNotEmpty) {
        counts[status] = (counts[status] ?? 0) + 1;
      }
    }
    return LibraryStatsDistributionCard(title: 'Tracking', values: counts);
  }
}
