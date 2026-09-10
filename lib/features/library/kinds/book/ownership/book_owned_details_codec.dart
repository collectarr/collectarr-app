import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_draft.dart';

class BookOwnedDetailsCodec
    extends OwnedDetailsPersistenceCodec<BookOwnedDetails> {
  const BookOwnedDetailsCodec();

  @override
  BookOwnedDetails fromJson(Map<String, dynamic> json) =>
      BookOwnedDetails.fromJson(json);

  @override
  Map<String, dynamic> toJson(BookOwnedDetails details) => details.toJson();

  @override
  Map<String, dynamic> toSyncPayload(BookOwnedDetails details) =>
      details.toJson();

  @override
  BookOwnedDetails defaultDetails() => const BookOwnedDetails();

  BookOwnedDetailsDraft draftFromDetails(BookOwnedDetails details) =>
      BookOwnedDetailsDraft(
        signedBy: details.signedBy,
        dustJacketPresent: details.dustJacketPresent,
        dustJacketCondition: details.dustJacketCondition,
      );

  BookOwnedDetailsDraft defaultDraft() => const BookOwnedDetailsDraft();
}
