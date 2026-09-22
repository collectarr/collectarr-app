import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:flutter/foundation.dart';
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

/// Structural targets understood by a kind's tracking integration.
///
/// `work`, `release`, and `copy` are the common library entity scopes. The
/// `content` target is intentionally separate because kinds such as TV,
/// Anime, Comic, and Manga track seasons, episodes, volumes, or chapters
/// inside the work/release shell.
enum LibraryTrackingTargetScope { work, release, copy, content }

enum LibraryTrackingLookupScope {
  exactCatalog,
  rootCatalog,
}

enum LibraryOwnedTrackingTarget {
  catalog,
  owned,
}

extension LibraryTrackingTargetScopeLabels on LibraryTrackingTargetScope {
  String get apiValue => switch (this) {
        LibraryTrackingTargetScope.work => 'work',
        LibraryTrackingTargetScope.release => 'release',
        LibraryTrackingTargetScope.copy => 'copy',
        LibraryTrackingTargetScope.content => 'content',
      };
}

/// Kind-owned tracking topology.
///
/// Tracking is deliberately not folded into the work/release/copy workspace
/// contract. A kind may expose a writable release state, a derived work
/// aggregate, and a separate content timeline at the same time.
@immutable
final class LibraryTrackingTopology {
  const LibraryTrackingTopology({
    this.writableTargets = const <LibraryTrackingTargetScope>{},
    this.aggregateTargets = const <LibraryTrackingTargetScope>{},
    this.contentTargets = const <LibraryTrackingTargetScope>{},
    this.lookupScope = LibraryTrackingLookupScope.rootCatalog,
    this.ownedTrackingTarget = LibraryOwnedTrackingTarget.owned,
    this.sessionLabels = LibraryTrackingSessionLabels.watch,
  });

  final Set<LibraryTrackingTargetScope> writableTargets;
  final Set<LibraryTrackingTargetScope> aggregateTargets;
  final Set<LibraryTrackingTargetScope> contentTargets;
  final LibraryTrackingLookupScope lookupScope;
  final LibraryOwnedTrackingTarget ownedTrackingTarget;
  final LibraryTrackingSessionLabels sessionLabels;

  bool get usesCatalogTargetForOwnedTracking =>
      ownedTrackingTarget == LibraryOwnedTrackingTarget.catalog;

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
