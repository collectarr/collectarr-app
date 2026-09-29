import 'package:flutter/foundation.dart';

import 'catalog_entity_ref.dart';
import 'owned_copy_ref.dart';

export 'owned_copy_ref.dart';

/// Small read projection used by mixed-kind hosts such as Loans and Shelf.
///
/// Keep this projection intentionally boring. If a UI needs condition, grade,
/// packaging, value, or another semantic field, it must dispatch to the
/// owning kind.
@immutable
final class OwnedCopySummary {
  const OwnedCopySummary({
    required this.ref,
    required this.title,
    this.catalogRef,
    this.targetRef,
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
    this.quantity = 1,
    this.subtitle,
    this.imageUrl,
    this.ownerLabel,
    this.locationId,
    this.locationLabel,
    this.notes,
    this.hasNotes = false,
  });

  final OwnedCopyRef ref;
  final String title;
  final CatalogEntityRef? catalogRef;
  final CatalogEntityRef? targetRef;
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
  final int quantity;
  final String? subtitle;
  final String? imageUrl;
  final String? ownerLabel;
  final String? locationId;
  final String? locationLabel;
  final String? notes;
  final bool hasNotes;

  bool get isDeleted => deletedAt != null;

  OwnedCopySummary copyWith({
    OwnedCopyRef? ref,
    String? title,
    Object? catalogRef = _summaryUnset,
    Object? targetRef = _summaryUnset,
    Object? subtitle = _summaryUnset,
    Object? imageUrl = _summaryUnset,
    Object? ownerLabel = _summaryUnset,
    Object? locationLabel = _summaryUnset,
    Object? notes = _summaryUnset,
    bool? hasNotes,
  }) {
    return OwnedCopySummary(
      ref: ref ?? this.ref,
      title: title ?? this.title,
      catalogRef: catalogRef == _summaryUnset
          ? this.catalogRef
          : catalogRef as CatalogEntityRef?,
      targetRef: targetRef == _summaryUnset
          ? this.targetRef
          : targetRef as CatalogEntityRef?,
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
      quantity: quantity,
      subtitle: subtitle == _summaryUnset ? this.subtitle : subtitle as String?,
      imageUrl: imageUrl == _summaryUnset ? this.imageUrl : imageUrl as String?,
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
