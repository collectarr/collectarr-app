import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_external_link_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_values.dart';

/// Book Add state contains typed catalog values; schema renderers own inputs.
final class BookAddManualDraft
    implements BookCatalogFormDraft, LibraryKindAddDraftWithResources {
  BookAddManualDraft({
    BookCatalogFormValues? values,
    this.catalogTitle = '',
  }) : values = values ?? BookCatalogFormValues();

  @override
  final BookCatalogFormValues values;
  final List<BookCatalogExternalLinkDraft> externalLinks = [];
  @override
  String catalogTitle;

  @override
  void dispose() {
    for (final link in externalLinks) {
      link.dispose();
    }
  }
}
