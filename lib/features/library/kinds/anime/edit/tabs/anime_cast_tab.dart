import 'package:collectarr_app/features/library/kinds/anime/forms/anime_credit_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_controller.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_named_detail_list.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
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
    return EditTabShell(
      children: [
        LibraryNamedDetailList(
          title: 'Cast',
          emptyMessage: 'No cast data yet.',
          addLabel: 'Add Cast',
          accent: accent,
          rows: () => [
            for (final credit in animeEdit.castCredits)
              LibraryNamedDetailControllers(
                identity: credit,
                name: credit.nameController,
                detail: credit.roleController,
              ),
          ],
          onAdd: () => animeEdit.castCredits
              .add(EditableAnimeCredit.custom(role: 'Actor')),
          onRemove: (index) => animeEdit.castCredits.removeAt(index).dispose(),
          onReorder: (oldIndex, newIndex) {
            final credit = animeEdit.castCredits.removeAt(oldIndex);
            animeEdit.castCredits.insert(newIndex, credit);
          },
          onChanged: markDirty,
        ),
      ],
    );
  }
}
