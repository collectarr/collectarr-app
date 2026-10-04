import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec_renderer.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_credits_editor.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_characters_editor.dart';
import 'package:flutter/material.dart';

class MovieAddManualPane extends StatelessWidget {
  const MovieAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final draft = request.manualDraftAs<MovieAddManualDraft>();
    return LibraryAddManualPaneShell(
      request: request,
      tabs: [
        LibraryAddManualPaneTab(
          id: 'main',
          label: 'Main',
          icon: Icons.movie_outlined,
          content: LibraryFieldSpecRenderer<MovieAddManualDraft>.embedded(
            schema: movieAddSchemaFor(
              fieldIds: movieMainFieldIds,
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
          label: 'Edition details',
          icon: Icons.info_outline,
          content: LibraryFieldSpecRenderer<MovieAddManualDraft>.embedded(
            schema: movieAddSchemaFor(
              fieldIds: movieEditionFieldIds,
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
          content: LibraryFieldSpecRenderer<MovieAddManualDraft>.embedded(
            schema: movieAddSchemaFor(
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
          content: LibraryFieldSpecRenderer<MovieAddManualDraft>.embedded(
            schema: movieAddSchemaFor(
              fieldIds: movieSpecsFieldIds,
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
          content: LibraryFieldSpecRenderer<MovieAddManualDraft>.embedded(
            schema: movieCoverAddSchema,
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
              MovieCreditsEditor(
                title: 'Cast',
                emptyMessage: 'No cast credits yet.',
                addLabel: 'Add Cast',
                defaultRole: 'Actor',
                accent: request.accent,
                credits: draft.castCredits,
                onChanged: request.onManualDraftChanged,
              ),
              const SizedBox(height: 12),
              MovieCharactersEditor(
                characters: draft.values.characters,
                onChanged: (characters) {
                  draft.values.characters = characters;
                  request.onManualDraftChanged?.call();
                },
              ),
            ],
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'crew',
          label: 'Crew',
          icon: Icons.work_outline,
          content: MovieCreditsEditor(
            title: 'Crew',
            emptyMessage: 'No crew credits yet.',
            addLabel: 'Add Crew',
            defaultRole: 'Director',
            accent: request.accent,
            credits: draft.crewCredits,
            onChanged: request.onManualDraftChanged,
          ),
        ),
      ],
    );
  }
}

Widget buildMovieAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) =>
    MovieAddManualPane(request: request);
