import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_edit_presentation_builder_base.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/boardgame_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/entry/boardgame_entry_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/vocabulary/boardgame_vocabularies.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

const _boardGameTabs0 = LibraryEditTabSpec(
  id: 'main',
  icon: Icons.casino_outlined,
  label: 'Main',
  sectionIds: [
    'catalog_snapshot',
    'tracking_context',
    'entries_reference',
    'entry_grading',
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

const _boardGameReleaseIdentityTab = LibraryEditTabSpec(
  id: 'edition',
  icon: Icons.album_outlined,
  label: 'Edition Details',
  sectionIds: ['release_identity'],
);

const _boardGameEntryTab = LibraryEditTabSpec(
  id: 'entry',
  icon: Icons.inventory_2,
  label: 'Personal',
);

const _boardGameCombinedTabs = [
  _boardGameTabs0,
  _boardGameEntryTab,
  _boardGameReleaseIdentityTab,
  ..._boardGameSecondaryTabs,
];

Widget? buildBoardGameCustomTabView({
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
    if (kindDraft is! BoardGameEditDraft) {
      throw StateError(
          'Expected BoardGameEditDraft for BoardGame entry editing');
    }
    final detailsDraft =
        kindDraft.toDetailsDraft() as BoardgameEntryDetailsDraft;
    final details = detailsDraft.toDetails();
    return EditSchemaRenderer<BoardgameEntryDetails, BoardGameEditDraft>.embedded(
      schema: boardGameEntryEditSchema,
      model: details,
      draft: kindDraft,
      mediaKind: draft.type.kind.apiValue,
      showTabBar: false,
    );
  }
  if (tabId == 'edition') {
    final kindDraft = draft.session.catalogItemSession;
    if (kindDraft is! BoardGameEditDraft) {
      throw StateError(
        'Expected BoardGameEditDraft for Board Game edition editing',
      );
    }
    final physicalFormatOptions = <String>{
      for (final format in draft.physicalFormats) format.label,
      ...BoardGameVocabularies.format.builtIns,
    }.toList(growable: false);
    return EditTabShell(
      children: [
        EditSection(
          title: 'Edition Details',
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LibraryReleaseIdentityFields(
                editionTitleController: kindDraft.editionTitleController,
                variantController: kindDraft.variantController,
                barcodeController: kindDraft.barcodeController,
                releaseDateController: kindDraft.releaseDateController,
                releaseYearController: kindDraft.releaseYearController,
                physicalFormatController: kindDraft.physicalFormatController,
                physicalFormatOptions: physicalFormatOptions,
                onPhysicalFormatChanged: (value) {
                  kindDraft.physicalFormatController.text = value ?? '';
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
  return null;
}

class BoardGameLibraryCombinedEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const BoardGameLibraryCombinedEditPresentationBuilder()
      : super(
          useEntryMainArtworkLayout: false,
          useDetailsTab: false,
          useArtworkCoverTab: false,
          useArtworkPhotosTab: false,
          trackingSectionTitle: 'Tracking edition',
          entryDigitalTrackingSectionTitle: 'EntryPolicy details',
          entryDigitalTrackingHint:
              'Digital items keep tracking, notes, and value fields, while physical media fields stay disabled.',
          entryTabs: _boardGameCombinedTabs,
          trackedTabs: _boardGameCombinedTabs,
          catalogTabs: _boardGameCombinedTabs,
          customTabBuilder: buildBoardGameCustomTabView,
        );
}

const boardGamesLibraryEditPresentation = LibraryEditPresentation(
  builder: BoardGameLibraryCombinedEditPresentationBuilder(),
);
