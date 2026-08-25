import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';

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

  factory LibraryValueSnapshot.fromItem(
    LibraryProjectionRuntime item, {
    OwnedItem? ownedItem,
    String? providerName,
    DateTime? providerUpdatedAt,
  }) {
    final dto = item.dto;
    final currency = ownedItem?.currency?.trim().isNotEmpty == true
        ? ownedItem!.currency!.trim()
        : dto.currency?.trim().isNotEmpty == true
            ? dto.currency!.trim()
            : null;
    final metadata = item.source.catalogItem?.kindMetadata;
    final providerValue = metadata is ComicCatalogMetadata
        ? metadata.publishing?.coverPriceCents
      : item.source.catalogItem?.toCatalogItem().publishing?.coverPriceCents;
    final manualValue = ownedItem?.marketValueCents;
    final currentValue = providerValue ?? manualValue;
    return LibraryValueSnapshot(
      purchasePriceCents: ownedItem?.pricePaidCents,
      soldPriceCents: ownedItem?.sellPriceCents,
      manualEstimatedValueCents: manualValue,
      providerValueCents: providerValue,
      insuranceValueCents:
          currentValue ?? manualValue ?? ownedItem?.pricePaidCents,
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

  int? get displayPrimaryValueCents =>
      providerValueCents ??
      manualEstimatedValueCents ??
      purchasePriceCents ??
      soldPriceCents;

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
        if (providerValueCents != null)
          LibraryValueHistoryEntry(
            label: providerName ?? 'Provider value',
            valueCents: providerValueCents,
            currency: currency,
            timestamp: providerUpdatedAt,
          ),
        if (soldPriceCents != null)
          LibraryValueHistoryEntry(
            label: 'Sold price',
            valueCents: soldPriceCents,
            currency: currency,
          ),
      ];
}
