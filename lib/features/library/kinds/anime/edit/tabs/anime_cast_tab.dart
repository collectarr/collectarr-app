import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_tab_helpers.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_controller.dart';
import 'package:flutter/material.dart';

class AnimeEditCastTab extends StatelessWidget {
  const AnimeEditCastTab({
    super.key,
    required this.accent,
    required this.animeEdit,
  });

  final Color accent;
  final AnimeEditController animeEdit;

  @override
  Widget build(BuildContext context) {
    return buildAnimeCreditsTab(
      title: 'Cast',
      emptyMessage: 'No cast data yet.',
      addLabel: 'Add Cast',
      accent: accent,
      credits: animeEdit.castCredits,
      onAdd: () =>
          animeEdit.castCredits.add(EditableAnimeCredit.custom(role: 'Actor')),
    );
  }
}
