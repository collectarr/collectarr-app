import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class MusicWorkspaceCatalogData implements LibraryWorkspaceCatalogData {
  MusicWorkspaceCatalogData({
    required this.ref,
    required this.music,
    required this.release,
    this.listeningSummary,
  });

  /// Creates workspace data after the Music transport codec has decoded the
  /// payload. The generic catalog DTO is deliberately not retained here.
  factory MusicWorkspaceCatalogData.fromMusic(
    MusicReleaseGroup music, {
    CatalogEntityRef? ref,
    MusicRelease? release,
    MusicReleaseGroupTrackingSummary? listeningSummary,
  }) {
    return MusicWorkspaceCatalogData(
      ref: ref ??
          CatalogEntityRef(
            kind: CatalogMediaKind.music,
            entityType: CatalogEntityTypeId.root,
            id: music.id.value,
          ),
      music: music,
      release: release,
      listeningSummary: listeningSummary,
    );
  }

  @override
  final CatalogEntityRef ref;
  final MusicReleaseGroup music;
  final MusicRelease? release;
  final MusicReleaseGroupTrackingSummary? listeningSummary;

  MusicWorkspaceCatalogData copyWith({
    MusicReleaseGroupTrackingSummary? listeningSummary,
  }) {
    return MusicWorkspaceCatalogData(
      ref: ref,
      music: music,
      release: release,
      listeningSummary: listeningSummary ?? this.listeningSummary,
    );
  }

  MusicReleaseLookup lookupRelease(String releaseId) {
    for (final release in music.releases) {
      if (release.id.value == releaseId) {
        return MusicReleaseFound(release);
      }
    }
    return MusicReleaseMissing(releaseId);
  }

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;
  @override
  String get title => music.title;
  @override
  String? get synopsis => music.synopsis;
  @override
  DateTime? get releaseDate => release?.releaseDate ?? music.releaseDate;
  @override
  String? get coverImageUrl => release?.coverImageUrl ?? music.coverImageUrl;
  @override
  String? get thumbnailImageUrl =>
      release?.coverImageUrl ?? music.coverImageUrl;
}

sealed class MusicReleaseLookup {
  const MusicReleaseLookup(this.releaseId);

  final String releaseId;
}

final class MusicReleaseFound extends MusicReleaseLookup {
  MusicReleaseFound(this.release) : super(release.id.value);

  final MusicRelease release;
}

final class MusicReleaseMissing extends MusicReleaseLookup {
  const MusicReleaseMissing(super.releaseId);
}

final class MusicReleaseNeedsFetch extends MusicReleaseLookup {
  const MusicReleaseNeedsFetch(super.releaseId);
}
