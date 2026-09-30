import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final musicListeningRepositoryProvider = Provider<MusicListeningRepository>(
  (ref) => MusicListeningRepository(ref.watch(localDatabaseProvider)),
);

final musicListeningEventsProvider =
    FutureProvider.family<List<MusicListenEvent>, CatalogEntityRef>(
  (ref, catalogRef) => ref
      .watch(musicListeningRepositoryProvider)
      .listForCatalogItem(catalogRef),
);

final musicCatalogItemListeningSummaryProvider =
    FutureProvider.family<MusicCatalogItemListeningSummary, CatalogEntityRef>(
  (ref, catalogRef) =>
      ref.watch(musicListeningRepositoryProvider).getSummary(catalogRef),
);
