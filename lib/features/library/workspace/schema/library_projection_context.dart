import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';

/// Context containing the canonical source [LibraryWorkspaceSource], the navigation [LibraryEntityRef],
/// and the kind-specific metadata [TDto].
final class LibraryProjectionContext<TDto extends LibraryWorkspaceDto> {
  const LibraryProjectionContext({
    required this.source,
    required this.node,
    required this.dto,
  });

  final LibraryWorkspaceSource source;
  final LibraryEntityRef node;
  final TDto dto;
}
