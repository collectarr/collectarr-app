import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';

class MangaOwnedDetailsCodec implements OwnedDetailsCodec<MangaOwnedDetails> {
  const MangaOwnedDetailsCodec();

  @override
  MangaOwnedDetails fromJson(Map<String, dynamic> json) =>
      MangaOwnedDetails.fromJson(json);

  @override
  Map<String, dynamic> toJson(MangaOwnedDetails details) => details.toJson();

  @override
  Map<String, dynamic> toSyncPayload(MangaOwnedDetails details) =>
      details.toJson();

  @override
  MangaOwnedDetails defaultDetails() => const MangaOwnedDetails();

  @override
  OwnedDetailsDraft defaultDraft() => const MangaOwnedDetailsDraft();

  @override
  OwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) {
    return MangaOwnedDetailsDraft(
      rawOrSlabbed: personal.rawOrSlabbed,
      signedBy: personal.signedBy,
      gradingCompany: personal.gradingCompany,
      graderNotes: personal.graderNotes,
      labelType: personal.labelType,
      customLabel: personal.customLabel,
      pageQuality: personal.pageQuality,
      certificationNumber: personal.certificationNumber,
    );
  }
}
