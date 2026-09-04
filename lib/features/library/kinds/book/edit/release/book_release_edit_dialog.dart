import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/edition/book_edition_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/edition/book_edition_edit_schema.dart';
import 'package:flutter/material.dart';

Widget buildBookReleaseLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return _BookReleaseSchemaEditDialog(request: request);
}

class _BookReleaseSchemaEditDialog extends StatefulWidget {
  const _BookReleaseSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_BookReleaseSchemaEditDialog> createState() =>
      _BookReleaseSchemaEditDialogState();
}

class _BookReleaseSchemaEditDialogState
    extends State<_BookReleaseSchemaEditDialog> {
  late final LibraryEditDraft _editDraft;
  late final BookCatalogMetadata _metadata;
  late final BookRelease _release;
  late final BookEditionEditDraft _releaseDraft;

  @override
  void initState() {
    super.initState();
    final metadata = widget.request.item.kindMetadata;
    if (metadata is! BookCatalogMetadata) {
      throw StateError('Expected BookCatalogMetadata for Book release editing');
    }
    _metadata = metadata;
    final book = BookCatalogMapper.mapMetadataItemToBook(widget.request.item);
    _release = _resolveRelease(book, widget.request.ownedItem?.editionId);
    _releaseDraft = BookEditionEditDraft.fromRelease(_release);
    _editDraft = LibraryEditDraft.fromRequest(widget.request);
  }

  @override
  void dispose() {
    _releaseDraft.dispose();
    _editDraft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditSchemaRenderer<BookRelease, BookEditionEditDraft>(
      schema: bookEditionEditSchema,
      model: _release,
      draft: _releaseDraft,
      title: bookEditionEditSchema.title?.call(_release),
      onCancel: () => Navigator.of(context).pop(),
      onSave: (_) {
        final selection = _editDraft.toSelection(
          submitAction: LibraryEditSubmitAction.save,
        );
        final updatedRelease = _releaseDraft.toRelease();
        final updatedMetadata = _replaceRelease(_metadata, updatedRelease);
        Navigator.of(context).pop(
          selection.copyWith(
            item: selection.item.copyWith(kindMetadata: updatedMetadata),
            scope: LibraryEditScope.release,
          ),
        );
      },
    );
  }
}

BookRelease _resolveRelease(BookCatalogItem book, String? releaseId) {
  if (releaseId != null) {
    for (final release in book.releases) {
      if (release.id == releaseId) return release;
    }
  }
  if (book.releases.isNotEmpty) return book.releases.first;
  return BookRelease(id: '${book.id}-release', title: book.title);
}

BookCatalogMetadata _replaceRelease(
  BookCatalogMetadata metadata,
  BookRelease release,
) {
  final edition = BookEditionMetadata.fromRelease(release);
  final hasRelease = metadata.editions.any((entry) => entry.id == release.id);
  final editions = [
    for (final entry in metadata.editions)
      entry.id == release.id ? edition : entry,
    if (!hasRelease) edition,
  ];
  final format = release.physicalFormatLabel ?? release.physicalFormat;
  return metadata.copyWith(
    editions: editions,
    publisher: release.publisher,
    barcode: release.upc ?? release.isbn,
    editionTitle: release.title,
    physicalFormat: format,
    physicalFormatLabel: release.physicalFormatLabel ?? format,
    language: release.language,
    country: release.region,
    originalPublicationDate: release.releaseDate,
  );
}
