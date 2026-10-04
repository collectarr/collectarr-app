import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_draft_contract.dart';
import 'package:collectarr_app/features/library/kinds/shared/video/library_video_specs_section.dart';
import 'package:flutter/material.dart';

class AnimeEditSpecsTab extends StatelessWidget {
  const AnimeEditSpecsTab({
    super.key,
    required this.animeDraft,
    required this.accent,
  });

  final AnimeEditDraftContract animeDraft;
  final Color accent;

  @override
  Widget build(BuildContext context) => LibraryVideoSpecsSection(
        accent: accent,
        audioTracksController: animeDraft.audioTracksController,
        subtitlesController: animeDraft.subtitlesController,
        layersController: animeDraft.layersController,
        colorController: animeDraft.colorController,
        discsController: animeDraft.nrDiscsController,
      );
}
