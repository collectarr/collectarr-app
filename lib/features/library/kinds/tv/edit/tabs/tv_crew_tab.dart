import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_tab_helpers.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_controller.dart';
import 'package:flutter/material.dart';

class TvEditCrewTab extends StatelessWidget {
  const TvEditCrewTab({
    super.key,
    required this.accent,
    required this.tvEdit,
  });

  final Color accent;
  final TvEditController tvEdit;

  @override
  Widget build(BuildContext context) {
    return buildTvCreditsTab(
      title: 'Crew',
      emptyMessage: 'No crew data yet.',
      addLabel: 'Add Crew',
      accent: accent,
      credits: tvEdit.crewCredits,
      onAdd: () =>
          tvEdit.crewCredits.add(EditableTvCredit.custom(role: 'Director')),
    );
  }
}
