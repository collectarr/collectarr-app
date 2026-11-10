import '../domain/book_metadata.dart';
import '../forms/catalog_form_adapters.dart';
import '../forms/catalog_form_draft.dart';
import '../forms/catalog_form_values.dart';
import '../forms/catalog_external_link_draft.dart';
import 'package:collectarr_app/features/library/edit/session/vocabulary_edit_accumulator.dart';

final class BookItemEditDraft implements BookCatalogFormDraft {
  BookItemEditDraft.fromMetadata(this.original)
      : values = bookCatalogFormValuesFromMetadata(original),
        externalLinks = [
          for (final link in original.externalLinks)
            BookCatalogExternalLinkDraft(original: link)
        ];
  final BookCatalogMetadata original;
  @override
  final BookCatalogFormValues values;
  final List<BookCatalogExternalLinkDraft> externalLinks;
  LibraryVocabularyEditAccumulator vocabularyEdits =
      LibraryVocabularyEditAccumulator();
  @override
  String get catalogTitle => values.title;
  @override
  set catalogTitle(String value) => values.title = value;

  BookCatalogMetadata toMetadata() => applyBookCatalogFormValues(
        current: original,
        values: values,
        title: catalogTitle,
      ).copyWith(externalLinks: [
        for (final (index, link) in externalLinks
            .where((link) => link.row.urlController.text.trim().isNotEmpty)
            .indexed)
          link.toModel(index + 1),
      ]);
  void dispose() {
    for (final link in externalLinks) {
      link.dispose();
    }
  }
}
