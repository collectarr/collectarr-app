import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import '../domain/game_toy_metadata.dart';
import '../domain/game_toy_library_entry.dart';

final class GameToyWorkspaceDto implements LibraryWorkspaceDto {
  const GameToyWorkspaceDto(
      {required this.common,
      required this.personal,
      required this.metadata,
      this.entry});
  final WorkspaceCommonProjection common;
  final PersonalEntryProjection personal;
  final GameToyCatalogMetadata metadata;
  final GameToyLibraryEntry? entry;
  @override
  String get primaryLabel => metadata.title;
  @override
  String? get secondaryLabel => metadata.seriesTitle;
  @override
  String? get imageUrl => metadata.coverImageUrl;
}
