import 'package:flutter/foundation.dart';

import 'catalog_entity_ref.dart';
import 'catalog_media_kind.dart';
import 'money.dart';

/// Stable cross-kind identity for an owned copy.
///
/// This is a reference only. It deliberately does not expose the owned
/// domain model or any kind-specific fields.
@immutable
final class OwnedItemRef {
  const OwnedItemRef({required this.kind, required this.id});

  final CatalogMediaKind kind;
  final OwnedItemId id;

  String get key => '${kind.apiValue}:${id.value}';

  /// Decode the stable storage key used by cross-kind infrastructure.
  ///
  /// This format is intentionally strict. A bare ID is not an owned-item
  /// reference because it does not identify the owning kind.
  factory OwnedItemRef.fromKey(String key) {
    final separator = key.indexOf(':');
    if (separator <= 0 || separator == key.length - 1) {
      throw const FormatException(
        'OwnedItemRef key must be <kind>:<id>',
      );
    }
    final kind = catalogMediaKindFromApiValue(key.substring(0, separator));
    final id = key.substring(separator + 1);
    if (kind.isUnknown || id.trim().isEmpty) {
      throw const FormatException(
        'OwnedItemRef key must contain a known kind and non-empty id',
      );
    }
    return OwnedItemRef(kind: kind, id: OwnedItemId(id));
  }

  Map<String, Object?> toJson() => {
        'kind': kind.apiValue,
        'id': id.value,
      };

  factory OwnedItemRef.fromJson(Map<String, Object?> json) {
    final rawKind = json['kind'];
    final rawId = json['id'];
    if (rawKind is! String || rawId is! String || rawId.trim().isEmpty) {
      throw const FormatException('OwnedItemRef requires kind and id');
    }
    return OwnedItemRef(
      kind: catalogMediaKindFromApiValue(rawKind),
      id: OwnedItemId(rawId),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnedItemRef && kind == other.kind && id == other.id;

  @override
  int get hashCode => Object.hash(kind, id);
}

/// Decodes the canonical cross-kind Owned reference at a transport boundary.
///
/// JSON transports may carry the structured object while schema-v1 text
/// columns carry [OwnedItemRef.key]. Neither form is a bare Owned id.
OwnedItemRef? ownedItemRefFromSerialized(Object? value) {
  if (value == null) return null;
  if (value is String) return OwnedItemRef.fromKey(value);
  if (value is Map) {
    return OwnedItemRef.fromJson(Map<String, Object?>.from(value));
  }
  throw FormatException('Invalid serialized OwnedItemRef: $value');
}

/// Small read projection used by mixed-kind hosts such as Loans and Shelf.
///
/// Keep this projection intentionally boring. If a UI needs condition, grade,
/// packaging, or another semantic field, it must dispatch to the owning kind.
@immutable
final class OwnedItemSummary {
  const OwnedItemSummary({
    required this.ref,
    required this.title,
    this.catalogRef,
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
    this.locationLabel,
    this.notes,
    this.hasNotes = false,
  });

  final OwnedItemRef ref;
  final String title;
  final CatalogEntityRef? catalogRef;
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
  final String? locationLabel;
  final String? notes;
  final bool hasNotes;

  bool get isDeleted => deletedAt != null;

  OwnedItemSummary copyWith({
    OwnedItemRef? ref,
    String? title,
    Object? catalogRef = _summaryUnset,
    Object? subtitle = _summaryUnset,
    Object? imageUrl = _summaryUnset,
    Object? ownerLabel = _summaryUnset,
    Object? locationLabel = _summaryUnset,
    Object? notes = _summaryUnset,
    bool? hasNotes,
  }) {
    return OwnedItemSummary(
      ref: ref ?? this.ref,
      title: title ?? this.title,
      catalogRef: catalogRef == _summaryUnset
          ? this.catalogRef
          : catalogRef as CatalogEntityRef?,
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
      locationLabel: locationLabel == _summaryUnset
          ? this.locationLabel
          : locationLabel as String?,
      notes: notes == _summaryUnset ? this.notes : notes as String?,
      hasNotes: hasNotes ?? this.hasNotes,
    );
  }
}

const Object _summaryUnset = Object();
