import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/book/book_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/game/game_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/tracking/boardgame_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/tracking/game_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/tracking/movie_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_codec.dart';

import 'tracking_state_contract.dart';
import 'tracking_profile_contract.dart';

void main() {
  defineTrackingProfileContract(
    name: 'Comic',
    create: () => comicKindTrackingProfile,
  );
  defineTrackingProfileContract(
    name: 'Manga',
    create: () => mangaKindTrackingProfile,
  );
  defineTrackingProfileContract(
    name: 'Book',
    create: () => bookKindTrackingProfile,
  );
  defineTrackingProfileContract(
    name: 'Game',
    create: () => gameKindTrackingProfile,
  );
  defineTrackingProfileContract(
    name: 'BoardGame',
    create: () => boardGameKindTrackingProfile,
  );
  defineTrackingProfileContract(
    name: 'Movie',
    create: () => movieKindTrackingProfile,
  );
  defineTrackingProfileContract(
    name: 'TV',
    create: () => tvKindTrackingProfile,
  );
  defineTrackingProfileContract(
    name: 'Anime',
    create: () => animeKindTrackingProfile,
  );
  defineTrackingProfileContract(
    name: 'Music',
    create: () => musicKindTrackingProfile,
  );

  _defineTrackingStateContract('comic', CatalogMediaKind.comic);
  _defineTrackingStateContract('manga', CatalogMediaKind.manga);
  _defineTrackingStateContract('book', CatalogMediaKind.book);
  _defineTrackingStateContract('game', CatalogMediaKind.game);
  _defineTrackingStateContract('boardgame', CatalogMediaKind.boardgame);
  _defineTrackingStateContract('movie', CatalogMediaKind.movie);
  _defineTrackingStateContract('tv', CatalogMediaKind.tv);
  _defineTrackingStateContract('anime', CatalogMediaKind.anime);
  _defineTrackingStateContract('music', CatalogMediaKind.music);
}

void _defineTrackingStateContract(
  String name,
  CatalogMediaKind kind,
) {
  final TrackingStorageCodec codec = switch (kind) {
    CatalogMediaKind.anime => const AnimeTrackingStateCodec(),
    CatalogMediaKind.boardgame => const BoardGameTrackingStateCodec(),
    CatalogMediaKind.book => const BookTrackingStateCodec(),
    CatalogMediaKind.comic => const ComicTrackingStateCodec(),
    CatalogMediaKind.game => const GameTrackingStateCodec(),
    CatalogMediaKind.manga => const MangaTrackingStateCodec(),
    CatalogMediaKind.movie => const MovieTrackingStateCodec(),
    CatalogMediaKind.music => const MusicTrackingStateCodec(),
    CatalogMediaKind.tv => const TvTrackingStateCodec(),
    CatalogMediaKind.unknown => throw ArgumentError.value(kind),
  };
  defineTrackingStateContract(
    name: name,
    codec: codec,
    create: () => codec.create(
      id: '$name-tracking-1',
      catalogRef: CatalogEntityRef(
        id: '$name-work-1',
        kind: kind,
        entityType: const CatalogEntityTypeId('work'),
      ),
      status: MediaTrackingStatus.inProgress,
      rating: 8,
      startedAt: DateTime.utc(2026, 1, 2),
      progressCurrent: 3,
      progressTotal: 10,
      timesCompleted: 1,
      notes: 'Contract fixture',
      updatedAt: DateTime.utc(2026, 1, 3),
      deletedAt: null,
    ),
  );
}
