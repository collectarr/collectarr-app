part of 'video_edit_tabs.dart';

class VideoEditCastTab extends StatelessWidget {
  const VideoEditCastTab({
    super.key,
    required this.accent,
    required this.videoEdit,
  });

  final Color accent;
  final VideoEditController videoEdit;

  @override
  Widget build(BuildContext context) {
    return _creditsTab(
      title: 'Cast',
      emptyMessage: 'No cast data yet.',
      addLabel: 'Add Cast',
      accent: accent,
      credits: videoEdit.castCredits,
      onAdd: () => videoEdit.castCredits.add(EditableVideoCredit.custom(role: 'Actor')),
    );
  }
}
