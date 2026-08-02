import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';

/// Context containing the canonical source [ShelfEntry], the navigation [LibraryNodeRef],
/// and the kind-specific metadata [TDto].
final class LibraryProjectionContext<TDto extends LibraryWorkspaceDto> {
  const LibraryProjectionContext({
    required this.source,
    required this.node,
    required this.dto,
  });

  final ShelfEntry source;
  final LibraryNodeRef node;
  final TDto dto;
}
