import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';

class BookOwnedDetailsDraft implements JsonEncodable {
  const BookOwnedDetailsDraft({
    this.signedBy,
    this.dustJacketPresent = false,
    this.dustJacketCondition,
  });

  final String? signedBy;
  final bool dustJacketPresent;
  final String? dustJacketCondition;

  BookOwnedDetails toDetails() => BookOwnedDetails(
        signedBy: signedBy,
        dustJacketPresent: dustJacketPresent,
        dustJacketCondition: dustJacketCondition,
      );

  @override
  Map<String, dynamic> toJson() => toDetails().toJson();
}
