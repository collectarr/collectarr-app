import 'package:collectarr_app/features/library/kinds/video/edit/tabs/video_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/video/edit/tabs/video_edit_tab_helpers.dart';
import 'package:collectarr_app/features/library/kinds/video/edit/video_edit_controller.dart';
import 'package:flutter/material.dart';

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
    return buildVideoCreditsTab(
      title: 'Cast',
      emptyMessage: 'No cast data yet.',
      addLabel: 'Add Cast',
      accent: accent,
      credits: videoEdit.castCredits,
      onAdd: () => videoEdit.castCredits.add(EditableVideoCredit.custom(role: 'Actor')),
    );
  }
}
