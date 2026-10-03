import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';

final class AnimeAddManualDraft implements LibraryKindAddDraft {
  AnimeAddManualDraft({
    AnimeMetadata? metadata,
    this.catalogTitle = '',
  }) : metadata = metadata ?? const AnimeMetadata();

  AnimeMetadata metadata;
  @override
  String catalogTitle;

  @override
  void dispose() {}
}
