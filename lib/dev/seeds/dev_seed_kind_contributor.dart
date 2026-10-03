import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
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
typedef DevSeedLibraryEntrySummaryFactory = List<LibraryEntrySummary> Function(
  DateTime now,
);
typedef DevSeedEntryQualityValidator = List<String> Function(DateTime now);
typedef DevSeedEntrySeeder = Future<void> Function(
  LocalDatabase db,
  DateTime now,
);
typedef DevSeedTrackingFactory = List<TrackingStorageRecord> Function(
    DateTime now);
typedef DevSeedTrackingUnitFactory = Iterable<TrackingUnitSummary> Function(
  Iterable<CatalogItemDto> items,
  DateTime now,
);
typedef DevSeedWatchSessionFactory = List<WatchSession> Function(DateTime now);
typedef DevSeedDatabaseSeeder = Future<void> Function(
  LocalDatabase db,
  Iterable<CatalogItemDto> items,
  DateTime now,
);

/// Kind-entry defaults used only while enriching development catalog fixtures.
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

/// The complete development-fixture contribution entry by one library kind.
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
  DevSeedLibraryEntrySummaryFactory get entrySummaries;
  DevSeedEntryQualityValidator get validateEntry;
  DevSeedEntrySeeder get seedEntry;
  DevSeedTrackingFactory get trackingRecords;
  DevSeedTrackingUnitFactory? get trackingUnits;
  DevSeedWatchSessionFactory? get watchSessions;
  DevSeedDatabaseSeeder? get seedDatabase;
}

/// Typed implementation used by every concrete kind seed.
///
/// The generated contributor registry is necessarily heterogeneous, so it
/// exposes the small [DevSeedKindContributor] interface. The only erased
/// boundary is this adapter; the seed declarations and validators remain
/// concrete and cannot accidentally validate the wrong Entry model.
final class TypedDevSeedKindContributor<TLibraryEntry extends Object>
    implements DevSeedKindContributor {
  const TypedDevSeedKindContributor({
    required this.kind,
    required this.catalogDefaults,
    required this.catalogItems,
    required this.enrichItem,
    required this.validateCatalog,
    required this.validateCatalogGraph,
    required this.validateBarcode,
    required this.libraryEntriesTyped,
    required this.libraryEntrySummaryTyped,
    required this.validateEntryTyped,
    required this.trackingRecords,
    this.trackingUnits,
    this.watchSessions,
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
  final List<TLibraryEntry> Function(DateTime now) libraryEntriesTyped;
  final LibraryEntrySummary Function(TLibraryEntry item)
      libraryEntrySummaryTyped;
  final List<String> Function(TLibraryEntry item) validateEntryTyped;
  @override
  final DevSeedTrackingFactory trackingRecords;
  @override
  final DevSeedTrackingUnitFactory? trackingUnits;
  @override
  final DevSeedWatchSessionFactory? watchSessions;
  @override
  final DevSeedDatabaseSeeder? seedDatabase;

  @override
  DevSeedLibraryEntrySummaryFactory get entrySummaries => (now) {
        return libraryEntriesTyped(now).map(libraryEntrySummaryTyped).toList(
              growable: false,
            );
      };

  @override
  DevSeedEntryQualityValidator get validateEntry => (now) {
        final issues = <String>[];
        for (final item in libraryEntriesTyped(now)) {
          issues.addAll(validateEntryTyped(item));
        }
        return issues;
      };

  @override
  DevSeedEntrySeeder get seedEntry => (database, now) async {
        final cache = CatalogItemCacheRepository(database);
        final store = LibraryEntryStore(database);
        for (final value in libraryEntriesTyped(now)) {
          if (value is! JsonEncodable) {
            throw StateError(
              'The ${kind.apiValue} seed entry must expose its JSON record.',
            );
          }
          final payload = value.toJson();
          final rawSource = payload['source_catalog_ref'];
          if (rawSource is! Map) {
            throw FormatException(
              'The ${kind.apiValue} seed entry is missing source_catalog_ref.',
            );
          }
          final source = CatalogItemRef.fromJson(
            Map<String, Object?>.from(rawSource),
          );
          if (source.kind != kind) {
            throw FormatException(
              'The ${kind.apiValue} seed entry references a different kind.',
            );
          }
          final catalogItem = await cache.find(source);
          if (catalogItem == null) {
            throw StateError(
              'The ${kind.apiValue} seed entry references missing catalog '
              'item ${source.id}.',
            );
          }
          await store.putKindJson(kind, {
            ...payload,
            'kind': kind.apiValue,
            'catalog_data': catalogItem.kindData,
          });
        }
      };
}
