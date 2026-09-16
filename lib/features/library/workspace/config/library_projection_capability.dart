import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';

abstract interface class WorkProjectionCapability<
    TDto extends LibraryWorkspaceDto> {
  LibraryProjectionItem<TDto> projectWork({
    required LibraryWorkspaceSource source,
    required LibraryWorkRef node,
    required LibraryEntityWorkspaceProjector<TDto> projector,
    List<String> customFieldBadges = const [],
  });
}

abstract interface class ReleaseProjectionCapability<
    TDto extends LibraryWorkspaceDto> {
  List<LibraryProjectionItem<TDto>> projectReleases({
    required LibraryWorkspaceSource source,
    required LibraryKindRegistration type,
    required LibraryEntityWorkspaceProjector<TDto> projector,
    required List<CustomFieldDefinition> customFieldDefinitions,
    required Map<String, Map<String, String>>
        customFieldValuesByDefinitionByItem,
    required Map<String, List<String>> customFieldValuesByItem,
    String? requestedWorkId,
  });
}

abstract interface class CopyProjectionCapability<
    TDto extends LibraryWorkspaceDto> {
  List<LibraryProjectionItem<TDto>> projectCopies({
    required LibraryWorkspaceSource source,
    required LibraryKindRegistration type,
    required LibraryEntityWorkspaceProjector<TDto> projector,
    required List<CustomFieldDefinition> customFieldDefinitions,
    required Map<String, Map<String, String>>
        customFieldValuesByDefinitionByItem,
    required Map<String, List<String>> customFieldValuesByItem,
    String? requestedWorkId,
  });
}

final class DefaultWorkProjectionCapability<TDto extends LibraryWorkspaceDto>
    implements WorkProjectionCapability<TDto> {
  const DefaultWorkProjectionCapability();

  @override
  LibraryProjectionItem<TDto> projectWork({
    required LibraryWorkspaceSource source,
    required LibraryWorkRef node,
    required LibraryEntityWorkspaceProjector<TDto> projector,
    List<String> customFieldBadges = const [],
  }) {
    final dto = projector.project(source: source, entity: node);
    return LibraryProjectionItem<TDto>(
      source: source,
      node: node,
      dto: dto,
      customFieldBadges: customFieldBadges,
    );
  }
}
