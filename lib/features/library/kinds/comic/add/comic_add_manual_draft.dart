import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_values.dart';

final class ComicAddManualDraft implements LibraryKindAddDraft {
  ComicAddManualDraft({ComicCatalogItemFormValues? values})
      : values = values ?? ComicCatalogItemFormValues();

  final ComicCatalogItemFormValues values;

  @override
  void dispose() {}
}
