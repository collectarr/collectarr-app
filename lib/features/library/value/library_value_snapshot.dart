import 'package:collectarr_app/features/library/generic/projection_item.dart';

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
    this.insuranceValueCents,
    this.currency,
  });

  factory LibraryValueSnapshot.fromItem(
    LibraryProjectionView item, {
    int? purchasePriceCents,
    int? soldPriceCents,
    int? manualEstimatedValueCents,
    String? ownedCurrency,
  }) {
    final currency = ownedCurrency?.trim().isNotEmpty == true
        ? ownedCurrency!.trim()
        : item.source.currency?.trim().isNotEmpty == true
            ? item.source.currency!.trim()
            : null;
    final manualValue = manualEstimatedValueCents;
    return LibraryValueSnapshot(
      purchasePriceCents: purchasePriceCents,
      soldPriceCents: soldPriceCents,
      manualEstimatedValueCents: manualValue,
      insuranceValueCents: manualValue ?? purchasePriceCents,
      currency: currency,
    );
  }

  final int? purchasePriceCents;
  final int? soldPriceCents;
  final int? manualEstimatedValueCents;
  final int? insuranceValueCents;
  final String? currency;

  int? get displayPrimaryValueCents =>
      manualEstimatedValueCents ?? purchasePriceCents ?? soldPriceCents;

  int? get totalOwnedCostBasisCents => purchasePriceCents;

  int? get unrealizedGainLossCents {
    final current = displayPrimaryValueCents;
    final paid = purchasePriceCents;
    if (current == null || paid == null) {
      return null;
    }
    return current - paid;
  }

  double? get unrealizedGainLossPercentage {
    final delta = unrealizedGainLossCents;
    final paid = purchasePriceCents;
    if (delta == null || paid == null || paid == 0) {
      return null;
    }
    return (delta / paid) * 100;
  }

  List<LibraryValueHistoryEntry> get historyEntries => [
        if (purchasePriceCents != null)
          LibraryValueHistoryEntry(
            label: 'Purchase price',
            valueCents: purchasePriceCents,
            currency: currency,
          ),
        if (manualEstimatedValueCents != null)
          LibraryValueHistoryEntry(
            label: 'Manual estimate',
            valueCents: manualEstimatedValueCents,
            currency: currency,
          ),
        if (soldPriceCents != null)
          LibraryValueHistoryEntry(
            label: 'Sold price',
            valueCents: soldPriceCents,
            currency: currency,
          ),
      ];
}
