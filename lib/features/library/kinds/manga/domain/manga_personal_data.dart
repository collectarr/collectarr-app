import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/manga/entries/manga_entry_details.dart';
import 'package:flutter/foundation.dart';

const Object _mangaPersonalUnset = Object();

@immutable
final class MangaPersonalData implements JsonEncodable {
  const MangaPersonalData({
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
    this.details = const MangaEntryDetails(),
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
  final MangaEntryDetails details;

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

  factory MangaPersonalData.fromJson(Map<String, dynamic> json) =>
      MangaPersonalData(
        isDigital: json['is_digital'] as bool?,
        condition: json['condition'] as String?,
        grade: json['grade'] as String?,
        purchaseDate: _mangaPersonalDate(json['purchase_date']),
        pricePaidCents: (json['price_paid_cents'] as num?)?.toInt(),
        currency: json['currency'] as String?,
        personalNotes: json['personal_notes'] as String?,
        indexNumber: (json['index_number'] as num?)?.toInt(),
        tags: json['tags'] as String?,
        soldAt: _mangaPersonalDate(json['sold_at']),
        sellPriceCents: (json['sell_price_cents'] as num?)?.toInt(),
        soldTo: json['sold_to'] as String?,
        ownerUserId: json['owner_user_id'] as String?,
        ownerLabel: json['owner_label'] as String?,
        locationId: json['location_id'] as String?,
        purchaseStore: json['purchase_store'] as String?,
        collectionStatus: json['collection_status'] as String?,
        marketValueCents: (json['market_value_cents'] as num?)?.toInt(),
        details: MangaEntryDetails.fromJson(json),
      );

  MangaPersonalData copyWith({
    Object? isDigital = _mangaPersonalUnset,
    Object? condition = _mangaPersonalUnset,
    Object? grade = _mangaPersonalUnset,
    Object? purchaseDate = _mangaPersonalUnset,
    Object? pricePaidCents = _mangaPersonalUnset,
    Object? currency = _mangaPersonalUnset,
    Object? personalNotes = _mangaPersonalUnset,
    Object? indexNumber = _mangaPersonalUnset,
    Object? tags = _mangaPersonalUnset,
    Object? soldAt = _mangaPersonalUnset,
    Object? sellPriceCents = _mangaPersonalUnset,
    Object? soldTo = _mangaPersonalUnset,
    Object? ownerUserId = _mangaPersonalUnset,
    Object? ownerLabel = _mangaPersonalUnset,
    Object? locationId = _mangaPersonalUnset,
    Object? purchaseStore = _mangaPersonalUnset,
    Object? collectionStatus = _mangaPersonalUnset,
    Object? marketValueCents = _mangaPersonalUnset,
    MangaEntryDetails? details,
  }) =>
      MangaPersonalData(
        isDigital: identical(isDigital, _mangaPersonalUnset)
            ? this.isDigital
            : isDigital as bool?,
        condition: identical(condition, _mangaPersonalUnset)
            ? this.condition
            : condition as String?,
        grade: identical(grade, _mangaPersonalUnset)
            ? this.grade
            : grade as String?,
        purchaseDate: identical(purchaseDate, _mangaPersonalUnset)
            ? this.purchaseDate
            : purchaseDate as DateTime?,
        pricePaidCents: identical(pricePaidCents, _mangaPersonalUnset)
            ? this.pricePaidCents
            : pricePaidCents as int?,
        currency: identical(currency, _mangaPersonalUnset)
            ? this.currency
            : currency as String?,
        personalNotes: identical(personalNotes, _mangaPersonalUnset)
            ? this.personalNotes
            : personalNotes as String?,
        indexNumber: identical(indexNumber, _mangaPersonalUnset)
            ? this.indexNumber
            : indexNumber as int?,
        tags:
            identical(tags, _mangaPersonalUnset) ? this.tags : tags as String?,
        soldAt: identical(soldAt, _mangaPersonalUnset)
            ? this.soldAt
            : soldAt as DateTime?,
        sellPriceCents: identical(sellPriceCents, _mangaPersonalUnset)
            ? this.sellPriceCents
            : sellPriceCents as int?,
        soldTo: identical(soldTo, _mangaPersonalUnset)
            ? this.soldTo
            : soldTo as String?,
        ownerUserId: identical(ownerUserId, _mangaPersonalUnset)
            ? this.ownerUserId
            : ownerUserId as String?,
        ownerLabel: identical(ownerLabel, _mangaPersonalUnset)
            ? this.ownerLabel
            : ownerLabel as String?,
        locationId: identical(locationId, _mangaPersonalUnset)
            ? this.locationId
            : locationId as String?,
        purchaseStore: identical(purchaseStore, _mangaPersonalUnset)
            ? this.purchaseStore
            : purchaseStore as String?,
        collectionStatus: identical(collectionStatus, _mangaPersonalUnset)
            ? this.collectionStatus
            : collectionStatus as String?,
        marketValueCents: identical(marketValueCents, _mangaPersonalUnset)
            ? this.marketValueCents
            : marketValueCents as int?,
        details: details ?? this.details,
      );
}

DateTime? _mangaPersonalDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
