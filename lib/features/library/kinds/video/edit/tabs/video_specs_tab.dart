import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/kinds/video/edit/tabs/video_edit_tab_helpers.dart';
import 'package:collectarr_app/features/library/kinds/video/edit/video_edit_controller.dart';
import 'package:flutter/material.dart';

class VideoEditSpecsTab extends StatelessWidget {
  const VideoEditSpecsTab({
    super.key,
    required this.draft,
    required this.videoEdit,
    required this.accent,
    required this.audioTrackOptions,
    required this.subtitleOptions,
    required this.layersOptions,
    required this.colorOptions,
  });

  final LibraryEditDraft draft;
  final VideoEditController videoEdit;
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
        buildVideoResponsiveFields([
                LibraryVocabularyField(
                  label: 'Audio tracks',
                  controller: videoEdit.audioTracksController,
                  options: audioTrackOptions,
                  multiSelect: true,
                ),
                LibraryVocabularyField(
                  label: 'Subtitles',
                  controller: videoEdit.subtitlesController,
                  options: subtitleOptions,
                  multiSelect: true,
                ),
              ]),
              const SizedBox(height: 10),
              buildVideoResponsiveFields([
                LibraryVocabularyField(
                  label: 'Layers',
                  controller: videoEdit.layersController,
                  options: layersOptions,
                ),
                LibraryVocabularyField(
                  label: 'Color',
                  controller: videoEdit.colorController,
                  options: colorOptions,
                ),
                buildVideoField(
                  controller: videoEdit.nrDiscsController,
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
