import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_draft.dart';

class BookOwnedDetailsCodec
    implements OwnedDetailsCodec<BookOwnedDetails, BookOwnedDetailsDraft> {
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

  @override
  BookOwnedDetailsDraft draftFromDetails(BookOwnedDetails details) =>
      BookOwnedDetailsDraft(
        signedBy: details.signedBy,
        dustJacketPresent: details.dustJacketPresent,
        dustJacketCondition: details.dustJacketCondition,
      );

  @override
  BookOwnedDetailsDraft defaultDraft() => const BookOwnedDetailsDraft();

  @override
  BookOwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) =>
      BookOwnedDetailsDraft(
        signedBy: personal.signedBy,
        dustJacketPresent: personal.dustJacketPresent ?? false,
        dustJacketCondition: personal.dustJacketCondition,
      );
}
