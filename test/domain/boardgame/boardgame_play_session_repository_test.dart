import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_play_session_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_play_session.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips typed play sessions and orders newest first', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = BoardGamePlaySessionRepository(db);

    final older = BoardGamePlaySession(
      id: 'session-old',
      boardGameId: 'boardgame-1',
      date: DateTime.utc(2026, 1, 1),
      players: const ['Alex', 'Sam'],
      winner: 'Alex',
      scores: const [
        BoardGamePlayerScore(playerName: 'Alex', score: 42, isWinner: true),
        BoardGamePlayerScore(playerName: 'Sam', score: 31),
      ],
      durationMinutes: 90,
      location: 'Kitchen table',
      notes: 'First play',
    );
    final newer = BoardGamePlaySession(
      id: 'session-new',
      boardGameId: 'boardgame-1',
      date: DateTime.utc(2026, 2, 1),
      players: const ['Sam'],
    );
    await repository.upsertAll([older, newer]);

    final sessions = await repository.listForBoardGame(
      const BoardGameMediaId('boardgame-1'),
    );
    expect(
      sessions.map((session) => session.id),
      ['session-new', 'session-old'],
    );
    expect(sessions.last.players, ['Alex', 'Sam']);
    expect(sessions.last.scores.first.playerName, 'Alex');
    expect(sessions.last.scores.first.score, 42);
    expect(sessions.last.scores.first.isWinner, isTrue);
    expect(sessions.last.durationMinutes, 90);
    expect(sessions.last.location, 'Kitchen table');
    expect(sessions.last.notes, 'First play');

    final stats = BoardGamePlayStats.fromSessions(sessions);
    expect(stats.playCount, 2);
    expect(stats.lastPlayed?.toUtc(), DateTime.utc(2026, 2, 1));
    expect(stats.mostPlayedWith, ['Sam', 'Alex']);
    expect(stats.winStats, {'Alex': 1});
    expect(stats.averageDurationMinutes, 90);

    await repository.deleteById('session-new');
    expect(await repository.findById('session-new'), isNull);
  });
}
