import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_read_event.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details.dart';

class BookEntryDetailsDraft implements JsonEncodable {
  const BookEntryDetailsDraft({
    this.signedBy = const [],
    this.dustJacketPresent = false,
    this.dustJacketCondition,
    this.retailPriceCents,
    this.readEvents = const [],
  });

  final List<String> signedBy;
  final bool dustJacketPresent;
  final String? dustJacketCondition;
  final int? retailPriceCents;
  final List<BookReadEvent> readEvents;

  BookEntryDetails toDetails() => BookEntryDetails(
        signedBy: signedBy,
        retailPriceCents: retailPriceCents,
        dustJacketPresent: dustJacketPresent,
        dustJacketCondition: dustJacketCondition,
        readEvents: readEvents,
      );

  @override
  Map<String, dynamic> toJson() => toDetails().toJson();
}
