import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';

class ComicOwnedDetailsCodec implements OwnedDetailsCodec<ComicOwnedDetails> {
  const ComicOwnedDetailsCodec();

  @override
  ComicOwnedDetails fromJson(Map<String, dynamic> json) =>
      ComicOwnedDetails.fromJson(json);

  @override
  Map<String, dynamic> toJson(ComicOwnedDetails details) => details.toJson();

  @override
  Map<String, dynamic> toSyncPayload(ComicOwnedDetails details) =>
      details.toJson();

  @override
  ComicOwnedDetails defaultDetails() => const ComicOwnedDetails();

  @override
  OwnedDetailsDraft defaultDraft() => const ComicOwnedDetailsDraft();

  @override
  OwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) {
    return ComicOwnedDetailsDraft(
      rawOrSlabbed: personal.rawOrSlabbed,
      gradingCompany: personal.gradingCompany,
      graderNotes: personal.graderNotes,
      signedBy: personal.signedBy,
      labelType: personal.labelType,
      customLabel: personal.customLabel,
      pageQuality: personal.pageQuality,
      certificationNumber: personal.certificationNumber,
      keyComic: personal.keyComic ?? false,
      keyReason: personal.keyReason,
      keyCategory: personal.keyCategory,
      keySeverity: personal.keySeverity,
      coverPriceCents: personal.coverPriceCents,
      lastBagBoardDate: personal.lastBagBoardDate,
    );
  }
}
