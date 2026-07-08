import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class ComicWorkspaceDto implements LibraryWorkspaceDto {
  const ComicWorkspaceDto(this.entry);

  final LibraryWorkspaceEntry entry;

  factory ComicWorkspaceDto.fromEntry(LibraryWorkspaceEntry entry) {
    return ComicWorkspaceDto(entry);
  }

  String get title => entry.resolvedTitle;
  String? get issue => entry.itemNumber;
  String? get publisher => entry.publisher;
  DateTime? get releaseDate => entry.releaseDate;
}
