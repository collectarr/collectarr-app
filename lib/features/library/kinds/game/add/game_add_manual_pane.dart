import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_field_ids.dart';
import 'package:flutter/material.dart';

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
        AddSchemaRenderer<GameCatalogFormDraft>.embedded(
          schema: gameAddSchemaFor<GameCatalogFormDraft>(
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
            gameMainFieldIds,
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
            gameEditionFieldIds,
            sectionLabels: const {'catalog_item': 'Edition'},
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'synopsis',
          label: 'Description',
          icon: Icons.description_outlined,
          content: buildFields(
            gameDescriptionFieldIds,
            sectionLabels: const {'game_details': 'Description'},
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'cover',
          label: 'Covers',
          icon: Icons.camera_alt_outlined,
          content: buildFields(
            gameCoverFieldIds,
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
