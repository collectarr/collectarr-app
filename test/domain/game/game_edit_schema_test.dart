import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/game_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/media/game_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/media/game_media_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/owned/game_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/release/game_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/release/game_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details_draft.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/media_edit_contract.dart';
import '../../contracts/owned_edit_contract.dart';

void main() {
  defineMediaEditContract<EditSchema<GameMedia, GameMediaEditDraft>>(
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

  test('Game media schema binds canonical fields', () {
    const media = GameMedia(
      id: GameMediaId('game-1'),
      title: 'Chrono Trigger',
      platforms: ['Super Nintendo Entertainment System'],
      publisher: 'Square',
      genres: ['Role-playing'],
      originalLanguage: 'Japanese',
      ageRatings: ['CERO A'],
    );
    final draft = GameMediaEditDraft.fromMedia(media);
    addTearDown(draft.dispose);

    (_field('publisher') as LibraryTextFieldSpec<GameMediaEditDraft>)
        .setValue(draft, 'New Publisher');
    (_field('platforms') as LibraryTextFieldSpec<GameMediaEditDraft>)
        .setValue(draft, 'Nintendo Switch, PC');
    (_field('genres') as LibraryTextFieldSpec<GameMediaEditDraft>)
        .setValue(draft, 'Role-playing, Adventure');
    (_field('original_language') as LibraryTextFieldSpec<GameMediaEditDraft>)
        .setValue(draft, 'English');

    final updated = draft.toMedia();
    expect(updated.publisher, 'New Publisher');
    expect(updated.platforms, ['Nintendo Switch', 'PC']);
    expect(updated.genres, ['Role-playing', 'Adventure']);
    expect(updated.originalLanguage, 'English');
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
            as LibraryVocabularyFieldSpec<GameReleaseEditDraft, String>)
        .setValue(draft, 'Nintendo Switch');
    (_releaseField('region')
            as LibraryVocabularyFieldSpec<GameReleaseEditDraft, String>)
        .setValue(draft, 'Region Free');
    (_releaseField('title') as LibraryTextFieldSpec<GameReleaseEditDraft>)
        .setValue(draft, 'Remastered edition');
    (_releaseField('publisher') as LibraryTextFieldSpec<GameReleaseEditDraft>)
        .setValue(draft, 'New Publisher');
    (_releaseField('catalog_number')
            as LibraryTextFieldSpec<GameReleaseEditDraft>)
        .setValue(draft, 'NEW-1');
    (_releaseField('barcode') as LibraryTextFieldSpec<GameReleaseEditDraft>)
        .setValue(draft, '0002');
    (_releaseField('release_date')
            as LibraryDateFieldSpec<GameReleaseEditDraft>)
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

LibraryFieldSpec<GameMediaEditDraft> _field(String id) {
  return [
    for (final tab in gameMediaEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

LibraryFieldSpec<GameEditDraft> _ownedField(String id) {
  return [
    for (final tab in gameOwnedEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

LibraryFieldSpec<GameReleaseEditDraft> _releaseField(String id) {
  return [
    for (final tab in gameReleaseEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
