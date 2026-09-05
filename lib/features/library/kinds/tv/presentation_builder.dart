import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/video_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/add/library_add_video_preview_sections.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_shelf_drilldown.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:flutter/material.dart';

const tvMetadataLabels = LibraryMetadataLabels(
  identitySectionTitle: 'Series identity',
  contextSectionTitle: 'Broadcast context',
  creditsSectionTitle: 'Cast & Crew',
  values: {'creators': 'Cast & Crew'},
);

class TvLibraryMediaPresentationBuilder
    extends VideoLibraryMediaPresentationBuilder {
  const TvLibraryMediaPresentationBuilder()
      : super(
          showSummary: true,
          metadataLabels: tvMetadataLabels,
          itemNumberLabel: 'Edition no.',
          publisherLabel: 'Studio',
          variantLabel: 'Format / Edition',
          barcodeLabel: 'UPC / Barcode',
          shelfDrilldownEntryTypes: const {'tv'},
        );

  @override
  List<Widget> buildAddPreviewSections({
    required Color accent,
    required CatalogMediaKind kind,
    required String provider,
    required String providerItemId,
  }) {
    return [
      VideoAddPreviewSeasonsSection(
        kind: kind,
        provider: provider,
        providerItemId: providerItemId,
        accent: accent,
      ),
    ];
  }

  @override
  Widget? buildKindDrilldown({
    required BuildContext context,
    required LibraryProjectionRuntime selectedItem,
    required Color accent,
    required double coverSize,
    required VoidCallback onBack,
    required Future<void> Function() onRefreshFromCore,
    required VoidCallback onOpenTitleDetails,
    required List<OwnedItem> ownedCopies,
    required List<WishlistItem> wishlistItems,
    required String? selectedReleaseId,
    required void Function(String releaseId) onSelectRelease,
    required LibraryWorkspaceProjector projector,
  }) {
    return TvShelfSeasonDrilldown(
      titleItem: selectedItem,
      coverSize: coverSize,
      accent: accent,
      onBack: onBack,
      onRefreshFromCore: onRefreshFromCore,
      onOpenTitleDetails: onOpenTitleDetails,
    );
  }
}
