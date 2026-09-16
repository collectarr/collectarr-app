import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';

final class LibraryReleaseState {
  const LibraryReleaseState({
    required this.isOwned,
    required this.isWishlisted,
    required this.isTracked,
    this.trackingSummary,
  });

  final bool isOwned;
  final bool isWishlisted;
  final bool isTracked;
  final TrackingSummary? trackingSummary;
}

/// Projects one kind-owned entity into the generic workspace DTO boundary.
///
/// The entity ref carries the structural scope, so a projector has one
/// semantic operation instead of three methods that every kind had to fake.
abstract interface class LibraryEntityWorkspaceProjector<
    TDto extends LibraryWorkspaceDto> {
  TDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
    LibraryReleaseState? releaseState,
  });
}
