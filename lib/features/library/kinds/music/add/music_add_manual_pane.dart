import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_schema.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:flutter/material.dart';

class MusicAddManualPane extends StatelessWidget {
  const MusicAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final draft = request.manualDraftAs<MusicAddManualDraft>();
    return LibraryAddManualPaneShell(
      request: request,
      title: 'Manual music album setup',
      subtitle:
          'Capture the release identity before saving it to your library.',
      identity: LibraryFormSection(
        title: 'Album title',
        accent: request.accent,
        child: TextField(
          controller: request.titleController,
          decoration: const InputDecoration(
            labelText: 'Album title',
            prefixIcon: Icon(Icons.album_outlined),
          ),
        ),
      ),
      formContent: AddSchemaRenderer<MusicAddManualDraft>.embedded(
        schema: musicAddSchema,
        draft: draft,
        mediaKind: 'music',
      ),
    );
  }
}

Widget buildMusicAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) =>
    MusicAddManualPane(request: request);
