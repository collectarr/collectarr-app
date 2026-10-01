import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/boardgame_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/owned/boardgame_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details_draft.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('manual Add exposes one Catalog Item section', () {
    expect(boardGameAddSchema.sections, hasLength(1));
    expect(boardGameAddSchema.sections.single.id, 'catalog_item');
    expect(boardGameAddSchema.sections.single.label, 'Catalog Item');
  });

  test('flat Catalog Item form values map to Board Game metadata', () {
    final values = BoardGameCatalogFormValues(
      originalTitle: 'Catan',
      publisher: 'Kosmos',
      barcode: '123456789',
      country: 'DE',
      language: 'German',
      format: 'Board game',
      minPlayers: 2,
      maxPlayers: 4,
      designers: ['Klaus Teuber'],
      mechanics: ['Trading'],
      releaseDate: DateTime.utc(1995, 1, 1),
    );

    final metadata = boardGameMetadataFromManualFormValues(
      values: values,
      id: 'boardgame-edition-1',
      title: 'Catan Revised Edition',
    );
    final restored = boardGameCatalogFormValuesFromMetadata(metadata);

    expect(metadata.title, 'Catan Revised Edition');
    expect(metadata.originalTitle, 'Catan');
    expect(metadata.publisher, 'Kosmos');
    expect(metadata.barcode, '123456789');
    expect(metadata.minPlayers, 2);
    expect(metadata.maxPlayers, 4);
    expect(restored.country, 'DE');
    expect(restored.language, 'German');
    expect(restored.format, 'Board game');
    expect(restored.releaseDate, DateTime.utc(1995, 1, 1));
    expect(restored.designers, ['Klaus Teuber']);
    expect(restored.mechanics, ['Trading']);
  });

  test('Board Game Owned Copy schema round trips typed details', () {
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

LibraryFieldSpec<BoardGameEditDraft> _ownedField(String id) => [
      for (final tab in boardGameOwnedEditSchema.tabs)
        for (final section in tab.sections)
          for (final field in section.fields)
            if (field.id == id) field,
    ].single;
