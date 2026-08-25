import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/manga/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const mangaWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.manga,
  title: 'Manga',
  icon: Icons.import_contacts_outlined,
  accent: Color(0xFFFF6F91),
  preferencePrefix: 'manga',
);

final mangaTransferableFields = <TransferableField>[
  TransferableField(
    key: 'signedBy',
    label: 'Signed by',
    icon: Icons.draw_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.mangaDetails?.signedBy,
    write: (item, value) {
      final m = item.mangaDetails ?? const MangaOwnedDetails();
      return item.copyWith(details: m.copyWith(signedBy: value));
    },
  ),
  TransferableField(
    key: 'gradingCompany',
    label: 'Grading company',
    icon: Icons.verified_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.mangaDetails?.gradingCompany,
    write: (item, value) {
      final m = item.mangaDetails ?? const MangaOwnedDetails();
      return item.copyWith(details: m.copyWith(gradingCompany: value));
    },
  ),
  TransferableField(
    key: 'graderNotes',
    label: 'Grader notes',
    icon: Icons.note_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.mangaDetails?.graderNotes,
    write: (item, value) {
      final m = item.mangaDetails ?? const MangaOwnedDetails();
      return item.copyWith(details: m.copyWith(graderNotes: value));
    },
  ),
  TransferableField(
    key: 'dustJacketPresent',
    label: 'Dust jacket',
    icon: Icons.book_outlined,
    type: TransferableFieldType.boolean,
    scope: LibraryEditScope.release,
    read: (item) =>
        (item.mangaDetails?.dustJacketPresent == true) ? 'true' : null,
    write: (item, value) {
      final m = item.mangaDetails ?? const MangaOwnedDetails();
      return item.copyWith(
          details: m.copyWith(dustJacketPresent: value == 'true'));
    },
  ),
  TransferableField(
    key: 'obiStripPresent',
    label: 'Obi strip',
    icon: Icons.bookmark_border,
    type: TransferableFieldType.boolean,
    scope: LibraryEditScope.release,
    read: (item) =>
        (item.mangaDetails?.obiStripPresent == true) ? 'true' : null,
    write: (item, value) {
      final m = item.mangaDetails ?? const MangaOwnedDetails();
      return item.copyWith(
          details: m.copyWith(obiStripPresent: value == 'true'));
    },
  ),
];

final mangaLibraryConfig = LibraryTypeConfig(
  workspace: mangaWorkspaceConfig,
  singularLabel: 'Manga',
  pluralLabel: 'Manga',
  defaultMetadataProvider: 'hardcover',
  metadataProviders: [
    hardcoverMetadataProvider,
    comicVineMetadataProvider,
    anilistMetadataProvider,
    mangadexMetadataProvider,
  ],
  trackingProfile: comicTrackingProfile,
  presentation: mangaLibraryMediaPresentation,
  editDialogBuilder: buildMangaLibraryEditDialog,
  inspectorSectionsBuilder: _emptyInspectorSectionsBuilder,
  editChrome: LibraryEditChromeConfig(
    titleUsesItemTitle: true,
    synopsisLabel: 'Plot',
    showsIssueBadge: true,
    showsPhysicalFormatBadge: true,
  ),
  mediaFields: MediaEditFields.print(
    numberLabel: 'Chapter / Vol.',
    publisherLabel: 'Publisher / Studio / Creator',
    releaseDateLabel: 'First published',
  ),
  collectionExportTitleLabel: 'Series',
  manualAddUsesTitleAsSeries: true,
  editUsesTitleAsSeries: true,
  releaseFields: ReleaseEditFields(
    variantLabel: 'Edition / Variant / Format',
    barcodeLabel: 'Barcode / UPC / ISBN',
    variantSeedsPhysicalFormatLabel: true,
  ),
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    canScanCover: true,
    supportsMediaReleaseSplit: true,
    supportsIndexReassignment: true,
    contentHierarchy: LibraryContentHierarchy.volumes,
    supportsSeriesSubgroups: true,
  ),
  showsDefaultInspectorPersonalSection: false,
);

List<Widget> _emptyInspectorSectionsBuilder(
  BuildContext context,
  LibraryInspectorRequest request,
) =>
    const [];
