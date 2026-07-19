import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class ComicWorkspaceDto implements LibraryWorkspaceDto {
  const ComicWorkspaceDto({
    required this.title,
    required this.seriesTitle,
    required this.itemNumber,
    required this.publisher,
    required this.releaseDate,
    required this.isOwned,
    required this.isWishlisted,
    required this.condition,
    required this.locationPath,
    required this.rating,
    required this.pricePaidCents,
    required this.addedAt,
    required this.updatedAt,
    required this.tags,
    required this.collectionStatus,
    required this.keyComic,
    required this.grade,
    required this.crossover,
    required this.storyArcs,
    required this.characters,
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

  @override
  final String? condition;
  @override
  final String? locationPath;
  @override
  final int? rating;
  @override
  final int? pricePaidCents;
  @override
  final DateTime? addedAt;
  @override
  final DateTime updatedAt;
  @override
  final String? tags;
  @override
  final String? collectionStatus;

  final bool keyComic;
  final String? grade;
  final String? crossover;
  final List<String>? storyArcs;
  final List<String>? characters;

  factory ComicWorkspaceDto.fromEntry(LibraryWorkspaceEntry entry) {
    return ComicWorkspaceDto(
      title: entry.resolvedTitle,
      seriesTitle: entry.series?.seriesTitle,
      itemNumber: entry.itemNumber,
      publisher: entry.publisher,
      releaseDate: entry.releaseDate,
      isOwned: entry.isOwned,
      isWishlisted: entry.isWishlisted,
      condition: entry.condition,
      locationPath: entry.locationPath,
      rating: entry.rating,
      pricePaidCents: entry.pricePaidCents,
      addedAt: entry.addedAt,
      updatedAt: entry.updatedAt,
      tags: entry.tags,
      collectionStatus: entry.collectionStatus,
      keyComic: entry.comic?.keyComic ?? false,
      grade: entry.grade,
      crossover: entry.crossover,
      storyArcs: entry.storyArcs,
      characters: entry.characters,
    );
  }
}
