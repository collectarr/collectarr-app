import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/activity/global_activity_provider.dart';
import 'package:collectarr_app/features/calendar/calendar_provider.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';
import 'package:collectarr_app/features/collection/repositories/location_provider.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/detail/library_detail_page.dart';
import 'package:collectarr_app/features/library/home/home_counts.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_state_provider.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_play_session_providers.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_providers.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_release_image_providers.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_mutation_provider.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_state_provider.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_account_store.dart';
import 'package:collectarr_app/features/settings/database_backup.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Coordinates replacement of local rows with sync state and live projections.
final class LocalDatabaseMaintenanceCoordinator {
  LocalDatabaseMaintenanceCoordinator(this.ref)
      : _database = ref.read(localDatabaseProvider);

  final WidgetRef ref;
  final LocalDatabase _database;

  Future<void> restore(Map<String, dynamic> backup) async {
    await _run(() => DatabaseBackup(_database).import(backup));
  }

  Future<void> clear() async {
    await _run(() => DatabaseBackup(_database).clearAll());
  }

  Future<void> _run(Future<void> Function() mutation) async {
    await ref.read(syncControllerProvider.notifier).runDatabaseMaintenance(
      () async {
        try {
          await mutation();
          invalidateLocalDatabaseProjections(ref);
        } finally {
          try {
            await ref
                .read(syncControllerProvider.notifier)
                .refreshPendingCount();
          } catch (_) {
            // Keep the original restore/clear failure as the reported error.
          }
        }
      },
    );
  }
}

/// Refreshes every Riverpod projection that reads the local Drift database.
void invalidateLocalDatabaseProjections(WidgetRef ref) {
  ref.invalidate(collectionProvider);
  ref.invalidate(collectionSummariesProvider);
  ref.invalidate(trackingSummariesProvider);
  ref.invalidate(trackingUnitsProvider);
  ref.invalidate(watchSessionsProvider);
  ref.invalidate(wishlistRefsProvider);
  ref.invalidate(wishlistProvider);
  ref.invalidate(metadataOverridesProvider);
  ref.invalidate(userExternalLinksByItemProvider);
  ref.invalidate(shelfProvider);
  ref.invalidate(allLocationsProvider);
  ref.invalidate(globalActivityProvider);
  ref.invalidate(calendarEventsProvider);
  ref.invalidate(localItemImageProvider);
  ref.invalidate(localCoverImageProvider);
  ref.invalidate(animeTrackingStateBySeriesIdProvider);
  ref.invalidate(boardGamePlaySessionsProvider);
  ref.invalidate(boardGameAllPlaySessionsProvider);
  ref.invalidate(boardGamePlayStatsProvider);
  ref.invalidate(musicListeningEventsProvider);
  ref.invalidate(musicReleaseGroupTrackingSummaryProvider);
  ref.invalidate(musicReleaseImagesProvider);
  ref.invalidate(overdueLoanOwnedItemIdsProvider);
  ref.invalidate(activeOwnedCopiesByCatalogItemProvider);
  ref.invalidate(libraryCustomFieldCacheProvider);
  ref.invalidate(tvTrackingStateBySeriesIdProvider);
  ref.invalidate(tvCustomEpisodesByCatalogRefProvider);
  ref.invalidate(externalAccountsProvider);
}
