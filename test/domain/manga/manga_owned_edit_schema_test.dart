import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/models/grading_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/manga_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/owned/manga_owned_edit_schema.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/owned_edit_contract.dart';

void main() {
  final details = MangaOwnedDetails(
    grading: const GradingDetails(
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

  defineOwnedEditContract<EditSchema<MangaOwnedDetails, MangaEditDraft>>(
    name: 'Manga',
    create: () => mangaOwnedEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  test('declares Manga ownership sections and fields in order', () {
    expect(mangaOwnedEditSchema.tabs.map((tab) => tab.id), ['owned']);
    expect(
      mangaOwnedEditSchema.tabs.single.sections.map((section) => section.id),
      ['grading', 'signature', 'edition_details'],
    );
    expect(
      [
        for (final section in mangaOwnedEditSchema.tabs.single.sections)
          for (final field in section.fields) field.label,
      ].every((label) => label.isNotEmpty),
      isTrue,
    );
  });

  test('round trips Manga grading and collector details', () {
    final draft = _createDraft(details);
    addTearDown(draft.dispose);

    expect(draft.toDetailsDraft().toDetails(), details);

    final gradingCompany =
        _field('grading_company') as TextEditField<MangaEditDraft>;
    final signedBy = _field('signed_by') as TextEditField<MangaEditDraft>;
    final obiStrip =
        _field('obi_strip_present') as ToggleEditField<MangaEditDraft>;
    gradingCompany.setValue(draft, 'BGS');
    signedBy.setValue(draft, 'Tsukasa Abe');
    obiStrip.setValue(draft, false);

    final updated = draft.toDetailsDraft().toDetails() as MangaOwnedDetails;
    expect(updated.gradingCompany, 'BGS');
    expect(updated.signedBy, 'Tsukasa Abe');
    expect(updated.obiStripPresent, isFalse);
  });

  test('compares nested Manga grading details', () {
    expect(
      MangaOwnedDetails(
        grading: const GradingDetails(labelType: 'Signature Series'),
      ),
      isNot(
        MangaOwnedDetails(
          grading: const GradingDetails(labelType: 'Qualified'),
        ),
      ),
    );
  });

  test('applies Manga media and ownership edits to the selection', () {
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
      item: _mangaItem(),
      personal: const LibraryPersonalEditSelection(
        anchorType: null,
        editionId: null,
        variantId: null,
        bundleReleaseId: null,
        condition: null,
        grade: null,
        purchaseDate: null,
        pricePaidCents: null,
        currency: null,
        personalNotes: null,
        indexNumber: null,
        locationId: null,
        tags: null,
      ),
    );

    final updated = draft.applySelectionEdits(selection);
    final metadata = updated.item.kindMetadata as MangaMetadata;
    expect(metadata.pageCount, 224);
    expect(metadata.publisher, 'VIZ Media');
    expect(updated.personal!.gradingCompany, 'BGS');
    expect(updated.personal!.graderNotes, 'Regraded');
    expect(updated.personal!.labelType, 'Qualified');
    expect(updated.personal!.customLabel, 'Signed copy');
    expect(updated.personal!.pageQuality, 'Cream');
    expect(updated.personal!.certificationNumber, '987654');
    expect(updated.personal!.signedBy, 'Tsukasa Abe');
  });
}

MangaEditDraft _createDraft(MangaOwnedDetails details) {
  final item = _mangaItem();
  return createMangaEditDraft(
    item: item,
    ownedItem: OwnedItem(
      id: 'owned-1',
      catalogRef: const CatalogEntityRef(
        id: 'manga-1',
        kind: 'manga',
        entityType: CatalogEntityType.work,
      ),
      updatedAt: DateTime(2026),
      details: details,
    ),
    textControllers: TextControllerGroup(),
  ) as MangaEditDraft;
}

CatalogItem _mangaItem() => CatalogItem(
      identity: const LibraryItemIdentity(
        id: 'manga-1',
        mediaKind: CatalogMediaKind.manga,
      ),
      kindMetadata: const MangaMetadata(title: 'Frieren'),
    );

EditFieldSpec<MangaEditDraft> _field(String id) {
  return [
    for (final tab in mangaOwnedEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
