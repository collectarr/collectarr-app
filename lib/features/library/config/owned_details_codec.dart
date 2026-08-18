import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';

abstract interface class LibraryOwnershipCapability<
    TDetails extends OwnedItemDetails> {
  OwnedDetailsDraft defaultDraft();
  OwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal);
}

abstract interface class OwnedDetailsCodec<TDetails extends OwnedItemDetails>
    implements LibraryOwnershipCapability<TDetails> {
  TDetails fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(TDetails details);
  Map<String, dynamic> toSyncPayload(TDetails details);
  TDetails defaultDetails();
}

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

class VideoOwnedDetailsCodec implements OwnedDetailsCodec<VideoOwnedDetails> {
  const VideoOwnedDetailsCodec();

  @override
  VideoOwnedDetails fromJson(Map<String, dynamic> json) =>
      VideoOwnedDetails.fromJson(json);

  @override
  Map<String, dynamic> toJson(VideoOwnedDetails details) => details.toJson();

  @override
  Map<String, dynamic> toSyncPayload(VideoOwnedDetails details) =>
      details.toJson();

  @override
  VideoOwnedDetails defaultDetails() => const VideoOwnedDetails();

  @override
  OwnedDetailsDraft defaultDraft() => const VideoOwnedDetailsDraft();

  @override
  OwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) {
    return VideoOwnedDetailsDraft(
      features: personal.features,
      hdrFormats: personal.hdrFormats ?? const [],
      boxSetName: personal.boxSetName,
      region: personal.region,
      packaging: personal.packaging,
      distributor: personal.distributor,
    );
  }
}

class GameOwnedDetailsCodec implements OwnedDetailsCodec<GameOwnedDetails> {
  const GameOwnedDetailsCodec();

  @override
  GameOwnedDetails fromJson(Map<String, dynamic> json) =>
      GameOwnedDetails.fromJson(json);

  @override
  Map<String, dynamic> toJson(GameOwnedDetails details) => details.toJson();

  @override
  Map<String, dynamic> toSyncPayload(GameOwnedDetails details) =>
      details.toJson();

  @override
  GameOwnedDetails defaultDetails() => const GameOwnedDetails();

  @override
  OwnedDetailsDraft defaultDraft() => const GameOwnedDetailsDraft();

  @override
  OwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) {
    return GameOwnedDetailsDraft(
      completeness: personal.gameCompleteness,
      hasBox: personal.gameHasBox,
      hasManual: personal.gameHasManual,
      priceChartingId: personal.gamePriceChartingId,
      coreRegion: personal.gameCoreRegion,
      valueIsLocked: personal.gameValueIsLocked,
    );
  }
}

class MusicOwnedDetailsCodec implements OwnedDetailsCodec<MusicOwnedDetails> {
  const MusicOwnedDetailsCodec();

  @override
  MusicOwnedDetails fromJson(Map<String, dynamic> json) =>
      MusicOwnedDetails.fromJson(json);

  @override
  Map<String, dynamic> toJson(MusicOwnedDetails details) => details.toJson();

  @override
  Map<String, dynamic> toSyncPayload(MusicOwnedDetails details) =>
      details.toJson();

  @override
  MusicOwnedDetails defaultDetails() => const MusicOwnedDetails();

  @override
  OwnedDetailsDraft defaultDraft() => const MusicOwnedDetailsDraft();

  @override
  OwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) {
    return MusicOwnedDetailsDraft(
      storageDevice: personal.storageDevice,
      storageSlot: personal.storageSlot,
    );
  }
}

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

class BoardgameOwnedDetailsCodec
    implements OwnedDetailsCodec<BoardgameOwnedDetails> {
  const BoardgameOwnedDetailsCodec();

  @override
  BoardgameOwnedDetails fromJson(Map<String, dynamic> json) =>
      BoardgameOwnedDetails.fromJson(json);

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

class GenericOwnedDetailsCodec
    implements OwnedDetailsCodec<GenericOwnedDetails> {
  const GenericOwnedDetailsCodec();

  @override
  GenericOwnedDetails fromJson(Map<String, dynamic> json) =>
      const GenericOwnedDetails();

  @override
  Map<String, dynamic> toJson(GenericOwnedDetails details) => details.toJson();

  @override
  Map<String, dynamic> toSyncPayload(GenericOwnedDetails details) =>
      details.toJson();

  @override
  GenericOwnedDetails defaultDetails() => const GenericOwnedDetails();

  @override
  OwnedDetailsDraft defaultDraft() => const GenericOwnedDetailsDraft();

  @override
  OwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) =>
      const GenericOwnedDetailsDraft();
}
