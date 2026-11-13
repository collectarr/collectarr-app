import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/registry/catalog_kind_transport_codec_defaults.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/data.dart';
import 'package:collectarr_app/features/library/workspace/entry/kind_data.dart';

final class MusicCatalogTransportCodec
    with CatalogKindTransportCodecDefaults<MusicAlbum>
    implements CatalogWorkspaceDataEnricher, CatalogWorkspaceDataBatchEnricher {
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
        subtitle: item.artist,
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
}
