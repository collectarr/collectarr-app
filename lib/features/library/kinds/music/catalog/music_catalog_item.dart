import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_release.dart';

class MusicWorkMetadata {
  const MusicWorkMetadata({
    required this.title,
    this.originalTitle,
    this.synopsis,
    this.artist,
    this.genres = const [],
  });

  final String title;
  final String? originalTitle;
  final String? synopsis;
  final String? artist;
  final List<String> genres;
}

class MusicRecordingMetadata {
  const MusicRecordingMetadata({
    this.trackCount,
    this.studio,
    this.originalReleaseDate,
    this.recordingDate,
    this.isLive,
    this.composition,
  });

  final int? trackCount;
  final String? studio;
  final DateTime? originalReleaseDate;
  final DateTime? recordingDate;
  final bool? isLive;
  final String? composition;
}

class MusicCatalogItem {
  const MusicCatalogItem({
    required this.id,
    required this.work,
    required this.recording,
    required this.releases,
  });

  final String id;
  final MusicWorkMetadata work;
  final MusicRecordingMetadata recording;
  final List<MusicCatalogRelease> releases;

  String get title => work.title;
  String? get originalTitle => work.originalTitle;
  String? get synopsis => work.synopsis;
  List<String> get genres => work.genres;
  CatalogSeriesDetails? get series => null;
  CatalogPublishingDetails? get publishing => null;
  List<Map<String, dynamic>>? get contributors => null;
  String? get coverImageUrl =>
      releases.isEmpty ? null : releases.first.coverImageUrl;
  String? get thumbnailImageUrl => coverImageUrl;
  DateTime? get releaseDate =>
      releases.isEmpty ? null : releases.first.releaseDate;
  int? get releaseYear => releaseDate?.year;
  String? get publisher => releases.isEmpty ? null : releases.first.publisher;
  String? get country => null;
  String? get language => null;
  String? get ageRating => null;
  String? get audienceRating => null;
  String? get barcode => releases.isEmpty ? null : releases.first.upc;
  bool get hasMissingCoreMetadata => work.title.isEmpty;

  // Extended getters for workspace_entry_builder compatibility
  String? get displayTitle => null;
  String? get localizedTitle => null;
  List<String>? get searchAliases => null;
  String? get itemNumber => null;
  DateTime? get coverDate => null;
  String? get displayEditionLabel => null;
  String? get crossover => null;
  String? get displayCoverUrl => coverImageUrl;
  List<TrailerLink> get trailerUrls => const <TrailerLink>[];
  List<Map<String, dynamic>>? get creators => null;
  List<String>? get characters => null;
  List<String>? get storyArcs => null;
  List<CatalogEdition> get editions => const <CatalogEdition>[];
}
