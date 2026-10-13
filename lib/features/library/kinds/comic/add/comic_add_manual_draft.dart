import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_person_draft.dart';

final class ComicAddManualDraft implements LibraryKindAddDraftWithResources {
  ComicAddManualDraft({
    ComicCatalogItemFormValues? values,
    this.catalogTitle = '',
  }) : values = values ?? ComicCatalogItemFormValues();

  final ComicCatalogItemFormValues values;
  final List<LibraryExternalLinkDraftRow> externalLinks = [];
  final List<EditableComicCreator> creators = [];
  final List<EditableComicCharacter> characters = [];
  @override
  String catalogTitle;

  @override
  void dispose() {
    for (final link in externalLinks) {
      link.dispose();
    }
    for (final creator in creators) {
      creator.dispose();
    }
    for (final character in characters) {
      character.dispose();
    }
  }
}
