import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:flutter/material.dart';

@immutable
final class LibraryTrackingSessionLabels {
  const LibraryTrackingSessionLabels({
    required this.title,
    required this.nounSingular,
    required this.nounPlural,
    required this.addTooltip,
    required this.emptyText,
    required this.icon,
  });

  final String title;
  final String nounSingular;
  final String nounPlural;
  final String addTooltip;
  final String emptyText;
  final IconData icon;

  static const watch = LibraryTrackingSessionLabels(
    title: 'Watch history',
    nounSingular: 'watch',
    nounPlural: 'watches',
    addTooltip: 'Log a watch',
    emptyText: 'No watches logged yet.',
    icon: Icons.visibility,
  );

  static const read = LibraryTrackingSessionLabels(
    title: 'Read history',
    nounSingular: 'read',
    nounPlural: 'reads',
    addTooltip: 'Log a read',
    emptyText: 'No reads logged yet.',
    icon: Icons.menu_book_outlined,
  );

  static const listen = LibraryTrackingSessionLabels(
    title: 'Listen history',
    nounSingular: 'listen',
    nounPlural: 'listens',
    addTooltip: 'Log a listen',
    emptyText: 'No listens logged yet.',
    icon: Icons.headphones_outlined,
  );

  static const play = LibraryTrackingSessionLabels(
    title: 'Play history',
    nounSingular: 'play',
    nounPlural: 'plays',
    addTooltip: 'Log a play',
    emptyText: 'No plays logged yet.',
    icon: Icons.sports_esports_outlined,
  );
}

/// Tracking may target a complete catalog item or one of its contained pieces.
enum LibraryTrackingTargetScope { catalogItem, content }

enum LibraryTrackingLookupScope {
  exactCatalog,
  rootCatalog,
}

extension LibraryTrackingTargetScopeLabels on LibraryTrackingTargetScope {
  String get apiValue => switch (this) {
        LibraryTrackingTargetScope.catalogItem => 'catalog_item',
        LibraryTrackingTargetScope.content => 'content',
      };
}

/// Kind-entry tracking topology.
///
/// Tracking state belongs to a local library entry. Contained repeated content
/// can keep its own progress, aggregated under that entry's Catalog Item.
@immutable
final class LibraryTrackingTopology {
  const LibraryTrackingTopology({
    this.writableTargets = const <LibraryTrackingTargetScope>{},
    this.aggregateTargets = const <LibraryTrackingTargetScope>{},
    this.contentTargets = const <LibraryTrackingTargetScope>{},
    this.lookupScope = LibraryTrackingLookupScope.rootCatalog,
    this.sessionLabels = LibraryTrackingSessionLabels.watch,
  });

  final Set<LibraryTrackingTargetScope> writableTargets;
  final Set<LibraryTrackingTargetScope> aggregateTargets;
  final Set<LibraryTrackingTargetScope> contentTargets;
  final LibraryTrackingLookupScope lookupScope;
  final LibraryTrackingSessionLabels sessionLabels;

  CatalogEntityRef lookupReferenceFor(CatalogEntityRef ref) =>
      lookupScope == LibraryTrackingLookupScope.exactCatalog
          ? ref
          : ref.rootScope;

  bool canWrite(LibraryTrackingTargetScope target) =>
      writableTargets.contains(target);

  bool aggregates(LibraryTrackingTargetScope target) =>
      aggregateTargets.contains(target);

  bool isContentTarget(LibraryTrackingTargetScope target) =>
      contentTargets.contains(target);
}
