import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_draft_contract.dart';
import 'package:collectarr_app/features/library/kinds/shared/video/library_video_specs_section.dart';
import 'package:flutter/material.dart';

class MovieEditSpecsTab extends StatelessWidget {
  const MovieEditSpecsTab({
    super.key,
    required this.movieDraft,
    required this.accent,
    required this.audioTrackOptions,
    required this.subtitleOptions,
  });

  final MovieEditDraftContract movieDraft;
  final Color accent;
  final List<String> audioTrackOptions;
  final List<String> subtitleOptions;

  @override
  Widget build(BuildContext context) => LibraryVideoSpecsSection(
        accent: accent,
        audioTracksController: movieDraft.audioTracksController,
        subtitlesController: movieDraft.subtitlesController,
        layersController: movieDraft.layersController,
        colorController: movieDraft.colorController,
        discsController: movieDraft.nrDiscsController,
        audioTrackOptions: audioTrackOptions,
        subtitleOptions: subtitleOptions,
      );
}
