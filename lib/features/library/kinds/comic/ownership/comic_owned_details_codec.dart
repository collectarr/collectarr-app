import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details_draft.dart';

class ComicOwnedDetailsCodec
    implements OwnedDetailsCodec<ComicOwnedDetails, ComicOwnedDetailsDraft> {
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
  ComicOwnedDetailsDraft draftFromDetails(ComicOwnedDetails details) =>
      ComicOwnedDetailsDraft(
        rawOrSlabbed: details.rawOrSlabbed,
        gradingCompany: details.gradingCompany,
        graderNotes: details.graderNotes,
        signedBy: details.signedBy,
        labelType: details.labelType,
        customLabel: details.customLabel,
        pageQuality: details.pageQuality,
        certificationNumber: details.certificationNumber,
        keyComic: details.keyComic,
        keyReason: details.keyReason,
        keyCategory: details.keyCategory,
        keySeverity: details.keySeverity,
        coverPriceCents: details.coverPriceCents,
        lastBagBoardDate: details.lastBagBoardDate,
      );

  @override
  ComicOwnedDetailsDraft defaultDraft() => const ComicOwnedDetailsDraft();

  @override
  ComicOwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) {
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
