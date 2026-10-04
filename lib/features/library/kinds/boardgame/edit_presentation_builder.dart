import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_edit_presentation_builder_base.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_schema.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/boardgame_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/entry/boardgame_entry_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_field_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/vocabulary/boardgame_vocabularies.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

const _boardGameTabs0 = LibraryEditTabSpec(
  id: 'main',
  icon: Icons.casino_outlined,
  label: 'Main',
);

const _boardGameSecondaryTabs = [
  LibraryEditTabSpec(
    id: 'gameplay',
    icon: Icons.casino_outlined,
    label: 'Gameplay & Ratings',
  ),
  LibraryEditTabSpec(
    id: 'synopsis',
    icon: Icons.description_outlined,
    label: 'Description',
  ),
  LibraryEditTabSpec(
    id: 'links',
    icon: Icons.public,
    label: 'Links',
    sectionIds: ['external_links'],
  ),
  LibraryEditTabSpec(
    id: 'cover',
    icon: Icons.photo_camera_outlined,
    label: 'Covers',
  ),
  LibraryEditTabSpec(
    id: 'photos',
    icon: Icons.image_outlined,
    label: 'My Images',
    sectionIds: ['photos'],
  ),
];

const _boardGameEditionTab = LibraryEditTabSpec(
  id: 'edition',
  icon: Icons.album_outlined,
  label: 'Edition Details',
);

const _boardGameEntryTab = LibraryEditTabSpec(
  id: 'entry',
  icon: Icons.inventory_2,
  label: 'Personal',
);

const _boardGameCombinedTabs = [
  _boardGameTabs0,
  _boardGameEntryTab,
  _boardGameEditionTab,
  ..._boardGameSecondaryTabs,
];

Widget? buildBoardGameCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditShellState draft,
  required Color accent,
  required LibraryEntityScope scope,
  required CatalogSearchCandidate item,
  required VoidCallback markDirty,
}) {
  final kindDraft = draft.session.catalogItemSession;
  if (kindDraft is! BoardGameEditDraft) {
    throw StateError('Expected BoardGameEditDraft for Board Game editing');
  }

  if (tabId == 'entry') {
    final detailsDraft =
        kindDraft.toDetailsDraft() as BoardgameEntryDetailsDraft;
    final details = detailsDraft.toDetails();
    return EditSchemaRenderer<BoardgameEntryDetails,
        BoardGameEditDraft>.embedded(
      schema: boardGameEntryEditSchema,
      model: details,
      draft: kindDraft,
      mediaKind: draft.type.kind.apiValue,
      showTabBar: false,
    );
  }

  final fieldIds = switch (tabId) {
    'main' => boardGameMainFieldIds,
    'edition' => boardGameEditionFieldIds,
    'gameplay' => boardGamePlayFieldIds,
    'synopsis' => boardGameDescriptionFieldIds,
    'cover' => boardGameCoverFieldIds,
    _ => null,
  };
  if (fieldIds == null) return null;

  final sectionLabel = switch (tabId) {
    'main' => 'Main',
    'edition' => 'Edition',
    'gameplay' => 'Gameplay and ratings',
    'synopsis' => 'Description',
    _ => 'Covers',
  };
  final schema = boardGameAddSchemaFor<BoardGameEditDraft>(
    fieldIds: fieldIds,
    sectionLabels: {'catalog_item': sectionLabel},
    publisherOptions: _options(
      draft,
      BoardGameVocabularyIds.publisher.value,
      BoardGameVocabularies.publisher.builtIns,
    ),
    categoryOptions: _options(
      draft,
      BoardGameVocabularyIds.category.value,
      BoardGameVocabularies.category.builtIns,
    ),
    formatOptions: _options(
      draft,
      BoardGameVocabularyIds.format.value,
      BoardGameVocabularies.format.builtIns,
    ),
  );
  return EditTabShell(
    children: [
      AddSchemaRenderer<BoardGameEditDraft>.embedded(
        key: ValueKey('boardgame-fields-${draft.type.kind.apiValue}-$tabId'),
        schema: schema,
        draft: kindDraft,
        mediaKind: draft.type.kind.apiValue,
        onChanged: markDirty,
        onVocabularyValueChanged: ({
          required fieldId,
          required listName,
          required value,
        }) {
          draft.recordPendingVocabularyValue(
            fieldId: fieldId,
            listName: listName,
            value: value,
            options: _optionsForField(draft, fieldId),
            allowCustomValues: true,
            mediaKind: draft.type.kind.apiValue,
          );
        },
        onVocabularyValuesChanged: ({
          required fieldId,
          required listName,
          required values,
        }) {
          draft.recordPendingVocabularyValues(
            fieldId: fieldId,
            listName: listName,
            values: values,
            options: _optionsForField(draft, fieldId),
            allowCustomValues: true,
            mediaKind: draft.type.kind.apiValue,
          );
        },
      ),
    ],
  );
}

List<String> _options(
  LibraryEditShellState draft,
  String key,
  Iterable<String> fallback,
) =>
    draft.kindVocabularies[key]?.toList(growable: false) ??
    fallback.toList(growable: false);

List<String> _optionsForField(
  LibraryEditShellState draft,
  String fieldId,
) =>
    switch (fieldId) {
      'publisher' => _options(
          draft,
          BoardGameVocabularyIds.publisher.value,
          BoardGameVocabularies.publisher.builtIns,
        ),
      'categories' => _options(
          draft,
          BoardGameVocabularyIds.category.value,
          BoardGameVocabularies.category.builtIns,
        ),
      'format' => _options(
          draft,
          BoardGameVocabularyIds.format.value,
          BoardGameVocabularies.format.builtIns,
        ),
      _ => const <String>[],
    };

class BoardGameLibraryCombinedEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const BoardGameLibraryCombinedEditPresentationBuilder()
      : super(
          useEntryMainArtworkLayout: false,
          useDetailsTab: false,
          useArtworkCoverTab: false,
          useArtworkPhotosTab: false,
          trackingSectionTitle: 'Tracking edition',
          entryDigitalTrackingSectionTitle: 'Digital Entry Details',
          entryDigitalTrackingHint:
              'Digital items keep tracking, notes, and value fields, while physical media fields stay disabled.',
          entryTabs: _boardGameCombinedTabs,
          trackedTabs: _boardGameCombinedTabs,
          catalogTabs: _boardGameCombinedTabs,
          customTabBuilder: buildBoardGameCustomTabView,
        );
}

const boardGamesLibraryEditPresentation = LibraryEditPresentation(
  builder: BoardGameLibraryCombinedEditPresentationBuilder(),
);
