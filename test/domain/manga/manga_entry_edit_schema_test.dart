import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/entries/manga_grading_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/entries/manga_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/manga_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/entry/manga_entry_edit_schema.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_ids.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/manga/entries/manga_entry_details.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_data_factories.dart';

import '../../contracts/entry_edit_contract.dart';

void main() {
  final details = MangaEntryDetails(
    grading: const MangaGradingDetails(
      rawOrSlabbed: 'Slabbed',
      gradingCompany: 'CGC',
      graderNotes: 'Clean and centered',
      labelType: 'Signature Series',
      customLabel: 'First print',
      pageQuality: 'White',
      certificationNumber: '123456',
    ),
    signedBy: 'Kanehito Yamada',
    obiStripPresent: true,
    slipcoverPresent: true,
    dustJacketPresent: true,
    dustJacketCondition: 'Near Mint',
    boxSetOuterCondition: 'Mint',
    insertsPresent: true,
    printing: '1st Print',
    localizedEdition: 'VIZ Signature',
  );

  defineEntryEditContract<EditSchema<MangaEntryDetails, MangaEditDraft>>(
    name: 'Manga',
    create: () => mangaEntryEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  test('declares Manga entries sections and fields in order', () {
    expect(mangaEntryEditSchema.tabs.map((tab) => tab.id), ['entry']);
    expect(
      mangaEntryEditSchema.tabs.single.sections.map((section) => section.id),
      ['grading', 'signature', 'edition_details'],
    );
    expect(
      [
        for (final section in mangaEntryEditSchema.tabs.single.sections)
          for (final field in section.fields) field.label,
      ].every((label) => label.isNotEmpty),
      isTrue,
    );
  });

  test('round trips Manga grading and collector details', () {
    final draft = _createDraft(details);
    addTearDown(draft.dispose);

    expect(
      (draft.toDetailsDraft() as MangaEntryDetailsDraft).toDetails(),
      details,
    );

    final gradingCompany =
        _field('grading_company') as LibraryTextFieldSpec<MangaEditDraft>;
    final signedBy =
        _field('signed_by') as LibraryTextFieldSpec<MangaEditDraft>;
    final obiStrip =
        _field('obi_strip_present') as LibraryToggleFieldSpec<MangaEditDraft>;
    gradingCompany.setValue(draft, 'BGS');
    signedBy.setValue(draft, 'Tsukasa Abe');
    obiStrip.setValue(draft, false);

    final updated =
        (draft.toDetailsDraft() as MangaEntryDetailsDraft).toDetails();
    expect(updated.gradingCompany, 'BGS');
    expect(updated.signedBy, 'Tsukasa Abe');
    expect(updated.obiStripPresent, isFalse);
  });

  test('compares nested Manga grading details', () {
    expect(
      MangaEntryDetails(
        grading: const MangaGradingDetails(labelType: 'Signature Series'),
      ),
      isNot(
        MangaEntryDetails(
          grading: const MangaGradingDetails(labelType: 'Qualified'),
        ),
      ),
    );
  });

  test('applies Manga media and entries edits to the selection', () {
    final draft = _createDraft(details);
    addTearDown(draft.dispose);

    draft.pageCountController.text = '224';
    draft.publisherController.text = 'VIZ Media';
    draft.gradingCompany = 'BGS';
    draft.graderNotes = 'Regraded';
    draft.labelType = 'Qualified';
    draft.customLabel = 'Signed copy';
    draft.pageQuality = 'Cream';
    draft.certificationNumber = '987654';
    draft.signedBy = 'Tsukasa Abe';

    final selection = LibraryEditSelection(
      kindItem: _mangaItem(),
    );

    final updated = draft.applySelectionEdits(selection);
    final metadata = updated.kindItem.kindCapability.mapTransport(
      (transport) => transport.kindMetadata,
    ) as MangaMetadata;
    expect(metadata.pageCount, 224);
    expect(metadata.publisher, 'VIZ Media');
    expect(
      (draft.toDetailsDraft() as MangaEntryDetailsDraft)
          .toDetails()
          .gradingCompany,
      'BGS',
    );
    final updatedDetails =
        (draft.toDetailsDraft() as MangaEntryDetailsDraft).toDetails();
    expect(updatedDetails.graderNotes, 'Regraded');
    expect(updatedDetails.grading.labelType, 'Qualified');
    expect(updatedDetails.grading.customLabel, 'Signed copy');
    expect(updatedDetails.grading.pageQuality, 'Cream');
    expect(updatedDetails.grading.certificationNumber, '987654');
    expect(updatedDetails.signedBy, 'Tsukasa Abe');
  });
}

MangaEditDraft _createDraft(MangaEntryDetails details) {
  final item = _mangaItem();
  return createMangaEditDraft(
    item: item,
    libraryEntryDispatch: testMangaLibraryEntryDispatchFrom(
      MangaLibraryEntry(
        id: const LibraryEntryId('entry-1'),
        catalogRef: const CatalogEntityRef(
          id: 'manga-1',
          kind: CatalogMediaKind.manga,
          entityType: CatalogEntityTypeId.catalogItem,
        ),
        updatedAt: DateTime(2026),
        details: details,
      ),
    ),
    textControllers: TextControllerGroup(),
  ).copySession as MangaEditDraft;
}

CatalogSearchCandidate _mangaItem() => CatalogSearchCandidate.fromItem(
      CatalogItemDto(
        identity: const LibraryItemIdentity(
          id: 'manga-1',
          mediaKind: CatalogMediaKind.manga,
        ),
        kindData: const MangaMetadata(title: 'Frieren'),
      ),
    );

LibraryFieldSpec<MangaEditDraft> _field(String id) {
  return [
    for (final tab in mangaEntryEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
