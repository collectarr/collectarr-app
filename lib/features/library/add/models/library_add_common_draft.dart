import 'package:flutter/foundation.dart';

@immutable
class LibraryAddCommonDraft {
  const LibraryAddCommonDraft({
    this.condition,
    this.purchaseDate,
    this.pricePaidCents,
    this.currency,
    this.personalNotes,
    this.quantity = 1,
    this.tags,
    this.locationId,
    this.purchaseStore,
    this.collectionStatus,
    this.isDigital,
    this.collectionValue,
  });

  final String? condition;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final int quantity;
  final String? tags;
  final String? locationId;
  final String? purchaseStore;
  final String? collectionStatus;
  final bool? isDigital;
  final String? collectionValue;

  LibraryAddCommonDraft copyWith({
    String? condition,
    DateTime? purchaseDate,
    int? pricePaidCents,
    String? currency,
    String? personalNotes,
    int? quantity,
    String? tags,
    String? locationId,
    String? purchaseStore,
    String? collectionStatus,
    bool? isDigital,
    String? collectionValue,
  }) {
    return LibraryAddCommonDraft(
      condition: condition ?? this.condition,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      pricePaidCents: pricePaidCents ?? this.pricePaidCents,
      currency: currency ?? this.currency,
      personalNotes: personalNotes ?? this.personalNotes,
      quantity: quantity ?? this.quantity,
      tags: tags ?? this.tags,
      locationId: locationId ?? this.locationId,
      purchaseStore: purchaseStore ?? this.purchaseStore,
      collectionStatus: collectionStatus ?? this.collectionStatus,
      isDigital: isDigital ?? this.isDigital,
      collectionValue: collectionValue ?? this.collectionValue,
    );
  }
}
