import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_schema.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:flutter/material.dart';

class BoardgameAddManualPane extends StatelessWidget {
  const BoardgameAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final draft = request.manualDraftAs<BoardgameAddManualDraft>();
    return LibraryAddManualPaneShell(
      request: request,
      title: 'Manual board game setup',
      subtitle:
          'Set game title, designer, and publisher details before saving.',
      identity: LibraryFormSection(
        title: 'Board Game Title',
        accent: request.accent,
        child: TextField(
          controller: request.titleController,
          decoration: const InputDecoration(
            labelText: 'Board Game Title',
            prefixIcon: Icon(Icons.casino_outlined),
          ),
        ),
      ),
      formContent: AddSchemaRenderer<BoardgameAddManualDraft>.embedded(
        schema: boardGameAddSchema,
        draft: draft,
      ),
    );
  }
}

Widget buildBoardgameAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) =>
    BoardgameAddManualPane(request: request);
