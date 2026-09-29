import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_personal_tab.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_credits_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_covers_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_tracks_tab.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:flutter/material.dart';

class MusicAddManualPane extends StatelessWidget {
  const MusicAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final draft = request.manualDraftAs<MusicAddManualDraft>();
    final mainSchema = AddSchema<MusicAddManualDraft>(
      sections: musicAddSchema.sections
          .where((section) => section.id != 'technical')
          .toList(growable: false),
    );
    final detailsSchema = AddSchema<MusicAddManualDraft>(
      sections: musicAddSchema.sections
          .where((section) => section.id == 'technical')
          .toList(growable: false),
    );

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
      tabs: [
        LibraryAddManualPaneTab(
          label: 'Main',
          icon: Icons.music_note_outlined,
          content: AddSchemaRenderer<MusicAddManualDraft>.embedded(
            schema: mainSchema,
            draft: draft,
            mediaKind: request.kind.apiValue,
            onVocabularyValueChanged: request.onVocabularyValueChanged,
            onVocabularyValuesChanged: request.onVocabularyValuesChanged,
          ),
        ),
        LibraryAddManualPaneTab(
          label: 'Details',
          icon: Icons.info_outline,
          content: AddSchemaRenderer<MusicAddManualDraft>.embedded(
            schema: detailsSchema,
            draft: draft,
            mediaKind: request.kind.apiValue,
            onVocabularyValueChanged: request.onVocabularyValueChanged,
            onVocabularyValuesChanged: request.onVocabularyValuesChanged,
          ),
        ),
        LibraryAddManualPaneTab(
          label: 'Classical',
          icon: Icons.queue_music_outlined,
          content: MusicAddManualCreditsTab(
            draft: draft,
            accent: request.accent,
            classical: true,
          ),
        ),
        LibraryAddManualPaneTab(
          label: 'People',
          icon: Icons.people_outline,
          content: MusicAddManualCreditsTab(
            draft: draft,
            accent: request.accent,
            classical: false,
          ),
        ),
        LibraryAddManualPaneTab(
          label: 'Tracks',
          icon: Icons.format_list_numbered,
          content: MusicAddManualTracksTab(
            draft: draft,
            accent: request.accent,
          ),
        ),
        LibraryAddManualPaneTab(
          label: 'Personal',
          icon: Icons.person_outline,
          content: LibraryAddManualPersonalTab(request: request),
        ),
        LibraryAddManualPaneTab(
          label: 'Covers',
          icon: Icons.photo_camera_outlined,
          content: MusicAddManualCoversTab(draft: draft),
        ),
        LibraryAddManualPaneTab(
          label: 'Links',
          icon: Icons.public,
          content: MusicAddManualLinksTab(
            draft: draft,
            accent: request.accent,
          ),
        ),
      ],
    );
  }
}

Widget buildMusicAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) =>
    MusicAddManualPane(request: request);
