import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_release_form_values.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_release_group_form_values.dart';

/// Add values for one release group and its first concrete release.
final class MusicAddManualDraft implements LibraryKindAddDraft {
  MusicAddManualDraft({
    MusicReleaseGroupFormValues? releaseGroup,
    MusicReleaseFormValues? release,
    this.year,
  })  : releaseGroup = releaseGroup ?? MusicReleaseGroupFormValues(),
        release = release ?? MusicReleaseFormValues();

  final MusicReleaseGroupFormValues releaseGroup;
  final MusicReleaseFormValues release;
  int? year;

  @override
  void dispose() {}
}
