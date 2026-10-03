import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track_list_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';

/// Fully typed read model used by the Music inspector.
///
/// The generic inspector host still owns navigation and chrome, but Music
/// resolves the concrete album and its contained discs/tracks once here.
final class MusicInspectorViewModel {
  const MusicInspectorViewModel({
    required this.music,
    required this.discs,
    required this.tracks,
    this.entry,
  });

  factory MusicInspectorViewModel.from(LibraryProjectionView item) {
    final catalog = item.source.catalogData is MusicWorkspaceCatalogData
        ? item.source.catalogData! as MusicWorkspaceCatalogData
        : _fallbackMusicCatalog(item.source);

    final music = catalog.music;
    final detailReleases = [music];
    final discs = <MusicDisc>[
      for (final entry in detailReleases) ...entry.discs,
    ];
    final tracks = <MusicTrackListEntry>[
      for (final releaseEntry in detailReleases)
        for (final disc in releaseEntry.discs)
          for (final track in disc.tracks)
            MusicTrackListEntry(
              discNumber: disc.discNumber,
              track: track,
              albumId: releaseEntry.id.value,
              albumTitle: releaseEntry.title,
              catalogNumber: releaseEntry.catalogNumber,
            ),
    ];

    return MusicInspectorViewModel(
      music: music,
      discs: List<MusicDisc>.unmodifiable(discs),
      tracks: List<MusicTrackListEntry>.unmodifiable(tracks),
      entry: MusicLibraryEntryProjection.fromDispatch(
          item.source.libraryEntryDispatch),
    );
  }

  final MusicAlbum music;
  final List<MusicDisc> discs;
  final List<MusicTrackListEntry> tracks;
  final MusicLibraryEntry? entry;

  MusicEntryDiscStorageView storageForDisc(int discNumber) {
    final entryDetails = entry?.personal.details;
    final discId = discs
        .where((disc) => disc.discNumber == discNumber)
        .firstOrNull
        ?.id
        .value;
    final scoped = discId == null ? null : entryDetails?.disc(discId);
    if (scoped != null) {
      return MusicEntryDiscStorageView(
        discNumber: discNumber,
        storageDevice: scoped.storageDevice,
        storageSlot: scoped.storageSlot,
      );
    }
    return MusicEntryDiscStorageView(discNumber: discNumber);
  }
}

MusicWorkspaceCatalogData _fallbackMusicCatalog(
  LibraryWorkspaceSource source,
) {
  final sourceRef = source.catalogRef;
  final rootId = (sourceRef?.kind == CatalogMediaKind.music
          ? sourceRef!.rootScope.id
          : source.itemId)
      .trim();
  final ref = CatalogEntityRef(
    kind: CatalogMediaKind.music,
    entityType: CatalogEntityTypeId.catalogItem,
    id: rootId.isEmpty ? 'unknown-music-item' : rootId,
  );
  return MusicWorkspaceCatalogData.fromMusic(
    MusicAlbum(
      id: MusicAlbumId(ref.id),
      title: source.title,
      coverImageUrl: source.catalogSummary?.imageUrl,
    ),
    ref: ref,
  );
}

final class MusicEntryDiscStorageView {
  const MusicEntryDiscStorageView({
    required this.discNumber,
    this.storageDevice,
    this.storageSlot,
  });

  final int discNumber;
  final String? storageDevice;
  final String? storageSlot;

  String get label {
    final values = [
      if (storageDevice?.trim().isNotEmpty == true) storageDevice!.trim(),
      if (storageSlot?.trim().isNotEmpty == true) storageSlot!.trim(),
    ];
    return values.isEmpty ? '-' : values.join(' / ');
  }
}
