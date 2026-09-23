import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/book_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/edition/book_edition_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/edition/book_edition_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/media/book_media_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/media/book_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/owned/book_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/media_edit_contract.dart';
import '../../contracts/owned_edit_contract.dart';

void main() {
  defineMediaEditContract<EditSchema<BookMedia, BookMediaEditDraft>>(
    name: 'Book',
    create: () => bookMediaEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  defineOwnedEditContract<EditSchema<BookOwnedDetails, BookEditDraft>>(
    name: 'Book',
    create: () => bookOwnedEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  test('Book media schema binds canonical fields', () {
    final draft = BookMediaEditDraft.fromMedia(
      const BookMedia(
        id: BookMediaId('book-1'),
        title: 'The Left Hand of Darkness',
        originalLanguage: 'English',
        genres: ['Science fiction'],
      ),
    );
    addTearDown(draft.dispose);

    (_mediaField('genres') as LibraryTextFieldSpec<BookMediaEditDraft>)
        .setValue(draft, 'Science fiction, Fantasy');
    (_mediaField('original_language')
            as LibraryTextFieldSpec<BookMediaEditDraft>)
        .setValue(draft, 'German');
    (_mediaField('title') as LibraryTextFieldSpec<BookMediaEditDraft>)
        .setValue(draft, 'The Left Hand of Darkness Revised');
    (_mediaField('search_aliases') as LibraryTextFieldSpec<BookMediaEditDraft>)
        .setValue(draft, 'Gender, Society');

    final updated = draft.toMedia();
    expect(updated.title, 'The Left Hand of Darkness Revised');
    expect(updated.genres, ['Science fiction', 'Fantasy']);
    expect(updated.originalLanguage, 'German');
    expect(updated.searchAliases, ['Gender', 'Society']);
  });

  test('Book media schema rejects invalid values', () {
    final draft = BookMediaEditDraft.fromMedia(
      const BookMedia(id: BookMediaId('book-1'), title: 'Book'),
    );
    addTearDown(draft.dispose);

    draft.firstPublicationDateController.text = 'not-a-date';
    expect(
      bookMediaEditSchema.validate!(
          const BookMedia(id: BookMediaId('book-1'), title: 'Book'), draft),
      'Publication date is invalid',
    );
  });

  test('Book ownership schema round trips signed copies and dust jackets', () {
    final draft = _createMediaDraft(const BookCatalogMetadata(title: 'Book'));
    addTearDown(draft.dispose);

    draft.signedBy = 'Ursula K. Le Guin';
    draft.dustJacketPresent = true;
    draft.dustJacketCondition = 'Very Good';

    final details =
        (draft.toDetailsDraft() as BookOwnedDetailsDraft).toDetails();
    expect(
      details,
      const BookOwnedDetails(
        signedBy: 'Ursula K. Le Guin',
        dustJacketPresent: true,
        dustJacketCondition: 'Very Good',
      ),
    );
    final condition = _ownedField('dust_jacket_condition')
        as LibraryVocabularyFieldSpec<BookEditDraft, String>;
    expect(
      condition.options.map((option) => option.value),
      BookVocabularies.condition.builtIns,
    );
    expect(condition.isVisible(draft), isTrue);
  });

  test('Book edition schema edits a typed release without video fields', () {
    final original = BookRelease(
      id: 'edition-1',
      title: 'Collector edition',
      workId: 'work-1',
      publisher: 'Old Publisher',
      isbn: '9780000000001',
      pageCount: 320,
      releaseDate: DateTime(2020, 1, 1),
      physicalFormatLabel: 'Hardcover',
    );
    final draft = BookEditionEditDraft.fromRelease(original);
    addTearDown(draft.dispose);

    final format = _editionField('format')
        as LibraryVocabularyFieldSpec<BookEditionEditDraft, String>;
    expect(
      format.options.map((option) => option.value),
      BookVocabularies.format.builtIns,
    );
    (_editionField('publisher') as LibraryTextFieldSpec<BookEditionEditDraft>)
        .setValue(draft, 'New Publisher');
    (_editionField('page_count')
            as LibraryNumberFieldSpec<BookEditionEditDraft>)
        .setValue(draft, 352);
    format.setValue(draft, 'Trade Paperback');
    (_editionField('release_date')
            as LibraryDateFieldSpec<BookEditionEditDraft>)
        .setValue(draft, DateTime(2026, 4, 12));

    final updated = draft.toRelease();
    expect(updated.id, 'edition-1');
    expect(updated.workId, 'work-1');
    expect(updated.publisher, 'New Publisher');
    expect(updated.pageCount, 352);
    expect(updated.physicalFormatLabel, 'Trade Paperback');
    expect(updated.releaseDate, DateTime(2026, 4, 12));
    expect(
      bookEditionEditSchema.validate!(original, draft),
      isNull,
    );
    expect(
      bookEditionEditSchema.tabs
          .expand((tab) => tab.sections)
          .expand(
            (section) => section.fields,
          )
          .any((field) => field.id == 'season'),
      isFalse,
    );
  });
}

BookEditDraft _createMediaDraft(BookCatalogMetadata metadata) {
  return createBookEditDraft(
    item: _bookItem(metadata),
    textControllers: TextControllerGroup(),
  ).copySession as BookEditDraft;
}

CatalogSearchCandidate _bookItem([
  BookCatalogMetadata metadata = const BookCatalogMetadata(title: 'Book'),
]) {
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      identity: const LibraryItemIdentity(
        id: 'book-1',
        mediaKind: CatalogMediaKind.book,
      ),
      kindMetadata: metadata,
    ),
  );
}

LibraryFieldSpec<BookMediaEditDraft> _mediaField(String id) {
  return [
    for (final tab in bookMediaEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

LibraryFieldSpec<BookEditDraft> _ownedField(String id) {
  return [
    for (final tab in bookOwnedEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

LibraryFieldSpec<BookEditionEditDraft> _editionField(String id) {
  return [
    for (final tab in bookEditionEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
