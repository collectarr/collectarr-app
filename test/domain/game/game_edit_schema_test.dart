import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/game_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/media/game_media_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/owned/game_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/release/game_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details_draft.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/media_edit_contract.dart';
import '../../contracts/owned_edit_contract.dart';

void main() {
  defineMediaEditContract<EditSchema<GameMedia, GameCatalogFormValues>>(
    name: 'Game',
    create: () => gameMediaEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  defineOwnedEditContract<EditSchema<GameOwnedDetails, GameEditDraft>>(
    name: 'Game',
    create: () => gameOwnedEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  defineMediaEditContract<EditSchema<GameRelease, GameCatalogFormValues>>(
    name: 'Game release',
    create: () => gameReleaseEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  test('Game media form maps typed fields and preserves unrelated payload', () {
    const media = GameMedia(
      id: GameMediaId('game-1'),
      title: 'Chrono Trigger',
      platforms: ['Super Nintendo Entertainment System'],
      publisher: 'Square',
      genres: ['Role-playing'],
      originalLanguage: 'Japanese',
      ageRatings: ['CERO A'],
      rawPayload: {'provider_only': 'keep'},
    );
    final values = gameCatalogFormValuesFromMedia(media);

    (_field('publisher') as LibraryTextFieldSpec<GameCatalogFormValues>)
        .setValue(values, 'New Publisher');
    (_field('platforms')
            as LibraryMultiVocabularyFieldSpec<GameCatalogFormValues, String>)
        .setValues(values, {'Nintendo Switch', 'PC'});
    (_field('genres')
            as LibraryMultiVocabularyFieldSpec<GameCatalogFormValues, String>)
        .setValues(values, {'Role-playing', 'Adventure'});
    (_field('original_language') as LibraryTextFieldSpec<GameCatalogFormValues>)
        .setValue(values, 'English');

    final updated = gameMediaFromCatalogFormValues(
      original: media,
      values: values,
    );
    expect(updated.publisher, 'New Publisher');
    expect(updated.platforms, unorderedEquals(['Nintendo Switch', 'PC']));
    expect(updated.genres, unorderedEquals(['Role-playing', 'Adventure']));
    expect(updated.originalLanguage, 'English');
    expect(updated.rawPayload['provider_only'], 'keep');
  });

  test('Game ownership schema round trips typed owned details', () {
    final draft = _createDraft(const GameCatalogMetadata(title: 'Game'));
    addTearDown(draft.dispose);

    (_ownedField('completeness')
            as LibraryVocabularyFieldSpec<GameEditDraft, String>)
        .setValue(draft, 'Complete in Box (CIB)');
    (_ownedField('has_box') as LibraryToggleFieldSpec<GameEditDraft>)
        .setValue(draft, true);
    (_ownedField('has_manual') as LibraryToggleFieldSpec<GameEditDraft>)
        .setValue(draft, true);
    (_ownedField('pricecharting_id') as LibraryTextFieldSpec<GameEditDraft>)
        .setValue(draft, 'pc-123');
    (_ownedField('core_region')
            as LibraryVocabularyFieldSpec<GameEditDraft, String>)
        .setValue(draft, 'NTSC-U/C (US/Canada)');
    (_ownedField('value_locked') as LibraryToggleFieldSpec<GameEditDraft>)
        .setValue(draft, true);

    expect(
      (draft.toDetailsDraft() as GameOwnedDetailsDraft).toDetails(),
      const GameOwnedDetails(
        completeness: 'Complete in Box (CIB)',
        hasBox: true,
        hasManual: true,
        priceChartingId: 'pc-123',
        coreRegion: 'NTSC-U/C (US/Canada)',
        valueIsLocked: true,
      ),
    );
  });

  test('Game release form updates a typed release and preserves release data',
      () {
    const original = GameRelease(
      id: 'release-1',
      title: 'Launch edition',
      workId: 'work-1',
      platform: 'Nintendo 64',
      regionCode: 'NTSC-U/C (US/Canada)',
      format: 'Cartridge',
      publisher: 'Old Publisher',
      catalogNumber: 'OLD-1',
      releaseStatus: 'released',
      language: 'English',
      barcode: '0001',
      coverImageUrl: 'https://example.test/old.jpg',
      rawPayload: {'provider_only': 'keep'},
    );
    final values = gameCatalogFormValuesFromRelease(original);

    (_releaseField('platform')
            as LibraryVocabularyFieldSpec<GameCatalogFormValues, String>)
        .setValue(values, 'Nintendo Switch');
    (_releaseField('region')
            as LibraryVocabularyFieldSpec<GameCatalogFormValues, String>)
        .setValue(values, 'Region Free');
    (_releaseField('release_title')
            as LibraryTextFieldSpec<GameCatalogFormValues>)
        .setValue(values, 'Remastered edition');
    (_releaseField('publisher') as LibraryTextFieldSpec<GameCatalogFormValues>)
        .setValue(values, 'New Publisher');
    (_releaseField('catalog_number')
            as LibraryTextFieldSpec<GameCatalogFormValues>)
        .setValue(values, 'NEW-1');
    (_releaseField('barcode') as LibraryTextFieldSpec<GameCatalogFormValues>)
        .setValue(values, '0002');
    (_releaseField('release_date')
            as LibraryDateFieldSpec<GameCatalogFormValues>)
        .setValue(values, DateTime(2026, 4, 12));

    final updated = gameReleaseFromCatalogFormValues(
      original: original,
      values: values,
    );
    expect(updated.id, 'release-1');
    expect(updated.workId, 'work-1');
    expect(updated.title, 'Remastered edition');
    expect(updated.platform, 'Nintendo Switch');
    expect(updated.regionCode, 'Region Free');
    expect(updated.publisher, 'New Publisher');
    expect(updated.catalogNumber, 'NEW-1');
    expect(updated.barcode, '0002');
    expect(updated.releaseDate, DateTime(2026, 4, 12));
    expect(updated.rawPayload['provider_only'], 'keep');
    expect(gameReleaseEditSchema.validate!(original, values), isNull);
  });
}

GameEditDraft _createDraft(GameCatalogMetadata metadata) {
  return createGameEditDraft(
    item: _item(metadata),
    textControllers: TextControllerGroup(),
  ).copySession as GameEditDraft;
}

CatalogSearchCandidate _item(GameCatalogMetadata metadata) {
  return CatalogSearchCandidate.fromItem(
    CatalogItemDto(
      identity: const LibraryItemIdentity(
        id: 'game-1',
        mediaKind: CatalogMediaKind.game,
      ),
      kindMetadata: metadata,
    ),
  );
}

LibraryFieldSpec<GameCatalogFormValues> _field(String id) => [
      for (final tab in gameMediaEditSchema.tabs)
        for (final section in tab.sections)
          for (final field in section.fields)
            if (field.id == id) field,
    ].single;

LibraryFieldSpec<GameEditDraft> _ownedField(String id) => [
      for (final tab in gameOwnedEditSchema.tabs)
        for (final section in tab.sections)
          for (final field in section.fields)
            if (field.id == id) field,
    ].single;

LibraryFieldSpec<GameCatalogFormValues> _releaseField(String id) => [
      for (final tab in gameReleaseEditSchema.tabs)
        for (final section in tab.sections)
          for (final field in section.fields)
            if (field.id == id) field,
    ].single;
