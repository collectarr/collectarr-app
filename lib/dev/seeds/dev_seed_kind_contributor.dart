import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/models/watch_session.dart';

typedef DevSeedCatalogFactory = List<CatalogItemDto> Function();
typedef DevSeedItemEnricher = CatalogItemDto Function(CatalogItemDto item);
typedef DevSeedCatalogPayloadEnricher = void Function(
  CatalogItemDto item,
  Map<String, dynamic> payload,
);
typedef DevSeedCatalogQualityValidator = List<String> Function(
  CatalogItemDto item,
);
typedef DevSeedCatalogBarcodeValidator = void Function(
  List<String> issues,
  String prefix,
  String? barcode,
);
typedef DevSeedCatalogGraphValidator = List<String> Function(
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

/// Kind-owned defaults used only while enriching development catalog fixtures.
///
/// Keeping these values with each contributor prevents the generic seed
/// runner from becoming a semantic switchboard for all kinds.
final class DevSeedCatalogDefaults {
  const DevSeedCatalogDefaults({
    required this.includePublishingDetails,
    required this.paperType,
    required this.originalLanguage,
    required this.pageCount,
    required this.coverPriceCents,
    required this.runtimeMinutes,
    required this.ageRating,
    required this.audienceRating,
    required this.enrichPayload,
  });

  final bool includePublishingDetails;
  final String? paperType;
  final String originalLanguage;
  final int pageCount;
  final int coverPriceCents;
  final int runtimeMinutes;
  final String ageRating;
  final String audienceRating;
  final DevSeedCatalogPayloadEnricher enrichPayload;
}

/// The complete development-fixture contribution owned by one library kind.
///
/// This is a dev-only composition contract. It keeps fixture construction
/// typed while allowing the seed entry point to remain unaware of concrete
/// kind repositories and tracking models.
final class DevSeedKindContributor {
  const DevSeedKindContributor({
    required this.kind,
    required this.catalogDefaults,
    required this.catalogItems,
    required this.enrichItem,
    required this.validateCatalog,
    required this.validateCatalogGraph,
    required this.validateBarcode,
    required this.ownedItems,
    required this.validateOwned,
    required this.trackingEntries,
    this.trackingUnits,
    this.watchSessions,
    this.customEpisodes,
    this.seedDatabase,
  });

  final String kind;
  final DevSeedCatalogDefaults catalogDefaults;
  final DevSeedCatalogFactory catalogItems;
  final DevSeedItemEnricher enrichItem;
  final DevSeedCatalogQualityValidator validateCatalog;
  final DevSeedCatalogGraphValidator validateCatalogGraph;
  final DevSeedCatalogBarcodeValidator validateBarcode;
  final DevSeedOwnedFactory ownedItems;
  final DevSeedOwnedQualityValidator validateOwned;
  final DevSeedTrackingFactory trackingEntries;
  final DevSeedTrackingUnitFactory? trackingUnits;
  final DevSeedWatchSessionFactory? watchSessions;
  final DevSeedCustomEpisodeFactory? customEpisodes;
  final DevSeedDatabaseSeeder? seedDatabase;
}
