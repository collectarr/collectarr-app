import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class MovieWorkspaceDto implements LibraryWorkspaceDto {
  const MovieWorkspaceDto(this.entry);

  final LibraryWorkspaceEntry entry;

  factory MovieWorkspaceDto.fromEntry(LibraryWorkspaceEntry entry) {
    return MovieWorkspaceDto(entry);
  }

  String get title => entry.resolvedTitle;
  String? get publisher => entry.publisher;
  DateTime? get releaseDate => entry.releaseDate;
}
