import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';
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
typedef DevSeedOwnedFactory = List<Object> Function(DateTime now);
typedef DevSeedOwnedQualityValidator = List<String> Function(Object item);
typedef DevSeedTrackingFactory = List<TrackingLifecycle> Function(DateTime now);
typedef DevSeedTrackingUnitFactory = Iterable<TrackingUnitSummary> Function(
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
abstract interface class DevSeedKindContributor {
  CatalogMediaKind get kind;
  DevSeedCatalogDefaults get catalogDefaults;
  DevSeedCatalogFactory get catalogItems;
  DevSeedItemEnricher get enrichItem;
  DevSeedCatalogQualityValidator get validateCatalog;
  DevSeedCatalogGraphValidator get validateCatalogGraph;
  DevSeedCatalogBarcodeValidator get validateBarcode;
  DevSeedOwnedFactory get ownedItems;
  DevSeedOwnedQualityValidator get validateOwned;
  DevSeedTrackingFactory get trackingLifecycles;
  DevSeedTrackingUnitFactory? get trackingUnits;
  DevSeedWatchSessionFactory? get watchSessions;
  DevSeedCustomEpisodeFactory? get customEpisodes;
  DevSeedDatabaseSeeder? get seedDatabase;
}

/// Typed implementation used by every concrete kind seed.
///
/// The generated contributor registry is necessarily heterogeneous, so it
/// exposes the small [DevSeedKindContributor] interface. The only erased
/// boundary is this adapter; the seed declarations and validators remain
/// concrete and cannot accidentally validate the wrong Owned model.
final class TypedDevSeedKindContributor<TOwned extends Object>
    implements DevSeedKindContributor {
  const TypedDevSeedKindContributor({
    required this.kind,
    required this.catalogDefaults,
    required this.catalogItems,
    required this.enrichItem,
    required this.validateCatalog,
    required this.validateCatalogGraph,
    required this.validateBarcode,
    required this.ownedItemsTyped,
    required this.validateOwnedTyped,
    required this.trackingLifecycles,
    this.trackingUnits,
    this.watchSessions,
    this.customEpisodes,
    this.seedDatabase,
  });

  @override
  final CatalogMediaKind kind;
  @override
  final DevSeedCatalogDefaults catalogDefaults;
  @override
  final DevSeedCatalogFactory catalogItems;
  @override
  final DevSeedItemEnricher enrichItem;
  @override
  final DevSeedCatalogQualityValidator validateCatalog;
  @override
  final DevSeedCatalogGraphValidator validateCatalogGraph;
  @override
  final DevSeedCatalogBarcodeValidator validateBarcode;
  final List<TOwned> Function(DateTime now) ownedItemsTyped;
  final List<String> Function(TOwned item) validateOwnedTyped;
  @override
  final DevSeedTrackingFactory trackingLifecycles;
  @override
  final DevSeedTrackingUnitFactory? trackingUnits;
  @override
  final DevSeedWatchSessionFactory? watchSessions;
  @override
  final DevSeedCustomEpisodeFactory? customEpisodes;
  @override
  final DevSeedDatabaseSeeder? seedDatabase;

  @override
  DevSeedOwnedFactory get ownedItems => (now) {
        return List<Object>.of(ownedItemsTyped(now));
      };

  @override
  DevSeedOwnedQualityValidator get validateOwned => (item) {
        if (item is! TOwned) {
          throw StateError(
            'Seed ${kind.apiValue} received an Owned item of type '
            '${item.runtimeType}; expected $TOwned',
          );
        }
        return validateOwnedTyped(item);
      };
}
