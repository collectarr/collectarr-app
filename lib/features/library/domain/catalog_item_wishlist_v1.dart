import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:flutter/foundation.dart';

/// App-owned wishlist entry for one canonical Catalog Item.
@immutable
final class CatalogItemWishlistV1 {
  CatalogItemWishlistV1({
    required this.id,
    required this.catalogItem,
    required this.createdAt,
    required this.updatedAt,
    this.targetPriceCents,
    this.currency,
    this.notes,
    this.deletedAt,
  }) {
    if (id.trim().isEmpty) throw ArgumentError('Wishlist ID is required.');
    if ((targetPriceCents == null) != (currency == null)) {
      throw ArgumentError(
          'Wishlist price and currency must be provided together.');
    }
  }

  final String id;
  final CatalogItemRef catalogItem;
  final int? targetPriceCents;
  final String? currency;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Map<String, Object?> toJson() => {
        'id': id,
        'catalog_item': catalogItem.toJson(),
        'target_price_cents': targetPriceCents,
        'currency': currency,
        'notes': notes,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
      };

  factory CatalogItemWishlistV1.fromJson(Map<String, Object?> json) {
    final rawRef = json['catalog_item'];
    if (rawRef is! Map) {
      throw const FormatException('Wishlist v1 needs a Catalog Item ref.');
    }
    final id = json['id'];
    final created = json['created_at'];
    final updated = json['updated_at'];
    final targetPrice = json['target_price_cents'];
    final currency = json['currency'];
    final notes = json['notes'];
    if (id is! String || created is! String || updated is! String) {
      throw const FormatException('Wishlist v1 needs ID and timestamps.');
    }
    if (targetPrice != null && targetPrice is! int) {
      throw const FormatException('Wishlist target price must be cents.');
    }
    if (currency != null && currency is! String) {
      throw const FormatException('Wishlist currency must be text.');
    }
    if (notes != null && notes is! String) {
      throw const FormatException('Wishlist notes must be text.');
    }
    return CatalogItemWishlistV1(
      id: id,
      catalogItem: CatalogItemRef.fromJson(Map<String, Object?>.from(rawRef)),
      targetPriceCents: targetPrice as int?,
      currency: currency as String?,
      notes: notes as String?,
      createdAt: _parseUtc(created, 'created_at'),
      updatedAt: _parseUtc(updated, 'updated_at'),
    );
  }

  static DateTime _parseUtc(String value, String field) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) throw FormatException('Invalid wishlist $field.');
    return parsed.toUtc();
  }
}
