import 'dart:convert';

import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_play_session.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:drift/drift.dart';

final class BoardGameLocalMapper {
  const BoardGameLocalMapper._();

  static BoardGameCollectionItemsRowsCompanion toCollectionItemRow(
    BoardGameCollectionItem item,
  ) {
    if (item.id.value.isEmpty ||
        item.catalogRef.mediaKind != CatalogMediaKind.boardgame) {
      throw StateError('Cannot persist an invalid BoardGameCollectionItem');
    }

    final details = item.details;
    return BoardGameCollectionItemsRowsCompanion.insert(
      id: item.id.value,
      itemId: item.itemId,
      createdAt: Value(item.createdAt),
      isDigital: Value(item.isDigital),
      condition: Value(item.condition),
      grade: Value(item.grade),
      purchaseDate: Value(item.purchaseDate),
      pricePaidCents: Value(item.pricePaidCents),
      currency: Value(item.currency),
      personalNotes: Value(item.personalNotes),
      indexNumber: Value(item.indexNumber),
      tags: Value(item.tags),
      updatedAt: item.updatedAt,
      deletedAt: Value(item.deletedAt),
      soldAt: Value(item.soldAt),
      sellPriceCents: Value(item.sellPriceCents),
      soldTo: Value(item.soldTo),
      ownerUserId: Value(item.ownerUserId),
      ownerLabel: Value(item.ownerLabel),
      locationId: Value(item.locationId),
      purchaseStore: Value(item.purchaseStore),
      collectionStatus: Value(item.collectionStatus),
      marketValueCents: Value(item.marketValueCents),
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

  static BoardGameCollectionItem fromCollectionItemRow(BoardGameCollectionItemsRow row) {
    final catalogRef = CatalogEntityRef(
      kind: CatalogMediaKind.boardgame,
      entityType: CatalogEntityTypeId.catalogItem,
      id: row.itemId,
    );
    return BoardGameCollectionItem(
      id: CollectionItemId(row.id),
      catalogRef: catalogRef,
      createdAt: row.createdAt,
      isDigital: row.isDigital,
      condition: row.condition,
      grade: row.grade,
      purchaseDate: row.purchaseDate,
      pricePaidCents: row.pricePaidCents,
      currency: row.currency,
      personalNotes: row.personalNotes,
      indexNumber: row.indexNumber,
      tags: row.tags,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      soldAt: row.soldAt,
      sellPriceCents: row.sellPriceCents,
      soldTo: row.soldTo,
      ownerUserId: row.ownerUserId,
      ownerLabel: row.ownerLabel,
      locationId: row.locationId,
      purchaseStore: row.purchaseStore,
      collectionStatus: row.collectionStatus,
      marketValueCents: row.marketValueCents,
      details: BoardgameOwnedDetails(
        editionLanguage: row.editionLanguage,
        editionRegion: row.editionRegion,
        componentCondition: row.componentCondition,
        componentCompleteness: row.componentCompleteness,
        missingPiecesNotes: row.missingPiecesNotes,
        isSleeved: row.isSleeved,
        hasCustomInsert: row.hasCustomInsert,
        hasPaintedMiniatures: row.hasPaintedMiniatures,
        storageNotes: row.storageNotes,
      ),
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
}
