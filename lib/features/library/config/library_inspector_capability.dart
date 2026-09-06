import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_tracking_editor_capability.dart';
import 'package:flutter/material.dart';

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
  });

  final LibraryInspectorHeroBuilder? heroBuilder;
  final LibraryDetailSectionsBuilder? sectionsBuilder;
  final LibraryDetailPageBuilder? detailPageBuilder;
  final LibraryVideoDetailContributionBuilder? videoDetailContributionBuilder;
  final bool showsDefaultPersonalSection;
  final bool showsCreatorSpotlight;
  final bool supportsOwnedItemImages;
  final LibraryTrackingEditorCapability? trackingEditor;

  List<Widget> buildSections(
    BuildContext context,
    LibraryInspectorRequest request,
  ) {
    return sectionsBuilder?.call(context, request) ?? const [];
  }
}
