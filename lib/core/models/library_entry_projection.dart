import 'package:flutter/foundation.dart';

import 'catalog_item_ref.dart';
import 'library_entry_ref.dart';

export 'library_entry_ref.dart';

/// Structural summary for one independently editable local library entry.
///
/// The entry owns both its kind catalog metadata and personal data. Its local
/// identity is [ref]; [sourceCatalogRef] is recorded separately by the owning
/// kind when metadata came from Core.
@immutable
final class LibraryEntrySummary {
  const LibraryEntrySummary({
    required this.ref,
    this.sourceCatalogRef,
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

  final LibraryEntryRef ref;
  final CatalogItemRef? sourceCatalogRef;
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

  LibraryEntrySummary copyWith({
    LibraryEntryRef? ref,
    Object? sourceCatalogRef = _summaryUnset,
    Object? ownerLabel = _summaryUnset,
    Object? locationLabel = _summaryUnset,
    Object? notes = _summaryUnset,
    bool? hasNotes,
  }) {
    return LibraryEntrySummary(
      ref: ref ?? this.ref,
      sourceCatalogRef: sourceCatalogRef == _summaryUnset
          ? this.sourceCatalogRef
          : sourceCatalogRef as CatalogItemRef?,
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
