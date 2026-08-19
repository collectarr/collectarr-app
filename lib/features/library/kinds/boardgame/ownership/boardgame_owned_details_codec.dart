import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';

class BoardgameOwnedDetailsCodec
    implements OwnedDetailsCodec<BoardgameOwnedDetails> {
  const BoardgameOwnedDetailsCodec();

  @override
  BoardgameOwnedDetails fromJson(Map<String, dynamic> json) =>
      const BoardgameOwnedDetails();

  @override
  Map<String, dynamic> toJson(BoardgameOwnedDetails details) =>
      details.toJson();

  @override
  Map<String, dynamic> toSyncPayload(BoardgameOwnedDetails details) =>
      details.toJson();

  @override
  BoardgameOwnedDetails defaultDetails() => const BoardgameOwnedDetails();

  @override
  OwnedDetailsDraft defaultDraft() => const BoardgameOwnedDetailsDraft();

  @override
  OwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) =>
      const BoardgameOwnedDetailsDraft();
}
