import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_fields.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/entry/game_entry_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details_draft.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
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
  if (tabId == 'entry') {
    final kindDraft = draft.session.catalogItemSession;
    if (kindDraft is! GameEditDraft) {
      throw StateError('Expected GameEditDraft for Game entry editing');
    }
    final detailsDraft = kindDraft.toDetailsDraft() as GameEntryDetailsDraft;
    final details = detailsDraft.toDetails();
    return EditSchemaRenderer<GameEntryDetails, GameEditDraft>(
      schema: gameEntryEditSchema,
      model: details,
      draft: kindDraft,
      mediaKind: draft.type.kind.apiValue,
      showTabBar: false,
      showFooter: false,
      onSave: (_) {},
      onCancel: () {},
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
                editionTitleController: TextEditingController(
                  text: (item.gameCatalogFields.titleExtension ??
                              item.kindCapability
                                  .mapTransport((transport) => transport)
                                  .editionTitle)
                          ?.trim() ??
                      '',
                ),
                variantController: TextEditingController(),
                barcodeController: TextEditingController(),
                releaseDateController:
                    (draft.session.catalogItemSession as GameEditDraft?)
                            ?.gameEdit
                            .releaseDateController ??
                        TextEditingController(),
                releaseYearController:
                    (draft.session.catalogItemSession as GameEditDraft?)
                            ?.gameEdit
                            .releaseYearController ??
                        TextEditingController(),
                physicalFormatController: TextEditingController(),
                physicalFormatOptions: const [],
                onPhysicalFormatChanged: (_) {},
                editionTitleLabel: 'Edition title',
                variantLabel: 'Variant',
                barcodeLabel: 'UPC / Barcode',
                releaseDateLabel: 'Release date',
              ),
            ],
          ),
        ),
      ],
    );
  }
  if (tabId != 'main') return null;
  final gameDraft = draft.session.catalogItemSession is GameEditDraft
      ? draft.session.catalogItemSession as GameEditDraft
      : null;

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
                label: 'Sort title',
              ),
            ]),
            const SizedBox(height: 10),
            LibraryEditResponsiveRow(children: [
              LibraryEditTextField(
                controller: draft.formFields
                    .controller(GameCanonicalEditField.originalTitle),
                label: 'Original title',
              ),
              LibraryEditTextField(
                controller: gameDraft?.gameEdit.seriesTitleController ??
                    TextEditingController(),
                label: 'Series',
              ),
            ]),
            const SizedBox(height: 10),
            LibraryEditResponsiveRow(children: [
              LibraryEditTextField(
                controller: gameDraft?.gameEdit.publisherController ??
                    TextEditingController(),
                label: 'Publisher / Studio',
              ),
              LibraryEditTextField(
                controller: gameDraft?.gameEdit.releaseDateController ??
                    TextEditingController(),
                label: 'Release date',
              ),
            ]),
            if (gameDraft != null) ...[
              const SizedBox(height: 10),
              TagPickListField(
                controller: gameDraft.gameEdit.platformsController,
                options: const [
                  'PlayStation 5',
                  'Xbox Series X',
                  'Nintendo Switch',
                  'PC',
                  'PlayStation 4',
                  'Xbox One',
                ],
                label: 'Platform',
                hint: 'Select platforms',
              ),
            ],
          ],
        ),
      ),
    ],
  );
}
