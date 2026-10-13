import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_credits_editor.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_characters_editor.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_values.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:flutter/material.dart';

class MovieEditCastTab extends StatelessWidget {
  const MovieEditCastTab({
    super.key,
    required this.movieEdit,
    required this.catalogValues,
    required this.accent,
    required this.markDirty,
  });

  final MovieEditController movieEdit;
  final MovieCatalogFormValues catalogValues;
  final Color accent;
  final VoidCallback markDirty;

  @override
  Widget build(BuildContext context) {
    return EditTabShell(
      children: [
        MovieCreditsEditor(
          title: 'Cast',
          emptyMessage: 'No cast data yet.',
          addLabel: 'Add Cast',
          defaultRole: 'Actor',
          accent: accent,
          credits: movieEdit.castCredits,
          onChanged: markDirty,
        ),
        const SizedBox(height: 12),
        MovieCharactersEditor(
          characters: catalogValues.characters,
          onChanged: (characters) {
            catalogValues.characters = characters;
            markDirty();
          },
        ),
      ],
    );
  }
}
