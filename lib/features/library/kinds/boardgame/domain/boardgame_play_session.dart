import 'package:flutter/foundation.dart';

@immutable
class BoardGamePlayerScore {
  const BoardGamePlayerScore({
    required this.playerName,
    required this.score,
    this.isWinner = false,
  });

  final String playerName;
  final int score;
  final bool isWinner;

  Map<String, dynamic> toJson() => {
        'player_name': playerName,
        'score': score,
        if (isWinner) 'is_winner': true,
      };

  factory BoardGamePlayerScore.fromJson(Map<String, dynamic> json) {
    return BoardGamePlayerScore(
      playerName: (json['player_name'] as String?) ?? '',
      score: json['score'] as int? ?? 0,
      isWinner: json['is_winner'] as bool? ?? false,
    );
  }
}

@immutable
class BoardGamePlaySession {
  const BoardGamePlaySession({
    required this.id,
    required this.boardGameId,
    required this.date,
    this.players = const [],
    this.winner,
    this.scores = const [],
    this.durationMinutes,
    this.location,
    this.notes,
  });

  final String id;
  final String boardGameId;
  final DateTime date;
  final List<String> players;
  final String? winner;
  final List<BoardGamePlayerScore> scores;
  final int? durationMinutes;
  final String? location;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'board_game_id': boardGameId,
        'date': date.toIso8601String(),
        if (players.isNotEmpty) 'players': players,
        if (winner != null) 'winner': winner,
        if (scores.isNotEmpty) 'scores': scores.map((e) => e.toJson()).toList(),
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
        if (location != null) 'location': location,
        if (notes != null) 'notes': notes,
      };

  factory BoardGamePlaySession.fromJson(Map<String, dynamic> json) {
    return BoardGamePlaySession(
      id: (json['id'] as String?) ?? '',
      boardGameId: (json['board_game_id'] as String?) ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      players: (json['players'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      winner: json['winner'] as String?,
      scores: (json['scores'] as List<dynamic>?)
              ?.map((e) =>
                  BoardGamePlayerScore.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      durationMinutes: json['duration_minutes'] as int?,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

@immutable
class BoardGamePlayStats {
  const BoardGamePlayStats({
    required this.playCount,
    this.lastPlayed,
    this.mostPlayedWith = const [],
    this.winStats = const {},
    this.averageDurationMinutes,
  });

  final int playCount;
  final DateTime? lastPlayed;
  final List<String> mostPlayedWith;
  final Map<String, int> winStats;
  final double? averageDurationMinutes;

  /// Aggregates a list of [BoardGamePlaySession]s into calculated stats.
  factory BoardGamePlayStats.fromSessions(List<BoardGamePlaySession> sessions) {
    if (sessions.isEmpty) {
      return const BoardGamePlayStats(playCount: 0);
    }

    DateTime? latestDate;
    var totalDuration = 0;
    var durationCount = 0;
    final playerCounts = <String, int>{};
    final wins = <String, int>{};

    for (final session in sessions) {
      if (latestDate == null || session.date.isAfter(latestDate)) {
        latestDate = session.date;
      }
      if (session.durationMinutes != null && session.durationMinutes! > 0) {
        totalDuration += session.durationMinutes!;
        durationCount++;
      }
      for (final player in session.players) {
        playerCounts[player] = (playerCounts[player] ?? 0) + 1;
      }

      final sessionWinners = <String>{};
      if (session.winner != null && session.winner!.isNotEmpty) {
        sessionWinners.add(session.winner!);
      }
      for (final score in session.scores) {
        if (score.isWinner) {
          sessionWinners.add(score.playerName);
        }
      }
      for (final winner in sessionWinners) {
        wins[winner] = (wins[winner] ?? 0) + 1;
      }
    }

    final sortedPlayers = playerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final mostPlayed =
        sortedPlayers.take(3).map((e) => e.key).toList(growable: false);

    return BoardGamePlayStats(
      playCount: sessions.length,
      lastPlayed: latestDate,
      mostPlayedWith: mostPlayed,
      winStats: wins,
      averageDurationMinutes:
          durationCount > 0 ? (totalDuration / durationCount) : null,
    );
  }
}
