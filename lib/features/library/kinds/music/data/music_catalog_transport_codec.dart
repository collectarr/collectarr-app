import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_derived_data.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_serial_authority_contributors.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';

final class MusicCatalogTransportCodec
    implements
        CatalogKindTransportCodec<MusicAlbum>,
        CatalogWorkspaceDataEnricher,
        CatalogWorkspaceDataBatchEnricher {
  const MusicCatalogTransportCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  MusicAlbum decode(CatalogItemDto item) =>
      MusicCatalogMapper.mapMetadataItemToMusic(item);

  @override
  MusicAlbum decodeKindData(Map<String, dynamic> kindData) =>
      MusicAlbum.fromJson(kindData);

  @override
  CatalogItemDto encode(String id, MusicAlbum item) =>
      MusicCatalogMapper.toCatalogItemDto(
        item,
        ref: CatalogItemRef(kind: kind, id: id),
      );

  @override
  CatalogDisplaySummary summarize(String catalogItemId, MusicAlbum item) =>
      CatalogDisplaySummary.forCatalogItem(
        kind: kind,
        id: catalogItemId,
        primaryLabel: item.title,
        imageUrl: item.coverImageUrl,
      );

  @override
  MusicWorkspaceData workspaceData(CatalogItemDto item) =>
      MusicWorkspaceData.fromMusic(decode(item));

  @override
  MusicWorkspaceData workspaceDataFromKindData(
    Map<String, dynamic> kindData,
  ) =>
      MusicWorkspaceData.fromMusic(MusicAlbum.fromJson(kindData));

  @override
  Future<LibraryWorkspaceKindData> enrichWorkspaceData(
    LocalDatabase db,
    LibraryWorkspaceKindData data, {
    LibraryEntryRef? libraryEntryRef,
  }) async {
    if (data is! MusicWorkspaceData || libraryEntryRef == null) {
      return data;
    }
    final summary =
        await MusicListeningRepository(db).getSummary(libraryEntryRef);
    return data.copyWith(listeningSummary: summary);
  }

  @override
  Future<Map<LibraryEntryRef, LibraryWorkspaceKindData>>
      enrichWorkspaceDataForEntries(
    LocalDatabase db,
    Map<LibraryEntryRef, LibraryWorkspaceKindData> dataByEntry,
  ) async {
    final summaries =
        await MusicListeningRepository(db).getSummaries(dataByEntry.keys);
    return {
      for (final entry in dataByEntry.entries)
        entry.key: entry.value is MusicWorkspaceData
            ? (entry.value as MusicWorkspaceData).copyWith(
                listeningSummary: summaries[entry.key],
              )
            : entry.value,
    };
  }

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
    MusicAlbum item,
  ) async {
    await captureCatalogKindDerivedData(
      kind: kind,
      derived: _derivedDataFromTyped(item),
      pickLists: pickLists,
      serialAuthority: serialAuthority,
    );
  }

  CatalogKindDerivedData? _derivedDataFromTyped(MusicAlbum item) =>
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
    final items = await listTransport(db);
    return [
      for (final item in items) summarize(item.id, decode(item)),
    ];
  }
}

int? _replacementValueFromPayload(CatalogItemDto item) {
  final value = item.kindData['cover_price_cents'];
  return value is num ? value.toInt() : null;
}
