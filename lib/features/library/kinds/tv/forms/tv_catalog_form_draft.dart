import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';

/// Mutable catalog values consumed by the shared TV Add/Edit field schema.
abstract interface class TvCatalogFormDraft implements LibraryKindAddDraft {
  TvMetadata get metadata;
  set metadata(TvMetadata value);
}
