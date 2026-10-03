import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
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
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class MusicCatalogTransportCodec
    implements
        CatalogKindTransportCodec<MusicAlbum>,
        CatalogWorkspaceDataEnricher {
  const MusicCatalogTransportCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  MusicAlbum decode(CatalogItemDto item) =>
      MusicCatalogMapper.mapMetadataItemToMusic(item);

  @override
  Future<void> upsert(LocalDatabase db, MusicAlbum item) {
    return CatalogItemCacheRepository(db).upsert(_projection(item));
  }

  @override
  CatalogDisplaySummary summarize(MusicAlbum item) =>
      CatalogDisplaySummary.root(
        kind: kind,
        id: item.id.value,
        primaryLabel: item.title,
        imageUrl: item.coverImageUrl,
      );

  @override
  MusicWorkspaceCatalogData workspaceData(CatalogItemDto item) =>
      MusicWorkspaceCatalogData.fromMusic(
        decode(item),
        ref: item.catalogRef,
      );

  @override
  Future<LibraryWorkspaceCatalogData> enrichWorkspaceData(
    LocalDatabase db,
    CatalogItemDto item,
    LibraryWorkspaceCatalogData data, {
    LibraryEntryRef? libraryEntryRef,
  }) async {
    if (data is! MusicWorkspaceCatalogData || libraryEntryRef == null) {
      return data;
    }
    final summary =
        await MusicListeningRepository(db).getSummary(libraryEntryRef);
    return data.copyWith(listeningSummary: summary);
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
      metadata: [for (final item in await listTransport(db)) decode(item)],
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
    return [for (final item in items) summarize(decode(item))];
  }
}

int? _replacementValueFromPayload(CatalogItemDto item) {
  final direct = item.payload['cover_price_cents'];
  if (direct is num) return direct.toInt();
  final publishing = item.payload['publishing'];
  final nested = publishing is Map ? publishing['cover_price_cents'] : null;
  return nested is num ? nested.toInt() : null;
}

CatalogItemDto _projection(MusicAlbum item) {
  // The local repository stores discs and tracks in child tables. Rebuild the
  // complete concrete item payload when catalog features need a typed view.
  final payload = Map<String, dynamic>.from(item.toJson())
    ..['id'] = item.id.value
    ..['kind'] = 'music'
    ..['title'] = item.title;
  payload.putIfAbsent(
    'thumbnail_image_url',
    () => item.coverImageUrl,
  );
  final projection = CatalogItemDto.fromJson(payload);
  return projection.withKindData(item);
}
