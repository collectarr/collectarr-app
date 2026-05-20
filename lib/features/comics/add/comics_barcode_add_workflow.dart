import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';

Future<CatalogItem> addComicByBarcodeToCollection({
  required ApiClient api,
  required CatalogCacheRepository catalog,
  required CollectionMutations mutations,
  required String barcode,
  LibraryTypeConfig type = comicsLibraryConfig,
}) async {
  final item = await lookupLibraryBarcode(
    api,
    type,
    barcode,
  );
  await catalog.upsertAll([item]);
  await mutations.addItem(
    item.id,
    condition: 'Near Mint',
    grade: 'Ungraded',
  );
  return item;
}
