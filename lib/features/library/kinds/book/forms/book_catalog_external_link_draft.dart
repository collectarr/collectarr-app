import 'package:collectarr_app/features/library/edit/fields/library_external_links_table.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';

/// Book-owned mapping between the shared editable row and catalog link data.
final class BookCatalogExternalLinkDraft {
  BookCatalogExternalLinkDraft({BookExternalLink? original})
      : original = original,
        row = LibraryExternalLinkDraftRow(
          title: original?.title ?? '',
          url: original?.url ?? '',
          description: original?.description ?? '',
        );

  final BookExternalLink? original;
  final LibraryExternalLinkDraftRow row;

  BookExternalLink toModel(int position) => BookExternalLink(
        url: row.urlController.text.trim(),
        id: original?.id,
        description: _nullable(row.descriptionController.text),
        kind: original?.kind ?? 'external',
        label: original?.label,
        linkType: original?.linkType,
        name: original?.name,
        position: position,
        site: original?.site,
        title: _nullable(row.titleController.text),
      );

  void dispose() => row.dispose();
}

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
