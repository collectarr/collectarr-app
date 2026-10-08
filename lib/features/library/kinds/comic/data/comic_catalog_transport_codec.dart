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
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_data.dart';

final class ComicCatalogTransportCodec
    implements CatalogKindTransportCodec<ComicCatalogItem> {
  const ComicCatalogTransportCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  ComicCatalogItem decode(CatalogItemDto item) =>
      ComicCatalogItem.fromJson(catalogTransportPayloadFor(item));

  @override
  ComicCatalogItem decodeKindData(Map<String, dynamic> kindData) =>
      ComicCatalogItem.fromJson(kindData);

  @override
  CatalogItemDto encode(String id, ComicCatalogItem item) => CatalogItemDto.raw(
        id: id,
        mediaKind: kind,
        kindData: item.toJson(),
      );

  @override
  CatalogDisplaySummary summarize(
          String catalogItemId, ComicCatalogItem item) =>
      _comicSummary(catalogItemId, item);

  @override
  ComicWorkspaceData workspaceData(CatalogItemDto item) =>
      ComicWorkspaceData(comic: decode(item));

  @override
  ComicWorkspaceData workspaceDataFromKindData(
    Map<String, dynamic> kindData,
  ) =>
      ComicWorkspaceData(comic: ComicCatalogItem.fromJson(kindData));

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
    ComicCatalogItem item,
  ) async {
    await captureCatalogKindDerivedData(
      kind: kind,
      derived: _derivedDataFromTyped(item),
      pickLists: pickLists,
      serialAuthority: serialAuthority,
    );
  }

  CatalogKindDerivedData? _derivedDataFromTyped(ComicCatalogItem item) =>
      catalogDerivedDataFor(
        kind: kind,
        metadata: item,
        pickListContributors: defaultPickListDefinitionContributors,
        serialAuthorityContributors: collectarrSerialAuthorityContributors,
      );

  @override
  Future<List<CatalogItemDto>> listTransport(LocalDatabase db) =>
      CatalogItemCacheRepository(db).findAll(kind: kind);

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

CatalogDisplaySummary _comicSummary(
    String catalogItemId, ComicCatalogItem item) {
  final issue = item.issueNumber?.trim();
  return CatalogDisplaySummary.forCatalogItem(
    kind: CatalogMediaKind.comic,
    id: catalogItemId,
    primaryLabel:
        issue == null || issue.isEmpty ? item.title : '${item.title} #$issue',
    imageUrl: item.thumbnailImageUrl ?? item.coverImageUrl,
  );
}
