import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_tracking_editor_capability.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:flutter/material.dart';

typedef LibraryPersonalDetailFieldsBuilder = List<LibraryDetailField> Function({
  required BuildContext context,
  required LibraryProjectionView item,
  required LibraryEntrySummary? libraryEntry,
  required LibraryEntryDispatch? libraryEntryDispatch,
  required String? currency,
});

/// Kind-entry inspector contribution for one structural entity boundary.
final class LibraryTargetInspectorContributor {
  const LibraryTargetInspectorContributor({
    this.heroBuilder,
    this.sectionsBuilder,
    this.detailPageBuilder,
  });

  final LibraryInspectorHeroBuilder? heroBuilder;
  final LibraryDetailSectionsBuilder? sectionsBuilder;
  final LibraryDetailPageBuilder? detailPageBuilder;
}

final class LibraryTargetInspectorRegistry {
  const LibraryTargetInspectorRegistry({
    this.catalogItem,
    this.libraryEntry,
  });

  final LibraryTargetInspectorContributor? catalogItem;
  final LibraryTargetInspectorContributor? libraryEntry;

  LibraryTargetInspectorContributor? contributorForTarget(
    LibraryTargetRef target,
  ) =>
      switch (target) {
        CatalogTargetRef() => catalogItem,
        EntryTargetRef() => libraryEntry,
      };
}

/// Encapsulates inspector header, sections, and detail presentation for a media kind.
class LibraryInspectorCapability {
  const LibraryInspectorCapability({
    this.entityRegistry = const LibraryTargetInspectorRegistry(),
    this.mediaDetailContributionBuilder,
    this.showsDefaultPersonalSection = true,
    this.showsActionBar = true,
    this.supportsLibraryEntryImages = true,
    this.trackingEditor,
    this.personalDetailFieldsBuilder,
  });

  final LibraryTargetInspectorRegistry entityRegistry;
  final LibraryMediaDetailContributionBuilder? mediaDetailContributionBuilder;
  final bool showsDefaultPersonalSection;
  final bool showsActionBar;
  final bool supportsLibraryEntryImages;
  final LibraryTrackingEditorCapability? trackingEditor;
  final LibraryPersonalDetailFieldsBuilder? personalDetailFieldsBuilder;

  LibraryInspectorHeroBuilder? heroBuilderForTarget(LibraryTargetRef target) =>
      entityRegistry.contributorForTarget(target)?.heroBuilder;

  LibraryDetailPageBuilder? detailPageBuilderForTarget(
    LibraryTargetRef target,
  ) =>
      entityRegistry.contributorForTarget(target)?.detailPageBuilder;

  List<LibraryDetailField> buildPersonalDetailFields({
    required BuildContext context,
    required LibraryProjectionView item,
    required LibraryEntrySummary? libraryEntry,
    required LibraryEntryDispatch? libraryEntryDispatch,
    required String? currency,
  }) {
    return personalDetailFieldsBuilder?.call(
          context: context,
          item: item,
          libraryEntry: libraryEntry,
          libraryEntryDispatch: libraryEntryDispatch,
          currency: currency,
        ) ??
        const [];
  }

  List<Widget> buildSections(
    BuildContext context,
    LibraryInspectorRequest request,
  ) {
    final scoped = entityRegistry.contributorForTarget(request.item.target);
    return scoped?.sectionsBuilder?.call(context, request) ?? const [];
  }
}
