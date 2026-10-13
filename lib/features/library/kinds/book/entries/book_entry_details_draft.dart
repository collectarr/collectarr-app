import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details.dart';

class BookEntryDetailsDraft implements JsonEncodable {
  const BookEntryDetailsDraft({
    this.signedBy,
    this.dustJacketPresent = false,
    this.dustJacketCondition,
  });

  final String? signedBy;
  final bool dustJacketPresent;
  final String? dustJacketCondition;

  BookEntryDetails toDetails() => BookEntryDetails(
        signedBy: signedBy,
        dustJacketPresent: dustJacketPresent,
        dustJacketCondition: dustJacketCondition,
      );

  @override
  Map<String, dynamic> toJson() => toDetails().toJson();
}
