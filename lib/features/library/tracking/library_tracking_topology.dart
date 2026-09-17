import 'package:flutter/foundation.dart';

/// Structural targets understood by a kind's tracking integration.
///
/// `work`, `release`, and `copy` are the common library entity scopes. The
/// `content` target is intentionally separate because kinds such as TV,
/// Anime, Comic, and Manga track seasons, episodes, volumes, or chapters
/// inside the work/release shell.
enum LibraryTrackingTargetScope { work, release, copy, content }

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
  });

  final Set<LibraryTrackingTargetScope> writableTargets;
  final Set<LibraryTrackingTargetScope> aggregateTargets;
  final Set<LibraryTrackingTargetScope> contentTargets;

  bool canWrite(LibraryTrackingTargetScope target) =>
      writableTargets.contains(target);

  bool aggregates(LibraryTrackingTargetScope target) =>
      aggregateTargets.contains(target);

  bool isContentTarget(LibraryTrackingTargetScope target) =>
      contentTargets.contains(target);
}
