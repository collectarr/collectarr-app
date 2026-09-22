import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class GenericWorkspaceDto implements LibraryWorkspaceDto {
  GenericWorkspaceDto({
    required this.common,
    required this.personal,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;

  @override
  String get primaryLabel => common.title;

  @override
  String? get imageUrl => common.coverImageUrl;

  @override
  String? get secondaryLabel => null;

  @override
  Iterable<String> get searchTokens => const <String>[];
}

final class GenericWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<GenericWorkspaceDto> {
  const GenericWorkspaceProjector();

  @override
  GenericWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
    LibraryReleaseState? releaseState,
  }) {
    return GenericWorkspaceDto(
      common: WorkspaceCommonProjection.fromStructuralShelf(source, entity),
      personal:
          PersonalCopyProjection.fromShelf(source, releaseState: releaseState),
    );
  }
}
