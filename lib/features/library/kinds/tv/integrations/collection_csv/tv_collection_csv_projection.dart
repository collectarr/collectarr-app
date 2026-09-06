import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/integrations/collection_csv/tv_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/library/models/library_entry.dart';

/// TV's semantic contribution to the generic collection CSV host.
///
/// TV owns series/release metadata and the Network label. Seasons and
/// episodes remain typed TV hierarchy and are not flattened into generic
/// collection-owned fields.
final class TvCollectionCsvProjection
    implements LibraryCollectionCsvProjection {
  const TvCollectionCsvProjection();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

  @override
  List<String> get clzFriendlyHeader =>
      TvCollectionCsvImportProfile.clzFriendlyHeader;

  @override
  List<String>? importCatalogCells({
    required List<String> header,
    required List<String> values,
  }) {
    return const TvCollectionCsvImportProfile().importCatalogCells(
      header: header,
      values: values,
    );
  }

  @override
  List<String>? importOwnedCells({
    required List<String> header,
    required List<String> values,
  }) {
    return const TvCollectionCsvImportProfile().importOwnedCells(
      header: header,
      values: values,
    );
  }

  @override
  Map<String, List<String>> get columnAliases =>
      TvCollectionCsvImportProfile.columnAliases;

  @override
  List<String> catalogCells(LibraryEntry entry) {
    final catalog = entry.catalogItem;
    final metadata = catalog == null
        ? null
        : TvSeriesMetadata.fromJson({
            ...catalog.toSyncPayload(),
            'id': catalog.id,
            'kind': CatalogMediaKind.tv.apiValue,
          });
    return [
      entry.itemId,
      catalog?.kind ?? '',
      metadata?.title ?? catalog?.title ?? '',
      metadata?.itemNumber ?? '',
      metadata?.variant ?? '',
      '',
      metadata?.physicalFormat ?? '',
      metadata?.physicalFormatLabel ?? '',
      metadata?.publisher ??
          metadata?.network ??
          metadata?.streamingService ??
          metadata?.productionCompanies.firstOrNull ??
          '',
      _formatDate(metadata?.firstAirDate ?? catalog?.releaseDate),
      metadata?.barcode ?? '',
    ];
  }

  @override
  List<String> ownedCellsBeforeQuantity(
    LibraryEntry entry, {
    required bool clzFriendly,
  }) {
    return clzFriendly ? const [''] : const [];
  }

  @override
  List<String> ownedCellsAfterIndex(
    LibraryEntry entry, {
    required bool clzFriendly,
  }) {
    return List<String>.filled(
      clzFriendly
          ? libraryCollectionCsvOwnedCellCount - 1
          : libraryCollectionCsvOwnedCellCount,
      '',
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '';
    final utc = value.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}-'
        '${utc.day.toString().padLeft(2, '0')}';
  }
}
