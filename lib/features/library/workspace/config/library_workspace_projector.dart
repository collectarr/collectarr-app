import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';

final class LibraryReleaseState {
  const LibraryReleaseState({
    required this.isOwned,
    required this.isWishlisted,
    required this.isTracked,
    this.referenceEditionId,
    this.referenceVariantId,
    this.referenceBundleReleaseId,
  });

  final bool isOwned;
  final bool isWishlisted;
  final bool isTracked;
  final String? referenceEditionId;
  final String? referenceVariantId;
  final String? referenceBundleReleaseId;
}

abstract interface class LibraryWorkspaceProjector<
    TDto extends LibraryWorkspaceDto> {
  TDto projectTitle({
    required ShelfEntry source,
    required LibraryTitleNodeRef node,
  });

  TDto projectRelease({
    required ShelfEntry source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  });

  TDto projectCopy({
    required ShelfEntry source,
    required LibraryCopyNodeRef node,
  });
}
