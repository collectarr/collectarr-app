import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class MusicWorkspaceDto implements LibraryWorkspaceDto {
  const MusicWorkspaceDto(this.entry);

  final LibraryWorkspaceEntry entry;

  factory MusicWorkspaceDto.fromEntry(LibraryWorkspaceEntry entry) {
    return MusicWorkspaceDto(entry);
  }

  String get title => entry.resolvedTitle;
  String? get publisher => entry.publisher;
  DateTime? get releaseDate => entry.releaseDate;
}
