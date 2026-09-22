import 'package:collectarr_app/features/library/config/library_route_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/detail/comic_routes.dart';
import 'package:collectarr_app/features/library/kinds/comic/detail/character_detail_page.dart';
import 'package:collectarr_app/features/library/kinds/comic/detail/creator_detail_page.dart';
import 'package:collectarr_app/features/library/kinds/comic/detail/comic_series_detail_page.dart';
import 'package:collectarr_app/features/library/kinds/comic/detail/story_arc_detail_page.dart';
import 'package:go_router/go_router.dart';

final class ComicRouteContributor implements LibraryRouteContributor {
  const ComicRouteContributor();

  @override
  List<GoRoute> buildRoutes() {
    return [
      GoRoute(
        path: comicSeriesRoutePath,
        builder: (context, state) => ComicSeriesDetailPage(
          seriesId: state.pathParameters['seriesId']!,
          seriesTitle: state.uri.queryParameters['title'] ?? '',
        ),
      ),
      GoRoute(
        path: comicCreatorRoutePath,
        builder: (context, state) => ComicCreatorDetailPage(
          creatorName: Uri.decodeComponent(state.pathParameters['name']!),
        ),
      ),
      GoRoute(
        path: comicCharacterRoutePath,
        builder: (context, state) => CharacterDetailPage(
          characterName: Uri.decodeComponent(state.pathParameters['name']!),
        ),
      ),
      GoRoute(
        path: comicStoryArcRoutePath,
        builder: (context, state) => StoryArcDetailPage(
          storyArcName: Uri.decodeComponent(state.pathParameters['name']!),
        ),
      ),
    ];
  }
}
