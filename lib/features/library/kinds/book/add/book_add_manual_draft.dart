import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_values.dart';

/// Book Add state contains typed catalog values; schema renderers own inputs.
final class BookAddManualDraft implements BookCatalogFormDraft {
  BookAddManualDraft({
    BookCatalogFormValues? values,
    this.catalogTitle = '',
  }) : values = values ?? BookCatalogFormValues();

  @override
  final BookCatalogFormValues values;
  @override
  String catalogTitle;
}
