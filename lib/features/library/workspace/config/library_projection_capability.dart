import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';

abstract interface class TitleProjectionCapability<
    TDto extends LibraryWorkspaceDto> {
  LibraryProjectionItem<TDto> projectTitle({
    required ShelfEntry source,
    required LibraryTitleNodeRef node,
    required LibraryWorkspaceProjector<TDto> projector,
    List<String> customFieldBadges = const [],
  });
}

abstract interface class ReleaseProjectionCapability<
    TDto extends LibraryWorkspaceDto> {
  List<LibraryProjectionItem<TDto>> projectReleases({
    required ShelfEntry source,
    required LibraryKindRuntime type,
    required LibraryWorkspaceProjector<TDto> projector,
    required List<CustomFieldDefinition> customFieldDefinitions,
    required Map<String, Map<String, String>>
        customFieldValuesByDefinitionByItem,
    required Map<String, List<String>> customFieldValuesByItem,
    String? requestedTitleId,
  });
}

abstract interface class CopyProjectionCapability<
    TDto extends LibraryWorkspaceDto> {
  List<LibraryProjectionItem<TDto>> projectCopies({
    required ShelfEntry source,
    required LibraryKindRuntime type,
    required LibraryWorkspaceProjector<TDto> projector,
    required List<CustomFieldDefinition> customFieldDefinitions,
    required Map<String, Map<String, String>>
        customFieldValuesByDefinitionByItem,
    required Map<String, List<String>> customFieldValuesByItem,
    String? requestedTitleId,
  });
}

final class DefaultTitleProjectionCapability<TDto extends LibraryWorkspaceDto>
    implements TitleProjectionCapability<TDto> {
  const DefaultTitleProjectionCapability();

  @override
  LibraryProjectionItem<TDto> projectTitle({
    required ShelfEntry source,
    required LibraryTitleNodeRef node,
    required LibraryWorkspaceProjector<TDto> projector,
    List<String> customFieldBadges = const [],
  }) {
    final dto = projector.projectTitle(source: source, node: node);
    return LibraryProjectionItem<TDto>(
      source: source,
      node: node,
      dto: dto,
      customFieldBadges: customFieldBadges,
    );
  }
}
