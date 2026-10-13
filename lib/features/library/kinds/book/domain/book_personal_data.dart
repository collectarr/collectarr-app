import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details.dart';
import 'package:flutter/foundation.dart';

const Object _bookPersonalUnset = Object();

@immutable
final class BookPersonalData implements JsonEncodable {
  const BookPersonalData({
    this.isDigital,
    this.condition,
    this.grade,
    this.purchaseDate,
    this.pricePaidCents,
    this.currency,
    this.personalNotes,
    this.indexNumber,
    this.tags,
    this.soldAt,
    this.sellPriceCents,
    this.soldTo,
    this.ownerUserId,
    this.ownerLabel,
    this.locationId,
    this.purchaseStore,
    this.collectionStatus,
    this.marketValueCents,
    this.details = const BookEntryDetails(),
  });

  final bool? isDigital;
  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final int? indexNumber;
  final String? tags;
  final DateTime? soldAt;
  final int? sellPriceCents;
  final String? soldTo;
  final String? ownerUserId;
  final String? ownerLabel;
  final String? locationId;
  final String? purchaseStore;
  final String? collectionStatus;
  final int? marketValueCents;
  final BookEntryDetails details;

  @override
  Map<String, dynamic> toJson() => {
        'is_digital': isDigital,
        'condition': condition,
        'grade': grade,
        'purchase_date': purchaseDate?.toUtc().toIso8601String(),
        'price_paid_cents': pricePaidCents,
        'currency': currency,
        'personal_notes': personalNotes,
        'index_number': indexNumber,
        'tags': tags,
        'sold_at': soldAt?.toUtc().toIso8601String(),
        'sell_price_cents': sellPriceCents,
        'sold_to': soldTo,
        'owner_user_id': ownerUserId,
        'owner_label': ownerLabel,
        'location_id': locationId,
        'purchase_store': purchaseStore,
        'collection_status': collectionStatus,
        'market_value_cents': marketValueCents,
        ...details.toJson(),
      };

  factory BookPersonalData.fromJson(Map<String, dynamic> json) =>
      BookPersonalData(
        isDigital: json['is_digital'] as bool?,
        condition: json['condition'] as String?,
        grade: json['grade'] as String?,
        purchaseDate: _bookPersonalDate(json['purchase_date']),
        pricePaidCents: (json['price_paid_cents'] as num?)?.toInt(),
        currency: json['currency'] as String?,
        personalNotes: json['personal_notes'] as String?,
        indexNumber: (json['index_number'] as num?)?.toInt(),
        tags: json['tags'] as String?,
        soldAt: _bookPersonalDate(json['sold_at']),
        sellPriceCents: (json['sell_price_cents'] as num?)?.toInt(),
        soldTo: json['sold_to'] as String?,
        ownerUserId: json['owner_user_id'] as String?,
        ownerLabel: json['owner_label'] as String?,
        locationId: json['location_id'] as String?,
        purchaseStore: json['purchase_store'] as String?,
        collectionStatus: json['collection_status'] as String?,
        marketValueCents: (json['market_value_cents'] as num?)?.toInt(),
        details: BookEntryDetails.fromJson(json),
      );

  BookPersonalData copyWith({
    Object? isDigital = _bookPersonalUnset,
    Object? condition = _bookPersonalUnset,
    Object? grade = _bookPersonalUnset,
    Object? purchaseDate = _bookPersonalUnset,
    Object? pricePaidCents = _bookPersonalUnset,
    Object? currency = _bookPersonalUnset,
    Object? personalNotes = _bookPersonalUnset,
    Object? indexNumber = _bookPersonalUnset,
    Object? tags = _bookPersonalUnset,
    Object? soldAt = _bookPersonalUnset,
    Object? sellPriceCents = _bookPersonalUnset,
    Object? soldTo = _bookPersonalUnset,
    Object? ownerUserId = _bookPersonalUnset,
    Object? ownerLabel = _bookPersonalUnset,
    Object? locationId = _bookPersonalUnset,
    Object? purchaseStore = _bookPersonalUnset,
    Object? collectionStatus = _bookPersonalUnset,
    Object? marketValueCents = _bookPersonalUnset,
    BookEntryDetails? details,
  }) =>
      BookPersonalData(
        isDigital: identical(isDigital, _bookPersonalUnset)
            ? this.isDigital
            : isDigital as bool?,
        condition: identical(condition, _bookPersonalUnset)
            ? this.condition
            : condition as String?,
        grade: identical(grade, _bookPersonalUnset)
            ? this.grade
            : grade as String?,
        purchaseDate: identical(purchaseDate, _bookPersonalUnset)
            ? this.purchaseDate
            : purchaseDate as DateTime?,
        pricePaidCents: identical(pricePaidCents, _bookPersonalUnset)
            ? this.pricePaidCents
            : pricePaidCents as int?,
        currency: identical(currency, _bookPersonalUnset)
            ? this.currency
            : currency as String?,
        personalNotes: identical(personalNotes, _bookPersonalUnset)
            ? this.personalNotes
            : personalNotes as String?,
        indexNumber: identical(indexNumber, _bookPersonalUnset)
            ? this.indexNumber
            : indexNumber as int?,
        tags: identical(tags, _bookPersonalUnset) ? this.tags : tags as String?,
        soldAt: identical(soldAt, _bookPersonalUnset)
            ? this.soldAt
            : soldAt as DateTime?,
        sellPriceCents: identical(sellPriceCents, _bookPersonalUnset)
            ? this.sellPriceCents
            : sellPriceCents as int?,
        soldTo: identical(soldTo, _bookPersonalUnset)
            ? this.soldTo
            : soldTo as String?,
        ownerUserId: identical(ownerUserId, _bookPersonalUnset)
            ? this.ownerUserId
            : ownerUserId as String?,
        ownerLabel: identical(ownerLabel, _bookPersonalUnset)
            ? this.ownerLabel
            : ownerLabel as String?,
        locationId: identical(locationId, _bookPersonalUnset)
            ? this.locationId
            : locationId as String?,
        purchaseStore: identical(purchaseStore, _bookPersonalUnset)
            ? this.purchaseStore
            : purchaseStore as String?,
        collectionStatus: identical(collectionStatus, _bookPersonalUnset)
            ? this.collectionStatus
            : collectionStatus as String?,
        marketValueCents: identical(marketValueCents, _bookPersonalUnset)
            ? this.marketValueCents
            : marketValueCents as int?,
        details: details ?? this.details,
      );
}

DateTime? _bookPersonalDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
