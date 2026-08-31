import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

const _boardGameTabs0 = LibraryEditTabSpec(
  id: 'main',
  icon: Icons.casino_outlined,
  label: 'Main',
  sectionIds: [
    'catalog_snapshot',
    'tracking_context',
    'ownership_reference',
    'owned_grading',
  ],
);

const _boardGameSecondaryTabs = [
  LibraryEditTabSpec(
    id: 'synopsis',
    icon: Icons.description_outlined,
    label: 'Description',
    sectionIds: ['synopsis'],
  ),
  LibraryEditTabSpec(
    id: 'links',
    icon: Icons.public,
    label: 'Links',
    sectionIds: ['external_links'],
  ),
  LibraryEditTabSpec(
    id: 'cover',
    icon: Icons.photo_camera_outlined,
    label: 'Covers',
    sectionIds: ['cover_images'],
  ),
  LibraryEditTabSpec(
    id: 'photos',
    icon: Icons.image_outlined,
    label: 'My Images',
    sectionIds: ['photos'],
  ),
];

const _boardGameTabs = [
  _boardGameTabs0,
  ..._boardGameSecondaryTabs,
];

const _boardGameReleaseIdentityTab = LibraryEditTabSpec(
  id: 'release',
  icon: Icons.album_outlined,
  label: 'Release',
  sectionIds: ['release_identity'],
);

const _boardGameCombinedTabs = [
  _boardGameTabs0,
  _boardGameReleaseIdentityTab,
  ..._boardGameSecondaryTabs,
];

class BoardGameLibraryEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const BoardGameLibraryEditPresentationBuilder()
      : super(
          ownedTabs: _boardGameTabs,
          trackedTabs: _boardGameTabs,
          catalogTabs: _boardGameTabs,
        );
}

Widget? buildBoardGameCustomTabView({
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
                  text: item.titleExtension ?? '',
                ),
                variantController: TextEditingController(),
                barcodeController: TextEditingController(),
                releaseDateController: draft.metadata.releaseDateController,
                releaseYearController: draft.metadata.releaseYearController,
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
  return null;
}

class BoardGameLibraryCombinedEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const BoardGameLibraryCombinedEditPresentationBuilder()
      : super(
          ownedTabs: _boardGameCombinedTabs,
          trackedTabs: _boardGameCombinedTabs,
          catalogTabs: _boardGameCombinedTabs,
          customTabBuilder: buildBoardGameCustomTabView,
        );
}

const boardGamesLibraryEditPresentation = LibraryEditPresentation(
  builder: BoardGameLibraryCombinedEditPresentationBuilder(),
  mediaBuilder: BoardGameLibraryEditPresentationBuilder(),
  releaseBuilder: BoardGameLibraryEditPresentationBuilder(),
);
