part of 'video_edit_tabs.dart';

class VideoEditCrewTab extends StatelessWidget {
  const VideoEditCrewTab({
    super.key,
    required this.accent,
    required this.videoEdit,
  });

  final Color accent;
  final VideoEditController videoEdit;

  @override
  Widget build(BuildContext context) {
    return _creditsTab(
      context: context,
      title: 'Crew',
      emptyMessage: 'No crew data yet.',
      addLabel: 'Add Crew',
      accent: accent,
      credits: videoEdit.crewCredits,
      defaultRole: 'Director',
      onAdd: () => videoEdit.crewCredits.add(EditableVideoCredit.custom(role: 'Director')),
    );
  }
}
