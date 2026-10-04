import 'package:collectarr_app/features/library/kinds/tv/forms/tv_credit_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/shared/video/library_video_credits_section.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:flutter/material.dart';

class TvEditCrewTab extends StatelessWidget {
  const TvEditCrewTab({
    super.key,
    required this.accent,
    required this.tvEdit,
    required this.markDirty,
  });

  final Color accent;
  final TvEditController tvEdit;
  final VoidCallback markDirty;

  @override
  Widget build(BuildContext context) {
    return EditTabShell(
      children: [
        LibraryVideoCreditsSection(
          title: 'Crew',
          emptyMessage: 'No crew data yet.',
          addLabel: 'Add Crew',
          accent: accent,
          credits: [
            for (final credit in tvEdit.crewCredits)
              LibraryVideoCreditControllers(
                identity: credit,
                name: credit.nameController,
                role: credit.roleController,
              ),
          ],
          onAdd: () =>
              tvEdit.crewCredits.add(EditableTvCredit.custom(role: 'Director')),
          onRemove: (index) => tvEdit.crewCredits.removeAt(index).dispose(),
          onReorder: (oldIndex, newIndex) {
            final credit = tvEdit.crewCredits.removeAt(oldIndex);
            tvEdit.crewCredits.insert(newIndex, credit);
          },
          onChanged: markDirty,
        ),
      ],
    );
  }
}
