import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec_renderer.dart';
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
    LibraryAddManualPaneTab schemaTab({
      required String id,
      required String label,
      required IconData icon,
      required LibraryFormSchema<TvAddManualDraft> schema,
      bool validateSchema = false,
      bool vocabularies = false,
    }) =>
        LibraryAddManualPaneTab.fromSchema<TvAddManualDraft>(
          id: id,
          label: label,
          icon: icon,
          schema: schema,
          draft: draft,
          mediaKind: request.kind.apiValue,
          onVocabularyValueChanged:
              vocabularies ? request.onVocabularyValueChanged : null,
          onVocabularyValuesChanged:
              vocabularies ? request.onVocabularyValuesChanged : null,
          onChanged: request.onManualDraftChanged,
          validateSchema: validateSchema,
        );

    return LibraryAddManualPaneShell(
      request: request,
      tabs: [
        schemaTab(
          id: 'main',
          label: 'Main',
          icon: Icons.edit_note_outlined,
          schema: tvAddSchemaFor(
            fieldIds: tvMainFieldIds,
            sectionLabel: 'Main',
          ),
          validateSchema: true,
          vocabularies: true,
        ),
        schemaTab(
          id: 'edition',
          label: 'Edition',
          icon: Icons.inventory_2_outlined,
          schema: tvAddSchemaFor(
            fieldIds: tvEditionFieldIds,
            sectionLabel: 'Edition',
          ),
          vocabularies: true,
        ),
        schemaTab(
          id: 'synopsis',
          label: 'Plot',
          icon: Icons.description_outlined,
          schema: tvAddSchemaFor(
            fieldIds: const {'synopsis'},
            sectionLabel: 'Plot',
          ),
        ),
        schemaTab(
          id: 'specs',
          label: 'Specs',
          icon: Icons.tune_outlined,
          schema: tvAddSchemaFor(
            fieldIds: tvSpecsFieldIds,
            sectionLabel: 'Specs',
          ),
          vocabularies: true,
        ),
        schemaTab(
          id: 'covers',
          label: 'Covers',
          icon: Icons.camera_alt_outlined,
          schema: tvAddSchemaFor(
            fieldIds: const {'cover_image_url'},
            sectionLabel: 'Covers',
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
