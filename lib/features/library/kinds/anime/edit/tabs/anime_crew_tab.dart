import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/shared/video/library_video_credits_section.dart';
import 'package:flutter/material.dart';

class AnimeEditCrewTab extends StatelessWidget {
  const AnimeEditCrewTab({
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
      title: 'Crew',
      emptyMessage: 'No crew data yet.',
      addLabel: 'Add Crew',
      accent: accent,
      credits: [
        for (final credit in animeEdit.crewCredits)
          LibraryVideoCreditControllers(
            identity: credit,
            name: credit.nameController,
            role: credit.roleController,
          ),
      ],
      onAdd: () => animeEdit.crewCredits
          .add(EditableAnimeCredit.custom(role: 'Director')),
      onRemove: (index) => animeEdit.crewCredits.removeAt(index).dispose(),
      onReorder: (oldIndex, newIndex) {
        final credit = animeEdit.crewCredits.removeAt(oldIndex);
        animeEdit.crewCredits.insert(newIndex, credit);
      },
      onChanged: markDirty,
    );
  }
}
