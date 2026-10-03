import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details.dart';
import 'package:flutter/foundation.dart';

const Object _boardgamePersonalUnset = Object();

@immutable
final class BoardGamePersonalData implements JsonEncodable {
  const BoardGamePersonalData({
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
    this.details = const BoardgameEntryDetails(),
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
  final BoardgameEntryDetails details;

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

  factory BoardGamePersonalData.fromJson(Map<String, dynamic> json) =>
      BoardGamePersonalData(
        isDigital: json['is_digital'] as bool?,
        condition: json['condition'] as String?,
        grade: json['grade'] as String?,
        purchaseDate: _boardgamePersonalDate(json['purchase_date']),
        pricePaidCents: (json['price_paid_cents'] as num?)?.toInt(),
        currency: json['currency'] as String?,
        personalNotes: json['personal_notes'] as String?,
        indexNumber: (json['index_number'] as num?)?.toInt(),
        tags: json['tags'] as String?,
        soldAt: _boardgamePersonalDate(json['sold_at']),
        sellPriceCents: (json['sell_price_cents'] as num?)?.toInt(),
        soldTo: json['sold_to'] as String?,
        ownerUserId: json['owner_user_id'] as String?,
        ownerLabel: json['owner_label'] as String?,
        locationId: json['location_id'] as String?,
        purchaseStore: json['purchase_store'] as String?,
        collectionStatus: json['collection_status'] as String?,
        marketValueCents: (json['market_value_cents'] as num?)?.toInt(),
        details: BoardgameEntryDetails.fromJson(json),
      );

  BoardGamePersonalData copyWith({
    Object? isDigital = _boardgamePersonalUnset,
    Object? condition = _boardgamePersonalUnset,
    Object? grade = _boardgamePersonalUnset,
    Object? purchaseDate = _boardgamePersonalUnset,
    Object? pricePaidCents = _boardgamePersonalUnset,
    Object? currency = _boardgamePersonalUnset,
    Object? personalNotes = _boardgamePersonalUnset,
    Object? indexNumber = _boardgamePersonalUnset,
    Object? tags = _boardgamePersonalUnset,
    Object? soldAt = _boardgamePersonalUnset,
    Object? sellPriceCents = _boardgamePersonalUnset,
    Object? soldTo = _boardgamePersonalUnset,
    Object? ownerUserId = _boardgamePersonalUnset,
    Object? ownerLabel = _boardgamePersonalUnset,
    Object? locationId = _boardgamePersonalUnset,
    Object? purchaseStore = _boardgamePersonalUnset,
    Object? collectionStatus = _boardgamePersonalUnset,
    Object? marketValueCents = _boardgamePersonalUnset,
    BoardgameEntryDetails? details,
  }) =>
      BoardGamePersonalData(
        isDigital: identical(isDigital, _boardgamePersonalUnset)
            ? this.isDigital
            : isDigital as bool?,
        condition: identical(condition, _boardgamePersonalUnset)
            ? this.condition
            : condition as String?,
        grade: identical(grade, _boardgamePersonalUnset)
            ? this.grade
            : grade as String?,
        purchaseDate: identical(purchaseDate, _boardgamePersonalUnset)
            ? this.purchaseDate
            : purchaseDate as DateTime?,
        pricePaidCents: identical(pricePaidCents, _boardgamePersonalUnset)
            ? this.pricePaidCents
            : pricePaidCents as int?,
        currency: identical(currency, _boardgamePersonalUnset)
            ? this.currency
            : currency as String?,
        personalNotes: identical(personalNotes, _boardgamePersonalUnset)
            ? this.personalNotes
            : personalNotes as String?,
        indexNumber: identical(indexNumber, _boardgamePersonalUnset)
            ? this.indexNumber
            : indexNumber as int?,
        tags: identical(tags, _boardgamePersonalUnset)
            ? this.tags
            : tags as String?,
        soldAt: identical(soldAt, _boardgamePersonalUnset)
            ? this.soldAt
            : soldAt as DateTime?,
        sellPriceCents: identical(sellPriceCents, _boardgamePersonalUnset)
            ? this.sellPriceCents
            : sellPriceCents as int?,
        soldTo: identical(soldTo, _boardgamePersonalUnset)
            ? this.soldTo
            : soldTo as String?,
        ownerUserId: identical(ownerUserId, _boardgamePersonalUnset)
            ? this.ownerUserId
            : ownerUserId as String?,
        ownerLabel: identical(ownerLabel, _boardgamePersonalUnset)
            ? this.ownerLabel
            : ownerLabel as String?,
        locationId: identical(locationId, _boardgamePersonalUnset)
            ? this.locationId
            : locationId as String?,
        purchaseStore: identical(purchaseStore, _boardgamePersonalUnset)
            ? this.purchaseStore
            : purchaseStore as String?,
        collectionStatus: identical(collectionStatus, _boardgamePersonalUnset)
            ? this.collectionStatus
            : collectionStatus as String?,
        marketValueCents: identical(marketValueCents, _boardgamePersonalUnset)
            ? this.marketValueCents
            : marketValueCents as int?,
        details: details ?? this.details,
      );
}

DateTime? _boardgamePersonalDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
