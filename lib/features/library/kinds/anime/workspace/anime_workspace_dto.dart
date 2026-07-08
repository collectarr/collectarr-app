import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class AnimeWorkspaceDto implements LibraryWorkspaceDto {
  const AnimeWorkspaceDto({
    required this.title,
    required this.seriesTitle,
    required this.itemNumber,
    required this.publisher,
    required this.releaseDate,
  });

  @override
  final String title;
  @override
  final String? seriesTitle;
  @override
  final String? itemNumber;
  @override
  final String? publisher;
  @override
  final DateTime? releaseDate;

  factory AnimeWorkspaceDto.fromEntry(LibraryWorkspaceEntry entry) {
    return AnimeWorkspaceDto(
      title: entry.resolvedTitle,
      seriesTitle: entry.series?.seriesTitle,
      itemNumber: entry.itemNumber,
      publisher: entry.publisher,
      releaseDate: entry.releaseDate,
    );
  }
}
