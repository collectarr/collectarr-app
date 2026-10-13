import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_play_session.dart';
import 'package:drift/drift.dart';

final class BoardGameLocalMapper {
  const BoardGameLocalMapper._();

  static BoardGamePlaySessionsRowsCompanion toPlaySessionRow(
    BoardGamePlaySession session,
  ) {
    if (session.id.isEmpty || session.boardGameId.isEmpty) {
      throw StateError('Cannot persist BoardGamePlaySession without an id');
    }

    return BoardGamePlaySessionsRowsCompanion.insert(
      id: session.id,
      boardGameId: session.boardGameId,
      date: session.date,
      playersJson: Value(_encodeList(session.players)),
      winner: Value(session.winner),
      scoresJson: Value(
        jsonEncode(session.scores.map((score) => score.toJson()).toList()),
      ),
      durationMinutes: Value(session.durationMinutes),
      location: Value(session.location),
      notes: Value(session.notes),
    );
  }

  static BoardGamePlaySession fromPlaySessionRow(
    BoardGamePlaySessionsRow row,
  ) {
    final decodedScores = _decodeJson(row.scoresJson);

    final scores = decodedScores is List
        ? [
            for (final value in decodedScores)
              if (value is Map)
                BoardGamePlayerScore.fromJson(
                  Map<String, dynamic>.from(value),
                ),
          ]
        : const <BoardGamePlayerScore>[];

    return BoardGamePlaySession(
      id: row.id,
      boardGameId: row.boardGameId,
      date: row.date,
      players: _decodeStringList(row.playersJson),
      winner: row.winner,
      scores: scores,
      durationMinutes: row.durationMinutes,
      location: row.location,
      notes: row.notes,
    );
  }

  static String _encodeList(Iterable<String> values) =>
      jsonEncode(values.toList(growable: false));

  static dynamic _decodeJson(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  static List<String> _decodeStringList(String raw) {
    final decoded = _decodeJson(raw);

    if (decoded is! List) return const <String>[];

    return decoded.whereType<String>().toList(growable: false);
  }
}
