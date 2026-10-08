import 'package:flutter/material.dart';

@immutable
final class LibraryTrackingSessionLabels {
  const LibraryTrackingSessionLabels({
    required this.title,
    required this.trackingStatusTitle,
    required this.nounSingular,
    required this.nounPlural,
    required this.addTooltip,
    required this.emptyText,
    required this.icon,
  });

  final String title;
  final String trackingStatusTitle;
  final String nounSingular;
  final String nounPlural;
  final String addTooltip;
  final String emptyText;
  final IconData icon;

  static const watch = LibraryTrackingSessionLabels(
    title: 'Watch history',
    trackingStatusTitle: 'Watched',
    nounSingular: 'watch',
    nounPlural: 'watches',
    addTooltip: 'Log a watch',
    emptyText: 'No watches logged yet.',
    icon: Icons.visibility,
  );

  static const read = LibraryTrackingSessionLabels(
    title: 'Read history',
    trackingStatusTitle: 'Read',
    nounSingular: 'read',
    nounPlural: 'reads',
    addTooltip: 'Log a read',
    emptyText: 'No reads logged yet.',
    icon: Icons.menu_book_outlined,
  );

  static const listen = LibraryTrackingSessionLabels(
    title: 'Listen history',
    trackingStatusTitle: 'Played',
    nounSingular: 'listen',
    nounPlural: 'listens',
    addTooltip: 'Log a listen',
    emptyText: 'No listens logged yet.',
    icon: Icons.headphones_outlined,
  );

  static const play = LibraryTrackingSessionLabels(
    title: 'Play history',
    trackingStatusTitle: 'Played',
    nounSingular: 'play',
    nounPlural: 'plays',
    addTooltip: 'Log a play',
    emptyText: 'No plays logged yet.',
    icon: Icons.sports_esports_outlined,
  );
}

/// Whole-item tracking belongs to the local entry; repeated child progress is
/// keyed by the same entry plus kind-owned content coordinates.
enum LibraryTrackingTarget { libraryEntry, content }

extension LibraryTrackingTargetLabels on LibraryTrackingTarget {
  String get apiValue => switch (this) {
        LibraryTrackingTarget.libraryEntry => 'library_entry',
        LibraryTrackingTarget.content => 'content',
      };
}

/// Kind-entry tracking topology.
///
/// Tracking state belongs to a local library entry. Contained repeated content
/// can keep its own progress, aggregated under that entry's Catalog Item.
@immutable
final class LibraryTrackingTopology {
  const LibraryTrackingTopology({
    this.writableTargets = const <LibraryTrackingTarget>{},
    this.aggregateTargets = const <LibraryTrackingTarget>{},
    this.contentTargets = const <LibraryTrackingTarget>{},
    this.sessionLabels = LibraryTrackingSessionLabels.watch,
  });

  final Set<LibraryTrackingTarget> writableTargets;
  final Set<LibraryTrackingTarget> aggregateTargets;
  final Set<LibraryTrackingTarget> contentTargets;
  final LibraryTrackingSessionLabels sessionLabels;

  bool canWrite(LibraryTrackingTarget target) =>
      writableTargets.contains(target);

  bool aggregates(LibraryTrackingTarget target) =>
      aggregateTargets.contains(target);

  bool isContentTarget(LibraryTrackingTarget target) =>
      contentTargets.contains(target);
}
