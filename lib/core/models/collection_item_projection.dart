import 'package:flutter/foundation.dart';

import 'catalog_entity_ref.dart';
import 'collection_item_ref.dart';

export 'collection_item_ref.dart';

/// Personal projection for one physical item in the user's collection.
///
/// Each row has its own [ref] and its own personal values. Multiple rows may
/// point at the same canonical [catalogRef]. Catalog metadata such as title,
/// synopsis, identifiers, and kind-specific details stays in the owning kind.
/// Mixed-kind hosts can read these personal values, but must dispatch
/// kind-specific fields through the owning kind.
@immutable
final class CollectionItemSummary {
  const CollectionItemSummary({
    required this.ref,
    this.catalogRef,
    this.isDigital,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.purchaseDate,
    this.purchaseStore,
    this.pricePaidCents,
    this.currency,
    this.soldAt,
    this.soldTo,
    this.sellPriceCents,
    this.marketValueCents,
    this.ownerLabel,
    this.locationId,
    this.locationLabel,
    this.notes,
    this.hasNotes = false,
  });

  final CollectionItemRef ref;
  final CatalogEntityRef? catalogRef;
  final bool? isDigital;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final DateTime? purchaseDate;
  final String? purchaseStore;
  final int? pricePaidCents;
  final String? currency;
  final DateTime? soldAt;
  final String? soldTo;
  final int? sellPriceCents;
  final int? marketValueCents;
  final String? ownerLabel;
  final String? locationId;
  final String? locationLabel;
  final String? notes;
  final bool hasNotes;

  bool get isDeleted => deletedAt != null;

  CollectionItemSummary copyWith({
    CollectionItemRef? ref,
    Object? catalogRef = _summaryUnset,
    Object? ownerLabel = _summaryUnset,
    Object? locationLabel = _summaryUnset,
    Object? notes = _summaryUnset,
    bool? hasNotes,
  }) {
    return CollectionItemSummary(
      ref: ref ?? this.ref,
      catalogRef: catalogRef == _summaryUnset
          ? this.catalogRef
          : catalogRef as CatalogEntityRef?,
      isDigital: isDigital,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      purchaseDate: purchaseDate,
      purchaseStore: purchaseStore,
      pricePaidCents: pricePaidCents,
      currency: currency,
      soldAt: soldAt,
      soldTo: soldTo,
      sellPriceCents: sellPriceCents,
      marketValueCents: marketValueCents,
      ownerLabel:
          ownerLabel == _summaryUnset ? this.ownerLabel : ownerLabel as String?,
      locationId: locationId,
      locationLabel: locationLabel == _summaryUnset
          ? this.locationLabel
          : locationLabel as String?,
      notes: notes == _summaryUnset ? this.notes : notes as String?,
      hasNotes: hasNotes ?? this.hasNotes,
    );
  }
}

const Object _summaryUnset = Object();
