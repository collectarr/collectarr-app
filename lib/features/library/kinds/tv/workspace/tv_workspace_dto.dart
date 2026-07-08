import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class TvWorkspaceDto implements LibraryWorkspaceDto {
  const TvWorkspaceDto(this.entry);

  final LibraryWorkspaceEntry entry;

  factory TvWorkspaceDto.fromEntry(LibraryWorkspaceEntry entry) {
    return TvWorkspaceDto(entry);
  }

  String get title => entry.resolvedTitle;
  String? get publisher => entry.publisher;
  DateTime? get releaseDate => entry.releaseDate;
}
