import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/shared/video/library_video_credits_section.dart';
import 'package:flutter/material.dart';

class AnimeEditCastTab extends StatelessWidget {
  const AnimeEditCastTab({
    super.key,
    required this.accent,
    required this.animeEdit,
    required this.markDirty,
  });

  final Color accent;
  final AnimeEditController animeEdit;
  final VoidCallback markDirty;

  @override
  Widget build(BuildContext context) {
    return LibraryVideoCreditsSection(
      title: 'Cast',
      emptyMessage: 'No cast data yet.',
      addLabel: 'Add Cast',
      accent: accent,
      credits: [
        for (final credit in animeEdit.castCredits)
          LibraryVideoCreditControllers(
            identity: credit,
            name: credit.nameController,
            role: credit.roleController,
          ),
      ],
      onAdd: () =>
          animeEdit.castCredits.add(EditableAnimeCredit.custom(role: 'Actor')),
      onChanged: markDirty,
    );
  }
}
