import 'package:collectarr_app/features/library/config/library_route_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/detail/comic_routes.dart';
import 'package:collectarr_app/features/library/kinds/comic/detail/comic_series_detail_page.dart';
import 'package:go_router/go_router.dart';

final class ComicRouteContributor implements LibraryRouteContributor {
  const ComicRouteContributor();

  @override
  GoRoute build() {
    return GoRoute(
      path: comicSeriesRoutePath,
      builder: (context, state) => ComicSeriesDetailPage(
        seriesId: state.pathParameters['seriesId']!,
        seriesTitle: state.uri.queryParameters['title'] ?? '',
      ),
    );
  }
}
