import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_credits_editor.dart';
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
        LibraryAddManualPaneTab.main(
          content: AddSchemaRenderer<MovieAddManualDraft>.embedded(
            schema: movieAddSchema,
            draft: draft,
            mediaKind: request.kind.apiValue,
            onVocabularyValueChanged: request.onVocabularyValueChanged,
            onVocabularyValuesChanged: request.onVocabularyValuesChanged,
            onChanged: request.onManualDraftChanged,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'cast',
          label: 'Cast',
          icon: Icons.people_outline,
          content: MovieCreditsEditor(
            title: 'Cast',
            emptyMessage: 'No cast credits yet.',
            addLabel: 'Add Cast',
            defaultRole: 'Actor',
            credits: draft.castCredits,
            onChanged: request.onManualDraftChanged,
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
