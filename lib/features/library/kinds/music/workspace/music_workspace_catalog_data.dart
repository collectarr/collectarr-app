import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

/// Music workspace data for one concrete album item.
///
/// Discs and tracks remain contained under [music].
final class MusicWorkspaceCatalogData implements LibraryWorkspaceCatalogData {
  MusicWorkspaceCatalogData({
    required this.ref,
    required this.music,
    this.listeningSummary,
  });

  factory MusicWorkspaceCatalogData.fromMusic(
    MusicAlbum music, {
    CatalogEntityRef? ref,
    MusicCatalogItemListeningSummary? listeningSummary,
  }) {
    return MusicWorkspaceCatalogData(
      ref: ref ??
          CatalogEntityRef(
            kind: CatalogMediaKind.music,
            entityType: CatalogEntityTypeId.root,
            id: music.id.value,
          ),
      music: music,
      listeningSummary: listeningSummary,
    );
  }

  @override
  final CatalogEntityRef ref;
  final MusicAlbum music;
  final MusicCatalogItemListeningSummary? listeningSummary;

  MusicWorkspaceCatalogData copyWith({
    MusicCatalogItemListeningSummary? listeningSummary,
  }) =>
      MusicWorkspaceCatalogData(
        ref: ref,
        music: music,
        listeningSummary: listeningSummary ?? this.listeningSummary,
      );

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;
  @override
  String get title => music.title;
  @override
  DateTime? get releaseDate => music.releaseDate;
  @override
  String? get coverImageUrl => music.coverImageUrl;
  @override
  String? get thumbnailImageUrl =>
      music.thumbnailImageUrl ?? music.coverImageUrl;
}
