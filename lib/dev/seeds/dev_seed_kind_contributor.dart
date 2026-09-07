import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/models/watch_session.dart';

typedef DevSeedCatalogFactory = List<CatalogItemDto> Function();
typedef DevSeedItemEnricher = CatalogItemDto Function(CatalogItemDto item);
typedef DevSeedCatalogQualityValidator = List<String> Function(
  CatalogItemDto item,
);
typedef DevSeedOwnedFactory = List<OwnedItem> Function(DateTime now);
typedef DevSeedOwnedQualityValidator = List<String> Function(OwnedItem item);
typedef DevSeedTrackingFactory = List<TrackingEntry> Function(DateTime now);
typedef DevSeedTrackingUnitFactory = Iterable<TrackingUnit> Function(
  Iterable<CatalogItemDto> items,
  DateTime now,
);
typedef DevSeedWatchSessionFactory = List<WatchSession> Function(DateTime now);
typedef DevSeedCustomEpisodeFactory = List<CustomEpisode> Function(
  DateTime now,
);
typedef DevSeedDatabaseSeeder = Future<void> Function(
  LocalDatabase db,
  Iterable<CatalogItemDto> items,
  DateTime now,
);

/// The complete development-fixture contribution owned by one library kind.
///
/// This is a dev-only composition contract. It keeps fixture construction
/// typed while allowing the seed entry point to remain unaware of concrete
/// kind repositories and tracking models.
final class DevSeedKindContributor {
  const DevSeedKindContributor({
    required this.kind,
    required this.catalogItems,
    required this.enrichItem,
    required this.validateCatalog,
    required this.ownedItems,
    required this.validateOwned,
    required this.trackingEntries,
    this.trackingUnits,
    this.watchSessions,
    this.customEpisodes,
    this.seedDatabase,
  });

  final String kind;
  final DevSeedCatalogFactory catalogItems;
  final DevSeedItemEnricher enrichItem;
  final DevSeedCatalogQualityValidator validateCatalog;
  final DevSeedOwnedFactory ownedItems;
  final DevSeedOwnedQualityValidator validateOwned;
  final DevSeedTrackingFactory trackingEntries;
  final DevSeedTrackingUnitFactory? trackingUnits;
  final DevSeedWatchSessionFactory? watchSessions;
  final DevSeedCustomEpisodeFactory? customEpisodes;
  final DevSeedDatabaseSeeder? seedDatabase;
}
