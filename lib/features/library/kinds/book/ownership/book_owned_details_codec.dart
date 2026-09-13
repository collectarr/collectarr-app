import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_draft.dart';

final class BookOwnedDetailsCodec {
  const BookOwnedDetailsCodec();

  BookOwnedDetails fromJson(Map<String, dynamic> json) =>
      BookOwnedDetails.fromJson(json);

  Map<String, dynamic> toJson(BookOwnedDetails details) => details.toJson();

  Map<String, dynamic> toSyncPayload(BookOwnedDetails details) =>
      details.toJson();

  BookOwnedDetails defaultDetails() => const BookOwnedDetails();

  BookOwnedDetailsDraft draftFromDetails(BookOwnedDetails details) =>
      BookOwnedDetailsDraft(
        signedBy: details.signedBy,
        dustJacketPresent: details.dustJacketPresent,
        dustJacketCondition: details.dustJacketCondition,
      );

  BookOwnedDetailsDraft defaultDraft() => const BookOwnedDetailsDraft();
}
