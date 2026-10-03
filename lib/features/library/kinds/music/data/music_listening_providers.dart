import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_mutations.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final musicListeningRepositoryProvider = Provider<MusicListeningRepository>(
  (ref) => MusicListeningRepository(ref.watch(localDatabaseProvider)),
);

final musicListeningMutationsProvider = Provider<MusicListeningMutations>(
  (ref) => MusicListeningMutations(ref.watch(localDatabaseProvider)),
);

final musicListeningEventsProvider =
    FutureProvider.family<List<MusicListenEvent>, LibraryEntryRef>(
  (ref, libraryEntryRef) => ref
      .watch(musicListeningRepositoryProvider)
      .listForLibraryEntry(libraryEntryRef),
);

final musicCatalogItemListeningSummaryProvider =
    FutureProvider.family<MusicCatalogItemListeningSummary, LibraryEntryRef>(
  (ref, libraryEntryRef) =>
      ref.watch(musicListeningRepositoryProvider).getSummary(libraryEntryRef),
);
