import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/video/video_library_media_presentation_builder.dart';
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
  creators: 'Cast & Crew',
);

class TvLibraryMediaPresentationBuilder
    extends VideoLibraryMediaPresentationBuilder {
  const TvLibraryMediaPresentationBuilder()
      : super(
          showSummary: true,
          metadataLabels: tvMetadataLabels,
        );

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
