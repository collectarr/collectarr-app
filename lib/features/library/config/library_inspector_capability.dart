import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_tracking_editor_capability.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:flutter/material.dart';

typedef LibraryPersonalDetailFieldsBuilder = List<LibraryDetailField> Function({
  required BuildContext context,
  required LibraryProjectionView item,
  required OwnedItemSummary? ownedItem,
  required LibraryOwnedItemDispatch? ownedItemDispatch,
  required String? currency,
});

/// Kind-owned inspector contribution for one structural entity boundary.
final class LibraryEntityInspectorContributor {
  const LibraryEntityInspectorContributor({
    required this.scope,
    this.heroBuilder,
    this.sectionsBuilder,
    this.detailPageBuilder,
  });

  final LibraryEntityScope scope;
  final LibraryInspectorHeroBuilder? heroBuilder;
  final LibraryDetailSectionsBuilder? sectionsBuilder;
  final LibraryDetailPageBuilder? detailPageBuilder;
}

final class LibraryEntityInspectorRegistry {
  const LibraryEntityInspectorRegistry({
    this.contributors = const [],
  });

  final List<LibraryEntityInspectorContributor> contributors;

  LibraryEntityInspectorContributor? contributorForScope(
    LibraryEntityScope scope,
  ) {
    for (final contributor in contributors) {
      if (contributor.scope == scope) return contributor;
    }
    return null;
  }
}

/// Encapsulates inspector header, sections, and detail presentation for a media kind.
class LibraryInspectorCapability {
  const LibraryInspectorCapability({
    this.entityRegistry = const LibraryEntityInspectorRegistry(),
    this.mediaDetailContributionBuilder,
    this.showsDefaultPersonalSection = true,
    this.supportsOwnedItemImages = true,
    this.trackingEditor,
    this.personalDetailFieldsBuilder,
  });

  final LibraryEntityInspectorRegistry entityRegistry;
  final LibraryMediaDetailContributionBuilder? mediaDetailContributionBuilder;
  final bool showsDefaultPersonalSection;
  final bool supportsOwnedItemImages;
  final LibraryTrackingEditorCapability? trackingEditor;
  final LibraryPersonalDetailFieldsBuilder? personalDetailFieldsBuilder;

  LibraryInspectorHeroBuilder? heroBuilderForScope(LibraryEntityScope scope) =>
      entityRegistry.contributorForScope(scope)?.heroBuilder;

  LibraryDetailPageBuilder? detailPageBuilderForScope(
    LibraryEntityScope scope,
  ) =>
      entityRegistry.contributorForScope(scope)?.detailPageBuilder;

  List<LibraryDetailField> buildPersonalDetailFields({
    required BuildContext context,
    required LibraryProjectionView item,
    required OwnedItemSummary? ownedItem,
    required LibraryOwnedItemDispatch? ownedItemDispatch,
    required String? currency,
  }) {
    return personalDetailFieldsBuilder?.call(
          context: context,
          item: item,
          ownedItem: ownedItem,
          ownedItemDispatch: ownedItemDispatch,
          currency: currency,
        ) ??
        const [];
  }

  List<Widget> buildSections(
    BuildContext context,
    LibraryInspectorRequest request,
  ) {
    final scoped = entityRegistry.contributorForScope(request.item.node.scope);
    return scoped?.sectionsBuilder?.call(context, request) ?? const [];
  }
}
