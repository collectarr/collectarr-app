import 'package:collectarr_app/features/library/kinds/shared/video/library_video_specs_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft_contract.dart';
import 'package:flutter/material.dart';

class TvEditSpecsTab extends StatelessWidget {
  const TvEditSpecsTab({
    super.key,
    required this.tvDraft,
    required this.accent,
    required this.audioTrackOptions,
    required this.subtitleOptions,
  });

  final TvEditDraftContract tvDraft;
  final Color accent;
  final List<String> audioTrackOptions;
  final List<String> subtitleOptions;

  @override
  Widget build(BuildContext context) => LibraryVideoSpecsSection(
        accent: accent,
        audioTracksController: tvDraft.audioTracksController,
        subtitlesController: tvDraft.subtitlesController,
        screenRatioController: tvDraft.screenRatioController,
        layersController: tvDraft.layersController,
        colorController: tvDraft.colorController,
        discsController: tvDraft.nrDiscsController,
        audioTrackOptions: audioTrackOptions,
        subtitleOptions: subtitleOptions,
      );
}
