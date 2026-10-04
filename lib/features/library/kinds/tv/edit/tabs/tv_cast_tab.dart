import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_catalog_form_edit_tab.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_credit_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_named_detail_list.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:flutter/material.dart';

class TvEditCastTab extends StatelessWidget {
  const TvEditCastTab({
    super.key,
    required this.accent,
    required this.state,
    required this.draft,
    required this.itemId,
    required this.markDirty,
  });

  final Color accent;
  final LibraryEditShellState state;
  final TvEditDraft draft;
  final String itemId;
  final VoidCallback markDirty;

  @override
  Widget build(BuildContext context) {
    return EditTabShell(
      children: [
        TvCatalogFormFields(
          state: state,
          draft: draft,
          itemId: itemId,
          fieldIds: const {'characters'},
          sectionLabel: 'Characters',
          markDirty: markDirty,
        ),
        const SizedBox(height: 12),
        LibraryNamedDetailList(
          title: 'Cast',
          emptyMessage: 'No cast data yet.',
          addLabel: 'Add Cast',
          accent: accent,
          removeTooltip: 'Remove cast credit',
          rows: () => [
            for (final credit in draft.tvEdit.castCredits)
              LibraryNamedDetailControllers(
                identity: credit,
                name: credit.nameController,
                detail: credit.roleController,
              ),
          ],
          onAdd: () => draft.tvEdit.castCredits
              .add(EditableTvCredit.custom(role: 'Actor')),
          onRemove: (index) =>
              draft.tvEdit.castCredits.removeAt(index).dispose(),
          onReorder: (oldIndex, newIndex) {
            final credit = draft.tvEdit.castCredits.removeAt(oldIndex);
            draft.tvEdit.castCredits.insert(newIndex, credit);
          },
          onChanged: markDirty,
        ),
      ],
    );
  }
}
