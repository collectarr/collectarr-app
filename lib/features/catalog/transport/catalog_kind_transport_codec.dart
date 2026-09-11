import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_summary_reader.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';

/// Non-generic transport operations that the mixed catalog composition root
/// may invoke after dispatching by [kind].
///
/// This interface deliberately contains behavior, not a type-erased catalog
/// value. The generic codec below remains the concrete kind implementation;
/// registries store only this boundary interface.
abstract interface class CatalogKindTransportBoundary
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

  Future<void> captureDerivedData(
    PickListRepository pickLists,
    SerialAuthorityRepository serialAuthority,
    CatalogItemDto item,
  );

  Future<void> upsertTransport(LocalDatabase db, CatalogItemDto item);

  Future<List<CatalogItemDto>> listTransport(LocalDatabase db);
}

/// Explicit schema-v1 transport adapter for one catalog kind.
///
/// This is not a Library domain repository or a generic catalog model. It is
/// the serialization boundary used by sync, admin/transport workflows, and
/// mixed infrastructure that must persist a complete catalog snapshot. Kind
/// code owns the mapping to and from its concrete domain graph.
abstract interface class CatalogKindTransportCodec<TCatalog>
    implements CatalogKindTransportBoundary {
  /// Decodes the transport boundary into the owning kind's concrete domain.
  ///
  /// Generic catalog orchestration must not inspect the returned value. The
  /// generated registry may invoke this method at the dispatch boundary, but
  /// the concrete codec owns all interpretation of the DTO.
  TCatalog decode(CatalogItemDto item);

  /// Persists a value that has already been decoded by this kind.
  Future<void> upsert(LocalDatabase db, TCatalog item);

  /// Projects a concrete kind value for mixed/global read models.
  CatalogDisplaySummary summarize(TCatalog item);
}
