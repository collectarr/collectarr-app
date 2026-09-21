import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

/// Structural values shared by the three Music workspace entities.
///
/// This is intentionally an interface, not an entity DTO. Each workspace
/// scope below has its own concrete projection and its own projector.
abstract interface class MusicWorkspaceProjection
    implements LibraryWorkspaceDto {
  WorkspaceCommonProjection get common;
  PersonalCopyProjection get personal;
  MusicReleaseGroup get music;
  MusicRelease? get release;
  MusicReleaseGroupTrackingSummary? get groupListeningSummary;

  String? get synopsis;
  String? get currency;
  String? get artist;
  String? get catalogNumber;
  String? get format;
  String? get referenceFormatLabel;
  String? get releaseType;
  String? get packaging;
  String? get boxSet;
  String? get publisher;
  String? get genre;
  int? get releaseCount;
  DateTime? get releaseDate;
  String? get identifierCode;
  String? get barcode;
  String? get country;
  String? get language;
  MusicReleaseGroupTrackingSummary? get listeningSummary;
  int? get aggregateListenCount;
  int? get listenedReleaseCount;
  DateTime? get aggregateLastListened;
  MusicReleaseTrackingSummary? get releaseListeningSummary;
  int? get listenCount;
  DateTime? get lastListened;
  int? get discCount;
  int? get trackCount;
  String? get releaseStatus;
  bool? get isLive;
  List<String> get genres;
  List<Map<String, dynamic>> get credits;
}

/// Presentation values shared by entity projections without introducing a
/// semantic Music base entity.
abstract class MusicWorkspaceProjectionValues
    implements MusicWorkspaceProjection {
  MusicWorkspaceProjectionValues({
    required this.common,
    required this.personal,
    required this.music,
    required this.release,
    this.groupListeningSummary,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  @override
  final MusicReleaseGroup music;
  @override
  final MusicRelease? release;
  @override
  final MusicReleaseGroupTrackingSummary? groupListeningSummary;

  @override
  String get title => common.title;

  @override
  String? get synopsis => common.synopsis;

  @override
  String? get currency => common.currency;

  @override
  String? get artist => music.artist ?? _releaseArtist;

  @override
  String? get catalogNumber => release?.catalogNumber;

  @override
  String? get format =>
      release?.mediums.firstOrNull?.mediumType ?? release?.releaseType;

  @override
  String? get referenceFormatLabel => format;

  @override
  String? get releaseType => release?.releaseType;

  @override
  String? get packaging => release?.packaging;

  @override
  String? get boxSet => release?.boxSetTitle;

  @override
  String? get publisher => release?.publisher;

  @override
  String? get genre => music.genres.isEmpty ? null : music.genres.join(', ');

  @override
  int? get releaseCount => music.releases.length;

  @override
  DateTime? get releaseDate => release?.releaseDate;

  @override
  String? get identifierCode => release?.barcode ?? release?.upc;

  @override
  String? get barcode => identifierCode;

  @override
  String? get country => release?.countryCode;

  @override
  String? get language => release?.language;

  @override
  MusicReleaseGroupTrackingSummary? get listeningSummary =>
      groupListeningSummary;

  @override
  int? get aggregateListenCount => listeningSummary?.totalListenCount;

  @override
  int? get listenedReleaseCount => listeningSummary?.listenedReleaseCount;

  @override
  DateTime? get aggregateLastListened => listeningSummary?.lastListened;

  @override
  MusicReleaseTrackingSummary? get releaseListeningSummary {
    final summary = listeningSummary;
    final release = this.release;
    if (summary == null || release == null) return null;
    for (final entry in summary.releaseBreakdown) {
      if (entry.releaseId == release.id.value) return entry;
    }
    return null;
  }

  @override
  int? get listenCount =>
      releaseListeningSummary?.listenCount ??
      (release == null ? listeningSummary?.totalListenCount : null);

  @override
  DateTime? get lastListened =>
      releaseListeningSummary?.lastListened ??
      (release == null ? listeningSummary?.lastListened : null);

  @override
  String? get coverImageUrl => release?.coverImageUrl ?? common.coverImageUrl;

  @override
  int? get discCount {
    final release = this.release;
    return release == null || release.mediums.isEmpty
        ? null
        : release.mediums.length;
  }

  @override
  int? get trackCount {
    final release = this.release;
    return release?.tracks.isNotEmpty == true
        ? release!.tracks.length
        : music.trackCount;
  }

  @override
  String? get releaseStatus => release?.releaseStatus;

  @override
  bool? get isLive => music.isLive;

  @override
  List<String> get genres => music.genres;

  @override
  List<Map<String, dynamic>> get credits => [
        for (final contribution
            in release?.contributions ?? const <MusicReleaseContribution>[])
          contribution.toJson(),
      ];

  @override
  Iterable<String> get searchTokens => [
        if (artist != null) artist!,
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
        if (catalogNumber != null) catalogNumber!,
        ...genres,
      ];

  String? get _releaseArtist {
    final release = this.release;
    if (release == null) return null;
    for (final contribution in release.contributions) {
      final role = contribution.role.trim().toLowerCase();
      if (!(role.contains('artist') ||
          role.contains('performer') ||
          role.contains('musician') ||
          role.contains('band'))) {
        continue;
      }
      final name = contribution.displayName?.trim();
      if (name != null && name.isNotEmpty) return name;
    }
    return null;
  }
}

final class MusicReleaseGroupWorkspaceDto
    extends MusicWorkspaceProjectionValues {
  MusicReleaseGroupWorkspaceDto({
    required super.common,
    required super.personal,
    required super.music,
    required super.release,
    super.groupListeningSummary,
  });
}

final class MusicReleaseWorkspaceDto extends MusicWorkspaceProjectionValues {
  MusicReleaseWorkspaceDto({
    required super.common,
    required super.personal,
    required super.music,
    required super.release,
    super.groupListeningSummary,
  });
}

final class MusicOwnedCopyWorkspaceDto extends MusicWorkspaceProjectionValues {
  MusicOwnedCopyWorkspaceDto({
    required super.common,
    required super.personal,
    required super.music,
    required super.release,
    super.groupListeningSummary,
  });
}
