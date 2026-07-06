part of 'video_edit_tabs.dart';

class VideoEditSpecsTab extends StatelessWidget {
  const VideoEditSpecsTab({
    super.key,
    required this.draft,
    required this.videoEdit,
    required this.accent,
  });

  final LibraryEditDraft draft;
  final VideoEditController videoEdit;
  final Color accent;

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
                _field(controller: videoEdit.audioTracksController, label: 'Audio tracks'),
                _field(controller: videoEdit.subtitlesController, label: 'Subtitles'),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(controller: videoEdit.layersController, label: 'Layers'),
                _field(controller: videoEdit.colorController, label: 'Color'),
                _field(controller: videoEdit.nrDiscsController, label: 'Discs', validator: optionalIntValidator),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
