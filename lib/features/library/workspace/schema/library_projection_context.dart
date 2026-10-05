import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';

/// Context exposing the workspace row's two owners and kind-specific DTO.
final class LibraryProjectionContext<TDto extends LibraryWorkspaceDto> {
  const LibraryProjectionContext({
    required this.item,
    required this.personal,
    required this.dto,
  });

  final WorkspaceItem item;
  final PersonalOverlay personal;
  final TDto dto;

  DateTime get updatedAt {
    final entryUpdatedAt = item.entrySummary?.updatedAt;
    final personalUpdatedAt = personal.updatedAt;
    if (entryUpdatedAt == null || !entryUpdatedAt.isAfter(personalUpdatedAt)) {
      return personalUpdatedAt;
    }
    return entryUpdatedAt;
  }

  DateTime? get addedAt =>
      item.entrySummary?.createdAt ?? personal.wishlist?.createdAt;
}
