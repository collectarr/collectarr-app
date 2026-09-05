import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/book_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/edition/book_edition_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/edition/book_edition_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/media/book_media_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/owned/book_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/media_edit_contract.dart';
import '../../contracts/owned_edit_contract.dart';

void main() {
  defineMediaEditContract<EditSchema<BookCatalogMetadata, BookEditDraft>>(
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

  test('Book media schema binds typed metadata fields', () {
    final draft = _createMediaDraft(
      const BookCatalogMetadata(
        title: 'The Left Hand of Darkness',
        authors: ['Ursula K. Le Guin'],
        genres: ['Science fiction'],
        physicalFormatLabel: 'Hardcover',
      ),
    );
    addTearDown(draft.dispose);

    final format =
        _mediaField('format') as VocabularyEditField<BookEditDraft, String>;
    final publisher =
        _mediaField('publisher') as VocabularyEditField<BookEditDraft, String>;
    final language =
        _mediaField('language') as VocabularyEditField<BookEditDraft, String>;
    expect(
      format.options.map((option) => option.value),
      BookVocabularies.format.builtIns,
    );
    expect(
      publisher.options.map((option) => option.value),
      BookVocabularies.publisher.builtIns,
    );
    expect(
      language.options.map((option) => option.value),
      BookVocabularies.language.builtIns,
    );

    format.setValue(draft, 'Trade Paperback');
    publisher.setValue(draft, 'Penguin Random House');
    language.setValue(draft, 'English');
    (_mediaField('authors') as TextEditField<BookEditDraft>)
        .setValue(draft, 'Ursula K. Le Guin, Octavia E. Butler');
    (_mediaField('subjects') as TextEditField<BookEditDraft>)
        .setValue(draft, 'Gender, Society');

    expect(format.value(draft), 'Trade Paperback');
    expect(publisher.value(draft), 'Penguin Random House');
    expect(language.value(draft), 'English');

    final updated = draft.applySelectionEdits(
      LibraryEditSelection(
        item: _bookItem(),
        personal: null,
      ),
    );
    final metadata = updated.item.kindMetadata as BookCatalogMetadata;
    expect(metadata.physicalFormatLabel, 'Trade Paperback');
    expect(metadata.publisher, 'Penguin Random House');
    expect(metadata.authors, ['Ursula K. Le Guin', 'Octavia E. Butler']);
    expect(metadata.subjects, ['Gender', 'Society']);
  });

  test('Book media schema rejects invalid values', () {
    final draft = _createMediaDraft(const BookCatalogMetadata(title: 'Book'));
    addTearDown(draft.dispose);

    draft.pageCountController.text = '-1';
    expect(
      bookMediaEditSchema.validate!(
          const BookCatalogMetadata(title: 'Book'), draft),
      'Page count cannot be negative',
    );
    draft.pageCountController.text = '';
    draft.releaseDateController.text = 'not-a-date';
    expect(
      bookMediaEditSchema.validate!(
          const BookCatalogMetadata(title: 'Book'), draft),
      'Release date is invalid',
    );
  });

  test('Book ownership schema round trips signed copies and dust jackets', () {
    final draft = _createMediaDraft(const BookCatalogMetadata(title: 'Book'));
    addTearDown(draft.dispose);

    draft.signedBy = 'Ursula K. Le Guin';
    draft.dustJacketPresent = true;
    draft.dustJacketCondition = 'Very Good';

    final details = draft.toDetailsDraft().toDetails();
    expect(
      details,
      const BookOwnedDetails(
        signedBy: 'Ursula K. Le Guin',
        dustJacketPresent: true,
        dustJacketCondition: 'Very Good',
      ),
    );
    final condition = _ownedField('dust_jacket_condition')
        as VocabularyEditField<BookEditDraft, String>;
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
        as VocabularyEditField<BookEditionEditDraft, String>;
    expect(
      format.options.map((option) => option.value),
      BookVocabularies.format.builtIns,
    );
    (_editionField('publisher') as TextEditField<BookEditionEditDraft>)
        .setValue(draft, 'New Publisher');
    (_editionField('page_count') as NumberEditField<BookEditionEditDraft>)
        .setValue(draft, 352);
    format.setValue(draft, 'Trade Paperback');
    (_editionField('release_date') as DateEditField<BookEditionEditDraft>)
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
  ) as BookEditDraft;
}

CatalogItem _bookItem([
  BookCatalogMetadata metadata = const BookCatalogMetadata(title: 'Book'),
]) {
  return CatalogItem(
    identity: const LibraryItemIdentity(
      id: 'book-1',
      mediaKind: CatalogMediaKind.book,
    ),
    kindMetadata: metadata,
  );
}

EditFieldSpec<BookEditDraft> _mediaField(String id) {
  return [
    for (final tab in bookMediaEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

EditFieldSpec<BookEditDraft> _ownedField(String id) {
  return [
    for (final tab in bookOwnedEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

EditFieldSpec<BookEditionEditDraft> _editionField(String id) {
  return [
    for (final tab in bookEditionEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
