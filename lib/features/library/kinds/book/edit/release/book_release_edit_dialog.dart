import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/edition/book_edition_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/edition/book_edition_edit_schema.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter/material.dart';

Widget buildBookReleaseLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _BookReleaseSchemaEditDialog(request: request);

class _BookReleaseSchemaEditDialog extends StatefulWidget {
  const _BookReleaseSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_BookReleaseSchemaEditDialog> createState() =>
      _BookReleaseSchemaEditDialogState();
}

class _BookReleaseSchemaEditDialogState
    extends State<_BookReleaseSchemaEditDialog> {
  late final BookMedia _media;
  late final BookRelease _release;
  late final BookEditionEditDraft _draft;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.toTransport();
    final canonical = transport.kindMetadata;
    _media = canonical is BookMedia
        ? canonical
        : BookMedia.fromJson(transport.payload);
    _release = _resolveRelease(
      _media,
      widget.request,
    );
    _draft = BookEditionEditDraft.fromRelease(_release);
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<BookRelease, BookEditionEditDraft>(
        schema: bookEditionEditSchema,
        model: _release,
        draft: _draft,
        title: bookEditionEditSchema.title?.call(_release) ?? 'Edit edition',
        icon: widget.request.type.identity.icon,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_book_release',
        coreCorrectionSourceBuilder: () =>
            LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          originalFields: _release.toJson(),
          proposedFields: _draft.toRelease().toJson(),
        ),
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        onSave: (_) {
          final updatedMedia = _replaceRelease(_media, _draft.toRelease());
          final candidate = widget.request.kindItem.mapTransport(
            (transport) => CatalogSearchCandidate.fromItem(
              transport.withKindMetadata(updatedMedia),
            ),
          );
          Navigator.of(context).pop(
            LibraryEditSelection(
              item: candidate.editMetadata,
              kindItem: candidate,
              personal: null,
              scope: LibraryEntityScope.release,
            ),
          );
        },
      );
}

BookRelease _resolveRelease(
  BookMedia media,
  LibraryEditDialogRequest request,
) {
  final requestedReleaseId = switch (request.node) {
    LibraryReleaseRef(:final releaseId) => releaseId,
    LibraryCopyRef(:final releaseId) => releaseId,
    _ => null,
  };
  if (requestedReleaseId != null) {
    for (final release in media.editions) {
      if (release.id == requestedReleaseId) return release;
    }
    throw StateError(
      'Book edition "$requestedReleaseId" is not present in the canonical work graph',
    );
  }
  if (!request.editPrimaryRelease) {
    throw StateError(
      'Book edition edit requires an explicit release selection or primary-release intent',
    );
  }
  if (media.editions.isNotEmpty) return media.editions.first;
  throw StateError('Book edition edit requires a concrete release');
}

BookMedia _replaceRelease(BookMedia media, BookRelease release) {
  final editions = [
    for (final existing in media.editions)
      existing.id == release.id ? release : existing,
  ];
  return BookMedia(
    id: media.id,
    title: media.title,
    sortTitle: media.sortTitle,
    description: media.description,
    firstPublicationDate: media.firstPublicationDate,
    originalLanguage: media.originalLanguage,
    originalPublicationDate: media.originalPublicationDate,
    subtitle: media.subtitle,
    searchAliases: media.searchAliases,
    genres: media.genres,
    contributors: media.contributors,
    editions: editions,
    series: media.series,
    rawPayload: {
      ...media.rawPayload,
      'editions': editions.map((edition) => edition.toJson()).toList(),
    },
  );
}
