import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/boardgame_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/media/boardgame_media_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/owned/boardgame_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/release/boardgame_edition_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/release/boardgame_edition_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/media_edit_contract.dart';

void main() {
  defineMediaEditContract<EditSchema<BoardGameMetadata, BoardGameEditDraft>>(
    name: 'BoardGame',
    create: () => boardGameMediaEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  defineMediaEditContract<
      EditSchema<BoardGameRelease, BoardGameEditionEditDraft>>(
    name: 'BoardGame release',
    create: () => boardGameEditionEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  defineMediaEditContract<
      EditSchema<BoardGameOwnedDetails, BoardGameEditDraft>>(
    name: 'BoardGame ownership',
    create: () => boardGameOwnedEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  test('BoardGame media schema round trips typed metadata', () {
    const metadata = BoardGameMetadata(
      title: 'Brass: Birmingham',
      originalTitle: 'Brass Birmingham',
      yearPublished: 2018,
      minPlayers: 2,
      maxPlayers: 4,
      recommendedPlayers: '3-4',
      bestPlayers: '4',
      minPlaytimeMinutes: 60,
      maxPlaytimeMinutes: 120,
      minimumAge: 14,
      complexityWeight: 3.9,
      designers: ['Martin Wallace'],
      artists: ['Matieu Leyssenne'],
      publishers: ['Roxley'],
      mechanics: ['Hand Management'],
      categories: ['Economic'],
      families: ['Brass'],
      themes: ['Industry'],
      expansions: ['Brass: Lancashire'],
      expansionFor: 'Brass: Lancashire',
      languages: ['English'],
      bggRating: 8.6,
      bggRatingCount: 100000,
      bggRank: 1,
      seriesTitle: 'Brass',
      itemNumber: '1',
      physicalFormat: 'Base Game',
      physicalFormatLabel: 'Base Game',
      publisher: 'Roxley',
      barcode: '123',
      variant: 'Deluxe',
    );
    final draft = createBoardGameEditDraft(
      item: _item(metadata),
      textControllers: TextControllerGroup(),
    ) as BoardGameEditDraft;
    addTearDown(draft.dispose);

    _field('original_title').setValue(draft, 'Brass Birmingham Revised');
    _field('year_published').setValue(draft, '2019');
    _field('min_players').setValue(draft, '2');
    _field('max_players').setValue(draft, '5');
    _field('designers').setValue(draft, 'Martin Wallace, New Designer');
    (_findField('publisher') as VocabularyEditField<BoardGameEditDraft, String>)
        .setValue(draft, 'New Publisher');
    _field('categories').setValue(draft, 'Economic, Strategy');
    _field('languages').setValue(draft, 'English, German');
    _field('bgg_rating').setValue(draft, '9.1');
    _field('bgg_rank').setValue(draft, '2');

    final selection = draft.applySelectionEdits(
      LibraryEditSelection(item: _item(metadata), personal: null),
    );
    final updated = selection.item.kindMetadata as BoardGameMetadata;

    expect(updated.originalTitle, 'Brass Birmingham Revised');
    expect(updated.yearPublished, 2019);
    expect(updated.minPlayers, 2);
    expect(updated.maxPlayers, 5);
    expect(updated.designers, ['Martin Wallace', 'New Designer']);
    expect(updated.publishers, ['New Publisher']);
    expect(updated.publisher, 'New Publisher');
    expect(updated.categories, ['Economic', 'Strategy']);
    expect(updated.languages, ['English', 'German']);
    expect(updated.bggRating, 9.1);
    expect(updated.bggRank, 2);
  });

  test('BoardGame ownership schema round trips typed details', () {
    final draft = createBoardGameEditDraft(
      item: _item(const BoardGameMetadata(title: 'Catan')),
      textControllers: TextControllerGroup(),
    ) as BoardGameEditDraft;
    addTearDown(draft.dispose);

    (_findOwnedField('edition_language') as TextEditField<BoardGameEditDraft>)
        .setValue(draft, 'German');
    (_findOwnedField('edition_region') as TextEditField<BoardGameEditDraft>)
        .setValue(draft, 'EU');
    (_findOwnedField('component_condition')
            as TextEditField<BoardGameEditDraft>)
        .setValue(draft, 'Very good');
    (_findOwnedField('component_completeness')
            as TextEditField<BoardGameEditDraft>)
        .setValue(draft, 'Complete');
    (_findOwnedField('missing_pieces_notes')
            as TextEditField<BoardGameEditDraft>)
        .setValue(draft, 'One spare token');
    (_findOwnedField('is_sleeved') as ToggleEditField<BoardGameEditDraft>)
        .setValue(draft, true);
    (_findOwnedField('has_custom_insert')
            as ToggleEditField<BoardGameEditDraft>)
        .setValue(draft, true);
    (_findOwnedField('has_painted_miniatures')
            as ToggleEditField<BoardGameEditDraft>)
        .setValue(draft, true);
    (_findOwnedField('storage_notes') as TextEditField<BoardGameEditDraft>)
        .setValue(draft, 'Shelf 2');

    expect(
      draft.toDetailsDraft().toDetails(),
      const BoardgameOwnedDetails(
        editionLanguage: 'German',
        editionRegion: 'EU',
        componentCondition: 'Very good',
        componentCompleteness: 'Complete',
        missingPiecesNotes: 'One spare token',
        isSleeved: true,
        hasCustomInsert: true,
        hasPaintedMiniatures: true,
        storageNotes: 'Shelf 2',
      ),
    );
  });

  test('BoardGame release schema round trips every typed edition field', () {
    final original = BoardGameRelease(
      id: 'edition-1',
      title: 'Catan',
      titleValue: 'Catan',
      workId: 'boardgame-1',
      editionTitle: 'Fifth Edition',
      ageRating: '10+',
      audienceRating: 'Family',
      barcode: '123',
      catalogNumber: 'CAT-1',
      country: 'US',
      coverImageUrl: 'https://example.test/old.jpg',
      description: 'Old description',
      format: 'Base Game',
      language: 'English',
      maxPlayers: 4,
      minAge: 10,
      minPlayers: 3,
      playingTimeMinutes: 90,
      publisher: 'Old Publisher',
      releaseDate: DateTime(1995, 1, 1),
      releaseStatus: 'released',
    );
    final draft = BoardGameEditionEditDraft.fromRelease(original);
    addTearDown(draft.dispose);

    _releaseTextField('title').setValue(draft, 'Catan Revised');
    _releaseTextField('edition_title').setValue(draft, 'Collector Edition');
    _releaseTextField('barcode').setValue(draft, '456');
    _releaseTextField('catalog_number').setValue(draft, 'CAT-2');
    (_findReleaseField('format')
            as VocabularyEditField<BoardGameEditionEditDraft, String>)
        .setValue(draft, 'Deluxe Edition');
    (_findReleaseField('publisher')
            as VocabularyEditField<BoardGameEditionEditDraft, String>)
        .setValue(draft, 'New Publisher');
    _releaseTextField('country').setValue(draft, 'DE');
    _releaseTextField('language').setValue(draft, 'German');
    _releaseTextField('age_rating').setValue(draft, '12+');
    _releaseTextField('audience_rating').setValue(draft, 'Hobby');
    _releaseTextField('cover_image_url')
        .setValue(draft, 'https://example.test/new.jpg');
    _releaseTextField('description').setValue(draft, 'New description');
    _releaseTextField('release_status').setValue(draft, 'available');
    _releaseTextField('min_players').setValue(draft, '2');
    _releaseTextField('max_players').setValue(draft, '6');
    _releaseTextField('min_age').setValue(draft, '12');
    _releaseTextField('playing_time_minutes').setValue(draft, '120');
    (_findReleaseField('release_date')
            as DateEditField<BoardGameEditionEditDraft>)
        .setValue(draft, DateTime(2026, 9, 4));

    final updated = draft.toRelease();
    expect(updated.title, 'Catan Revised');
    expect(updated.editionTitle, 'Collector Edition');
    expect(updated.barcode, '456');
    expect(updated.catalogNumber, 'CAT-2');
    expect(updated.format, 'Deluxe Edition');
    expect(updated.publisher, 'New Publisher');
    expect(updated.country, 'DE');
    expect(updated.language, 'German');
    expect(updated.ageRating, '12+');
    expect(updated.audienceRating, 'Hobby');
    expect(updated.coverImageUrl, 'https://example.test/new.jpg');
    expect(updated.description, 'New description');
    expect(updated.releaseStatus, 'available');
    expect(updated.minPlayers, 2);
    expect(updated.maxPlayers, 6);
    expect(updated.minAge, 12);
    expect(updated.playingTimeMinutes, 120);
    expect(updated.releaseDate, DateTime(2026, 9, 4));
    expect(boardGameEditionEditSchema.validate!(original, draft), isNull);
  });
}

CatalogItem _item(BoardGameMetadata metadata) {
  return CatalogItem(
    identity: const LibraryItemIdentity(
      id: 'boardgame-1',
      mediaKind: CatalogMediaKind.boardgame,
    ),
    kindMetadata: metadata,
  );
}

TextEditField<BoardGameEditDraft> _field(String id) {
  return _findField(id) as TextEditField<BoardGameEditDraft>;
}

EditFieldSpec<BoardGameEditDraft> _findField(String id) {
  return [
    for (final tab in boardGameMediaEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

EditFieldSpec<BoardGameEditDraft> _findOwnedField(String id) {
  return [
    for (final tab in boardGameOwnedEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

EditFieldSpec<BoardGameEditionEditDraft> _findReleaseField(String id) {
  return [
    for (final tab in boardGameEditionEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

TextEditField<BoardGameEditionEditDraft> _releaseTextField(String id) {
  return _findReleaseField(id) as TextEditField<BoardGameEditionEditDraft>;
}
