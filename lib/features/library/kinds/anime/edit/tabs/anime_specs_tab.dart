import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_tab_helpers.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_controller.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:flutter/material.dart';

class AnimeEditSpecsTab extends StatelessWidget {
  const AnimeEditSpecsTab({
    super.key,
    required this.draft,
    required this.animeEdit,
    required this.accent,
    required this.audioTrackOptions,
    required this.subtitleOptions,
    required this.layersOptions,
    required this.colorOptions,
  });

  final LibraryEditDraft draft;
  final AnimeEditController animeEdit;
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
              buildAnimeResponsiveFields([
                LibraryVocabularyField(
                  label: 'Audio tracks',
                  controller: animeEdit.audioTracksController,
                  options: audioTrackOptions,
                  multiSelect: true,
                ),
                LibraryVocabularyField(
                  label: 'Subtitles',
                  controller: animeEdit.subtitlesController,
                  options: subtitleOptions,
                  multiSelect: true,
                ),
              ]),
              const SizedBox(height: 10),
              buildAnimeResponsiveFields([
                LibraryVocabularyField(
                  label: 'Layers',
                  controller: animeEdit.layersController,
                  options: layersOptions,
                ),
                LibraryVocabularyField(
                  label: 'Color',
                  controller: animeEdit.colorController,
                  options: colorOptions,
                ),
                buildAnimeField(
                  controller: animeEdit.nrDiscsController,
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
