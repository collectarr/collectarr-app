import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_edition.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/boardgame_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/media/boardgame_media_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/owned/boardgame_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/release/boardgame_edition_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details_draft.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/media_edit_contract.dart';

void main() {
  defineMediaEditContract<
      EditSchema<BoardGameMedia, BoardGameCatalogFormValues>>(
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
      EditSchema<BoardGameEdition, BoardGameCatalogFormValues>>(
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
      EditSchema<BoardgameOwnedDetails, BoardGameEditDraft>>(
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

  test('BoardGame media form maps typed fields and preserves unknown data', () {
    const media = BoardGameMedia(
      id: BoardGameMediaId('boardgame-1'),
      title: 'Brass: Birmingham',
      publisher: 'Roxley',
      mechanics: ['Hand Management'],
      categories: ['Economic'],
      families: ['Brass'],
      expansions: ['Brass: Lancashire'],
      rankings: ['1'],
      rawPayload: {'provider_only': 'keep'},
    );
    final values = boardGameCatalogFormValuesFromMedia(media);
    (_workField('publisher')
            as LibraryVocabularyFieldSpec<BoardGameCatalogFormValues, String>)
        .setValue(values, 'New Publisher');
    (_workField('categories') as LibraryMultiVocabularyFieldSpec<
            BoardGameCatalogFormValues, String>)
        .setValues(values, {'Economic', 'Strategy'});
    (_workField('mechanics')
            as LibraryTextFieldSpec<BoardGameCatalogFormValues>)
        .setValue(values, 'Hand Management, Networking');
    (_workField('original_language')
            as LibraryTextFieldSpec<BoardGameCatalogFormValues>)
        .setValue(values, 'German');
    final updated = boardGameMediaFromCatalogFormValues(
      original: media,
      values: values,
    );

    expect(updated.publisher, 'New Publisher');
    expect(updated.categories, ['Economic', 'Strategy']);
    expect(updated.mechanics, ['Hand Management', 'Networking']);
    expect(updated.originalLanguage, 'German');
    expect(updated.rawPayload['provider_only'], 'keep');
  });

  test('BoardGame ownership schema round trips typed details', () {
    final draft = createBoardGameEditDraft(
      item: _item(const BoardGameMetadata(title: 'Catan')),
      textControllers: TextControllerGroup(),
    ).copySession as BoardGameEditDraft;
    addTearDown(draft.dispose);

    (_ownedField('edition_language')
            as LibraryTextFieldSpec<BoardGameEditDraft>)
        .setValue(draft, 'German');
    (_ownedField('edition_region') as LibraryTextFieldSpec<BoardGameEditDraft>)
        .setValue(draft, 'EU');
    (_ownedField('component_condition')
            as LibraryTextFieldSpec<BoardGameEditDraft>)
        .setValue(draft, 'Very good');
    (_ownedField('component_completeness')
            as LibraryTextFieldSpec<BoardGameEditDraft>)
        .setValue(draft, 'Complete');
    (_ownedField('missing_pieces_notes')
            as LibraryTextFieldSpec<BoardGameEditDraft>)
        .setValue(draft, 'One spare token');
    (_ownedField('is_sleeved') as LibraryToggleFieldSpec<BoardGameEditDraft>)
        .setValue(draft, true);
    (_ownedField('has_custom_insert')
            as LibraryToggleFieldSpec<BoardGameEditDraft>)
        .setValue(draft, true);
    (_ownedField('has_painted_miniatures')
            as LibraryToggleFieldSpec<BoardGameEditDraft>)
        .setValue(draft, true);
    (_ownedField('storage_notes') as LibraryTextFieldSpec<BoardGameEditDraft>)
        .setValue(draft, 'Shelf 2');

    expect(
      (draft.toDetailsDraft() as BoardgameOwnedDetailsDraft).toDetails(),
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

  test('BoardGame release form round trips typed edition fields', () {
    final original = BoardGameEdition(
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
      rawPayload: {'provider_only': 'keep'},
    );
    final values = boardGameCatalogFormValuesFromEdition(original);

    (_releaseField('title') as LibraryTextFieldSpec<BoardGameCatalogFormValues>)
        .setValue(values, 'Catan Revised');
    (_releaseField('edition_title')
            as LibraryTextFieldSpec<BoardGameCatalogFormValues>)
        .setValue(values, 'Collector Edition');
    (_releaseField('barcode')
            as LibraryTextFieldSpec<BoardGameCatalogFormValues>)
        .setValue(values, '456');
    (_releaseField('catalog_number')
            as LibraryTextFieldSpec<BoardGameCatalogFormValues>)
        .setValue(values, 'CAT-2');
    (_releaseField('format')
            as LibraryVocabularyFieldSpec<BoardGameCatalogFormValues, String>)
        .setValue(values, 'Deluxe Edition');
    (_releaseField('publisher')
            as LibraryVocabularyFieldSpec<BoardGameCatalogFormValues, String>)
        .setValue(values, 'New Publisher');
    (_releaseField('country')
            as LibraryTextFieldSpec<BoardGameCatalogFormValues>)
        .setValue(values, 'DE');
    (_releaseField('language')
            as LibraryTextFieldSpec<BoardGameCatalogFormValues>)
        .setValue(values, 'German');
    (_releaseField('age_rating')
            as LibraryTextFieldSpec<BoardGameCatalogFormValues>)
        .setValue(values, '12+');
    (_releaseField('audience_rating')
            as LibraryTextFieldSpec<BoardGameCatalogFormValues>)
        .setValue(values, 'Hobby');
    (_releaseField('cover_image_url')
            as LibraryTextFieldSpec<BoardGameCatalogFormValues>)
        .setValue(values, 'https://example.test/new.jpg');
    (_releaseField('description')
            as LibraryTextFieldSpec<BoardGameCatalogFormValues>)
        .setValue(values, 'New description');
    (_releaseField('release_status')
            as LibraryTextFieldSpec<BoardGameCatalogFormValues>)
        .setValue(values, 'available');
    (_releaseField('min_players')
            as LibraryNumberFieldSpec<BoardGameCatalogFormValues>)
        .setValue(values, 2);
    (_releaseField('max_players')
            as LibraryNumberFieldSpec<BoardGameCatalogFormValues>)
        .setValue(values, 6);
    (_releaseField('min_age')
            as LibraryNumberFieldSpec<BoardGameCatalogFormValues>)
        .setValue(values, 12);
    (_releaseField('playing_time_minutes')
            as LibraryNumberFieldSpec<BoardGameCatalogFormValues>)
        .setValue(values, 120);
    (_releaseField('release_date')
            as LibraryDateFieldSpec<BoardGameCatalogFormValues>)
        .setValue(values, DateTime(2026, 9, 4));

    final updated = boardGameEditionFromCatalogFormValues(
      original: original,
      values: values,
    );
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
    expect(updated.rawPayload['provider_only'], 'keep');
    expect(boardGameEditionEditSchema.validate!(original, values), isNull);
  });
}

CatalogSearchCandidate _item(BoardGameMetadata metadata) =>
    CatalogSearchCandidate.fromItem(
      CatalogItemDto(
        identity: const LibraryItemIdentity(
          id: 'boardgame-1',
          mediaKind: CatalogMediaKind.boardgame,
        ),
        kindMetadata: metadata,
      ),
    );

LibraryFieldSpec<BoardGameCatalogFormValues> _workField(String id) => [
      for (final tab in boardGameMediaEditSchema.tabs)
        for (final section in tab.sections)
          for (final field in section.fields)
            if (field.id == id) field,
    ].single;

LibraryFieldSpec<BoardGameEditDraft> _ownedField(String id) => [
      for (final tab in boardGameOwnedEditSchema.tabs)
        for (final section in tab.sections)
          for (final field in section.fields)
            if (field.id == id) field,
    ].single;

LibraryFieldSpec<BoardGameCatalogFormValues> _releaseField(String id) => [
      for (final tab in boardGameEditionEditSchema.tabs)
        for (final section in tab.sections)
          for (final field in section.fields)
            if (field.id == id) field,
    ].single;
