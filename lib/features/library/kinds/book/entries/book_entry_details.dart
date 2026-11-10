import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

const Object _bookDetailsUnset = Object();

@immutable
class BookEntryDetails implements JsonEncodable {
  const BookEntryDetails({
    this.signedBy,
    this.dustJacketPresent = false,
    this.dustJacketCondition,
    this.retailPriceCents,
  });

  final String? signedBy;
  final bool dustJacketPresent;
  final String? dustJacketCondition;
  final int? retailPriceCents;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        if (retailPriceCents != null) 'retail_price_cents': retailPriceCents,
        if (signedBy != null) 'signed_by': signedBy,
        if (dustJacketPresent) 'dust_jacket_present': true,
        if (dustJacketCondition != null)
          'dust_jacket_condition': dustJacketCondition,
      };

  factory BookEntryDetails.fromJson(Map<String, dynamic> json) =>
      BookEntryDetails(
        signedBy: json['signed_by'] as String?,
        retailPriceCents: (json['retail_price_cents'] as num?)?.toInt(),
        dustJacketPresent: json['dust_jacket_present'] as bool? ?? false,
        dustJacketCondition: json['dust_jacket_condition'] as String?,
      );

  BookEntryDetails copyWith({
    Object? signedBy = _bookDetailsUnset,
    bool? dustJacketPresent,
    Object? dustJacketCondition = _bookDetailsUnset,
    Object? retailPriceCents = _bookDetailsUnset,
  }) {
    return BookEntryDetails(
      signedBy: identical(signedBy, _bookDetailsUnset)
          ? this.signedBy
          : signedBy as String?,
      retailPriceCents: identical(retailPriceCents, _bookDetailsUnset)
          ? this.retailPriceCents
          : retailPriceCents as int?,
      dustJacketPresent: dustJacketPresent ?? this.dustJacketPresent,
      dustJacketCondition: identical(dustJacketCondition, _bookDetailsUnset)
          ? this.dustJacketCondition
          : dustJacketCondition as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookEntryDetails &&
          runtimeType == other.runtimeType &&
          signedBy == other.signedBy &&
          retailPriceCents == other.retailPriceCents &&
          dustJacketPresent == other.dustJacketPresent &&
          dustJacketCondition == other.dustJacketCondition;

  @override
  int get hashCode => Object.hash(
        signedBy,
        retailPriceCents,
        dustJacketPresent,
        dustJacketCondition,
      );
}
