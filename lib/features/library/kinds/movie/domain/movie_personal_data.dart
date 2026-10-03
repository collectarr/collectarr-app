import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details.dart';
import 'package:flutter/foundation.dart';

const Object _moviePersonalUnset = Object();

@immutable
final class MoviePersonalData implements JsonEncodable {
  const MoviePersonalData({
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
    this.details = const MovieEntryDetails(),
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
  final MovieEntryDetails details;

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

  factory MoviePersonalData.fromJson(Map<String, dynamic> json) =>
      MoviePersonalData(
        isDigital: json['is_digital'] as bool?,
        condition: json['condition'] as String?,
        grade: json['grade'] as String?,
        purchaseDate: _moviePersonalDate(json['purchase_date']),
        pricePaidCents: (json['price_paid_cents'] as num?)?.toInt(),
        currency: json['currency'] as String?,
        personalNotes: json['personal_notes'] as String?,
        indexNumber: (json['index_number'] as num?)?.toInt(),
        tags: json['tags'] as String?,
        soldAt: _moviePersonalDate(json['sold_at']),
        sellPriceCents: (json['sell_price_cents'] as num?)?.toInt(),
        soldTo: json['sold_to'] as String?,
        ownerUserId: json['owner_user_id'] as String?,
        ownerLabel: json['owner_label'] as String?,
        locationId: json['location_id'] as String?,
        purchaseStore: json['purchase_store'] as String?,
        collectionStatus: json['collection_status'] as String?,
        marketValueCents: (json['market_value_cents'] as num?)?.toInt(),
        details: MovieEntryDetails.fromJson(json),
      );

  MoviePersonalData copyWith({
    Object? isDigital = _moviePersonalUnset,
    Object? condition = _moviePersonalUnset,
    Object? grade = _moviePersonalUnset,
    Object? purchaseDate = _moviePersonalUnset,
    Object? pricePaidCents = _moviePersonalUnset,
    Object? currency = _moviePersonalUnset,
    Object? personalNotes = _moviePersonalUnset,
    Object? indexNumber = _moviePersonalUnset,
    Object? tags = _moviePersonalUnset,
    Object? soldAt = _moviePersonalUnset,
    Object? sellPriceCents = _moviePersonalUnset,
    Object? soldTo = _moviePersonalUnset,
    Object? ownerUserId = _moviePersonalUnset,
    Object? ownerLabel = _moviePersonalUnset,
    Object? locationId = _moviePersonalUnset,
    Object? purchaseStore = _moviePersonalUnset,
    Object? collectionStatus = _moviePersonalUnset,
    Object? marketValueCents = _moviePersonalUnset,
    MovieEntryDetails? details,
  }) =>
      MoviePersonalData(
        isDigital: identical(isDigital, _moviePersonalUnset)
            ? this.isDigital
            : isDigital as bool?,
        condition: identical(condition, _moviePersonalUnset)
            ? this.condition
            : condition as String?,
        grade: identical(grade, _moviePersonalUnset)
            ? this.grade
            : grade as String?,
        purchaseDate: identical(purchaseDate, _moviePersonalUnset)
            ? this.purchaseDate
            : purchaseDate as DateTime?,
        pricePaidCents: identical(pricePaidCents, _moviePersonalUnset)
            ? this.pricePaidCents
            : pricePaidCents as int?,
        currency: identical(currency, _moviePersonalUnset)
            ? this.currency
            : currency as String?,
        personalNotes: identical(personalNotes, _moviePersonalUnset)
            ? this.personalNotes
            : personalNotes as String?,
        indexNumber: identical(indexNumber, _moviePersonalUnset)
            ? this.indexNumber
            : indexNumber as int?,
        tags:
            identical(tags, _moviePersonalUnset) ? this.tags : tags as String?,
        soldAt: identical(soldAt, _moviePersonalUnset)
            ? this.soldAt
            : soldAt as DateTime?,
        sellPriceCents: identical(sellPriceCents, _moviePersonalUnset)
            ? this.sellPriceCents
            : sellPriceCents as int?,
        soldTo: identical(soldTo, _moviePersonalUnset)
            ? this.soldTo
            : soldTo as String?,
        ownerUserId: identical(ownerUserId, _moviePersonalUnset)
            ? this.ownerUserId
            : ownerUserId as String?,
        ownerLabel: identical(ownerLabel, _moviePersonalUnset)
            ? this.ownerLabel
            : ownerLabel as String?,
        locationId: identical(locationId, _moviePersonalUnset)
            ? this.locationId
            : locationId as String?,
        purchaseStore: identical(purchaseStore, _moviePersonalUnset)
            ? this.purchaseStore
            : purchaseStore as String?,
        collectionStatus: identical(collectionStatus, _moviePersonalUnset)
            ? this.collectionStatus
            : collectionStatus as String?,
        marketValueCents: identical(marketValueCents, _moviePersonalUnset)
            ? this.marketValueCents
            : marketValueCents as int?,
        details: details ?? this.details,
      );
}

DateTime? _moviePersonalDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
