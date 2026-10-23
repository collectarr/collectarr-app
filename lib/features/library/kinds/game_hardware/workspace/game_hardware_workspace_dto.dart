import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import '../domain/game_hardware_metadata.dart';
import '../domain/game_hardware_library_entry.dart';

final class GameHardwareWorkspaceDto implements LibraryWorkspaceDto {
  const GameHardwareWorkspaceDto(
      {required this.common,
      required this.personal,
      required this.metadata,
      this.entry});
  final WorkspaceCommonProjection common;
  final PersonalEntryProjection personal;
  final GameHardwareCatalogMetadata metadata;
  final GameHardwareLibraryEntry? entry;
  @override
  String get primaryLabel => metadata.title;
  @override
  String? get secondaryLabel => metadata.seriesTitle;
  @override
  String? get imageUrl => metadata.coverImageUrl;
}
