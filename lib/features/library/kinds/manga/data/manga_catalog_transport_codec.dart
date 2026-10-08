import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_payload.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_derived_data.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_serial_authority_contributors.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_data.dart';

final class MangaCatalogTransportCodec
    implements CatalogKindTransportCodec<MangaMetadata> {
  const MangaCatalogTransportCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.manga;

  @override
  MangaMetadata decode(CatalogItemDto item) =>
      MangaMetadata.fromJson(catalogTransportPayloadFor(item));

  @override
  MangaMetadata decodeKindData(Map<String, dynamic> kindData) =>
      MangaMetadata.fromJson(kindData);

  @override
  CatalogItemDto encode(String id, MangaMetadata item) => CatalogItemDto.raw(
        id: id,
        mediaKind: kind,
        kindData: item.toJson(),
      );

  @override
  CatalogDisplaySummary summarize(String catalogItemId, MangaMetadata item) =>
      CatalogDisplaySummary.forCatalogItem(
        kind: kind,
        id: catalogItemId,
        primaryLabel: item.title,
        imageUrl: item.thumbnailImageUrl ?? item.coverImageUrl,
      );

  @override
  MangaWorkspaceData workspaceData(CatalogItemDto item) =>
      MangaWorkspaceData(metadata: decode(item));

  @override
  MangaWorkspaceData workspaceDataFromKindData(
    Map<String, dynamic> kindData,
  ) =>
      MangaWorkspaceData(metadata: MangaMetadata.fromJson(kindData));

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
      final value = _replacementValueFromPayload(item);
      if (value != null) result[item.id] = value;
    }
    return result;
  }

  @override
  Future<void> captureDerivedData(
    PickListRepository pickLists,
    SerialAuthorityRepository serialAuthority,
    CatalogItemDto item,
  ) async {
    await captureDerivedDataTyped(pickLists, serialAuthority, decode(item));
  }

  @override
  Future<void> captureDerivedDataTyped(
    PickListRepository pickLists,
    SerialAuthorityRepository serialAuthority,
    MangaMetadata item,
  ) async {
    await captureCatalogKindDerivedData(
      kind: kind,
      derived: _derivedDataFromTyped(item),
      pickLists: pickLists,
      serialAuthority: serialAuthority,
    );
  }

  CatalogKindDerivedData? _derivedDataFromTyped(MangaMetadata item) =>
      catalogDerivedDataFor(
        kind: kind,
        metadata: item,
        pickListContributors: defaultPickListDefinitionContributors,
        serialAuthorityContributors: collectarrSerialAuthorityContributors,
      );

  @override
  Future<List<CatalogItemDto>> listTransport(LocalDatabase db) async {
    return CatalogItemCacheRepository(db).findAll(kind: kind);
  }

  @override
  Future<List<CatalogDisplaySummary>> listSummaries(LocalDatabase db) async {
    return [
      for (final item in await listTransport(db))
        summarize(item.id, decode(item)),
    ];
  }
}

int? _replacementValueFromPayload(CatalogItemDto item) {
  final value = item.kindData['cover_price_cents'];
  return value is num ? value.toInt() : null;
}
