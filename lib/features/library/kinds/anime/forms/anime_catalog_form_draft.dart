import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';

/// Mutable catalog values consumed by the shared Anime Add/Edit field schema.
abstract interface class AnimeCatalogFormDraft implements LibraryKindAddDraft {
  AnimeMetadata get metadata;
  set metadata(AnimeMetadata value);
}
