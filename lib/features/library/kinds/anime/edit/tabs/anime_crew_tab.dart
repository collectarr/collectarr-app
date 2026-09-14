import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_tab_helpers.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_controller.dart';
import 'package:flutter/material.dart';

class AnimeEditCrewTab extends StatelessWidget {
  const AnimeEditCrewTab({
    super.key,
    required this.accent,
    required this.animeEdit,
  });

  final Color accent;
  final AnimeEditController animeEdit;

  @override
  Widget build(BuildContext context) {
    return buildAnimeCreditsTab(
      title: 'Crew',
      emptyMessage: 'No crew data yet.',
      addLabel: 'Add Crew',
      accent: accent,
      credits: animeEdit.crewCredits,
      onAdd: () => animeEdit.crewCredits
          .add(EditableAnimeCredit.custom(role: 'Director')),
    );
  }
}
