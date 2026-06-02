import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/game_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/config/presentation/music_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/config/presentation/video_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/shared/library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

const genericLibraryMediaBuilder = SharedLibraryMediaPresentationBuilder();
const comicsLibraryMediaBuilder =
    SharedLibraryMediaPresentationBuilder(showSummary: true);
const gamesLibraryMediaBuilder = GameLibraryMediaPresentationBuilder();
const boardGamesLibraryMediaBuilder = SharedLibraryMediaPresentationBuilder();
const moviesLibraryMediaBuilder = VideoLibraryMediaPresentationBuilder(
  showSummary: true,
);
const musicLibraryMediaBuilder = MusicLibraryMediaPresentationBuilder();

const defaultPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Items',
);
const issuesPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Issues',
);
const volumesPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Volumes',
);
const releasesPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Artist',
  itemCount: 'Releases',
);
const franchiseStatsLabels = LibraryMediaStatsLabels(
  topSeries: 'Top Franchises',
  topPublisher: 'Top Studios',
);
const musicStatsLabels = LibraryMediaStatsLabels(
  topSeries: 'Top Artists',
  topPublisher: 'Top Labels',
);
const gameStatsLabels = LibraryMediaStatsLabels(
  topSeries: 'Top Series',
  topPublisher: 'Top Publishers / Studios',
);
const issueVisibleColumns = {
  LibraryTableColumn.status,
  LibraryTableColumn.cover,
  LibraryTableColumn.title,
  LibraryTableColumn.issue,
  LibraryTableColumn.publisher,
  LibraryTableColumn.releaseDate,
  LibraryTableColumn.barcode,
  LibraryTableColumn.condition,
  LibraryTableColumn.price,
  LibraryTableColumn.location,
  LibraryTableColumn.wishlist,
  LibraryTableColumn.updated,
};