import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/stats/library_stats_cards.dart';
import 'package:flutter/material.dart';

class BookStatsCapability implements LibraryStatsCapability {
  const BookStatsCapability();

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
    final catalog = entry.catalogTransport;
    final metadata = entry.catalogTransport?.kindMetadata;
    if (catalog == null || metadata is! BookCatalogMetadata) return null;
    final primary =
        (metadata.seriesTitle ?? metadata.series?.seriesTitle ?? catalog.title)
            .trim();
    final secondary =
        (metadata.publisher ?? metadata.originalPublisher)?.trim();
    return LibraryStatsMetadataProjection(
      primaryGroup: primary,
      secondaryGroup: secondary,
      hasCover: catalog.displayCoverUrl?.trim().isNotEmpty == true,
      hasSynopsis: metadata.synopsis?.trim().isNotEmpty == true ||
          catalog.synopsis?.trim().isNotEmpty == true,
      hasSecondaryMetadata: secondary?.isNotEmpty == true ||
          metadata.physicalFormat?.trim().isNotEmpty == true,
      hasReleaseDate: metadata.originalPublicationDate != null ||
          catalog.releaseDate != null,
      hasItemNumber: metadata.itemNumber?.trim().isNotEmpty == true,
    );
  }

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryKindModule type,
  ) =>
      const [];

  @override
  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryKindModule type,
  ) {
    final volumeGap = _numberedGapSummary(
      state.entries,
      (entry) {
        final payload = entry.catalogTransport?.payload;
        final rawVolume = payload?['volume_number'] ??
            (payload?['series'] as Map?)?['volume_number'];
        if (rawVolume == null) return null;
        final volume = double.tryParse(rawVolume.toString());
        if (volume == null || volume % 1 != 0) return null;
        return volume.toInt();
      },
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

  static _MissingNumberSummary? _numberedGapSummary(
    List<LibraryWorkspaceSource> entries,
    int? Function(LibraryWorkspaceSource entry) numberFor,
  ) {
    _MissingNumberSummary? best;
    final seriesNumbers = <String, Set<int>>{};
    for (final entry in entries) {
      if (!entry.isOwned) continue;
      final payload = entry.catalogTransport?.payload;
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
}

class _MissingNumberSummary {
  const _MissingNumberSummary(this.seriesTitle, this.missingNumbers);
  final String seriesTitle;
  final List<int> missingNumbers;
}
