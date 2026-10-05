import 'package:collectarr_app/features/library/kinds/music/add/music_add_images_pane.dart';
import 'package:collectarr_app/features/library/edit/sections/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_personal_pane.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_status_strip.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_details_form_pane.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_managed_vocabulary_field.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_main_form_section.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/schema/library_form_schema.dart';
import 'package:collectarr_app/features/library/schema/library_form_schema_validation.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_credits_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_covers_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_tracks_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
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
    final mainSection = musicMainFormSection<MusicAddManualDraft>(
      fields: fieldsById.values,
      titleFieldId: 'catalog_title',
    );
    final mainSchema = LibraryFormSchema<MusicAddManualDraft>(
      validate: musicAddSchema.validate,
      sections: [mainSection],
    );
    return LibraryAddManualPaneShell(
      request: request,
      footerContent: MusicAddStatusStrip(request: request),
      tabs: [
        LibraryAddManualPaneTab.fromSchema<MusicAddManualDraft>(
          id: 'main',
          label: 'Main',
          icon: Icons.music_note_outlined,
          schema: mainSchema,
          draft: draft,
          mediaKind: request.kind.apiValue,
          onVocabularyValueChanged: request.onVocabularyValueChanged,
          onVocabularyValuesChanged: request.onVocabularyValuesChanged,
          onChanged: request.onManualDraftChanged,
          validateSchema: true,
        ),
        LibraryAddManualPaneTab.fromForm<MusicAddManualDraft>(
          id: 'details',
          label: 'Details',
          icon: Icons.info_outline,
          schema: musicAddSchema,
          draft: draft,
          content: MusicDetailsFormPane<MusicAddManualDraft>(
            draft: draft,
            values: (draft) => draft.values,
            onChanged: request.onManualDraftChanged,
            onVocabularyValueChanged: request.onVocabularyValueChanged,
            onVocabularyValuesChanged: request.onVocabularyValuesChanged,
            packageCondition: LibraryManagedVocabularyField(
                label: 'Package/Sleeve Condition',
                listName: MusicVocabularies.condition.key,
                mediaKind: 'music',
                value: request.commonDraft?.condition,
                builtIns: MusicVocabularies.condition.builtIns,
                onChanged: (value) {
                  request.onCommonDraftChanged?.call(
                      request.commonDraft!.copyWith(condition: value ?? ''));
                  request.onVocabularyValueChanged?.call(
                      fieldId: 'condition',
                      listName: MusicVocabularies.condition.key,
                      value: value);
                }),
            mediaCondition: LibraryManagedVocabularyField(
                label: 'Media Condition',
                listName: MusicVocabularies.mediaCondition.key,
                mediaKind: 'music',
                value: personalDraft.mediaCondition,
                builtIns: MusicVocabularies.mediaCondition.builtIns,
                onChanged: (value) {
                  request.onKindDraftChanged
                      ?.call(personalDraft.copyWith(mediaCondition: value));
                  request.onVocabularyValueChanged?.call(
                      fieldId: 'media_condition',
                      listName: MusicVocabularies.mediaCondition.key,
                      value: value);
                }),
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'classical',
          label: 'Classical',
          icon: Icons.queue_music_outlined,
          validate: (_) => _validateCredits(draft, classical: true),
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
          validate: (_) => _validateCredits(draft, classical: false),
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
          validate: (_) => _validateTrackDurations(draft),
          content: MusicAddManualTracksTab(
            request: request,
            draft: draft,
            accent: request.accent,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'personal',
          label: 'Personal',
          icon: Icons.person_outline,
          content: MusicAddPersonalPane(request: request),
        ),
        LibraryAddManualPaneTab(
            id: 'custom_fields',
            label: 'Custom Fields',
            icon: Icons.tune_outlined,
            content: CustomFieldsEditSection(
                definitions: request.customFieldDefinitions,
                values: request.customFieldValues,
                accent: request.accent,
                mediaKind: 'music',
                onChanged: (values) =>
                    request.onCustomFieldValuesChanged?.call(values),
                onCustomValueChanged: (id, value) =>
                    request.onVocabularyValueChanged?.call(
                        fieldId: 'customField:$id',
                        listName: 'customField:$id',
                        value: value))),
        LibraryAddManualPaneTab(
          id: 'covers',
          label: 'Covers',
          icon: Icons.photo_camera_outlined,
          content: MusicAddManualCoversTab(draft: draft, request: request),
        ),
        LibraryAddManualPaneTab(
            id: 'my_images',
            label: 'My Images',
            icon: Icons.collections_outlined,
            content: MusicAddImagesPane(request: request)),
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

LibraryFormValidationIssue? _validateCredits(
  MusicAddManualDraft draft, {
  required bool classical,
}) {
  final credits = classical
      ? [
          ...draft.composers,
          ...draft.conductors,
          ...draft.choruses,
          ...draft.compositions,
          ...draft.orchestras,
        ]
      : [
          ...draft.songwriters,
          ...draft.producers,
          ...draft.engineers,
          ...draft.musicians,
        ];
  if (credits.any((credit) => credit.name.trim().isEmpty)) {
    return const LibraryFormValidationIssue(
      'Complete or remove each unfinished music credit',
    );
  }
  return null;
}

LibraryFormValidationIssue? _validateTrackDurations(
  MusicAddManualDraft draft,
) {
  for (final disc in draft.discs) {
    for (final track in disc.tracks) {
      if (track.duration.trim().isNotEmpty && track.durationMs == null) {
        return const LibraryFormValidationIssue(
          'Enter a valid track length in seconds, MM:SS, or HH:MM:SS.',
        );
      }
    }
  }
  return null;
}

Widget buildMusicAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) =>
    MusicAddManualPane(request: request);
