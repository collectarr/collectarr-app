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
  final String? subtitle;
  final String? imageUrl;
  final String? ownerLabel;
  final String? locationLabel;
  final String? notes;
  final bool hasNotes;

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
