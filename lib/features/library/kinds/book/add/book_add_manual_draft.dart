import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_values.dart';

/// Book Add state contains typed catalog values; schema renderers own inputs.
final class BookAddManualDraft implements LibraryKindAddDraft {
  BookAddManualDraft({BookCatalogFormValues? values})
      : values = values ?? BookCatalogFormValues();

  final BookCatalogFormValues values;

  @override
  void dispose() {}
}
