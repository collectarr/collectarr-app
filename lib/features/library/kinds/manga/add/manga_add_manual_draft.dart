import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/forms/manga_catalog_form_values.dart';

/// Manga Add state contains typed catalog values; schema renderers own inputs.
final class MangaAddManualDraft implements LibraryKindAddDraft {
  MangaAddManualDraft({MangaCatalogFormValues? values})
      : values = values ?? MangaCatalogFormValues();

  final MangaCatalogFormValues values;

  @override
  void dispose() {}
}
