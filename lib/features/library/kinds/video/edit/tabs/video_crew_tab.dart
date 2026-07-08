import 'package:collectarr_app/features/library/kinds/video/edit/tabs/video_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/video/edit/tabs/video_edit_tab_helpers.dart';
import 'package:collectarr_app/features/library/kinds/video/edit/video_edit_controller.dart';
import 'package:flutter/material.dart';

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
    return buildVideoCreditsTab(
      title: 'Crew',
      emptyMessage: 'No crew data yet.',
      addLabel: 'Add Crew',
      accent: accent,
      credits: videoEdit.crewCredits,
      onAdd: () => videoEdit.crewCredits.add(EditableVideoCredit.custom(role: 'Director')),
    );
  }
}
