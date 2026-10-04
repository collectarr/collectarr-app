import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/forms/anime_credit_draft.dart';
import 'package:collectarr_app/features/library/kinds/shared/video/library_video_credits_section.dart';
import 'package:flutter/material.dart';

class AnimeAddManualPane extends StatelessWidget {
  const AnimeAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final draft = request.manualDraftAs<AnimeAddManualDraft>();
    return LibraryAddManualPaneShell(
      request: request,
      tabs: [
        LibraryAddManualPaneTab.main(
          content: AddSchemaRenderer<AnimeAddManualDraft>.embedded(
            schema: animeAddSchema,
            draft: draft,
            mediaKind: request.kind.apiValue,
            onVocabularyValueChanged: request.onVocabularyValueChanged,
            onVocabularyValuesChanged: request.onVocabularyValuesChanged,
            onChanged: request.onManualDraftChanged,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'cast',
          label: 'Cast',
          icon: Icons.people_outline,
          content: LibraryVideoCreditsSection(
            title: 'Cast',
            emptyMessage: 'No cast data yet.',
            addLabel: 'Add Cast',
            accent: request.accent,
            credits: [
              for (final credit in draft.castCredits)
                LibraryVideoCreditControllers(
                  identity: credit,
                  name: credit.nameController,
                  role: credit.roleController,
                ),
            ],
            onAdd: () => draft.castCredits
                .add(EditableAnimeCredit.custom(role: 'Actor')),
            onRemove: (index) => draft.castCredits.removeAt(index).dispose(),
            onReorder: (oldIndex, newIndex) {
              final credit = draft.castCredits.removeAt(oldIndex);
              draft.castCredits.insert(newIndex, credit);
            },
            onChanged: request.onManualDraftChanged ?? () {},
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'crew',
          label: 'Crew',
          icon: Icons.work_outline,
          content: LibraryVideoCreditsSection(
            title: 'Crew',
            emptyMessage: 'No crew data yet.',
            addLabel: 'Add Crew',
            accent: request.accent,
            credits: [
              for (final credit in draft.crewCredits)
                LibraryVideoCreditControllers(
                  identity: credit,
                  name: credit.nameController,
                  role: credit.roleController,
                ),
            ],
            onAdd: () => draft.crewCredits
                .add(EditableAnimeCredit.custom(role: 'Director')),
            onRemove: (index) => draft.crewCredits.removeAt(index).dispose(),
            onReorder: (oldIndex, newIndex) {
              final credit = draft.crewCredits.removeAt(oldIndex);
              draft.crewCredits.insert(newIndex, credit);
            },
            onChanged: request.onManualDraftChanged ?? () {},
          ),
        ),
      ],
    );
  }
}

Widget buildAnimeAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) =>
    AnimeAddManualPane(request: request);
