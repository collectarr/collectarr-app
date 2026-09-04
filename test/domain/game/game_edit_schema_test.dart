import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/game_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/media/game_media_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/owned/game_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/release/game_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/release/game_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/library/models/library_catalog_item_view.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/media_edit_contract.dart';
import '../../contracts/owned_edit_contract.dart';

void main() {
  defineMediaEditContract<EditSchema<GameCatalogMetadata, GameEditDraft>>(
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

  defineMediaEditContract<EditSchema<GameRelease, GameReleaseEditDraft>>(
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

  test('Game media schema binds typed metadata fields', () {
    const metadata = GameCatalogMetadata(
      title: 'Chrono Trigger',
      platform: 'Super Nintendo Entertainment System',
      platforms: ['Super Nintendo Entertainment System'],
      publishers: ['Square'],
      developers: ['Square'],
      genres: ['Role-playing'],
      languages: ['Japanese'],
      ageRating: 'CERO A',
    );
    final draft = _createDraft(metadata);
    addTearDown(draft.dispose);

    final ageRating =
        _field('age_rating') as VocabularyEditField<GameEditDraft, String>;
    expect(
      ageRating.options.map((option) => option.value),
      GameVocabularies.ageRating.builtIns,
    );
    ageRating.setValue(draft, 'ESRB: Teen (T)');
    (_field('publisher') as TextEditField<GameEditDraft>)
        .setValue(draft, 'New Publisher');
    (_field('developers') as TextEditField<GameEditDraft>)
        .setValue(draft, 'Studio A, Studio B');
    (_field('franchise') as TextEditField<GameEditDraft>)
        .setValue(draft, 'Chrono');
    (_field('genres') as TextEditField<GameEditDraft>)
        .setValue(draft, 'Role-playing, Adventure');
    (_field('language') as TextEditField<GameEditDraft>)
        .setValue(draft, 'English, Japanese');

    final updated = draft.applySelectionEdits(
      LibraryEditSelection(
        item: _item(metadata),
        personal: null,
      ),
    );
    final updatedMetadata = updated.item.kindMetadata as GameCatalogMetadata;
    expect(updatedMetadata.publishers, ['New Publisher']);
    expect(updatedMetadata.developers, ['Studio A', 'Studio B']);
    expect(updatedMetadata.franchise, 'Chrono');
    expect(updatedMetadata.genres, ['Role-playing', 'Adventure']);
    expect(updatedMetadata.languages, ['English', 'Japanese']);
    expect(updatedMetadata.ageRating, 'ESRB: Teen (T)');
  });

  test('Game ownership schema round trips typed owned details', () {
    final draft = _createDraft(const GameCatalogMetadata(title: 'Game'));
    addTearDown(draft.dispose);

    (_ownedField('completeness') as VocabularyEditField<GameEditDraft, String>)
        .setValue(draft, 'Complete in Box (CIB)');
    (_ownedField('has_box') as ToggleEditField<GameEditDraft>)
        .setValue(draft, true);
    (_ownedField('has_manual') as ToggleEditField<GameEditDraft>)
        .setValue(draft, true);
    (_ownedField('pricecharting_id') as TextEditField<GameEditDraft>)
        .setValue(draft, 'pc-123');
    (_ownedField('core_region') as VocabularyEditField<GameEditDraft, String>)
        .setValue(draft, 'NTSC-U/C (US/Canada)');
    (_ownedField('value_locked') as ToggleEditField<GameEditDraft>)
        .setValue(draft, true);

    expect(
      draft.toDetailsDraft().toDetails(),
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

  test('Game release schema edits every typed release field', () {
    final original = const GameRelease(
      id: 'release-1',
      title: 'Launch edition',
      workId: 'work-1',
      platform: 'Nintendo 64',
      releaseDate: null,
      regionCode: 'NTSC-U/C (US/Canada)',
      format: 'Cartridge',
      publisher: 'Old Publisher',
      catalogNumber: 'OLD-1',
      releaseStatus: 'released',
      language: 'English',
      barcode: '0001',
      coverImageUrl: 'https://example.test/old.jpg',
    );
    final draft = GameReleaseEditDraft.fromRelease(original);
    addTearDown(draft.dispose);

    (_releaseField('platform')
            as VocabularyEditField<GameReleaseEditDraft, String>)
        .setValue(draft, 'Nintendo Switch');
    (_releaseField('region')
            as VocabularyEditField<GameReleaseEditDraft, String>)
        .setValue(draft, 'Region Free');
    (_releaseField('title') as TextEditField<GameReleaseEditDraft>)
        .setValue(draft, 'Remastered edition');
    (_releaseField('publisher') as TextEditField<GameReleaseEditDraft>)
        .setValue(draft, 'New Publisher');
    (_releaseField('catalog_number') as TextEditField<GameReleaseEditDraft>)
        .setValue(draft, 'NEW-1');
    (_releaseField('barcode') as TextEditField<GameReleaseEditDraft>)
        .setValue(draft, '0002');
    (_releaseField('release_date') as DateEditField<GameReleaseEditDraft>)
        .setValue(draft, DateTime(2026, 4, 12));

    final updated = draft.toRelease();
    expect(updated.id, 'release-1');
    expect(updated.workId, 'work-1');
    expect(updated.title, 'Remastered edition');
    expect(updated.platform, 'Nintendo Switch');
    expect(updated.regionCode, 'Region Free');
    expect(updated.publisher, 'New Publisher');
    expect(updated.catalogNumber, 'NEW-1');
    expect(updated.barcode, '0002');
    expect(updated.releaseDate, DateTime(2026, 4, 12));
    expect(gameReleaseEditSchema.validate!(original, draft), isNull);
    expect(
      gameReleaseEditSchema.tabs
          .expand((tab) => tab.sections)
          .expand((section) => section.fields)
          .any((field) => field.id == 'season'),
      isFalse,
    );
  });
}

GameEditDraft _createDraft(GameCatalogMetadata metadata) {
  return createGameEditDraft(
    item: _item(metadata),
    textControllers: TextControllerGroup(),
  ) as GameEditDraft;
}

LibraryCatalogItemView _item(GameCatalogMetadata metadata) {
  return LibraryCatalogItemView(
    identity: const LibraryItemIdentity(
      id: 'game-1',
      mediaKind: CatalogMediaKind.game,
    ),
    kindMetadata: metadata,
  );
}

EditFieldSpec<GameEditDraft> _field(String id) {
  return [
    for (final tab in gameMediaEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

EditFieldSpec<GameEditDraft> _ownedField(String id) {
  return [
    for (final tab in gameOwnedEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

EditFieldSpec<GameReleaseEditDraft> _releaseField(String id) {
  return [
    for (final tab in gameReleaseEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
