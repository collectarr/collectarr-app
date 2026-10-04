import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/entry/game_entry_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:flutter/material.dart';

import 'game_edit_draft.dart';

Widget? buildGameCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditShellState draft,
  required Color accent,
  required LibraryEntityScope scope,
  required CatalogSearchCandidate item,
  required VoidCallback markDirty,
}) {
  final kindDraft = draft.session.catalogItemSession;
  if (kindDraft is! GameEditDraft) {
    throw StateError('Expected GameEditDraft for Game editing');
  }

  if (tabId == 'entry') {
    final detailsDraft = kindDraft.toDetailsDraft() as GameEntryDetailsDraft;
    final details = detailsDraft.toDetails();
    return EditSchemaRenderer<GameEntryDetails, GameEditDraft>.embedded(
      schema: gameEntryEditSchema,
      model: details,
      draft: kindDraft,
      mediaKind: draft.type.kind.apiValue,
      showTabBar: false,
    );
  }
  if (tabId == 'edition') {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Edition Details',
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LibraryReleaseIdentityFields(
                editionTitleController:
                    kindDraft.gameEdit.editionTitleController,
                variantController: kindDraft.gameEdit.variantController,
                barcodeController: kindDraft.gameEdit.barcodeController,
                releaseDateController: kindDraft.gameEdit.releaseDateController,
                releaseYearController: kindDraft.gameEdit.releaseYearController,
                physicalFormatController:
                    kindDraft.gameEdit.physicalFormatController,
                physicalFormatOptions: [
                  for (final format in draft.physicalFormats) format.label,
                ],
                onPhysicalFormatChanged: (value) {
                  kindDraft.gameEdit.physicalFormatId =
                      physicalMediaFormatByLabelOrId(
                    value,
                    formats: draft.physicalFormats,
                  )?.id;
                  markDirty();
                },
                editionTitleLabel: 'Edition title',
                variantLabel: 'Variant',
                barcodeLabel: 'UPC / Barcode',
                releaseDateLabel: 'Release Date',
              ),
            ],
          ),
        ),
      ],
    );
  }
  if (tabId != 'main') return null;

  return EditTabShell(
    children: [
      EditSection(
        title: 'Details',
        accent: accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LibraryEditResponsiveRow(children: [
              LibraryEditTextField(
                controller:
                    draft.formFields.controller(GameCanonicalEditField.title),
                label: 'Title',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              ),
              LibraryEditTextField(
                controller: draft.formFields
                    .controller(GameCanonicalEditField.sortTitle),
                label: 'Sort Title',
              ),
            ]),
            const SizedBox(height: 10),
            LibraryEditResponsiveRow(children: [
              LibraryEditTextField(
                controller: draft.formFields
                    .controller(GameCanonicalEditField.originalTitle),
                label: 'Original Title',
              ),
              LibraryEditTextField(
                controller: kindDraft.gameEdit.seriesTitleController,
                label: 'Series',
              ),
            ]),
            const SizedBox(height: 10),
            LibraryEditResponsiveRow(children: [
              LibraryEditTextField(
                controller: kindDraft.gameEdit.publisherController,
                label: 'Publisher / Studio',
              ),
              LibraryEditTextField(
                controller: kindDraft.gameEdit.releaseDateController,
                label: 'Release Date',
              ),
            ]),
            const SizedBox(height: 10),
            LibraryVocabularyField(
              controller: kindDraft.gameEdit.platformsController,
              options:
                  draft.kindVocabularies[GameVocabularyIds.platform.value] ??
                      const [],
              label: 'Platform',
              hint: 'Select platforms',
              multiSelect: true,
            ),
          ],
        ),
      ),
    ],
  );
}
