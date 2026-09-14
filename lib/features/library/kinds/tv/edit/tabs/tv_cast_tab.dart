import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_tab_helpers.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_controller.dart';
import 'package:flutter/material.dart';

class TvEditCastTab extends StatelessWidget {
  const TvEditCastTab({
    super.key,
    required this.accent,
    required this.tvEdit,
  });

  final Color accent;
  final TvEditController tvEdit;

  @override
  Widget build(BuildContext context) {
    return buildTvCreditsTab(
      title: 'Cast',
      emptyMessage: 'No cast data yet.',
      addLabel: 'Add Cast',
      accent: accent,
      credits: tvEdit.castCredits,
      onAdd: () =>
          tvEdit.castCredits.add(EditableTvCredit.custom(role: 'Actor')),
    );
  }
}
