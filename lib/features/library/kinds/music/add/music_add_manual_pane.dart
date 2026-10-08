import 'package:collectarr_app/features/library/kinds/music/add/music_add_images_pane.dart';
import 'package:collectarr_app/features/library/edit/sections/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_personal_pane.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_status_strip.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_details_form_pane.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_details_pane.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_managed_vocabulary_field.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_main_form_section.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'package:collectarr_app/features/library/forms/library_form_schema_validation.dart';
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
    final personalDraft = (request.kindDraft is MusicAddDraft)
        ? request.kindDraft as MusicAddDraft
        : const MusicAddDraft();
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
          svgAsset: 'assets/tab_icons/music.svg',
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
          svgAsset: 'assets/tab_icons/circle-info.svg',
          schema: musicAddSchema,
          draft: draft,
          content: MusicAddManualDetailsPane(
            draft: draft,
            request: request,
            generalContent: MusicDetailsFormPane<MusicAddManualDraft>(
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
        ),
        LibraryAddManualPaneTab(
          id: 'classical',
          label: 'Classical',
          svgAsset: 'assets/tab_icons/violin.svg',
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
          svgAsset: 'assets/tab_icons/users.svg',
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
          svgAsset: 'assets/tab_icons/list-ol.svg',
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
          svgAsset: 'assets/tab_icons/user.svg',
          content: MusicAddPersonalPane(request: request),
        ),
        LibraryAddManualPaneTab(
            id: 'custom_fields',
            label: 'Custom Fields',
            svgAsset: 'assets/tab_icons/pen-to-square.svg',
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
          svgAsset: 'assets/tab_icons/camera.svg',
          content: MusicAddManualCoversTab(draft: draft, request: request),
        ),
        LibraryAddManualPaneTab(
            id: 'my_images',
            label: 'My Images',
            svgAsset: 'assets/tab_icons/image.svg',
            content: MusicAddImagesPane(request: request)),
        LibraryAddManualPaneTab(
          id: 'links',
          label: 'Links',
          svgAsset: 'assets/tab_icons/globe.svg',
          content: MusicAddManualLinksTab(
            draft: draft,
            accent: request.accent,
          ),
        ),
      ],
    );
  }
}

LibraryFormValidationProblem? _validateCredits(
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
    return const LibraryFormValidationProblem(
      'Complete or remove each unfinished music credit',
    );
  }
  return null;
}

LibraryFormValidationProblem? _validateTrackDurations(
  MusicAddManualDraft draft,
) {
  for (final disc in draft.discs) {
    for (final track in disc.tracks) {
      if (track.duration.trim().isNotEmpty && track.durationMs == null) {
        return const LibraryFormValidationProblem(
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
