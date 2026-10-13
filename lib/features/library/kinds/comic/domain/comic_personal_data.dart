import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_reading_state.dart';
import 'package:flutter/foundation.dart';

const Object _comicPersonalUnset = Object();

@immutable
final class ComicPersonalData implements JsonEncodable {
  const ComicPersonalData({
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
    this.details = const ComicEntryDetails(),
    this.reading = const ComicReadingState(),
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
  final ComicEntryDetails details;
  final ComicReadingState reading;

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
        'reading': reading.toJson(),
      };

  factory ComicPersonalData.fromJson(Map<String, dynamic> json) =>
      ComicPersonalData(
        isDigital: json['is_digital'] as bool?,
        condition: json['condition'] as String?,
        grade: json['grade'] as String?,
        purchaseDate: _comicPersonalDate(json['purchase_date']),
        pricePaidCents: (json['price_paid_cents'] as num?)?.toInt(),
        currency: json['currency'] as String?,
        personalNotes: json['personal_notes'] as String?,
        indexNumber: (json['index_number'] as num?)?.toInt(),
        tags: json['tags'] as String?,
        soldAt: _comicPersonalDate(json['sold_at']),
        sellPriceCents: (json['sell_price_cents'] as num?)?.toInt(),
        soldTo: json['sold_to'] as String?,
        ownerUserId: json['owner_user_id'] as String?,
        ownerLabel: json['owner_label'] as String?,
        locationId: json['location_id'] as String?,
        purchaseStore: json['purchase_store'] as String?,
        collectionStatus: json['collection_status'] as String?,
        marketValueCents: (json['market_value_cents'] as num?)?.toInt(),
        details: ComicEntryDetails.fromJson(json),
        reading: json['reading'] is Map
            ? ComicReadingState.fromJson(
                Map<String, dynamic>.from(json['reading'] as Map))
            : const ComicReadingState(),
      );

  ComicPersonalData copyWith({
    Object? isDigital = _comicPersonalUnset,
    Object? condition = _comicPersonalUnset,
    Object? grade = _comicPersonalUnset,
    Object? purchaseDate = _comicPersonalUnset,
    Object? pricePaidCents = _comicPersonalUnset,
    Object? currency = _comicPersonalUnset,
    Object? personalNotes = _comicPersonalUnset,
    Object? indexNumber = _comicPersonalUnset,
    Object? tags = _comicPersonalUnset,
    Object? soldAt = _comicPersonalUnset,
    Object? sellPriceCents = _comicPersonalUnset,
    Object? soldTo = _comicPersonalUnset,
    Object? ownerUserId = _comicPersonalUnset,
    Object? ownerLabel = _comicPersonalUnset,
    Object? locationId = _comicPersonalUnset,
    Object? purchaseStore = _comicPersonalUnset,
    Object? collectionStatus = _comicPersonalUnset,
    Object? marketValueCents = _comicPersonalUnset,
    ComicEntryDetails? details,
    ComicReadingState? reading,
  }) =>
      ComicPersonalData(
        isDigital: identical(isDigital, _comicPersonalUnset)
            ? this.isDigital
            : isDigital as bool?,
        condition: identical(condition, _comicPersonalUnset)
            ? this.condition
            : condition as String?,
        grade: identical(grade, _comicPersonalUnset)
            ? this.grade
            : grade as String?,
        purchaseDate: identical(purchaseDate, _comicPersonalUnset)
            ? this.purchaseDate
            : purchaseDate as DateTime?,
        pricePaidCents: identical(pricePaidCents, _comicPersonalUnset)
            ? this.pricePaidCents
            : pricePaidCents as int?,
        currency: identical(currency, _comicPersonalUnset)
            ? this.currency
            : currency as String?,
        personalNotes: identical(personalNotes, _comicPersonalUnset)
            ? this.personalNotes
            : personalNotes as String?,
        indexNumber: identical(indexNumber, _comicPersonalUnset)
            ? this.indexNumber
            : indexNumber as int?,
        tags:
            identical(tags, _comicPersonalUnset) ? this.tags : tags as String?,
        soldAt: identical(soldAt, _comicPersonalUnset)
            ? this.soldAt
            : soldAt as DateTime?,
        sellPriceCents: identical(sellPriceCents, _comicPersonalUnset)
            ? this.sellPriceCents
            : sellPriceCents as int?,
        soldTo: identical(soldTo, _comicPersonalUnset)
            ? this.soldTo
            : soldTo as String?,
        ownerUserId: identical(ownerUserId, _comicPersonalUnset)
            ? this.ownerUserId
            : ownerUserId as String?,
        ownerLabel: identical(ownerLabel, _comicPersonalUnset)
            ? this.ownerLabel
            : ownerLabel as String?,
        locationId: identical(locationId, _comicPersonalUnset)
            ? this.locationId
            : locationId as String?,
        purchaseStore: identical(purchaseStore, _comicPersonalUnset)
            ? this.purchaseStore
            : purchaseStore as String?,
        collectionStatus: identical(collectionStatus, _comicPersonalUnset)
            ? this.collectionStatus
            : collectionStatus as String?,
        marketValueCents: identical(marketValueCents, _comicPersonalUnset)
            ? this.marketValueCents
            : marketValueCents as int?,
        details: details ?? this.details,
        reading: reading ?? this.reading,
      );
}

DateTime? _comicPersonalDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
