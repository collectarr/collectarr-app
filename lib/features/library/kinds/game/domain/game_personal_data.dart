import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
import 'package:flutter/foundation.dart';

const Object _gamePersonalUnset = Object();

@immutable
final class GamePersonalData implements JsonEncodable {
  const GamePersonalData({
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
    this.details = const GameEntryDetails(),
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
  final GameEntryDetails details;

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

  factory GamePersonalData.fromJson(Map<String, dynamic> json) =>
      GamePersonalData(
        isDigital: json['is_digital'] as bool?,
        condition: json['condition'] as String?,
        grade: json['grade'] as String?,
        purchaseDate: _gamePersonalDate(json['purchase_date']),
        pricePaidCents: (json['price_paid_cents'] as num?)?.toInt(),
        currency: json['currency'] as String?,
        personalNotes: json['personal_notes'] as String?,
        indexNumber: (json['index_number'] as num?)?.toInt(),
        tags: json['tags'] as String?,
        soldAt: _gamePersonalDate(json['sold_at']),
        sellPriceCents: (json['sell_price_cents'] as num?)?.toInt(),
        soldTo: json['sold_to'] as String?,
        ownerUserId: json['owner_user_id'] as String?,
        ownerLabel: json['owner_label'] as String?,
        locationId: json['location_id'] as String?,
        purchaseStore: json['purchase_store'] as String?,
        collectionStatus: json['collection_status'] as String?,
        marketValueCents: (json['market_value_cents'] as num?)?.toInt(),
        details: GameEntryDetails.fromJson(json),
      );

  GamePersonalData copyWith({
    Object? isDigital = _gamePersonalUnset,
    Object? condition = _gamePersonalUnset,
    Object? grade = _gamePersonalUnset,
    Object? purchaseDate = _gamePersonalUnset,
    Object? pricePaidCents = _gamePersonalUnset,
    Object? currency = _gamePersonalUnset,
    Object? personalNotes = _gamePersonalUnset,
    Object? indexNumber = _gamePersonalUnset,
    Object? tags = _gamePersonalUnset,
    Object? soldAt = _gamePersonalUnset,
    Object? sellPriceCents = _gamePersonalUnset,
    Object? soldTo = _gamePersonalUnset,
    Object? ownerUserId = _gamePersonalUnset,
    Object? ownerLabel = _gamePersonalUnset,
    Object? locationId = _gamePersonalUnset,
    Object? purchaseStore = _gamePersonalUnset,
    Object? collectionStatus = _gamePersonalUnset,
    Object? marketValueCents = _gamePersonalUnset,
    GameEntryDetails? details,
  }) =>
      GamePersonalData(
        isDigital: identical(isDigital, _gamePersonalUnset)
            ? this.isDigital
            : isDigital as bool?,
        condition: identical(condition, _gamePersonalUnset)
            ? this.condition
            : condition as String?,
        grade: identical(grade, _gamePersonalUnset)
            ? this.grade
            : grade as String?,
        purchaseDate: identical(purchaseDate, _gamePersonalUnset)
            ? this.purchaseDate
            : purchaseDate as DateTime?,
        pricePaidCents: identical(pricePaidCents, _gamePersonalUnset)
            ? this.pricePaidCents
            : pricePaidCents as int?,
        currency: identical(currency, _gamePersonalUnset)
            ? this.currency
            : currency as String?,
        personalNotes: identical(personalNotes, _gamePersonalUnset)
            ? this.personalNotes
            : personalNotes as String?,
        indexNumber: identical(indexNumber, _gamePersonalUnset)
            ? this.indexNumber
            : indexNumber as int?,
        tags: identical(tags, _gamePersonalUnset) ? this.tags : tags as String?,
        soldAt: identical(soldAt, _gamePersonalUnset)
            ? this.soldAt
            : soldAt as DateTime?,
        sellPriceCents: identical(sellPriceCents, _gamePersonalUnset)
            ? this.sellPriceCents
            : sellPriceCents as int?,
        soldTo: identical(soldTo, _gamePersonalUnset)
            ? this.soldTo
            : soldTo as String?,
        ownerUserId: identical(ownerUserId, _gamePersonalUnset)
            ? this.ownerUserId
            : ownerUserId as String?,
        ownerLabel: identical(ownerLabel, _gamePersonalUnset)
            ? this.ownerLabel
            : ownerLabel as String?,
        locationId: identical(locationId, _gamePersonalUnset)
            ? this.locationId
            : locationId as String?,
        purchaseStore: identical(purchaseStore, _gamePersonalUnset)
            ? this.purchaseStore
            : purchaseStore as String?,
        collectionStatus: identical(collectionStatus, _gamePersonalUnset)
            ? this.collectionStatus
            : collectionStatus as String?,
        marketValueCents: identical(marketValueCents, _gamePersonalUnset)
            ? this.marketValueCents
            : marketValueCents as int?,
        details: details ?? this.details,
      );
}

DateTime? _gamePersonalDate(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
