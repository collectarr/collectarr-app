import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class AnimeWorkspaceDto implements LibraryWorkspaceDto {
  const AnimeWorkspaceDto(this.entry);

  final LibraryWorkspaceEntry entry;

  factory AnimeWorkspaceDto.fromEntry(LibraryWorkspaceEntry entry) {
    return AnimeWorkspaceDto(entry);
  }

  String get title => entry.resolvedTitle;
  String? get publisher => entry.publisher;
  DateTime? get releaseDate => entry.releaseDate;
}
