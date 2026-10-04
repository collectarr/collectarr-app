import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_credit_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_named_detail_list.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:flutter/material.dart';

class TvEditCastTab extends StatelessWidget {
  const TvEditCastTab({
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
        LibraryNamedDetailList(
          title: 'Cast',
          emptyMessage: 'No cast data yet.',
          addLabel: 'Add Cast',
          accent: accent,
          rows: () => [
            for (final credit in tvEdit.castCredits)
              LibraryNamedDetailControllers(
                identity: credit,
                name: credit.nameController,
                detail: credit.roleController,
              ),
          ],
          onAdd: () =>
              tvEdit.castCredits.add(EditableTvCredit.custom(role: 'Actor')),
          onRemove: (index) => tvEdit.castCredits.removeAt(index).dispose(),
          onReorder: (oldIndex, newIndex) {
            final credit = tvEdit.castCredits.removeAt(oldIndex);
            tvEdit.castCredits.insert(newIndex, credit);
          },
          onChanged: markDirty,
        ),
      ],
    );
  }
}
