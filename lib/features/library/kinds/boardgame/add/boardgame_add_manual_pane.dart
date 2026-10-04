import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
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
    Widget buildFields(
      Set<String> fieldIds, {
      required String sectionLabel,
    }) =>
        AddSchemaRenderer<BoardgameAddManualDraft>.embedded(
          schema: boardGameAddSchemaFor(
            fieldIds: fieldIds,
            sectionLabels: {'catalog_item': sectionLabel},
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
            boardGameMainFieldIds,
            sectionLabel: 'Main',
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'edition',
          label: 'Edition Details',
          icon: Icons.inventory_2_outlined,
          content: buildFields(
            boardGameEditionFieldIds,
            sectionLabel: 'Edition',
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'gameplay',
          label: 'Gameplay & Ratings',
          icon: Icons.casino_outlined,
          content: buildFields(
            boardGamePlayFieldIds,
            sectionLabel: 'Gameplay and ratings',
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'description',
          label: 'Description',
          icon: Icons.description_outlined,
          content: buildFields(
            boardGameDescriptionFieldIds,
            sectionLabel: 'Description',
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'covers',
          label: 'Covers',
          icon: Icons.camera_alt_outlined,
          content: buildFields(
            boardGameCoverFieldIds,
            sectionLabel: 'Cover',
          ),
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
