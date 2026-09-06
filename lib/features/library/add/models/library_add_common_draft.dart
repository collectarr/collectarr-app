import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:flutter/foundation.dart';

@immutable
class LibraryAddCommonDraft {
  const LibraryAddCommonDraft({
    this.condition,
    this.grade,
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
  });

  final String? condition;
  final String? grade;
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

  LibraryAddCommonDraft copyWith({
    String? condition,
    String? grade,
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
  }) {
    return LibraryAddCommonDraft(
      condition: condition ?? this.condition,
      grade: grade ?? this.grade,
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
    );
  }

  OwnedItemCommonDraft toOwnedItemCommonDraft() {
    return OwnedItemCommonDraft(
      condition: condition,
      grade: grade,
      purchaseDate: purchaseDate,
      pricePaidCents: pricePaidCents,
      currency: currency,
      personalNotes: personalNotes,
      quantity: quantity,
      tags: tags,
      locationId: locationId,
      purchaseStore: purchaseStore,
      collectionStatus: collectionStatus,
      isDigital: isDigital,
    );
  }
}
