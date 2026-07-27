import 'package:collectarr_app/core/models/owned_item_details.dart';

abstract interface class OwnedDetailsCodec<TDetails extends OwnedItemDetails> {
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
}
