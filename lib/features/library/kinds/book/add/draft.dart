import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/add/models/kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_read_event.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details_draft.dart';
import 'package:flutter/foundation.dart';

@immutable
final class BookAddDraft extends LibraryAddKindDraft {
  const BookAddDraft({
    this.grade,
    this.signedBy,
    this.dustJacketPresent = false,
    this.dustJacketCondition,
    this.retailPriceCents,
    this.marketValueCents,
    this.sellPriceCents,
    this.soldAt,
    this.indexNumber,
    this.quantity = 1,
    this.readEvents = const [],
  });

  final String? grade;
  final String? signedBy;
  final bool dustJacketPresent;
  final String? dustJacketCondition;
  final int? retailPriceCents;
  final int? marketValueCents;
  final int? sellPriceCents;
  final DateTime? soldAt;
  final int? indexNumber;
  final int quantity;
  final List<BookReadEvent> readEvents;

  BookAddDraft copyWith({
    Object? signedBy = _bookAddUnset,
    Object? retailPriceCents = _bookAddUnset,
    Object? marketValueCents = _bookAddUnset,
    Object? sellPriceCents = _bookAddUnset,
    Object? soldAt = _bookAddUnset,
    Object? indexNumber = _bookAddUnset,
    int? quantity,
    List<BookReadEvent>? readEvents,
    bool? dustJacketPresent,
    Object? dustJacketCondition = _bookAddUnset,
  }) =>
      BookAddDraft(
        grade: grade,
        indexNumber: identical(indexNumber, _bookAddUnset)
            ? this.indexNumber
            : indexNumber as int?,
        quantity: quantity ?? this.quantity,
        readEvents: readEvents ?? this.readEvents,
        marketValueCents: identical(marketValueCents, _bookAddUnset)
            ? this.marketValueCents
            : marketValueCents as int?,
        sellPriceCents: identical(sellPriceCents, _bookAddUnset)
            ? this.sellPriceCents
            : sellPriceCents as int?,
        soldAt: identical(soldAt, _bookAddUnset)
            ? this.soldAt
            : soldAt as DateTime?,
        retailPriceCents: identical(retailPriceCents, _bookAddUnset)
            ? this.retailPriceCents
            : retailPriceCents as int?,
        signedBy: identical(signedBy, _bookAddUnset)
            ? this.signedBy
            : signedBy as String?,
        dustJacketPresent: dustJacketPresent ?? this.dustJacketPresent,
        dustJacketCondition: identical(dustJacketCondition, _bookAddUnset)
            ? this.dustJacketCondition
            : dustJacketCondition as String?,
      );

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;

  @override
  JsonEncodable toEntryDetailsDraft() => BookEntryDetailsDraft(
        signedBy: signedBy,
        retailPriceCents: retailPriceCents,
        dustJacketPresent: dustJacketPresent,
        dustJacketCondition: dustJacketCondition,
        readEvents: readEvents,
      );
}

const Object _bookAddUnset = Object();
