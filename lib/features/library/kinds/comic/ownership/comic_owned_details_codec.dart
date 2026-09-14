import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details_draft.dart';

final class ComicOwnedDetailsCodec {
  const ComicOwnedDetailsCodec();

  ComicOwnedDetails fromJson(Map<String, dynamic> json) =>
      ComicOwnedDetails.fromJson(json);

  Map<String, dynamic> toJson(ComicOwnedDetails details) => details.toJson();

  Map<String, dynamic> toSyncPayload(ComicOwnedDetails details) =>
      details.toJson();

  ComicOwnedDetails defaultDetails() => const ComicOwnedDetails();

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

  ComicOwnedDetailsDraft defaultDraft() => const ComicOwnedDetailsDraft();
}
