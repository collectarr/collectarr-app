import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:flutter/material.dart';

class GameStatsCapability implements LibraryStatsCapability {
  const GameStatsCapability();

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
