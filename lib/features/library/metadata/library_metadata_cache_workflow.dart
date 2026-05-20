import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';

typedef LibraryBarcodeLookupResultCallback = void Function(
  LibraryBarcodeLookupResult result,
);

class LibraryMetadataSearchInput {
  const LibraryMetadataSearchInput({
    this.query,
    this.series,
    this.issueNumber,
    this.publisher,
    this.year,
    this.barcode,
    this.limit,
  });

  final String? query;
  final String? series;
  final String? issueNumber;
  final String? publisher;
  final int? year;
  final String? barcode;
  final int? limit;

  bool get isEmpty {
    return _isBlank(query) &&
        _isBlank(series) &&
        _isBlank(issueNumber) &&
        _isBlank(publisher) &&
        _isBlank(barcode) &&
        year == null;
  }

  bool _isBlank(String? value) {
    return value == null || value.trim().isEmpty;
  }
}

class LibraryBarcodeLookupResult {
  const LibraryBarcodeLookupResult.found({
    required this.barcode,
    required CatalogItem this.item,
  }) : error = null;

  const LibraryBarcodeLookupResult.missing({
    required this.barcode,
    required Object this.error,
  }) : item = null;

  final String barcode;
  final CatalogItem? item;
  final Object? error;

  bool get found => item != null;
}

Future<List<CatalogItem>> searchAndCacheLibraryMetadata({
  required ApiClient api,
  required LibraryTypeConfig type,
  required CatalogCacheRepository catalog,
  required LibraryMetadataSearchInput input,
}) async {
  final items = await searchLibraryMetadata(
    api,
    type,
    query: input.query,
    series: input.series,
    issueNumber: input.issueNumber,
    publisher: input.publisher,
    year: input.year,
    barcode: input.barcode,
    limit: input.limit,
  );
  await catalog.upsertAll(items);
  return items;
}

Future<List<LibraryBarcodeLookupResult>> lookupAndCacheLibraryBarcodes({
  required ApiClient api,
  required LibraryTypeConfig type,
  required CatalogCacheRepository catalog,
  required Iterable<String> barcodes,
  LibraryBarcodeLookupResultCallback? onResult,
}) async {
  final results = <LibraryBarcodeLookupResult>[];
  final foundItems = <CatalogItem>[];
  for (final barcode in barcodes) {
    try {
      final item = await lookupLibraryBarcode(api, type, barcode);
      foundItems.add(item);
      final result = LibraryBarcodeLookupResult.found(
        barcode: barcode,
        item: item,
      );
      results.add(result);
      onResult?.call(result);
    } catch (error) {
      final result = LibraryBarcodeLookupResult.missing(
        barcode: barcode,
        error: error,
      );
      results.add(result);
      onResult?.call(result);
    }
  }
  await catalog.upsertAll(foundItems);
  return results;
}
