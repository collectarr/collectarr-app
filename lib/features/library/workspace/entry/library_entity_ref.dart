import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';

export 'package:collectarr_app/features/library/domain/library_entity_scope.dart';

/// Structural identity used by the generic library host.
///
/// Every node carries the complete containment path. A copy therefore never
/// needs a repository lookup to discover its release or work parent.
sealed class LibraryEntityRef {
  const LibraryEntityRef({required this.workId});

  final String workId;

  String get id;
  LibraryEntityScope get scope;
}

final class LibraryWorkRef extends LibraryEntityRef {
  const LibraryWorkRef({required super.workId});

  @override
  String get id => workId;

  @override
  LibraryEntityScope get scope => LibraryEntityScope.work;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LibraryWorkRef && other.workId == workId;
  }

  @override
  int get hashCode => workId.hashCode;
}

final class LibraryReleaseRef extends LibraryEntityRef {
  const LibraryReleaseRef({
    required super.workId,
    required this.releaseId,
    required this.release,
  });

  final String releaseId;
  final LibraryWorkspaceReleaseSummary release;

  @override
  String get id => '$workId:release:$releaseId';

  @override
  LibraryEntityScope get scope => LibraryEntityScope.release;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LibraryReleaseRef &&
            other.workId == workId &&
            other.releaseId == releaseId;
  }

  @override
  int get hashCode => Object.hash(workId, releaseId);
}

final class LibraryCopyRef extends LibraryEntityRef {
  const LibraryCopyRef({
    required super.workId,
    required this.releaseId,
    required this.ownedRef,
    this.copyId,
  });

  final String releaseId;
  final OwnedItemRef ownedRef;
  final String? copyId;

  @override
  String get id => '$workId:release:$releaseId:copy:${copyId ?? ownedRef.key}';

  @override
  LibraryEntityScope get scope => LibraryEntityScope.copy;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LibraryCopyRef &&
            other.workId == workId &&
            other.releaseId == releaseId &&
            other.ownedRef == ownedRef &&
            other.copyId == copyId;
  }

  @override
  int get hashCode => Object.hash(workId, releaseId, ownedRef, copyId);
}
