import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_play_session_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_play_session.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final boardGamePlaySessionRepositoryProvider =
    Provider<BoardGamePlaySessionRepository>((ref) {
  return BoardGamePlaySessionRepository(ref.watch(localDatabaseProvider));
});

final boardGamePlaySessionsProvider =
    FutureProvider.family<List<BoardGamePlaySession>, CatalogItemRef>(
  (ref, boardGameId) {
    return ref
        .watch(boardGamePlaySessionRepositoryProvider)
        .listForBoardGame(boardGameId);
  },
);

final boardGameAllPlaySessionsProvider =
    FutureProvider<List<BoardGamePlaySession>>((ref) {
  return ref.watch(boardGamePlaySessionRepositoryProvider).listAll();
});

final boardGamePlayStatsProvider =
    FutureProvider.family<BoardGamePlayStats, CatalogItemRef>(
  (ref, boardGameId) async {
    final sessions =
        await ref.watch(boardGamePlaySessionsProvider(boardGameId).future);
    return BoardGamePlayStats.fromSessions(sessions);
  },
);
