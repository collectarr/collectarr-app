import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:flutter/material.dart';

/// Shared physical-media specification editor used by video kinds.
///
/// Movie and TV can provide managed audio/subtitle vocabularies. Anime omits
/// those options and keeps the same fields as free text.
final class LibraryVideoSpecsSection extends StatelessWidget {
  const LibraryVideoSpecsSection({
    super.key,
    required this.accent,
    required this.audioTracksController,
    required this.subtitlesController,
    required this.screenRatioController,
    required this.layersController,
    required this.colorController,
    required this.discsController,
    this.audioTrackOptions,
    this.subtitleOptions,
  });

  final Color accent;
  final TextEditingController audioTracksController;
  final TextEditingController subtitlesController;
  final TextEditingController screenRatioController;
  final TextEditingController layersController;
  final TextEditingController colorController;
  final TextEditingController discsController;
  final List<String>? audioTrackOptions;
  final List<String>? subtitleOptions;

  @override
  Widget build(BuildContext context) => EditTabShell(
        children: [
          EditSection(
            title: 'Specs',
            accent: accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LibraryEditDenseFields(
                  wideColumns: 2,
                  ultraWideColumns: 2,
                  wideBreakpoint: 600,
                  ultraWideBreakpoint: 600,
                  children: [
                    _audioTracksField(),
                    _subtitlesField(),
                  ],
                ),
                const SizedBox(height: 10),
                LibraryEditDenseFields(
                  wideColumns: 2,
                  ultraWideColumns: 2,
                  wideBreakpoint: 600,
                  ultraWideBreakpoint: 600,
                  children: [
                    LibraryEditTextField(
                      label: 'Screen ratio',
                      controller: screenRatioController,
                    ),
                    LibraryEditTextField(
                      label: 'Layers',
                      controller: layersController,
                    ),
                    LibraryEditTextField(
                      label: 'Color',
                      controller: colorController,
                    ),
                    LibraryEditTextField(
                      label: 'Discs',
                      controller: discsController,
                      validator: optionalIntValidator,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );

  Widget _audioTracksField() {
    final options = audioTrackOptions;
    if (options == null || options.isEmpty) {
      return LibraryEditTextField(
        label: 'Audio tracks',
        controller: audioTracksController,
      );
    }
    return LibraryVocabularyField(
      label: 'Audio tracks',
      controller: audioTracksController,
      options: options,
      multiSelect: true,
    );
  }

  Widget _subtitlesField() {
    final options = subtitleOptions;
    if (options == null || options.isEmpty) {
      return LibraryEditTextField(
        label: 'Subtitles',
        controller: subtitlesController,
      );
    }
    return LibraryVocabularyField(
      label: 'Subtitles',
      controller: subtitlesController,
      options: options,
      multiSelect: true,
    );
  }
}
