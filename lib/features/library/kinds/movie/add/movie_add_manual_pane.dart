import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/schema/library_form_schema.dart';
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
    LibraryAddManualPaneTab schemaTab({
      required String id,
      required String label,
      required IconData icon,
      required LibraryFormSchema<MovieAddManualDraft> schema,
      bool validateSchema = false,
      bool vocabularies = false,
    }) =>
        LibraryAddManualPaneTab.fromSchema<MovieAddManualDraft>(
          id: id,
          label: label,
          icon: icon,
          schema: schema,
          draft: draft,
          mediaKind: request.kind.apiValue,
          onVocabularyValueChanged:
              vocabularies ? request.onVocabularyValueChanged : null,
          onVocabularyValuesChanged:
              vocabularies ? request.onVocabularyValuesChanged : null,
          onChanged: request.onManualDraftChanged,
          validateSchema: validateSchema,
        );

    return LibraryAddManualPaneShell(
      request: request,
      tabs: [
        schemaTab(
          id: 'main',
          label: 'Main',
          icon: Icons.movie_outlined,
          schema: movieAddSchemaFor(
            fieldIds: movieMainFieldIds,
            sectionLabel: 'Main',
          ),
          validateSchema: true,
          vocabularies: true,
        ),
        schemaTab(
          id: 'edition',
          label: 'Edition details',
          icon: Icons.info_outline,
          schema: movieAddSchemaFor(
            fieldIds: movieEditionFieldIds,
            sectionLabel: 'Edition',
          ),
          vocabularies: true,
        ),
        schemaTab(
          id: 'synopsis',
          label: 'Plot',
          icon: Icons.description_outlined,
          schema: movieAddSchemaFor(
            fieldIds: const {'synopsis'},
            sectionLabel: 'Plot',
          ),
        ),
        schemaTab(
          id: 'specs',
          label: 'Specs',
          icon: Icons.tune_outlined,
          schema: movieAddSchemaFor(
            fieldIds: movieSpecsFieldIds,
            sectionLabel: 'Specs',
          ),
          vocabularies: true,
        ),
        schemaTab(
          id: 'covers',
          label: 'Covers',
          icon: Icons.camera_alt_outlined,
          schema: movieCoverAddSchema,
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
