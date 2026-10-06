import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:flutter/material.dart';

class BookStatsCapability implements LibraryStatsCapability {
  const BookStatsCapability();

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
    final primary = (metadata.seriesTitle ?? metadata.title).trim();
    final secondary = metadata.publisher?.trim();
    return LibraryStatsMetadataProjection(
      primaryGroup: primary,
      secondaryGroup: secondary,
      hasCover: metadata.coverImageUrl?.trim().isNotEmpty == true,
      hasSynopsis: metadata.synopsis?.trim().isNotEmpty == true,
      hasSecondaryMetadata: secondary?.isNotEmpty == true ||
          metadata.physicalFormat?.trim().isNotEmpty == true,
      hasReleaseDate:
          metadata.releaseDate != null || metadata.releaseDateParts != null,
      hasItemNumber: metadata.itemNumber?.trim().isNotEmpty == true,
    );
  }

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryKindRegistration type,
  ) =>
      const [];

  @override
  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryKindRegistration type,
  ) {
    final volumeGap = _numberedGapSummary(
      state.entries,
      _volumeNumber,
    );

    return [
      if (volumeGap != null)
        LibraryMissingSequenceCard(
          title: 'Missing volumes',
          selectedSeries: volumeGap.seriesTitle,
          missingValues: volumeGap.missingNumbers,
          valueLabelBuilder: (value) => 'Vol. $value',
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

  static BookCatalogMetadata? _metadata(LibraryWorkspaceContext entry) {
    final catalog = entry.kindPresentationData;
    return catalog is BookWorkspaceData ? catalog.metadata : null;
  }

  static _MissingNumberSummary? _numberedGapSummary(
    List<LibraryWorkspaceContext> entries,
    int? Function(LibraryWorkspaceContext entry) numberFor,
  ) {
    _MissingNumberSummary? best;
    final seriesNumbers = <String, Set<int>>{};
    for (final entry in entries) {
      if (!entry.isEntry) continue;
      final metadata = _metadata(entry);
      final seriesTitle = metadata?.seriesTitle?.trim();
      final number = numberFor(entry);
      if (seriesTitle == null || seriesTitle.isEmpty || number == null) {
        continue;
      }
      seriesNumbers.putIfAbsent(seriesTitle, () => <int>{}).add(number);
    }
    for (final series in seriesNumbers.entries) {
      final sorted = series.value.toList(growable: false)..sort();
      if (sorted.length < 2) continue;
      final missing = <int>[];
      for (var number = sorted.first; number <= sorted.last; number++) {
        if (!series.value.contains(number)) missing.add(number);
      }
      if (missing.isEmpty) continue;
      final summary = _MissingNumberSummary(series.key, missing);
      if (best == null ||
          summary.missingNumbers.length > best.missingNumbers.length) {
        best = summary;
      }
    }
    return best;
  }

  static int? _volumeNumber(LibraryWorkspaceContext entry) {
    final metadata = _metadata(entry);
    if (metadata == null) return null;
    final seriesNumber = metadata.volumeNumber;
    final parsedSeries = int.tryParse(seriesNumber?.trim() ?? '');
    if (parsedSeries != null) return parsedSeries;
    return int.tryParse(metadata.itemNumber?.trim() ?? '');
  }
}

class _MissingNumberSummary {
  const _MissingNumberSummary(this.seriesTitle, this.missingNumbers);
  final String seriesTitle;
  final List<int> missingNumbers;
}
