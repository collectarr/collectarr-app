import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/book_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/entry/book_entry_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/entry_edit_contract.dart';

void main() {
  defineEntryEditContract<EditSchema<BookEntryDetails, BookEditDraft>>(
    name: 'Book',
    create: () => bookEntryEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  test('Book entries schema round trips signed copies and dust jackets', () {
    final draft = _createBookDraft(const BookCatalogMetadata(title: 'Book'));
    addTearDown(draft.dispose);

    draft.signedBy = 'Ursula K. Le Guin';
    draft.dustJacketPresent = true;
    draft.dustJacketCondition = 'Very Good';

    final details =
        (draft.toDetailsDraft() as BookEntryDetailsDraft).toDetails();
    expect(
      details,
      const BookEntryDetails(
        signedBy: 'Ursula K. Le Guin',
        dustJacketPresent: true,
        dustJacketCondition: 'Very Good',
      ),
    );
    final condition = _entryField('dust_jacket_condition')
        as LibraryVocabularyFieldSpec<BookEditDraft, String>;
    expect(
      condition.options.map((option) => option.value),
      BookVocabularies.condition.builtIns,
    );
    expect(condition.isVisible(draft), isTrue);
  });
}

BookEditDraft _createBookDraft(BookCatalogMetadata metadata) {
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
      kindData: metadata,
    ),
  );
}

LibraryFieldSpec<BookEditDraft> _entryField(String id) {
  return [
    for (final tab in bookEntryEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
