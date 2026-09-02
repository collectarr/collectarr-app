import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_values.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:flutter/material.dart';

import 'game_edit_draft.dart';

Widget? buildGameCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditDraft draft,
  required Color accent,
  required LibraryEditScope scope,
  required LibraryMetadataItem item,
  required VoidCallback markDirty,
}) {
  if (tabId == 'release') {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Release Details',
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LibraryReleaseIdentityFields(
                editionTitleController: TextEditingController(
                  text: libraryKindTitleExtension(item) ?? '',
                ),
                variantController: TextEditingController(),
                barcodeController: TextEditingController(),
                releaseDateController: (draft.kindDetails as GameEditDraft?)
                        ?.gameEdit
                        .releaseDateController ??
                    TextEditingController(),
                releaseYearController: (draft.kindDetails as GameEditDraft?)
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
  final gameDraft = draft.kindDetails is GameEditDraft
      ? draft.kindDetails as GameEditDraft
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
                controller: draft.metadata.titleController,
                label: 'Title',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              ),
              LibraryEditTextField(
                controller: draft.metadata.sortKeyController,
                label: 'Sort title',
              ),
            ]),
            const SizedBox(height: 10),
            LibraryEditResponsiveRow(children: [
              LibraryEditTextField(
                controller: draft.metadata.originalTitleController,
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
