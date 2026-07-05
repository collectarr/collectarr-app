import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

class LibraryValueHistoryEntry {
  const LibraryValueHistoryEntry({
    required this.label,
    required this.valueCents,
    required this.currency,
    this.timestamp,
  });

  final String label;
  final int? valueCents;
  final String? currency;
  final DateTime? timestamp;
}

class LibraryValueSnapshot {
  const LibraryValueSnapshot({
    this.purchasePriceCents,
    this.soldPriceCents,
    this.manualEstimatedValueCents,
    this.providerValueCents,
    this.insuranceValueCents,
    this.currency,
    this.providerName,
    this.providerUpdatedAt,
  });

  factory LibraryValueSnapshot.fromEntry(
    LibraryWorkspaceEntry entry, {
    OwnedItem? ownedItem,
    String? providerName,
    DateTime? providerUpdatedAt,
  }) {
    final currency = ownedItem?.currency?.trim().isNotEmpty == true
        ? ownedItem!.currency!.trim()
        : entry.marketValueCurrency?.trim().isNotEmpty == true
            ? entry.marketValueCurrency!.trim()
            : null;
    final providerValue = entry.marketValueCents;
    final manualValue = ownedItem?.marketValueCents;
    final currentValue = providerValue ?? manualValue;
    return LibraryValueSnapshot(
      purchasePriceCents: ownedItem?.pricePaidCents,
      soldPriceCents: ownedItem?.sellPriceCents,
      manualEstimatedValueCents: manualValue,
      providerValueCents: providerValue,
      insuranceValueCents: currentValue ?? manualValue ?? ownedItem?.pricePaidCents,
      currency: currency,
      providerName: providerName,
      providerUpdatedAt: providerUpdatedAt,
    );
  }

  final int? purchasePriceCents;
  final int? soldPriceCents;
  final int? manualEstimatedValueCents;
  final int? providerValueCents;
  final int? insuranceValueCents;
  final String? currency;
  final String? providerName;
  final DateTime? providerUpdatedAt;

  int? get currentValueCents => providerValueCents ?? manualEstimatedValueCents;

  int? get profitLossCents {
    final paid = purchasePriceCents;
    final sold = soldPriceCents;
    if (paid == null || sold == null) {
      return null;
    }
    return sold - paid;
  }

  bool get hasAnyValue =>
      purchasePriceCents != null ||
      soldPriceCents != null ||
      manualEstimatedValueCents != null ||
      providerValueCents != null ||
      insuranceValueCents != null;

  List<LibraryValueHistoryEntry> get history {
    final rows = <LibraryValueHistoryEntry>[];
    if (purchasePriceCents != null) {
      rows.add(
        LibraryValueHistoryEntry(
          label: 'Purchase',
          valueCents: purchasePriceCents,
          currency: currency,
        ),
      );
    }
    if (providerValueCents != null) {
      rows.add(
        LibraryValueHistoryEntry(
          label: providerName?.trim().isNotEmpty == true
              ? providerName!.trim()
              : 'Provider snapshot',
          valueCents: providerValueCents,
          currency: currency,
          timestamp: providerUpdatedAt,
        ),
      );
    }
    if (manualEstimatedValueCents != null) {
      rows.add(
        LibraryValueHistoryEntry(
          label: 'Manual estimate',
          valueCents: manualEstimatedValueCents,
          currency: currency,
        ),
      );
    }
    if (insuranceValueCents != null) {
      rows.add(
        LibraryValueHistoryEntry(
          label: 'Insurance',
          valueCents: insuranceValueCents,
          currency: currency,
        ),
      );
    }
    if (soldPriceCents != null) {
      rows.add(
        LibraryValueHistoryEntry(
          label: 'Sold',
          valueCents: soldPriceCents,
          currency: currency,
        ),
      );
    }
    return rows;
  }

  String formatValue(int? cents) => formatMoney(cents, currency);
}
