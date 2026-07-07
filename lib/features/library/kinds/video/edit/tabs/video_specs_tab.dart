part of 'video_edit_tabs.dart';

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
              _responsiveFields([
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
              _responsiveFields([
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
                _field(controller: videoEdit.nrDiscsController, label: 'Discs', validator: optionalIntValidator),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
