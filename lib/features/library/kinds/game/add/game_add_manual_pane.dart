import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_schema.dart';
import 'package:flutter/material.dart';

class GameAddManualPane extends StatelessWidget {
  const GameAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final draft = request.manualDraftAs<GameAddManualDraft>();
    return LibraryAddManualPaneShell(
      request: request,
      formContent: AddSchemaRenderer<GameAddManualDraft>.embedded(
        schema: gameAddSchema,
        draft: draft,
        mediaKind: request.kind.apiValue,
        onVocabularyValueChanged: request.onVocabularyValueChanged,
        onVocabularyValuesChanged: request.onVocabularyValuesChanged,
      ),
    );
  }
}

Widget buildGameAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) =>
    GameAddManualPane(request: request);
