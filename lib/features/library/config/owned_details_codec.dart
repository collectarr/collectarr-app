import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';

abstract interface class OwnedDetailsCodec<TDetails extends OwnedItemDetails> {
  TDetails fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(TDetails details);
  Map<String, dynamic> toSyncPayload(TDetails details);
  TDetails defaultDetails();
  OwnedDetailsDraft defaultDraft();
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
}
