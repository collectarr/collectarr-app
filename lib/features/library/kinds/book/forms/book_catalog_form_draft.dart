import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_values.dart';

/// Kind-owned catalog draft shared by the Book Add and Edit forms.
abstract interface class BookCatalogFormDraft implements LibraryKindAddDraft {
  BookCatalogFormValues get values;
}
