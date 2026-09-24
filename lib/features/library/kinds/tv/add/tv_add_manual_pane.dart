import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_schema.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:flutter/material.dart';

class TvAddManualPane extends StatelessWidget {
  const TvAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final draft = request.manualDraftAs<TvAddManualDraft>();
    return LibraryAddManualPaneShell(
      request: request,
      title: 'Manual TV show setup',
      subtitle: 'Set series and release details before saving to your library.',
      identity: LibraryFormSection(
        title: 'Series identity',
        accent: request.accent,
        child: TextField(
          controller: request.titleController,
          decoration: const InputDecoration(
            labelText: 'Show title',
            prefixIcon: Icon(Icons.tv_outlined),
          ),
        ),
      ),
      formContent: AddSchemaRenderer<TvAddManualDraft>.embedded(
        schema: tvAddSchema,
        draft: draft,
      ),
    );
  }
}

Widget buildTvAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) =>
    TvAddManualPane(request: request);
