import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class MusicWorkspaceDto implements LibraryWorkspaceDto {
  const MusicWorkspaceDto({
    required this.title,
    required this.seriesTitle,
    required this.itemNumber,
    required this.publisher,
    required this.releaseDate,
    required this.isOwned,
    required this.isWishlisted,
    required this.catalogNumber,
    required this.discCount,
    required this.trackCount,
    required this.length,
    required this.vinylColor,
    required this.rpm,
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

  final String? catalogNumber;
  final int? discCount;
  final int? trackCount;
  final String? length;
  final String? vinylColor;
  final String? rpm;

  factory MusicWorkspaceDto.fromEntry(LibraryWorkspaceEntry entry) {
    return MusicWorkspaceDto(
      title: entry.resolvedTitle,
      seriesTitle: entry.series?.seriesTitle,
      itemNumber: entry.itemNumber,
      publisher: entry.publisher,
      releaseDate: entry.releaseDate,
      isOwned: entry.isOwned,
      isWishlisted: entry.isWishlisted,
      catalogNumber: entry.music?.catalogNumber,
      discCount: entry.music?.discCount,
      trackCount: entry.music?.trackCount,
      length: entry.music?.length,
      vinylColor: entry.music?.vinylColor,
      rpm: entry.music?.rpm,
    );
  }
}
