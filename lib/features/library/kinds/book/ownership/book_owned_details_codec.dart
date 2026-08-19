import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';

class BookOwnedDetailsCodec implements OwnedDetailsCodec<BookOwnedDetails> {
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
  OwnedDetailsDraft defaultDraft() => const BookOwnedDetailsDraft();

  @override
  OwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) =>
      const BookOwnedDetailsDraft();
}
