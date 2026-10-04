import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_tab_helpers.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_draft_contract.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:flutter/material.dart';

class MovieEditSpecsTab extends StatelessWidget {
  const MovieEditSpecsTab({
    super.key,
    required this.movieDraft,
    required this.accent,
    required this.audioTrackOptions,
    required this.subtitleOptions,
  });

  final MovieEditDraftContract movieDraft;
  final Color accent;
  final List<String> audioTrackOptions;
  final List<String> subtitleOptions;

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
                  controller: movieDraft.audioTracksController,
                  options: audioTrackOptions,
                  multiSelect: true,
                ),
                LibraryVocabularyField(
                  label: 'Subtitles',
                  controller: movieDraft.subtitlesController,
                  options: subtitleOptions,
                  multiSelect: true,
                ),
              ]),
              const SizedBox(height: 10),
              buildMovieResponsiveFields([
                LibraryEditTextField(
                  label: 'Layers',
                  controller: movieDraft.layersController,
                ),
                LibraryEditTextField(
                  label: 'Color',
                  controller: movieDraft.colorController,
                ),
                buildMovieField(
                  controller: movieDraft.nrDiscsController,
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
