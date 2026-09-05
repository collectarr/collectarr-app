import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
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

import 'tracking_entry_contract.dart';
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

  _defineTrackingEntryContract('comic', CatalogMediaKind.comic);
  _defineTrackingEntryContract('manga', CatalogMediaKind.manga);
  _defineTrackingEntryContract('book', CatalogMediaKind.book);
  _defineTrackingEntryContract('game', CatalogMediaKind.game);
  _defineTrackingEntryContract('boardgame', CatalogMediaKind.boardgame);
  _defineTrackingEntryContract('movie', CatalogMediaKind.movie);
  _defineTrackingEntryContract('tv', CatalogMediaKind.tv);
  _defineTrackingEntryContract('anime', CatalogMediaKind.anime);
  _defineTrackingEntryContract('music', CatalogMediaKind.music);
}

void _defineTrackingEntryContract(String name, CatalogMediaKind kind) {
  defineTrackingEntryContract(
    name: name,
    create: () => TrackingEntry(
      id: '$name-tracking-1',
      catalogRef: CatalogEntityRef(
        id: '$name-work-1',
        kind: kind.apiValue,
        entityType: CatalogEntityType.work,
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
