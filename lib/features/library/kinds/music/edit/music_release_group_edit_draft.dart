import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_release_group_form_values.dart';

/// Edit session for release-group fields and its artwork/link tabs.
final class MusicReleaseGroupEditDraft {
  MusicReleaseGroupEditDraft.fromReleaseGroup(MusicReleaseGroup group)
      : original = group,
        values = MusicReleaseGroupFormValues.fromGroup(group),
        externalLinks = List<MusicExternalLink>.from(group.externalLinks),
        localCoverImagePath = group.localCoverImagePath,
        localBackImagePath = group.localBackImagePath,
        localThumbnailImagePath = group.localThumbnailImagePath;

  final MusicReleaseGroup original;
  final MusicReleaseGroupFormValues values;
  List<MusicExternalLink> externalLinks;
  String? localCoverImagePath;
  String? localBackImagePath;
  String? localThumbnailImagePath;

  MusicReleaseGroup toReleaseGroup() => MusicReleaseGroupFormAdapter.update(
        original,
        values,
        externalLinks: externalLinks,
        localCoverImagePath: localCoverImagePath,
        localBackImagePath: localBackImagePath,
        localThumbnailImagePath: localThumbnailImagePath,
      );
}
