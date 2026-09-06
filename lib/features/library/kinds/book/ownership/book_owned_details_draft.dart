import 'package:collectarr_app/features/library/config/owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';

class BookOwnedDetailsDraft extends OwnedDetailsDraft {
  const BookOwnedDetailsDraft({
    this.signedBy,
    this.dustJacketPresent = false,
    this.dustJacketCondition,
  });

  final String? signedBy;
  final bool dustJacketPresent;
  final String? dustJacketCondition;

  @override
  BookOwnedDetails toDetails() => BookOwnedDetails(
        signedBy: signedBy,
        dustJacketPresent: dustJacketPresent,
        dustJacketCondition: dustJacketCondition,
      );
}
