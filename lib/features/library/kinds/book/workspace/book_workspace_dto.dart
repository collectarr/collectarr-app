import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class BookWorkspaceDto implements LibraryWorkspaceDto {
  const BookWorkspaceDto(this.entry);

  final LibraryWorkspaceEntry entry;

  factory BookWorkspaceDto.fromEntry(LibraryWorkspaceEntry entry) {
    return BookWorkspaceDto(entry);
  }

  String get title => entry.resolvedTitle;
  String? get publisher => entry.publisher;
  DateTime? get releaseDate => entry.releaseDate;
}
