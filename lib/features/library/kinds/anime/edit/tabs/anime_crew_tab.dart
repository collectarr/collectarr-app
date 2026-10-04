import 'package:collectarr_app/features/library/kinds/anime/forms/anime_credit_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_controller.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_named_detail_list.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
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
    return EditTabShell(
      children: [
        LibraryNamedDetailList(
          title: 'Crew',
          emptyMessage: 'No crew data yet.',
          addLabel: 'Add Crew',
          accent: accent,
          credits: [
            for (final credit in animeEdit.crewCredits)
              LibraryNamedDetailControllers(
                identity: credit,
                name: credit.nameController,
                detail: credit.roleController,
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
        ),
      ],
    );
  }
}
