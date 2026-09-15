import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';

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
    final selected =
        release ?? music.primaryRelease ?? _placeholderRelease(music);
    return MusicWorkspaceCatalogData(
      ref: ref ??
          CatalogEntityRef(
            kind: CatalogMediaKind.music,
            entityType: CatalogEntityTypeId.root,
            id: music.id.value,
          ),
      music: music,
      release: selected,
      listeningSummary: listeningSummary,
    );
  }

  @override
  final CatalogEntityRef ref;
  final MusicReleaseGroup music;
  final MusicRelease release;
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

  MusicRelease releaseForSummary(LibraryWorkspaceReleaseSummary summary) {
    for (final release in music.releases) {
      if (release.id.value == summary.id) return release;
    }
    // Release nodes normally come from the same typed graph. A stale
    // structural summary still gets a typed placeholder rather than a second
    // generic DTO rehydration path.
    return MusicRelease(
      id: MusicReleaseId(summary.id),
      releaseGroupId: music.id,
      title: summary.title,
      releaseDate: summary.releaseDate,
      packaging: summary.formatLabel,
    );
  }

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;
  @override
  String get title => music.title;
  @override
  String? get synopsis => music.synopsis;
  @override
  DateTime? get releaseDate => release.releaseDate ?? music.releaseDate;
  @override
  String? get coverImageUrl => release.coverImageUrl ?? music.coverImageUrl;
  @override
  String? get thumbnailImageUrl => release.coverImageUrl ?? music.coverImageUrl;
}

MusicRelease _placeholderRelease(MusicReleaseGroup music) => MusicRelease(
      id: MusicReleaseId('${music.id.value}:release'),
      releaseGroupId: music.id,
      title: music.title,
      releaseDate: music.originalReleaseDate,
      coverImageUrl: music.coverImageUrl,
    );
