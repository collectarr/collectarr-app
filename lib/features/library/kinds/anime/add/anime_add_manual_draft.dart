import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/forms/anime_credit_draft.dart';

final class AnimeAddManualDraft implements LibraryKindAddDraftWithResources {
  AnimeAddManualDraft({
    AnimeMetadata? metadata,
    this.catalogTitle = '',
  }) : metadata = metadata ?? const AnimeMetadata();

  AnimeMetadata metadata;
  final List<EditableAnimeCredit> castCredits = [];
  final List<EditableAnimeCredit> crewCredits = [];
  @override
  String catalogTitle;

  @override
  void dispose() {
    for (final credit in [...castCredits, ...crewCredits]) {
      credit.dispose();
    }
  }
}
