import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_read_event.dart';

const Object _bookDetailsUnset = Object();

@immutable
class BookEntryDetails implements JsonEncodable {
  const BookEntryDetails({
    this.signedBy = const [],
    this.dustJacketPresent = false,
    this.dustJacketCondition,
    this.retailPriceCents,
    this.readEvents = const [],
  });

  /// The people who signed this copy, in the order entered.
  final List<String> signedBy;
  final bool dustJacketPresent;
  final String? dustJacketCondition;
  final int? retailPriceCents;
  final List<BookReadEvent> readEvents;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        if (retailPriceCents != null) 'retail_price_cents': retailPriceCents,
        if (signedBy.isNotEmpty) 'signed_by': signedBy,
        if (dustJacketPresent) 'dust_jacket_present': true,
        if (dustJacketCondition != null)
          'dust_jacket_condition': dustJacketCondition,
        if (readEvents.isNotEmpty)
          'read_events': [for (final event in readEvents) event.toJson()],
      };

  factory BookEntryDetails.fromJson(Map<String, dynamic> json) =>
      BookEntryDetails(
        signedBy: [
          for (final name in json['signed_by'] as List? ?? const [])
            name as String,
        ],
        retailPriceCents: (json['retail_price_cents'] as num?)?.toInt(),
        dustJacketPresent: json['dust_jacket_present'] as bool? ?? false,
        dustJacketCondition: json['dust_jacket_condition'] as String?,
        readEvents: BookReadEvent.listFromJson(json['read_events']),
      );

  BookEntryDetails copyWith({
    List<String>? signedBy,
    bool? dustJacketPresent,
    Object? dustJacketCondition = _bookDetailsUnset,
    Object? retailPriceCents = _bookDetailsUnset,
    List<BookReadEvent>? readEvents,
  }) {
    return BookEntryDetails(
      signedBy: signedBy ?? this.signedBy,
      retailPriceCents: identical(retailPriceCents, _bookDetailsUnset)
          ? this.retailPriceCents
          : retailPriceCents as int?,
      dustJacketPresent: dustJacketPresent ?? this.dustJacketPresent,
      dustJacketCondition: identical(dustJacketCondition, _bookDetailsUnset)
          ? this.dustJacketCondition
          : dustJacketCondition as String?,
      readEvents: readEvents ?? this.readEvents,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookEntryDetails &&
          runtimeType == other.runtimeType &&
          listEquals(signedBy, other.signedBy) &&
          retailPriceCents == other.retailPriceCents &&
          dustJacketPresent == other.dustJacketPresent &&
          dustJacketCondition == other.dustJacketCondition &&
          listEquals(readEvents, other.readEvents);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(signedBy),
        retailPriceCents,
        dustJacketPresent,
        dustJacketCondition,
        Object.hashAll(readEvents),
      );
}
