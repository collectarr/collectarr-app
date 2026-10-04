import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_credit_draft.dart';
import 'package:collectarr_app/features/library/kinds/shared/video/library_video_credits_section.dart';
import 'package:flutter/material.dart';

const _tvMainFieldIds = {
  'catalog_title',
  'sort_key',
  'original_title',
  'country',
  'publisher',
  'language',
  'age_rating',
  'genres',
  'runtime_minutes',
  'season_number',
};

const _tvEditionFieldIds = {
  'edition_title',
  'variant_name',
  'physical_format',
  'release_date',
  'barcode',
};

const _tvSpecsFieldIds = {
  'audio_tracks',
  'subtitles',
  'nr_discs',
  'screen_ratio',
  'layers',
  'color',
};

class TvAddManualPane extends StatelessWidget {
  const TvAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final draft = request.manualDraftAs<TvAddManualDraft>();
    return LibraryAddManualPaneShell(
      request: request,
      tabs: [
        LibraryAddManualPaneTab.main(
          content: AddSchemaRenderer<TvAddManualDraft>.embedded(
            schema: tvAddSchemaFor(
              fieldIds: _tvMainFieldIds,
              sectionLabel: 'Main',
            ),
            draft: draft,
            mediaKind: request.kind.apiValue,
            onVocabularyValueChanged: request.onVocabularyValueChanged,
            onVocabularyValuesChanged: request.onVocabularyValuesChanged,
            onChanged: request.onManualDraftChanged,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'edition',
          label: 'Edition',
          icon: Icons.inventory_2_outlined,
          content: AddSchemaRenderer<TvAddManualDraft>.embedded(
            schema: tvAddSchemaFor(
              fieldIds: _tvEditionFieldIds,
              sectionLabel: 'Edition',
            ),
            draft: draft,
            mediaKind: request.kind.apiValue,
            onVocabularyValueChanged: request.onVocabularyValueChanged,
            onVocabularyValuesChanged: request.onVocabularyValuesChanged,
            onChanged: request.onManualDraftChanged,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'synopsis',
          label: 'Plot',
          icon: Icons.description_outlined,
          content: AddSchemaRenderer<TvAddManualDraft>.embedded(
            schema: tvAddSchemaFor(
              fieldIds: const {'synopsis'},
              sectionLabel: 'Plot',
            ),
            draft: draft,
            mediaKind: request.kind.apiValue,
            onChanged: request.onManualDraftChanged,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'specs',
          label: 'Specs',
          icon: Icons.tune_outlined,
          content: AddSchemaRenderer<TvAddManualDraft>.embedded(
            schema: tvAddSchemaFor(
              fieldIds: _tvSpecsFieldIds,
              sectionLabel: 'Specs',
            ),
            draft: draft,
            mediaKind: request.kind.apiValue,
            onVocabularyValueChanged: request.onVocabularyValueChanged,
            onVocabularyValuesChanged: request.onVocabularyValuesChanged,
            onChanged: request.onManualDraftChanged,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'covers',
          label: 'Covers',
          icon: Icons.camera_alt_outlined,
          content: AddSchemaRenderer<TvAddManualDraft>.embedded(
            schema: tvAddSchemaFor(
              fieldIds: const {'cover_image_url'},
              sectionLabel: 'Covers',
            ),
            draft: draft,
            mediaKind: request.kind.apiValue,
            onChanged: request.onManualDraftChanged,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'cast',
          label: 'Cast',
          icon: Icons.people_outline,
          content: Column(
            children: [
              AddSchemaRenderer<TvAddManualDraft>.embedded(
                schema: tvAddSchemaFor(
                  fieldIds: const {'characters'},
                  sectionLabel: 'Characters',
                ),
                draft: draft,
                mediaKind: request.kind.apiValue,
                onChanged: request.onManualDraftChanged,
              ),
              const SizedBox(height: 12),
              LibraryVideoCreditsSection(
                title: 'Cast',
                emptyMessage: 'No cast data yet.',
                addLabel: 'Add Cast',
                accent: request.accent,
                credits: [
                  for (final credit in draft.castCredits)
                    LibraryVideoCreditControllers(
                      identity: credit,
                      name: credit.nameController,
                      role: credit.roleController,
                    ),
                ],
                onAdd: () => draft.castCredits
                    .add(EditableTvCredit.custom(role: 'Actor')),
                onRemove: (index) =>
                    draft.castCredits.removeAt(index).dispose(),
                onReorder: (oldIndex, newIndex) {
                  final credit = draft.castCredits.removeAt(oldIndex);
                  draft.castCredits.insert(newIndex, credit);
                },
                onChanged: request.onManualDraftChanged ?? () {},
              ),
            ],
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'crew',
          label: 'Crew',
          icon: Icons.work_outline,
          content: LibraryVideoCreditsSection(
            title: 'Crew',
            emptyMessage: 'No crew data yet.',
            addLabel: 'Add Crew',
            accent: request.accent,
            credits: [
              for (final credit in draft.crewCredits)
                LibraryVideoCreditControllers(
                  identity: credit,
                  name: credit.nameController,
                  role: credit.roleController,
                ),
            ],
            onAdd: () => draft.crewCredits
                .add(EditableTvCredit.custom(role: 'Director')),
            onRemove: (index) => draft.crewCredits.removeAt(index).dispose(),
            onReorder: (oldIndex, newIndex) {
              final credit = draft.crewCredits.removeAt(oldIndex);
              draft.crewCredits.insert(newIndex, credit);
            },
            onChanged: request.onManualDraftChanged ?? () {},
          ),
        ),
      ],
    );
  }
}

Widget buildTvAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) =>
    TvAddManualPane(request: request);
