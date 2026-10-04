import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/forms/anime_credit_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_named_detail_list.dart';
import 'package:flutter/material.dart';

const _animeMainFieldIds = {
  'catalog_title',
  'sort_key',
  'format',
  'season',
  'source_material',
  'original_language',
  'genres',
  'themes',
  'studios',
  'producers',
  'licensors',
  'airing_status',
  'season_year',
  'episode_count',
  'episode_runtime_minutes',
  'start_date',
  'end_date',
};
const _animeDetailsFieldIds = {
  'native_title',
  'romaji_title',
  'english_title',
  'alternate_titles',
  'country',
  'characters',
};
const _animeEditionFieldIds = {
  'edition_title',
  'physical_format',
  'publisher',
  'barcode',
  'release_date',
  'variant_name',
  'region',
  'description',
};
const _animeSpecsFieldIds = {
  'nr_discs',
  'audio_tracks',
  'subtitles',
  'screen_ratio',
  'layers',
  'color',
};

class AnimeAddManualPane extends StatelessWidget {
  const AnimeAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final draft = request.manualDraftAs<AnimeAddManualDraft>();
    return LibraryAddManualPaneShell(
      request: request,
      tabs: [
        LibraryAddManualPaneTab.main(
          content: AddSchemaRenderer<AnimeAddManualDraft>.embedded(
            schema: animeAddSchemaFor(
              fieldIds: _animeMainFieldIds,
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
          id: 'media',
          label: 'Details',
          icon: Icons.article_outlined,
          content: AddSchemaRenderer<AnimeAddManualDraft>.embedded(
            schema: animeAddSchemaFor(
              fieldIds: _animeDetailsFieldIds,
              sectionLabel: 'Details',
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
          content: AddSchemaRenderer<AnimeAddManualDraft>.embedded(
            schema: animeAddSchemaFor(
              fieldIds: _animeEditionFieldIds,
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
          id: 'specs',
          label: 'Specs',
          icon: Icons.tune_outlined,
          content: AddSchemaRenderer<AnimeAddManualDraft>.embedded(
            schema: animeAddSchemaFor(
              fieldIds: _animeSpecsFieldIds,
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
          id: 'cover',
          label: 'Cover',
          icon: Icons.camera_alt_outlined,
          content: AddSchemaRenderer<AnimeAddManualDraft>.embedded(
            schema: animeAddSchemaFor(
              fieldIds: const {'cover_image_url'},
              sectionLabel: 'Cover',
            ),
            draft: draft,
            mediaKind: request.kind.apiValue,
            onChanged: request.onManualDraftChanged,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'synopsis',
          label: 'Synopsis',
          icon: Icons.description_outlined,
          content: AddSchemaRenderer<AnimeAddManualDraft>.embedded(
            schema: animeAddSchemaFor(
              fieldIds: const {'synopsis'},
              sectionLabel: 'Synopsis',
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
          content: LibraryNamedDetailList(
            title: 'Cast',
            emptyMessage: 'No cast data yet.',
            addLabel: 'Add Cast',
            accent: request.accent,
            removeTooltip: 'Remove cast credit',
            rows: () => [
              for (final credit in draft.castCredits)
                LibraryNamedDetailControllers(
                  identity: credit,
                  name: credit.nameController,
                  detail: credit.roleController,
                ),
            ],
            onAdd: () => draft.castCredits
                .add(EditableAnimeCredit.custom(role: 'Actor')),
            onRemove: (index) => draft.castCredits.removeAt(index).dispose(),
            onReorder: (oldIndex, newIndex) {
              final credit = draft.castCredits.removeAt(oldIndex);
              draft.castCredits.insert(newIndex, credit);
            },
            onChanged: request.onManualDraftChanged ?? () {},
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'crew',
          label: 'Crew',
          icon: Icons.work_outline,
          content: LibraryNamedDetailList(
            title: 'Crew',
            emptyMessage: 'No crew data yet.',
            addLabel: 'Add Crew',
            accent: request.accent,
            removeTooltip: 'Remove crew credit',
            rows: () => [
              for (final credit in draft.crewCredits)
                LibraryNamedDetailControllers(
                  identity: credit,
                  name: credit.nameController,
                  detail: credit.roleController,
                ),
            ],
            onAdd: () => draft.crewCredits
                .add(EditableAnimeCredit.custom(role: 'Director')),
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

Widget buildAnimeAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) =>
    AnimeAddManualPane(request: request);
