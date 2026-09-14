import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/tracking/boardgame_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/tracking/game_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/tracking/movie_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_lifecycle_codec.dart';

import 'tracking_lifecycle_contract.dart';
import 'tracking_profile_contract.dart';

void main() {
  defineTrackingProfileContract(
    name: 'Comic',
    create: () => comicKindModule.trackingProfile,
  );
  defineTrackingProfileContract(
    name: 'Manga',
    create: () => mangaKindModule.trackingProfile,
  );
  defineTrackingProfileContract(
    name: 'Book',
    create: () => bookKindModule.trackingProfile,
  );
  defineTrackingProfileContract(
    name: 'Game',
    create: () => gameKindModule.trackingProfile,
  );
  defineTrackingProfileContract(
    name: 'BoardGame',
    create: () => boardGameKindModule.trackingProfile,
  );
  defineTrackingProfileContract(
    name: 'Movie',
    create: () => movieKindModule.trackingProfile,
  );
  defineTrackingProfileContract(
    name: 'TV',
    create: () => tvKindModule.trackingProfile,
  );
  defineTrackingProfileContract(
    name: 'Anime',
    create: () => animeKindModule.trackingProfile,
  );
  defineTrackingProfileContract(
    name: 'Music',
    create: () => musicKindModule.trackingProfile,
  );

  _defineTrackingLifecycleContract('comic', CatalogMediaKind.comic);
  _defineTrackingLifecycleContract('manga', CatalogMediaKind.manga);
  _defineTrackingLifecycleContract('book', CatalogMediaKind.book);
  _defineTrackingLifecycleContract('game', CatalogMediaKind.game);
  _defineTrackingLifecycleContract('boardgame', CatalogMediaKind.boardgame);
  _defineTrackingLifecycleContract('movie', CatalogMediaKind.movie);
  _defineTrackingLifecycleContract('tv', CatalogMediaKind.tv);
  _defineTrackingLifecycleContract('anime', CatalogMediaKind.anime);
  _defineTrackingLifecycleContract('music', CatalogMediaKind.music);
}

void _defineTrackingLifecycleContract(
  String name,
  CatalogMediaKind kind,
) {
  final TrackingLifecycleCodec codec = switch (kind) {
    CatalogMediaKind.anime => const AnimeTrackingLifecycleCodec(),
    CatalogMediaKind.boardgame => const BoardGameTrackingLifecycleCodec(),
    CatalogMediaKind.book => const BookTrackingLifecycleCodec(),
    CatalogMediaKind.comic => const ComicTrackingLifecycleCodec(),
    CatalogMediaKind.game => const GameTrackingLifecycleCodec(),
    CatalogMediaKind.manga => const MangaTrackingLifecycleCodec(),
    CatalogMediaKind.movie => const MovieTrackingLifecycleCodec(),
    CatalogMediaKind.music => const MusicTrackingLifecycleCodec(),
    CatalogMediaKind.tv => const TvTrackingLifecycleCodec(),
    CatalogMediaKind.unknown => throw ArgumentError.value(kind),
  };
  defineTrackingLifecycleContract(
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
