import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_external_link_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_values.dart';

final class ComicAddManualDraft implements LibraryKindAddDraftWithResources {
  ComicAddManualDraft({
    ComicCatalogItemFormValues? values,
    this.catalogTitle = '',
  }) : values = values ?? ComicCatalogItemFormValues();

  final ComicCatalogItemFormValues values;
  final List<ComicExternalLinkDraft> externalLinks = [];
  @override
  String catalogTitle;

  @override
  void dispose() {
    for (final link in externalLinks) {
      link.dispose();
    }
  }
}
