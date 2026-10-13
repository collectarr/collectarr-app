import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';

/// Projects one kind-entry entity into the generic workspace DTO boundary.
///
/// The source owns the single local or Core target, so projection does not
/// accept a second identity that could disagree with it.
abstract interface class LibraryTargetWorkspaceProjector<
    TDto extends LibraryWorkspaceDto> {
  TDto project({
    required WorkspaceItem item,
    required PersonalOverlay personal,
  });
}
