import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/game_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/entry/game_entry_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details_draft.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/entry_edit_contract.dart';

void main() {
  defineEntryEditContract<EditSchema<GameEntryDetails, GameEditDraft>>(
    name: 'Game',
    create: () => gameEntryEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  test('Game Add describes one concrete Catalog Item edition', () {
    final sectionIds = gameAddSchema.sections.map((section) => section.id);
    final fieldIds = {
      for (final section in gameAddSchema.sections)
        for (final field in section.fields) field.id,
    };

    expect(sectionIds, ['catalog_item', 'game_details']);
    expect(
      fieldIds,
      containsAll([
        'edition_title',
        'platform',
        'region',
        'release_date',
        'publisher',
        'barcode',
      ]),
    );
    expect(fieldIds, isNot(contains('release_title')));
  });

  test('Game Catalog Item form maps recognized edition data', () {
    final source = GameCatalogMetadata.fromJson({
      'title': 'Chrono Trigger',
      'edition_title': 'Collector Edition',
      'platforms': ['Super Nintendo'],
      'release_region': 'NTSC-U',
      'publisher': 'Square',
      'genres': ['Role-playing'],
      'language': 'Japanese',
      'release_date': '1995-03-11',
      'barcode': '045496870034',
      'physical_format': 'Cartridge',
    });
    final values = gameCatalogFormValuesFromMetadata(source);

    expect(values.editionTitle, 'Collector Edition');
    expect(values.platforms, ['Super Nintendo']);
    expect(values.region, 'NTSC-U');
    expect(values.publisher, 'Square');
    expect(values.releaseDate, DateTime(1995, 3, 11));

    values.editionTitle = 'Anniversary Edition';
    values.platforms = ['Nintendo Switch', 'PC'];
    values.region = 'Region Free';
    values.publisher = 'Square Enix';
    values.barcode = '000123';

    final updated = gameMetadataFromManualFormValues(
      values: values,
      id: 'game-1',
      title: 'Chrono Trigger',
    );
    final payload = updated.toJson();

    expect(payload['title'], 'Chrono Trigger');
    expect(payload['edition_title'], 'Anniversary Edition');
    expect(payload['platforms'], ['Nintendo Switch', 'PC']);
    expect(payload['release_region'], 'Region Free');
    expect(payload['publisher'], 'Square Enix');
    expect(payload['barcode'], '000123');
    expect(payload['release_date'], '1995-03-11T00:00:00.000');
    expect(payload, isNot(contains('editions')));
  });

  test('Game entries schema round trips typed entry details', () {
    final draft = _createDraft(const GameCatalogMetadata(title: 'Game'));
    addTearDown(draft.dispose);

    (_entryField('completeness')
            as LibraryVocabularyFieldSpec<GameEditDraft, String>)
        .setValue(draft, 'Complete in Box (CIB)');
    (_entryField('has_box') as LibraryToggleFieldSpec<GameEditDraft>)
        .setValue(draft, true);
    (_entryField('has_manual') as LibraryToggleFieldSpec<GameEditDraft>)
        .setValue(draft, true);
    (_entryField('pricecharting_id') as LibraryTextFieldSpec<GameEditDraft>)
        .setValue(draft, 'pc-123');
    (_entryField('core_region')
            as LibraryVocabularyFieldSpec<GameEditDraft, String>)
        .setValue(draft, 'NTSC-U/C (US/Canada)');
    (_entryField('value_locked') as LibraryToggleFieldSpec<GameEditDraft>)
        .setValue(draft, true);

    expect(
      (draft.toDetailsDraft() as GameEntryDetailsDraft).toDetails(),
      const GameEntryDetails(
        completeness: 'Complete in Box (CIB)',
        hasBox: true,
        hasManual: true,
        priceChartingId: 'pc-123',
        coreRegion: 'NTSC-U/C (US/Canada)',
        valueIsLocked: true,
      ),
    );
  });
}

GameEditDraft _createDraft(GameCatalogMetadata metadata) {
  return createGameEditDraft(
    item: CatalogSearchCandidate.fromItem(
      CatalogItemDto(
        identity: const LibraryItemIdentity(
          id: 'game-1',
          mediaKind: CatalogMediaKind.game,
        ),
        kindData: metadata,
      ),
    ),
    textControllers: TextControllerGroup(),
  ).copySession as GameEditDraft;
}

LibraryFieldSpec<GameEditDraft> _entryField(String id) => [
      for (final tab in gameEntryEditSchema.tabs)
        for (final section in tab.sections)
          for (final field in section.fields)
            if (field.id == id) field,
    ].single;
