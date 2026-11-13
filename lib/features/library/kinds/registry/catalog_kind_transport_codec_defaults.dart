import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_derived_data.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_serial_authority_contributors.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';

/// Transport operations every kind runs the same way over the shared item
/// cache. A kind codec keeps its own decoding, encoding and summary.
mixin CatalogKindTransportCodecDefaults<TCatalog extends JsonEncodable>
    implements CatalogKindTransportCodec<TCatalog> {
  @override
  Future<Map<String, int>> countCatalogValues(
    LocalDatabase db,
    String listName,
    Iterable<String> normalizedValues,
  ) async {
    final contributor = defaultPickListDefinitionContributors.singleWhere(
      (contributor) => contributor.kind == kind,
    );
    return countPickListCatalogValuesByValue(
      contributor: contributor,
      listName: listName,
      metadata: await listCatalogAndEntryMetadata(db),
      normalizedValues: normalizedValues,
    );
  }

  @override
  Future<Map<String, int>> replacementValuesByIds(
    LocalDatabase db,
    Iterable<String> ids,
  ) async {
    final wanted = ids.toSet();
    if (wanted.isEmpty) return const {};
    final result = <String, int>{};
    for (final item in await listTransport(db)) {
      if (!wanted.contains(item.id)) continue;
      final value = item.kindData['cover_price_cents'];
      if (value is num) result[item.id] = value.toInt();
    }
    return result;
  }

  @override
  Future<void> captureDerivedData(
    PickListRepository pickLists,
    SerialAuthorityRepository serialAuthority,
    CatalogItemDto item,
  ) =>
      captureDerivedDataTyped(pickLists, serialAuthority, decode(item));

  @override
  Future<void> captureDerivedDataTyped(
    PickListRepository pickLists,
    SerialAuthorityRepository serialAuthority,
    TCatalog item,
  ) =>
      captureCatalogKindDerivedData(
        kind: kind,
        derived: catalogDerivedDataFor(
          kind: kind,
          metadata: item,
          pickListContributors: defaultPickListDefinitionContributors,
          serialAuthorityContributors: collectarrSerialAuthorityContributors,
        ),
        pickLists: pickLists,
        serialAuthority: serialAuthority,
      );

  @override
  Future<List<CatalogItemDto>> listTransport(LocalDatabase db) =>
      CatalogItemCacheRepository(db).findAll(kind: kind);

  @override
  Future<List<CatalogDisplaySummary>> listSummaries(LocalDatabase db) async => [
        for (final item in await listTransport(db))
          summarize(item.id, decode(item)),
      ];
}
