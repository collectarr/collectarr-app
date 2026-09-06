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

abstract interface class LibraryStatsCapability {
  LibraryOwnedFinancialSummary buildOwnedFinancialSummary(ShelfEntry entry);

  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryKindRuntime type,
  );

  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryKindRuntime type,
  );
}

class DefaultLibraryStatsCapability implements LibraryStatsCapability {
  const DefaultLibraryStatsCapability();

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
  ) =>
      const [];

  @override
  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryKindRuntime type,
  ) =>
      const [];
}
