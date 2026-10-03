import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_tab_helpers.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_draft_contract.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:flutter/material.dart';

class AnimeEditSpecsTab extends StatelessWidget {
  const AnimeEditSpecsTab({
    super.key,
    required this.animeDraft,
    required this.accent,
    required this.audioTrackOptions,
    required this.subtitleOptions,
    required this.layersOptions,
    required this.colorOptions,
  });

  final AnimeEditDraftContract animeDraft;
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
                  controller: animeDraft.audioTracksController,
                  options: audioTrackOptions,
                  multiSelect: true,
                ),
                LibraryVocabularyField(
                  label: 'Subtitles',
                  controller: animeDraft.subtitlesController,
                  options: subtitleOptions,
                  multiSelect: true,
                ),
              ]),
              const SizedBox(height: 10),
              buildAnimeResponsiveFields([
                LibraryVocabularyField(
                  label: 'Layers',
                  controller: animeDraft.layersController,
                  options: layersOptions,
                ),
                LibraryVocabularyField(
                  label: 'Color',
                  controller: animeDraft.colorController,
                  options: colorOptions,
                ),
                buildAnimeField(
                  controller: animeDraft.nrDiscsController,
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
