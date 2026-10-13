import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/features/sync/state/sync_state.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'auth_fakes.dart';

class NoOpSyncFake extends SyncController {
  @override
  SyncState build() => SyncState();
  @override
  Future<void> syncOnlineFirstIfEnabled() async {}
}

List<Override> testAppOverrides({
  required LocalDatabase database,
  bool stubEmptyCollections = false,
  ApiClient? api,
}) =>
    [
      localDatabaseProvider.overrideWithValue(database),
      authControllerProvider.overrideWith(AuthenticatedAuthFake.new),
      syncControllerProvider.overrideWith(NoOpSyncFake.new),
      mediaCatalogProvider.overrideWith((ref) async => fallbackMediaCatalog),
      if (api != null) apiClientProvider.overrideWithValue(api),
      if (stubEmptyCollections) ...[
        shelfProvider.overrideWith((ref) async => const ShelfState(
            entries: [],
            entryCount: 0,
            wishlistCount: 0,
            pricedCount: 0,
            totalPaidCents: null,
            primaryCurrency: null,
            hasMixedCurrencies: false)),
        collectionProvider.overrideWith((ref) async => const []),
      ],
    ];
