import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';
import 'package:flutter/foundation.dart';

const Object _musicPersonalUnset = Object();

@immutable
final class MusicPersonalData implements JsonEncodable {
  const MusicPersonalData({
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
    this.details = const MusicEntryDetails(),
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
  final MusicEntryDetails details;

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

  factory MusicPersonalData.fromJson(Map<String, dynamic> json) =>
      MusicPersonalData(
        isDigital: json['is_digital'] as bool?,
        condition: json['condition'] as String?,
        grade: json['grade'] as String?,
        purchaseDate: _musicPersonalDate(json['purchase_date']),
        pricePaidCents: (json['price_paid_cents'] as num?)?.toInt(),
        currency: json['currency'] as String?,
        personalNotes: json['personal_notes'] as String?,
        indexNumber: (json['index_number'] as num?)?.toInt(),
        tags: json['tags'] as String?,
        soldAt: _musicPersonalDate(json['sold_at']),
        sellPriceCents: (json['sell_price_cents'] as num?)?.toInt(),
        soldTo: json['sold_to'] as String?,
        ownerUserId: json['owner_user_id'] as String?,
        ownerLabel: json['owner_label'] as String?,
        locationId: json['location_id'] as String?,
        purchaseStore: json['purchase_store'] as String?,
        collectionStatus: json['collection_status'] as String?,
        marketValueCents: (json['market_value_cents'] as num?)?.toInt(),
        details: MusicEntryDetails.fromJson(json),
      );

  MusicPersonalData copyWith({
    Object? isDigital = _musicPersonalUnset,
    Object? condition = _musicPersonalUnset,
    Object? grade = _musicPersonalUnset,
    Object? purchaseDate = _musicPersonalUnset,
    Object? pricePaidCents = _musicPersonalUnset,
    Object? currency = _musicPersonalUnset,
    Object? personalNotes = _musicPersonalUnset,
    Object? indexNumber = _musicPersonalUnset,
    Object? tags = _musicPersonalUnset,
    Object? soldAt = _musicPersonalUnset,
    Object? sellPriceCents = _musicPersonalUnset,
    Object? soldTo = _musicPersonalUnset,
    Object? ownerUserId = _musicPersonalUnset,
    Object? ownerLabel = _musicPersonalUnset,
    Object? locationId = _musicPersonalUnset,
    Object? purchaseStore = _musicPersonalUnset,
    Object? collectionStatus = _musicPersonalUnset,
    Object? marketValueCents = _musicPersonalUnset,
    MusicEntryDetails? details,
  }) =>
      MusicPersonalData(
        isDigital: identical(isDigital, _musicPersonalUnset)
            ? this.isDigital
            : isDigital as bool?,
        condition: identical(condition, _musicPersonalUnset)
            ? this.condition
            : condition as String?,
        grade: identical(grade, _musicPersonalUnset)
            ? this.grade
            : grade as String?,
        purchaseDate: identical(purchaseDate, _musicPersonalUnset)
            ? this.purchaseDate
            : purchaseDate as DateTime?,
        pricePaidCents: identical(pricePaidCents, _musicPersonalUnset)
            ? this.pricePaidCents
            : pricePaidCents as int?,
        currency: identical(currency, _musicPersonalUnset)
            ? this.currency
            : currency as String?,
        personalNotes: identical(personalNotes, _musicPersonalUnset)
            ? this.personalNotes
            : personalNotes as String?,
        indexNumber: identical(indexNumber, _musicPersonalUnset)
            ? this.indexNumber
            : indexNumber as int?,
        tags:
            identical(tags, _musicPersonalUnset) ? this.tags : tags as String?,
        soldAt: identical(soldAt, _musicPersonalUnset)
            ? this.soldAt
            : soldAt as DateTime?,
        sellPriceCents: identical(sellPriceCents, _musicPersonalUnset)
            ? this.sellPriceCents
            : sellPriceCents as int?,
        soldTo: identical(soldTo, _musicPersonalUnset)
            ? this.soldTo
            : soldTo as String?,
        ownerUserId: identical(ownerUserId, _musicPersonalUnset)
            ? this.ownerUserId
            : ownerUserId as String?,
        ownerLabel: identical(ownerLabel, _musicPersonalUnset)
            ? this.ownerLabel
            : ownerLabel as String?,
        locationId: identical(locationId, _musicPersonalUnset)
            ? this.locationId
            : locationId as String?,
        purchaseStore: identical(purchaseStore, _musicPersonalUnset)
            ? this.purchaseStore
            : purchaseStore as String?,
        collectionStatus: identical(collectionStatus, _musicPersonalUnset)
            ? this.collectionStatus
            : collectionStatus as String?,
        marketValueCents: identical(marketValueCents, _musicPersonalUnset)
            ? this.marketValueCents
            : marketValueCents as int?,
        details: details ?? this.details,
      );
}

DateTime? _musicPersonalDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
