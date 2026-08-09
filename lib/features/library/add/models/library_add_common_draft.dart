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
    this.rating,
    this.readStatus,
    this.startedAt,
    this.finishedAt,
    this.tags,
    this.locationId,
    this.purchaseStore,
    this.collectionStatus,
    this.isDigital,
    this.editionId,
    this.variantId,
    this.bundleReleaseId,
  });

  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final int quantity;
  final int? rating;
  final String? readStatus;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? tags;
  final String? locationId;
  final String? purchaseStore;
  final String? collectionStatus;
  final bool? isDigital;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;

  LibraryAddCommonDraft copyWith({
    String? condition,
    String? grade,
    DateTime? purchaseDate,
    int? pricePaidCents,
    String? currency,
    String? personalNotes,
    int? quantity,
    int? rating,
    String? readStatus,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? tags,
    String? locationId,
    String? purchaseStore,
    String? collectionStatus,
    bool? isDigital,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
  }) {
    return LibraryAddCommonDraft(
      condition: condition ?? this.condition,
      grade: grade ?? this.grade,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      pricePaidCents: pricePaidCents ?? this.pricePaidCents,
      currency: currency ?? this.currency,
      personalNotes: personalNotes ?? this.personalNotes,
      quantity: quantity ?? this.quantity,
      rating: rating ?? this.rating,
      readStatus: readStatus ?? this.readStatus,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      tags: tags ?? this.tags,
      locationId: locationId ?? this.locationId,
      purchaseStore: purchaseStore ?? this.purchaseStore,
      collectionStatus: collectionStatus ?? this.collectionStatus,
      isDigital: isDigital ?? this.isDigital,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
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
      rating: rating,
      readStatus: readStatus,
      startedAt: startedAt,
      finishedAt: finishedAt,
      tags: tags,
      locationId: locationId,
      purchaseStore: purchaseStore,
      collectionStatus: collectionStatus,
      isDigital: isDigital,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    );
  }
}
