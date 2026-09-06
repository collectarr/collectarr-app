import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_domain.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('boardgame work dto preserves typed collections', () {
    final dto = BoardGameWorkDto.fromJson({
      'id': 'boardgame-1',
      'title': 'Catan',
      'platforms': ['Base Game'],
      'identifiers': ['BGG:13'],
      'contributors': ['Klaus Teuber'],
      'mechanics': ['dice rolling'],
      'categories': ['economic'],
      'families': ['catan'],
      'expansions': ['Seafarers'],
      'rankings': ['BGG Rank #1'],
    });

    expect(dto.platforms, ['Base Game']);
    expect(dto.identifiers, ['BGG:13']);
    expect(dto.contributors, ['Klaus Teuber']);
    expect(dto.mechanics, ['dice rolling']);
    expect(dto.categories, ['economic']);
    expect(dto.families, ['catan']);
    expect(dto.expansions, ['Seafarers']);
    expect(dto.rankings, ['BGG Rank #1']);
  });

  test('BoardgameOwnedDetails supports rich copy fields and serialization', () {
    const details = BoardgameOwnedDetails(
      editionLanguage: 'English',
      editionRegion: 'US',
      componentCondition: 'Like New',
      componentCompleteness: 'Complete',
      missingPiecesNotes: 'None',
      isSleeved: true,
      hasCustomInsert: true,
      hasPaintedMiniatures: true,
      storageNotes: 'Stored horizontally on shelf 3',
    );

    final json = details.toJson();
    final fromJson = BoardgameOwnedDetails.fromJson(json);

    expect(fromJson.editionLanguage, 'English');
    expect(fromJson.isSleeved, isTrue);
    expect(fromJson.hasCustomInsert, isTrue);
    expect(fromJson.hasPaintedMiniatures, isTrue);
    expect(fromJson.storageNotes, 'Stored horizontally on shelf 3');
    expect(fromJson, details);
  });

  test('BoardGameMetadata parses rich BGG and game specifications', () {
    final meta = BoardGameMetadata(
      title: 'Terraforming Mars',
      yearPublished: 2016,
      minPlayers: 1,
      maxPlayers: 5,
      recommendedPlayers: '3-4',
      bestPlayers: '3',
      minPlaytimeMinutes: 90,
      maxPlaytimeMinutes: 120,
      minimumAge: 12,
      complexityWeight: 3.25,
      designers: const ['Jacob Fryxelius'],
      publishers: const ['FryxGames', 'Stronghold Games'],
      mechanics: const ['Drafting', 'Tile Placement', 'Hand Management'],
      categories: const ['Economic', 'Industry / Manufacturing', 'Space'],
      expansions: const ['Prelude', 'Hellas & Elysium', 'Venus Next'],
      bggRating: 8.38,
      bggRatingCount: 88000,
      bggRank: 7,
    );

    final json = meta.toJson();
    final fromJson = BoardGameMetadata.fromJson(json);

    expect(fromJson.title, 'Terraforming Mars');
    expect(fromJson.complexityWeight, 3.25);
    expect(fromJson.bggRank, 7);
    expect(fromJson.bggRating, 8.38);
    expect(fromJson.expansions, contains('Prelude'));
  });

  test('BoardGamePlaySession aggregates gameplay statistics correctly', () {
    final sessions = [
      BoardGamePlaySession(
        id: 'session-1',
        boardGameId: 'bg-1',
        date: DateTime.utc(2026, 1, 15, 19, 0),
        durationMinutes: 120,
        players: const ['Alice', 'Bob', 'Charlie'],
        winner: 'Alice',
        scores: const [
          BoardGamePlayerScore(playerName: 'Alice', score: 85, isWinner: true),
          BoardGamePlayerScore(playerName: 'Bob', score: 78),
          BoardGamePlayerScore(playerName: 'Charlie', score: 65),
        ],
      ),
      BoardGamePlaySession(
        id: 'session-2',
        boardGameId: 'bg-1',
        date: DateTime.utc(2026, 2, 10, 20, 0),
        durationMinutes: 90,
        players: const ['Alice', 'Bob'],
        winner: 'Bob',
        scores: const [
          BoardGamePlayerScore(playerName: 'Alice', score: 70),
          BoardGamePlayerScore(playerName: 'Bob', score: 92, isWinner: true),
        ],
      ),
    ];

    final stats = BoardGamePlayStats.fromSessions(sessions);

    expect(stats.playCount, 2);
    expect(stats.lastPlayed, DateTime.utc(2026, 2, 10, 20, 0));
    expect(stats.averageDurationMinutes, 105.0);
    expect(stats.mostPlayedWith, containsAll(['Alice', 'Bob']));
    expect(stats.winStats['Alice'], 1);
    expect(stats.winStats['Bob'], 1);
  });

  test('boardGameKindModule registers dedicated BoardGame capabilities', () {
    expect(boardGameKindModule.kind, CatalogMediaKind.boardgame);
    expect(boardGameKindModule.add.kind, CatalogMediaKind.boardgame);
    expect(
        boardGameKindModule.add.createInitialDraft(), isA<BoardGameAddDraft>());
    expect(
        const BoardgameOwnedDetailsCodec(), isA<BoardgameOwnedDetailsCodec>());
    expect(const BoardgameOwnedDetailsCodec().defaultDetails(),
        isA<BoardgameOwnedDetails>());
  });
}
