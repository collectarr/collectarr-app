import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_edition.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_play_session.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:drift/drift.dart';

final class BoardGameLocalMapper {
  const BoardGameLocalMapper._();

  static BoardGameMediaRowsCompanion toMediaRow(BoardGameMedia media) {
    if (media.id.value.isEmpty) {
      throw StateError('Cannot persist BoardGameMedia without an id');
    }

    return BoardGameMediaRowsCompanion.insert(
      id: media.id.value,
      title: media.title,
      sortTitle: Value(media.sortTitle),
      description: Value(media.description),
      releaseDate: Value(media.releaseDate),
      originalLanguage: Value(media.originalLanguage),
      publisher: Value(media.publisher),
      subtitle: Value(media.subtitle),
      platformsJson: Value(_encodeList(media.platforms)),
      identifiersJson: Value(_encodeList(media.identifiers)),
      contributorsJson: Value(_encodeList(media.contributors)),
      mechanicsJson: Value(_encodeList(media.mechanics)),
      categoriesJson: Value(_encodeList(media.categories)),
      familiesJson: Value(_encodeList(media.families)),
      expansionsJson: Value(_encodeList(media.expansions)),
      rankingsJson: Value(_encodeList(media.rankings)),
      searchAliasesJson: Value(_encodeList(media.searchAliases)),
      rawPayloadJson: Value(jsonEncode(media.rawPayload)),
    );
  }

  static BoardGameMedia fromMediaRow(
    BoardGameMediaRow row, {
    List<BoardGameEdition> editions = const <BoardGameEdition>[],
  }) {
    return BoardGameMedia(
      id: BoardGameMediaId(row.id),
      title: row.title,
      sortTitle: row.sortTitle,
      description: row.description,
      releaseDate: row.releaseDate,
      originalLanguage: row.originalLanguage,
      publisher: row.publisher,
      subtitle: row.subtitle,
      platforms: _decodeStringList(row.platformsJson),
      identifiers: _decodeStringList(row.identifiersJson),
      contributors: _decodeStringList(row.contributorsJson),
      mechanics: _decodeStringList(row.mechanicsJson),
      categories: _decodeStringList(row.categoriesJson),
      families: _decodeStringList(row.familiesJson),
      expansions: _decodeStringList(row.expansionsJson),
      rankings: _decodeStringList(row.rankingsJson),
      searchAliases: _decodeStringList(row.searchAliasesJson),
      editions: editions,
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static BoardGameEditionRowsCompanion toEditionRow(
    BoardGameMediaId mediaId,
    BoardGameEdition edition,
  ) {
    if (mediaId.value.isEmpty || edition.id.isEmpty) {
      throw StateError('Cannot persist BoardGameEdition without an id');
    }

    return BoardGameEditionRowsCompanion.insert(
      mediaId: mediaId.value,
      id: edition.id,
      title: edition.title,
      titleValue: Value(edition.titleValue),
      workId: Value(edition.workId),
      editionTitle: Value(edition.editionTitle),
      ageRating: Value(edition.ageRating),
      audienceRating: Value(edition.audienceRating),
      barcode: Value(edition.barcode),
      catalogNumber: Value(edition.catalogNumber),
      country: Value(edition.country),
      coverImageUrl: Value(edition.coverImageUrl),
      description: Value(edition.description),
      format: Value(edition.format),
      language: Value(edition.language),
      maxPlayers: Value(edition.maxPlayers),
      minAge: Value(edition.minAge),
      minPlayers: Value(edition.minPlayers),
      playingTimeMinutes: Value(edition.playingTimeMinutes),
      publisher: Value(edition.publisher),
      releaseDate: Value(edition.releaseDate),
      releaseStatus: Value(edition.releaseStatus),
      rawPayloadJson: Value(jsonEncode(edition.rawPayload)),
    );
  }

  static BoardGameEdition fromEditionRow(BoardGameEditionRow row) {
    return BoardGameEdition(
      id: row.id,
      title: row.title,
      titleValue: row.titleValue,
      workId: row.workId,
      editionTitle: row.editionTitle,
      ageRating: row.ageRating,
      audienceRating: row.audienceRating,
      barcode: row.barcode,
      catalogNumber: row.catalogNumber,
      country: row.country,
      coverImageUrl: row.coverImageUrl,
      description: row.description,
      format: row.format,
      language: row.language,
      maxPlayers: row.maxPlayers,
      minAge: row.minAge,
      minPlayers: row.minPlayers,
      playingTimeMinutes: row.playingTimeMinutes,
      publisher: row.publisher,
      releaseDate: row.releaseDate,
      releaseStatus: row.releaseStatus,
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static BoardGameOwnedDetailsRowsCompanion toOwnedDetailsRow(
    String ownedItemId,
    BoardgameOwnedDetails details,
  ) {
    if (ownedItemId.isEmpty) {
      throw StateError('Cannot persist BoardgameOwnedDetails without an id');
    }

    return BoardGameOwnedDetailsRowsCompanion.insert(
      ownedItemId: ownedItemId,
      editionLanguage: Value(details.editionLanguage),
      editionRegion: Value(details.editionRegion),
      componentCondition: Value(details.componentCondition),
      componentCompleteness: Value(details.componentCompleteness),
      missingPiecesNotes: Value(details.missingPiecesNotes),
      isSleeved: Value(details.isSleeved),
      hasCustomInsert: Value(details.hasCustomInsert),
      hasPaintedMiniatures: Value(details.hasPaintedMiniatures),
      storageNotes: Value(details.storageNotes),
    );
  }

  static BoardgameOwnedDetails fromOwnedDetailsRow(
    BoardGameOwnedDetailsRow row,
  ) {
    return BoardgameOwnedDetails(
      editionLanguage: row.editionLanguage,
      editionRegion: row.editionRegion,
      componentCondition: row.componentCondition,
      componentCompleteness: row.componentCompleteness,
      missingPiecesNotes: row.missingPiecesNotes,
      isSleeved: row.isSleeved,
      hasCustomInsert: row.hasCustomInsert,
      hasPaintedMiniatures: row.hasPaintedMiniatures,
      storageNotes: row.storageNotes,
    );
  }

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

  static Map<String, dynamic> _decodeMap(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! Map<Object?, Object?>) return const <String, dynamic>{};
    return Map<String, dynamic>.from(decoded);
  }
}
