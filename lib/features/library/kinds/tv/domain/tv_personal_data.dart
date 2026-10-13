import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/tv/entries/tv_entry_details.dart';
import 'package:flutter/foundation.dart';

const Object _tvPersonalUnset = Object();

@immutable
final class TvPersonalData implements JsonEncodable {
  const TvPersonalData({
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
    this.details = const TvEntryDetails(),
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
  final TvEntryDetails details;

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

  factory TvPersonalData.fromJson(Map<String, dynamic> json) => TvPersonalData(
        isDigital: json['is_digital'] as bool?,
        condition: json['condition'] as String?,
        grade: json['grade'] as String?,
        purchaseDate: _tvPersonalDate(json['purchase_date']),
        pricePaidCents: (json['price_paid_cents'] as num?)?.toInt(),
        currency: json['currency'] as String?,
        personalNotes: json['personal_notes'] as String?,
        indexNumber: (json['index_number'] as num?)?.toInt(),
        tags: json['tags'] as String?,
        soldAt: _tvPersonalDate(json['sold_at']),
        sellPriceCents: (json['sell_price_cents'] as num?)?.toInt(),
        soldTo: json['sold_to'] as String?,
        ownerUserId: json['owner_user_id'] as String?,
        ownerLabel: json['owner_label'] as String?,
        locationId: json['location_id'] as String?,
        purchaseStore: json['purchase_store'] as String?,
        collectionStatus: json['collection_status'] as String?,
        marketValueCents: (json['market_value_cents'] as num?)?.toInt(),
        details: TvEntryDetails.fromJson(json),
      );

  TvPersonalData copyWith({
    Object? isDigital = _tvPersonalUnset,
    Object? condition = _tvPersonalUnset,
    Object? grade = _tvPersonalUnset,
    Object? purchaseDate = _tvPersonalUnset,
    Object? pricePaidCents = _tvPersonalUnset,
    Object? currency = _tvPersonalUnset,
    Object? personalNotes = _tvPersonalUnset,
    Object? indexNumber = _tvPersonalUnset,
    Object? tags = _tvPersonalUnset,
    Object? soldAt = _tvPersonalUnset,
    Object? sellPriceCents = _tvPersonalUnset,
    Object? soldTo = _tvPersonalUnset,
    Object? ownerUserId = _tvPersonalUnset,
    Object? ownerLabel = _tvPersonalUnset,
    Object? locationId = _tvPersonalUnset,
    Object? purchaseStore = _tvPersonalUnset,
    Object? collectionStatus = _tvPersonalUnset,
    Object? marketValueCents = _tvPersonalUnset,
    TvEntryDetails? details,
  }) =>
      TvPersonalData(
        isDigital: identical(isDigital, _tvPersonalUnset)
            ? this.isDigital
            : isDigital as bool?,
        condition: identical(condition, _tvPersonalUnset)
            ? this.condition
            : condition as String?,
        grade:
            identical(grade, _tvPersonalUnset) ? this.grade : grade as String?,
        purchaseDate: identical(purchaseDate, _tvPersonalUnset)
            ? this.purchaseDate
            : purchaseDate as DateTime?,
        pricePaidCents: identical(pricePaidCents, _tvPersonalUnset)
            ? this.pricePaidCents
            : pricePaidCents as int?,
        currency: identical(currency, _tvPersonalUnset)
            ? this.currency
            : currency as String?,
        personalNotes: identical(personalNotes, _tvPersonalUnset)
            ? this.personalNotes
            : personalNotes as String?,
        indexNumber: identical(indexNumber, _tvPersonalUnset)
            ? this.indexNumber
            : indexNumber as int?,
        tags: identical(tags, _tvPersonalUnset) ? this.tags : tags as String?,
        soldAt: identical(soldAt, _tvPersonalUnset)
            ? this.soldAt
            : soldAt as DateTime?,
        sellPriceCents: identical(sellPriceCents, _tvPersonalUnset)
            ? this.sellPriceCents
            : sellPriceCents as int?,
        soldTo: identical(soldTo, _tvPersonalUnset)
            ? this.soldTo
            : soldTo as String?,
        ownerUserId: identical(ownerUserId, _tvPersonalUnset)
            ? this.ownerUserId
            : ownerUserId as String?,
        ownerLabel: identical(ownerLabel, _tvPersonalUnset)
            ? this.ownerLabel
            : ownerLabel as String?,
        locationId: identical(locationId, _tvPersonalUnset)
            ? this.locationId
            : locationId as String?,
        purchaseStore: identical(purchaseStore, _tvPersonalUnset)
            ? this.purchaseStore
            : purchaseStore as String?,
        collectionStatus: identical(collectionStatus, _tvPersonalUnset)
            ? this.collectionStatus
            : collectionStatus as String?,
        marketValueCents: identical(marketValueCents, _tvPersonalUnset)
            ? this.marketValueCents
            : marketValueCents as int?,
        details: details ?? this.details,
      );
}

DateTime? _tvPersonalDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
