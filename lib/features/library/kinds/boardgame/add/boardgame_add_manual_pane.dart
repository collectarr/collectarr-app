import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_field_ids.dart';
import 'package:flutter/material.dart';

class BoardgameAddManualPane extends StatelessWidget {
  const BoardgameAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final draft = request.manualDraftAs<BoardgameAddManualDraft>();
    LibraryFormSchema<BoardgameAddManualDraft> schemaFor(
      Set<String> fieldIds, {
      required String sectionLabel,
    }) =>
        boardGameAddSchemaFor(
          fieldIds: fieldIds,
          sectionLabels: {'catalog_item': sectionLabel},
        );

    LibraryAddManualPaneTab schemaTab({
      required String id,
      required String label,
      required IconData icon,
      required Set<String> fieldIds,
      required String sectionLabel,
      bool validateSchema = false,
    }) =>
        LibraryAddManualPaneTab.fromSchema<BoardgameAddManualDraft>(
          id: id,
          label: label,
          icon: icon,
          schema: schemaFor(fieldIds, sectionLabel: sectionLabel),
          draft: draft,
          mediaKind: request.kind.apiValue,
          onVocabularyValueChanged: request.onVocabularyValueChanged,
          onVocabularyValuesChanged: request.onVocabularyValuesChanged,
          onChanged: request.onManualDraftChanged,
          validateSchema: validateSchema,
        );

    return LibraryAddManualPaneShell(
      request: request,
      tabs: [
        schemaTab(
          id: 'main',
          label: 'Main',
          icon: Icons.edit_note_outlined,
          fieldIds: boardGameMainFieldIds,
          sectionLabel: 'Main',
          validateSchema: true,
        ),
        schemaTab(
          id: 'edition',
          label: 'Edition Details',
          icon: Icons.inventory_2_outlined,
          fieldIds: boardGameEditionFieldIds,
          sectionLabel: 'Edition',
        ),
        schemaTab(
          id: 'gameplay',
          label: 'Gameplay & Ratings',
          icon: Icons.casino_outlined,
          fieldIds: boardGamePlayFieldIds,
          sectionLabel: 'Gameplay and ratings',
        ),
        schemaTab(
          id: 'description',
          label: 'Description',
          icon: Icons.description_outlined,
          fieldIds: boardGameDescriptionFieldIds,
          sectionLabel: 'Description',
        ),
        schemaTab(
          id: 'covers',
          label: 'Covers',
          icon: Icons.camera_alt_outlined,
          fieldIds: boardGameCoverFieldIds,
          sectionLabel: 'Cover',
        ),
        LibraryAddManualPaneTab(
          id: 'links',
          label: 'Links',
          icon: Icons.public,
          content: BoardgameAddLinksTab(
            draft: draft,
            accent: request.accent,
            onChanged: request.onManualDraftChanged,
          ),
        ),
      ],
    );
  }
}

Widget buildBoardgameAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) =>
    BoardgameAddManualPane(request: request);
