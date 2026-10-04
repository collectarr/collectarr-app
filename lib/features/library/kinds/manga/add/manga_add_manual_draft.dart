import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:collectarr_app/features/library/kinds/manga/forms/manga_catalog_form_values.dart';

/// Manga Add state contains typed catalog values; schema renderers own inputs.
final class MangaAddManualDraft implements LibraryKindAddDraftWithResources {
  MangaAddManualDraft({
    MangaCatalogFormValues? values,
    this.catalogTitle = '',
  }) : values = values ?? MangaCatalogFormValues();

  final MangaCatalogFormValues values;
  final List<LibraryExternalLinkDraftRow> externalLinks = [];
  @override
  String catalogTitle;

  @override
  void dispose() {
    for (final link in externalLinks) {
      link.dispose();
    }
  }
}
