import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details_draft.dart';

final class BookEntryDetailsCodec {
  const BookEntryDetailsCodec();

  BookEntryDetails fromJson(Map<String, dynamic> json) =>
      BookEntryDetails.fromJson(json);

  Map<String, dynamic> toJson(BookEntryDetails details) => details.toJson();

  Map<String, dynamic> toSyncPayload(BookEntryDetails details) =>
      details.toJson();

  BookEntryDetails defaultDetails() => const BookEntryDetails();

  BookEntryDetailsDraft draftFromDetails(BookEntryDetails details) =>
      BookEntryDetailsDraft(
        signedBy: details.signedBy,
        dustJacketPresent: details.dustJacketPresent,
        dustJacketCondition: details.dustJacketCondition,
      );

  BookEntryDetailsDraft defaultDraft() => const BookEntryDetailsDraft();
}
