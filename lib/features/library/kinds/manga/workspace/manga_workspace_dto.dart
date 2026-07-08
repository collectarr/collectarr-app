import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class MangaWorkspaceDto implements LibraryWorkspaceDto {
  const MangaWorkspaceDto(this.entry);

  final LibraryWorkspaceEntry entry;

  factory MangaWorkspaceDto.fromEntry(LibraryWorkspaceEntry entry) {
    return MangaWorkspaceDto(entry);
  }

  String get title => entry.resolvedTitle;
  String? get publisher => entry.publisher;
  DateTime? get releaseDate => entry.releaseDate;
}
