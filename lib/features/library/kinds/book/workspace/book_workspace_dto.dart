import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class BookWorkspaceDto implements LibraryWorkspaceDto {
  const BookWorkspaceDto({required this.title,
    required this.seriesTitle,
    required this.itemNumber,
    required this.publisher,
    required this.releaseDate,
    required this.isOwned,
    required this.isWishlisted,
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
  @override
  final bool isOwned;
  @override
  final bool isWishlisted;

  factory BookWorkspaceDto.fromEntry(LibraryWorkspaceEntry entry) {
    return BookWorkspaceDto(
      title: entry.resolvedTitle,
      seriesTitle: entry.series?.seriesTitle,
      itemNumber: entry.itemNumber,
      publisher: entry.publisher,
      releaseDate: entry.releaseDate,
      isOwned: entry.isOwned,
      isWishlisted: entry.isWishlisted,
    );
  }
}
