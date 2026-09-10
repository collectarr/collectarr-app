import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_tracking_editor_capability.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

typedef LibraryPersonalDetailFieldsBuilder = List<LibraryDetailField> Function({
  required BuildContext context,
  required LibraryProjectionView item,
  required OwnedItemSummary? ownedItem,
  required Object? typedOwnedItem,
  required String? currency,
});

/// Encapsulates inspector header, sections, and detail presentation for a media kind.
class LibraryInspectorCapability {
  const LibraryInspectorCapability({
    this.heroBuilder,
    this.sectionsBuilder,
    this.detailPageBuilder,
    this.videoDetailContributionBuilder,
    this.showsDefaultPersonalSection = true,
    this.showsCreatorSpotlight = false,
    this.supportsOwnedItemImages = true,
    this.trackingEditor,
    this.personalDetailFieldsBuilder,
  });

  final LibraryInspectorHeroBuilder? heroBuilder;
  final LibraryDetailSectionsBuilder? sectionsBuilder;
  final LibraryDetailPageBuilder? detailPageBuilder;
  final LibraryVideoDetailContributionBuilder? videoDetailContributionBuilder;
  final bool showsDefaultPersonalSection;
  final bool showsCreatorSpotlight;
  final bool supportsOwnedItemImages;
  final LibraryTrackingEditorCapability? trackingEditor;
  final LibraryPersonalDetailFieldsBuilder? personalDetailFieldsBuilder;

  List<LibraryDetailField> buildPersonalDetailFields({
    required BuildContext context,
    required LibraryProjectionView item,
    required OwnedItemSummary? ownedItem,
    required Object? typedOwnedItem,
    required String? currency,
  }) {
    return personalDetailFieldsBuilder?.call(
          context: context,
          item: item,
          ownedItem: ownedItem,
          typedOwnedItem: typedOwnedItem,
          currency: currency,
        ) ??
        const [];
  }

  List<Widget> buildSections(
    BuildContext context,
    LibraryInspectorRequest request,
  ) {
    return sectionsBuilder?.call(context, request) ?? const [];
  }
}
