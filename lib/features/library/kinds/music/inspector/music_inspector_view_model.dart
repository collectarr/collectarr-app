import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
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
    required this.mediums,
    required this.tracks,
    this.entry,
  });

  factory MusicInspectorViewModel.from(LibraryProjectionView item) {
    final catalog = item.source.catalogData is MusicWorkspaceCatalogData
        ? item.source.catalogData! as MusicWorkspaceCatalogData
        : _fallbackMusicCatalog(item.source);

    final music = catalog.music;
    final detailReleases = [music];
    final mediums = <MusicMedium>[
      for (final entry in detailReleases) ...entry.mediums,
    ];
    final tracks = <MusicTrackListEntry>[
      for (final releaseEntry in detailReleases)
        for (final medium in releaseEntry.mediums)
          for (final track in medium.tracks)
            MusicTrackListEntry(
              mediumNumber: medium.mediumNumber,
              track: track,
              albumId: releaseEntry.id.value,
              releaseTitle: releaseEntry.title,
              catalogNumber: releaseEntry.catalogNumber,
            ),
    ];

    return MusicInspectorViewModel(
      music: music,
      mediums: List<MusicMedium>.unmodifiable(mediums),
      tracks: List<MusicTrackListEntry>.unmodifiable(tracks),
      entry: MusicLibraryEntryProjection.fromDispatch(
          item.source.libraryEntryDispatch),
    );
  }

  final MusicAlbum music;
  final List<MusicMedium> mediums;
  final List<MusicTrackListEntry> tracks;
  final MusicLibraryEntry? entry;

  MusicEntryMediumStorageView storageForMedium(int mediumNumber) {
    final entryDetails = entry?.details;
    final mediumId = mediums
        .where((medium) => medium.mediumNumber == mediumNumber)
        .firstOrNull
        ?.id
        .value;
    final scoped = mediumId == null ? null : entryDetails?.medium(mediumId);
    if (scoped != null) {
      return MusicEntryMediumStorageView(
        mediumNumber: mediumNumber,
        storageDevice: scoped.storageDevice,
        storageSlot: scoped.storageSlot,
      );
    }
    return MusicEntryMediumStorageView(mediumNumber: mediumNumber);
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

final class MusicEntryMediumStorageView {
  const MusicEntryMediumStorageView({
    required this.mediumNumber,
    this.storageDevice,
    this.storageSlot,
  });

  final int mediumNumber;
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
