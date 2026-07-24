import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_release.dart';

class ComicWorkMetadata {
  const ComicWorkMetadata({
    required this.title,
    this.issueNumber,
    this.synopsis,
    this.coverDate,
    this.creators = const [],
    this.characters = const [],
    this.storyArcs = const [],
    this.genres = const [],
  });

  final String title;
  final String? issueNumber;
  final String? synopsis;
  final DateTime? coverDate;
  final List<String> creators;
  final List<String> characters;
  final List<String> storyArcs;
  final List<String> genres;
}

class ComicPublishingMetadata {
  const ComicPublishingMetadata({
    this.pageCount,
    this.coverPriceCents,
    this.currency,
    this.publisher,
    this.imprint,
  });

  final int? pageCount;
  final int? coverPriceCents;
  final String? currency;
  final String? publisher;
  final String? imprint;
}

class ComicCatalogItem {
  const ComicCatalogItem({
    required this.id,
    required this.work,
    required this.publishing,
    required this.releases,
  });

  final String id;
  final ComicWorkMetadata work;
  final ComicPublishingMetadata publishing;
  final List<ComicRelease> releases;
}
