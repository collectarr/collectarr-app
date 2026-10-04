import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_field_ids.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_draft_editor.dart';
import 'package:flutter/material.dart';

class GameAddManualPane extends StatelessWidget {
  const GameAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final draft = request.manualDraftAs<GameAddManualDraft>();
    LibraryAddManualPaneTab schemaTab({
      required String id,
      required String label,
      required IconData icon,
      required Set<String> fieldIds,
      Map<String, String> sectionLabels = const {},
      bool validateSchema = false,
    }) {
      final schema = gameAddSchemaFor<GameCatalogFormDraft>(
        fieldIds: fieldIds,
        sectionLabels: sectionLabels,
      );
      return LibraryAddManualPaneTab.fromSchema<GameCatalogFormDraft>(
        id: id,
        label: label,
        icon: icon,
        schema: schema,
        draft: draft,
        mediaKind: request.kind.apiValue,
        onVocabularyValueChanged: request.onVocabularyValueChanged,
        onVocabularyValuesChanged: request.onVocabularyValuesChanged,
        onChanged: request.onManualDraftChanged,
        validateSchema: validateSchema,
      );
    }

    return LibraryAddManualPaneShell(
      request: request,
      tabs: [
        schemaTab(
          id: 'main',
          label: 'Main',
          icon: Icons.edit_note_outlined,
          fieldIds: gameMainFieldIds,
          validateSchema: true,
          sectionLabels: const {
            'catalog_item': 'Main',
            'game_details': 'Game details',
          },
        ),
        schemaTab(
          id: 'edition',
          label: 'Edition details',
          icon: Icons.inventory_2_outlined,
          fieldIds: gameEditionFieldIds,
          sectionLabels: const {'catalog_item': 'Edition'},
        ),
        schemaTab(
          id: 'synopsis',
          label: 'Description',
          icon: Icons.description_outlined,
          fieldIds: gameDescriptionFieldIds,
          sectionLabels: const {'game_details': 'Description'},
        ),
        LibraryAddManualPaneTab(
          id: 'links',
          label: 'Links',
          icon: Icons.public,
          content: LibraryExternalLinksDraftEditor(
            links: draft.externalLinks,
            accent: request.accent,
            onChanged: request.onManualDraftChanged,
          ),
        ),
        schemaTab(
          id: 'cover',
          label: 'Covers',
          icon: Icons.camera_alt_outlined,
          fieldIds: gameCoverFieldIds,
          sectionLabels: const {'catalog_item': 'Front and back covers'},
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
