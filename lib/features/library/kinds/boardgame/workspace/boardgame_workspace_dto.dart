import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class BoardGameWorkspaceDto implements LibraryWorkspaceDto {
  const BoardGameWorkspaceDto(this.entry);

  final LibraryWorkspaceEntry entry;

  factory BoardGameWorkspaceDto.fromEntry(LibraryWorkspaceEntry entry) {
    return BoardGameWorkspaceDto(entry);
  }

  String get title => entry.resolvedTitle;
  String? get publisher => entry.publisher;
  DateTime? get releaseDate => entry.releaseDate;
}
