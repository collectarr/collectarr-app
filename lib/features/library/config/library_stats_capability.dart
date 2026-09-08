import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:flutter/material.dart';

class LibraryStatsTileDescriptor {
  const LibraryStatsTileDescriptor({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

/// Small financial projection used by the generic toolbar host.
///
/// The host renders totals, while each kind decides how its Owned model
/// contributes the values.
class LibraryOwnedFinancialSummary {
  const LibraryOwnedFinancialSummary({
    this.pricePaidCents,
    this.sellPriceCents,
    this.currency,
  });

  final int? pricePaidCents;
  final int? sellPriceCents;
  final String? currency;
}

/// Structural metadata facts consumed by the generic statistics host.
///
/// The names deliberately describe presentation roles rather than domain
/// fields. A Comic, Book, or TV module decides what its primary and secondary
/// labels mean; the host only counts and renders the resulting values.
class LibraryStatsMetadataProjection {
  const LibraryStatsMetadataProjection({
    this.primaryGroup,
    this.secondaryGroup,
    this.hasCover = false,
    this.hasSynopsis = false,
    this.hasSecondaryMetadata = false,
    this.hasReleaseDate = false,
    this.hasItemNumber = false,
  });

  final String? primaryGroup;
  final String? secondaryGroup;
  final bool hasCover;
  final bool hasSynopsis;
  final bool hasSecondaryMetadata;
  final bool hasReleaseDate;
  final bool hasItemNumber;
}

abstract interface class LibraryStatsCapability {
  LibraryOwnedFinancialSummary buildOwnedFinancialSummary(ShelfEntry entry);

  /// Projects kind-owned metadata into structural facts for the generic stats
  /// renderer. No kind field names or domain objects cross this boundary.
  LibraryStatsMetadataProjection? buildMetadataProjection(ShelfEntry entry);

  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryKindModule type,
  );

  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryKindModule type,
  );
}

class DefaultLibraryStatsCapability implements LibraryStatsCapability {
  const DefaultLibraryStatsCapability();

  @override
  LibraryOwnedFinancialSummary buildOwnedFinancialSummary(ShelfEntry entry) {
    return LibraryOwnedFinancialSummary(
      pricePaidCents: entry.pricePaidCents,
      sellPriceCents: entry.sellPriceCents,
      currency: entry.currency,
    );
  }

  @override
  LibraryStatsMetadataProjection? buildMetadataProjection(ShelfEntry entry) {
    final summary = entry.catalogSummary;
    if (summary == null) return null;
    return LibraryStatsMetadataProjection(
      primaryGroup: summary.title,
      hasCover: summary.imageUrl?.trim().isNotEmpty == true,
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
  ) =>
      const [];
}
