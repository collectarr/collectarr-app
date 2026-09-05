import 'package:collectarr_app/core/models/activity_event.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('activity registry keeps episode semantics in TV and Anime kinds', () {
    expect(
      libraryActivityContributors.map((contributor) => contributor.kind),
      containsAll(<CatalogMediaKind>[
        CatalogMediaKind.tv,
        CatalogMediaKind.anime,
      ]),
    );
  });

  test('TV and Anime project episode coordinates with stable source ids', () {
    final events = libraryActivityEventsForWatchSessions([
      _session('tv', CatalogMediaKind.tv, season: 2, episode: 3),
      _session('anime', CatalogMediaKind.anime, season: 1, episode: 4),
    ]).toList();

    expect(events, hasLength(2));
    expect(events.map((event) => event.detail), containsAll(['S2E3', 'S1E4']));
    expect(events.map((event) => event.sourceId), containsAll(['tv', 'anime']));
    expect(events.every((event) => event.kind == ActivityEventKind.watched),
        isTrue);
  });

  test('generic activity projection does not inspect non-video coordinates',
      () {
    final event = libraryActivityEventsForWatchSessions([
      _session('book', CatalogMediaKind.book, season: 9, episode: 9),
    ]).single;

    expect(event.kind, ActivityEventKind.watched);
    expect(event.detail, isNull);
    expect(event.sourceId, 'book');
  });
}

WatchSession _session(
  String id,
  CatalogMediaKind kind, {
  required int season,
  required int episode,
}) {
  return WatchSession(
    id: id,
    targetRef: CatalogEntityRef(
      kind: kind.apiValue,
      entityType: CatalogEntityType.episode,
      id: '$id-item',
    ),
    watchedAt: DateTime.utc(2026, 9, 5),
    updatedAt: DateTime.utc(2026, 9, 5),
    seasonNumber: season,
    episodeNumber: episode,
  );
}
