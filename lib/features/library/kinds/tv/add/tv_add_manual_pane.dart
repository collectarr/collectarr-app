import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec_renderer.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_credit_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_named_detail_list.dart';
import 'package:flutter/material.dart';

class TvAddManualPane extends StatelessWidget {
  const TvAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final draft = request.manualDraftAs<TvAddManualDraft>();
    return LibraryAddManualPaneShell(
      request: request,
      tabs: [
        LibraryAddManualPaneTab.main(
          content: LibraryFieldSpecRenderer<TvAddManualDraft>.embedded(
            schema: tvAddSchemaFor(
              fieldIds: tvMainFieldIds,
              sectionLabel: 'Main',
            ),
            draft: draft,
            mediaKind: request.kind.apiValue,
            onVocabularyValueChanged: request.onVocabularyValueChanged,
            onVocabularyValuesChanged: request.onVocabularyValuesChanged,
            onChanged: request.onManualDraftChanged,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'edition',
          label: 'Edition',
          icon: Icons.inventory_2_outlined,
          content: LibraryFieldSpecRenderer<TvAddManualDraft>.embedded(
            schema: tvAddSchemaFor(
              fieldIds: tvEditionFieldIds,
              sectionLabel: 'Edition',
            ),
            draft: draft,
            mediaKind: request.kind.apiValue,
            onVocabularyValueChanged: request.onVocabularyValueChanged,
            onVocabularyValuesChanged: request.onVocabularyValuesChanged,
            onChanged: request.onManualDraftChanged,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'synopsis',
          label: 'Plot',
          icon: Icons.description_outlined,
          content: LibraryFieldSpecRenderer<TvAddManualDraft>.embedded(
            schema: tvAddSchemaFor(
              fieldIds: const {'synopsis'},
              sectionLabel: 'Plot',
            ),
            draft: draft,
            mediaKind: request.kind.apiValue,
            onChanged: request.onManualDraftChanged,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'specs',
          label: 'Specs',
          icon: Icons.tune_outlined,
          content: LibraryFieldSpecRenderer<TvAddManualDraft>.embedded(
            schema: tvAddSchemaFor(
              fieldIds: tvSpecsFieldIds,
              sectionLabel: 'Specs',
            ),
            draft: draft,
            mediaKind: request.kind.apiValue,
            onVocabularyValueChanged: request.onVocabularyValueChanged,
            onVocabularyValuesChanged: request.onVocabularyValuesChanged,
            onChanged: request.onManualDraftChanged,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'covers',
          label: 'Covers',
          icon: Icons.camera_alt_outlined,
          content: LibraryFieldSpecRenderer<TvAddManualDraft>.embedded(
            schema: tvAddSchemaFor(
              fieldIds: const {'cover_image_url'},
              sectionLabel: 'Covers',
            ),
            draft: draft,
            mediaKind: request.kind.apiValue,
            onChanged: request.onManualDraftChanged,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'cast',
          label: 'Cast',
          icon: Icons.people_outline,
          content: Column(
            children: [
              LibraryFieldSpecRenderer<TvAddManualDraft>.embedded(
                schema: tvAddSchemaFor(
                  fieldIds: const {'characters'},
                  sectionLabel: 'Characters',
                ),
                draft: draft,
                mediaKind: request.kind.apiValue,
                onChanged: request.onManualDraftChanged,
              ),
              const SizedBox(height: 12),
              LibraryNamedDetailList(
                title: 'Cast',
                emptyMessage: 'No cast data yet.',
                addLabel: 'Add Cast',
                accent: request.accent,
                removeTooltip: 'Remove cast credit',
                rows: () => [
                  for (final credit in draft.castCredits)
                    LibraryNamedDetailControllers(
                      identity: credit,
                      name: credit.nameController,
                      detail: credit.roleController,
                    ),
                ],
                onAdd: () => draft.castCredits
                    .add(EditableTvCredit.custom(role: 'Actor')),
                onRemove: (index) =>
                    draft.castCredits.removeAt(index).dispose(),
                onReorder: (oldIndex, newIndex) {
                  final credit = draft.castCredits.removeAt(oldIndex);
                  draft.castCredits.insert(newIndex, credit);
                },
                onChanged: request.onManualDraftChanged ?? () {},
              ),
            ],
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'crew',
          label: 'Crew',
          icon: Icons.work_outline,
          content: LibraryNamedDetailList(
            title: 'Crew',
            emptyMessage: 'No crew data yet.',
            addLabel: 'Add Crew',
            accent: request.accent,
            removeTooltip: 'Remove crew credit',
            rows: () => [
              for (final credit in draft.crewCredits)
                LibraryNamedDetailControllers(
                  identity: credit,
                  name: credit.nameController,
                  detail: credit.roleController,
                ),
            ],
            onAdd: () => draft.crewCredits
                .add(EditableTvCredit.custom(role: 'Director')),
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

Widget buildTvAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) =>
    TvAddManualPane(request: request);
