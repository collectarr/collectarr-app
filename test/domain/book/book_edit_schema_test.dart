import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/book_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/owned/book_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/owned_edit_contract.dart';

void main() {
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

  test('Book ownership schema round trips signed copies and dust jackets', () {
    final draft = _createBookDraft(const BookCatalogMetadata(title: 'Book'));
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

LibraryFieldSpec<BookEditDraft> _ownedField(String id) {
  return [
    for (final tab in bookOwnedEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
