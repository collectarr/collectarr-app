import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/anime/entries/anime_entry_details.dart';
import 'package:flutter/foundation.dart';

const Object _animePersonalUnset = Object();

@immutable
final class AnimePersonalData implements JsonEncodable {
  const AnimePersonalData({
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
    this.details = const AnimeEntryDetails(),
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
  final AnimeEntryDetails details;

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

  factory AnimePersonalData.fromJson(Map<String, dynamic> json) =>
      AnimePersonalData(
        isDigital: json['is_digital'] as bool?,
        condition: json['condition'] as String?,
        grade: json['grade'] as String?,
        purchaseDate: _animePersonalDate(json['purchase_date']),
        pricePaidCents: (json['price_paid_cents'] as num?)?.toInt(),
        currency: json['currency'] as String?,
        personalNotes: json['personal_notes'] as String?,
        indexNumber: (json['index_number'] as num?)?.toInt(),
        tags: json['tags'] as String?,
        soldAt: _animePersonalDate(json['sold_at']),
        sellPriceCents: (json['sell_price_cents'] as num?)?.toInt(),
        soldTo: json['sold_to'] as String?,
        ownerUserId: json['owner_user_id'] as String?,
        ownerLabel: json['owner_label'] as String?,
        locationId: json['location_id'] as String?,
        purchaseStore: json['purchase_store'] as String?,
        collectionStatus: json['collection_status'] as String?,
        marketValueCents: (json['market_value_cents'] as num?)?.toInt(),
        details: AnimeEntryDetails.fromJson(json),
      );

  AnimePersonalData copyWith({
    Object? isDigital = _animePersonalUnset,
    Object? condition = _animePersonalUnset,
    Object? grade = _animePersonalUnset,
    Object? purchaseDate = _animePersonalUnset,
    Object? pricePaidCents = _animePersonalUnset,
    Object? currency = _animePersonalUnset,
    Object? personalNotes = _animePersonalUnset,
    Object? indexNumber = _animePersonalUnset,
    Object? tags = _animePersonalUnset,
    Object? soldAt = _animePersonalUnset,
    Object? sellPriceCents = _animePersonalUnset,
    Object? soldTo = _animePersonalUnset,
    Object? ownerUserId = _animePersonalUnset,
    Object? ownerLabel = _animePersonalUnset,
    Object? locationId = _animePersonalUnset,
    Object? purchaseStore = _animePersonalUnset,
    Object? collectionStatus = _animePersonalUnset,
    Object? marketValueCents = _animePersonalUnset,
    AnimeEntryDetails? details,
  }) =>
      AnimePersonalData(
        isDigital: identical(isDigital, _animePersonalUnset)
            ? this.isDigital
            : isDigital as bool?,
        condition: identical(condition, _animePersonalUnset)
            ? this.condition
            : condition as String?,
        grade: identical(grade, _animePersonalUnset)
            ? this.grade
            : grade as String?,
        purchaseDate: identical(purchaseDate, _animePersonalUnset)
            ? this.purchaseDate
            : purchaseDate as DateTime?,
        pricePaidCents: identical(pricePaidCents, _animePersonalUnset)
            ? this.pricePaidCents
            : pricePaidCents as int?,
        currency: identical(currency, _animePersonalUnset)
            ? this.currency
            : currency as String?,
        personalNotes: identical(personalNotes, _animePersonalUnset)
            ? this.personalNotes
            : personalNotes as String?,
        indexNumber: identical(indexNumber, _animePersonalUnset)
            ? this.indexNumber
            : indexNumber as int?,
        tags:
            identical(tags, _animePersonalUnset) ? this.tags : tags as String?,
        soldAt: identical(soldAt, _animePersonalUnset)
            ? this.soldAt
            : soldAt as DateTime?,
        sellPriceCents: identical(sellPriceCents, _animePersonalUnset)
            ? this.sellPriceCents
            : sellPriceCents as int?,
        soldTo: identical(soldTo, _animePersonalUnset)
            ? this.soldTo
            : soldTo as String?,
        ownerUserId: identical(ownerUserId, _animePersonalUnset)
            ? this.ownerUserId
            : ownerUserId as String?,
        ownerLabel: identical(ownerLabel, _animePersonalUnset)
            ? this.ownerLabel
            : ownerLabel as String?,
        locationId: identical(locationId, _animePersonalUnset)
            ? this.locationId
            : locationId as String?,
        purchaseStore: identical(purchaseStore, _animePersonalUnset)
            ? this.purchaseStore
            : purchaseStore as String?,
        collectionStatus: identical(collectionStatus, _animePersonalUnset)
            ? this.collectionStatus
            : collectionStatus as String?,
        marketValueCents: identical(marketValueCents, _animePersonalUnset)
            ? this.marketValueCents
            : marketValueCents as int?,
        details: details ?? this.details,
      );
}

DateTime? _animePersonalDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
