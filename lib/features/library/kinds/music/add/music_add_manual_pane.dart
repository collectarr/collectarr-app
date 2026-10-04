import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_personal_tab.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_credits_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_covers_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_tracks_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_grade_field.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_signed_by_personal_field.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:flutter/material.dart';

class MusicAddManualPane extends StatelessWidget {
  const MusicAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final draft = request.manualDraftAs<MusicAddManualDraft>();
    final personalDraft = request.kindDraft;
    if (personalDraft is! MusicAddDraft) {
      throw StateError('Music Manual Add requires a MusicAddDraft.');
    }
    final fieldsById = {
      for (final section in musicAddSchema.sections)
        for (final field in section.fields) field.id: field,
    };
    const mainFieldIds = [
      'catalog_title',
      'release_date',
      'original_release_date',
      'sort_title',
      'record_label',
      'recording_date',
      'subtitle',
      'format',
      'barcode',
      'artist',
      'catalog_number',
      'genres',
    ];
    final mainSchema = AddSchema<MusicAddManualDraft>(
      validate: musicAddSchema.validate,
      sections: [
        AddSectionSpec<MusicAddManualDraft>(
          id: 'catalog_item',
          label: '',
          maxColumns: 4,
          fieldColumnSpans: const {
            'catalog_title': 2,
            'sort_title': 2,
            'subtitle': 2,
            'artist': 2,
            'catalog_number': 2,
            'genres': 2,
          },
          rightAlignedFieldIds: const {'genres'},
          fields: [
            for (final id in mainFieldIds) fieldsById[id]!,
          ],
        ),
      ],
    );
    final detailsSchema = AddSchema<MusicAddManualDraft>(
      sections: [
        AddSectionSpec<MusicAddManualDraft>(
          id: 'additional_details',
          label: 'Additional details',
          fields: [
            for (final section in musicAddSchema.sections)
              for (final field in section.fields)
                if (field.id != 'title' && !mainFieldIds.contains(field.id))
                  field,
          ],
        ),
      ],
    );

    return LibraryAddManualPaneShell(
      request: request,
      tabs: [
        LibraryAddManualPaneTab(
          id: 'main',
          label: 'Main',
          icon: Icons.music_note_outlined,
          content: AddSchemaRenderer<MusicAddManualDraft>.embedded(
            schema: mainSchema,
            draft: draft,
            mediaKind: request.kind.apiValue,
            onVocabularyValueChanged: request.onVocabularyValueChanged,
            onVocabularyValuesChanged: request.onVocabularyValuesChanged,
            onChanged: request.onManualDraftChanged,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'details',
          label: 'Details',
          icon: Icons.info_outline,
          content: AddSchemaRenderer<MusicAddManualDraft>.embedded(
            schema: detailsSchema,
            draft: draft,
            mediaKind: request.kind.apiValue,
            onVocabularyValueChanged: request.onVocabularyValueChanged,
            onVocabularyValuesChanged: request.onVocabularyValuesChanged,
            onChanged: request.onManualDraftChanged,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'classical',
          label: 'Classical',
          icon: Icons.queue_music_outlined,
          content: MusicAddManualCreditsTab(
            draft: draft,
            accent: request.accent,
            classical: true,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'people',
          label: 'People',
          icon: Icons.people_outline,
          content: MusicAddManualCreditsTab(
            draft: draft,
            accent: request.accent,
            classical: false,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'tracks',
          label: 'Tracks',
          icon: Icons.format_list_numbered,
          content: MusicAddManualTracksTab(
            draft: draft,
            accent: request.accent,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'personal',
          label: 'Personal',
          icon: Icons.person_outline,
          content: LibraryAddManualPersonalTab(
            request: request,
            kindSpecificFields: [
              MusicGradeField(
                value: personalDraft.grade,
                onChanged: (value) {
                  final update = request.onKindDraftChanged;
                  if (update == null) {
                    throw StateError(
                      'Music Manual Add has no kind-draft update callback.',
                    );
                  }
                  update(personalDraft.copyWith(grade: value));
                  request.onVocabularyValueChanged?.call(
                    fieldId: 'grade',
                    listName: MusicVocabularies.grade.key,
                    value: value == 'Ungraded' ? null : value,
                  );
                },
              ),
              MusicSignedByPersonalField(
                value: personalDraft.signedBy,
                onChanged: (value) {
                  final update = request.onKindDraftChanged;
                  if (update == null) {
                    throw StateError(
                      'Music Manual Add has no kind-draft update callback.',
                    );
                  }
                  update(personalDraft.copyWith(signedBy: value));
                  request.onVocabularyValuesChanged?.call(
                    fieldId: 'signed_by',
                    listName: 'music.signed_by',
                    values: splitPickListValues(value ?? '').toSet(),
                  );
                },
              ),
            ],
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'covers',
          label: 'Covers',
          icon: Icons.photo_camera_outlined,
          content: MusicAddManualCoversTab(draft: draft),
        ),
        LibraryAddManualPaneTab(
          id: 'links',
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
