import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_summary_reader.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_derived_data.dart';

/// Explicit schema-v1 transport adapter for one catalog kind.
///
/// This is not a Library domain repository or a generic catalog model. It is
/// the serialization boundary used by sync, admin/transport workflows, and
/// mixed infrastructure that must persist a complete catalog snapshot. Kind
/// code owns the mapping to and from its concrete domain graph.
abstract interface class CatalogKindTransportCodec
    implements CatalogKindSummaryReader {
  Future<int> countCatalogValue(
    LocalDatabase db,
    String semanticName,
    String normalizedValue,
  );

  Future<Map<String, int>> replacementValuesByIds(
    LocalDatabase db,
    Iterable<String> ids,
  );

  Object? typedMetadataFromDto(CatalogItemDto item);

  CatalogKindDerivedData? derivedDataFromDto(CatalogItemDto item);

  Future<void> upsert(LocalDatabase db, CatalogItemDto item);

  Future<List<CatalogItemDto>> list(LocalDatabase db);
}
