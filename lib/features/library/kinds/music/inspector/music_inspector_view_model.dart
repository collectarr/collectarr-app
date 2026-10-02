import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_collection_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track_list_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
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
    this.owned,
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
      owned:
          MusicCollectionItemProjection.fromDispatch(item.source.collectionItemDispatch),
    );
  }

  final MusicAlbum music;
  final List<MusicMedium> mediums;
  final List<MusicTrackListEntry> tracks;
  final MusicCollectionItem? owned;

  MusicOwnedMediumStorageView storageForMedium(int mediumNumber) {
    final ownedDetails = owned?.details;
    final scoped = ownedDetails?.medium(mediumNumber);
    if (scoped != null) {
      return MusicOwnedMediumStorageView(
        mediumNumber: mediumNumber,
        storageDevice: scoped.storageDevice,
        storageSlot: scoped.storageSlot,
      );
    }
    return MusicOwnedMediumStorageView(mediumNumber: mediumNumber);
  }

  List<MusicMatrixRunoutView> matrixForMedium(int mediumNumber) {
    final runouts = owned?.details.matrixRunoutsForMedium(mediumNumber) ??
        const <MusicMatrixRunout>[];
    return [
      for (final runout in runouts)
        MusicMatrixRunoutView(
          mediumNumber: mediumNumber,
          side: runout.side,
          text: runout.runoutText,
        ),
    ];
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

final class MusicOwnedMediumStorageView {
  const MusicOwnedMediumStorageView({
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

final class MusicMatrixRunoutView {
  const MusicMatrixRunoutView({
    required this.mediumNumber,
    required this.side,
    required this.text,
  });

  final int mediumNumber;
  final String side;
  final String text;
}
