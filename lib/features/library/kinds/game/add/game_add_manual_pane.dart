import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_schema.dart';
import 'package:flutter/material.dart';

const _gameMainFieldIds = {
  'catalog_title',
  'platform',
  'publisher',
  'sort_title',
  'subtitle',
  'identifiers',
  'company_roles',
  'search_aliases',
  'original_language',
  'developers',
  'genres',
  'age_ratings',
  'languages',
  'country',
  'franchise',
  'series',
};
const _gameEditionFieldIds = {
  'edition_title',
  'region',
  'format',
  'release_date',
  'catalog_number',
  'barcode',
  'release_year',
  'variant',
};
const _gameCoverFieldIds = {'cover_image_url', 'back_cover_image_url'};

class GameAddManualPane extends StatelessWidget {
  const GameAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final draft = request.manualDraftAs<GameAddManualDraft>();
    Widget buildFields(
      Set<String> fieldIds, {
      Map<String, String> sectionLabels = const {},
    }) =>
        AddSchemaRenderer<GameAddManualDraft>.embedded(
          schema: gameAddSchemaFor(
            fieldIds: fieldIds,
            sectionLabels: sectionLabels,
          ),
          draft: draft,
          mediaKind: request.kind.apiValue,
          onVocabularyValueChanged: request.onVocabularyValueChanged,
          onVocabularyValuesChanged: request.onVocabularyValuesChanged,
          onChanged: request.onManualDraftChanged,
        );

    return LibraryAddManualPaneShell(
      request: request,
      tabs: [
        LibraryAddManualPaneTab.main(
          content: buildFields(
            _gameMainFieldIds,
            sectionLabels: const {
              'catalog_item': 'Main',
              'game_details': 'Game details',
            },
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'edition',
          label: 'Edition details',
          icon: Icons.inventory_2_outlined,
          content: buildFields(
            _gameEditionFieldIds,
            sectionLabels: const {'catalog_item': 'Edition'},
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'synopsis',
          label: 'Description',
          icon: Icons.description_outlined,
          content: buildFields(
            const {'description'},
            sectionLabels: const {'game_details': 'Description'},
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'cover',
          label: 'Covers',
          icon: Icons.camera_alt_outlined,
          content: buildFields(
            _gameCoverFieldIds,
            sectionLabels: const {
              'catalog_item': 'Front and back covers',
            },
          ),
        ),
      ],
    );
  }
}

Widget buildGameAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) =>
    GameAddManualPane(request: request);
