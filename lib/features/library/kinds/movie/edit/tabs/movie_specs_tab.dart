import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_tab_helpers.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_controller.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:flutter/material.dart';

class MovieEditSpecsTab extends StatelessWidget {
  const MovieEditSpecsTab({
    super.key,
    required this.draft,
    required this.movieEdit,
    required this.accent,
    required this.audioTrackOptions,
    required this.subtitleOptions,
    required this.layersOptions,
    required this.colorOptions,
  });

  final LibraryEditDraft draft;
  final MovieEditController movieEdit;
  final Color accent;
  final List<String> audioTrackOptions;
  final List<String> subtitleOptions;
  final List<String> layersOptions;
  final List<String> colorOptions;

  @override
  Widget build(BuildContext context) {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Specs',
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildMovieResponsiveFields([
                LibraryVocabularyField(
                  label: 'Audio tracks',
                  controller: movieEdit.audioTracksController,
                  options: audioTrackOptions,
                  multiSelect: true,
                ),
                LibraryVocabularyField(
                  label: 'Subtitles',
                  controller: movieEdit.subtitlesController,
                  options: subtitleOptions,
                  multiSelect: true,
                ),
              ]),
              const SizedBox(height: 10),
              buildMovieResponsiveFields([
                LibraryVocabularyField(
                  label: 'Layers',
                  controller: movieEdit.layersController,
                  options: layersOptions,
                ),
                LibraryVocabularyField(
                  label: 'Color',
                  controller: movieEdit.colorController,
                  options: colorOptions,
                ),
                buildMovieField(
                  controller: movieEdit.nrDiscsController,
                  label: 'Discs',
                  validator: optionalIntValidator,
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
