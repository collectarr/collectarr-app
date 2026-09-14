import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_tab_helpers.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_controller.dart';
import 'package:flutter/material.dart';

class MovieEditCrewTab extends StatelessWidget {
  const MovieEditCrewTab({
    super.key,
    required this.accent,
    required this.movieEdit,
  });

  final Color accent;
  final MovieEditController movieEdit;

  @override
  Widget build(BuildContext context) {
    return buildMovieCreditsTab(
      title: 'Crew',
      emptyMessage: 'No crew data yet.',
      addLabel: 'Add Crew',
      accent: accent,
      credits: movieEdit.crewCredits,
      onAdd: () => movieEdit.crewCredits
          .add(EditableMovieCredit.custom(role: 'Director')),
    );
  }
}
