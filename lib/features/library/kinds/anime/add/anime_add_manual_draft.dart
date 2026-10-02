import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/forms/anime_catalog_form_values.dart';

final class AnimeAddManualDraft implements LibraryKindAddDraft {
  AnimeAddManualDraft({
    AnimeMediaFormValues? media,
    AnimeReleaseFormValues? release,
    this.catalogTitle = '',
  })  : media = media ?? AnimeMediaFormValues(),
        release = release ?? AnimeReleaseFormValues();

  final AnimeMediaFormValues media;
  final AnimeReleaseFormValues release;
  @override
  String catalogTitle;

  @override
  void dispose() {}
}
