import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_tab_helpers.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_controller.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:flutter/material.dart';

class TvEditSpecsTab extends StatelessWidget {
  const TvEditSpecsTab({
    super.key,
    required this.draft,
    required this.tvEdit,
    required this.accent,
    required this.audioTrackOptions,
    required this.subtitleOptions,
    required this.layersOptions,
    required this.colorOptions,
  });

  final LibraryEditDraft draft;
  final TvEditController tvEdit;
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
              buildTvResponsiveFields([
                LibraryVocabularyField(
                  label: 'Audio tracks',
                  controller: tvEdit.audioTracksController,
                  options: audioTrackOptions,
                  multiSelect: true,
                ),
                LibraryVocabularyField(
                  label: 'Subtitles',
                  controller: tvEdit.subtitlesController,
                  options: subtitleOptions,
                  multiSelect: true,
                ),
              ]),
              const SizedBox(height: 10),
              buildTvResponsiveFields([
                LibraryVocabularyField(
                  label: 'Layers',
                  controller: tvEdit.layersController,
                  options: layersOptions,
                ),
                LibraryVocabularyField(
                  label: 'Color',
                  controller: tvEdit.colorController,
                  options: colorOptions,
                ),
                buildTvField(
                  controller: tvEdit.nrDiscsController,
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
