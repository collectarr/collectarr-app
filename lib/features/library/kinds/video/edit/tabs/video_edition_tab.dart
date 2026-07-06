part of 'video_edit_tabs.dart';

class VideoEditEditionTab extends StatelessWidget {
  const VideoEditEditionTab({
    super.key,
    required this.type,
    required this.draft,
    required this.accent,
    required this.physicalFormats,
  });

  final LibraryTypeConfig type;
  final LibraryEditDraft draft;
  final Color accent;
  final List<dynamic> physicalFormats;

  @override
  Widget build(BuildContext context) {
    final releaseFields = type.releaseFields;
    return EditTabShell(
      children: [
        EditSection(
          title: 'Edition',
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveFields([
                _field(controller: draft.editionTitleController, label: releaseFields.editionTitleLabel),
                _field(controller: draft.variantController, label: releaseFields.variantLabel),
                _field(controller: draft.barcodeController, label: releaseFields.barcodeLabel),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
