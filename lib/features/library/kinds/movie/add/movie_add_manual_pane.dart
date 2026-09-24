import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_schema.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:flutter/material.dart';

class MovieAddManualPane extends StatelessWidget {
  const MovieAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final draft = request.manualDraftAs<MovieAddManualDraft>();
    return LibraryAddManualPaneShell(
      request: request,
      title: 'Manual movie setup',
      subtitle:
          'Set the movie and release details before saving to your library.',
      identity: LibraryFormSection(
        title: 'Identity',
        accent: request.accent,
        child: TextField(
          controller: request.titleController,
          decoration: const InputDecoration(
            labelText: 'Movie title',
            prefixIcon: Icon(Icons.movie_creation_outlined),
          ),
        ),
      ),
      formContent: AddSchemaRenderer<MovieAddManualDraft>.embedded(
        schema: movieAddSchema,
        draft: draft,
      ),
    );
  }
}

Widget buildMovieAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) =>
    MovieAddManualPane(request: request);
