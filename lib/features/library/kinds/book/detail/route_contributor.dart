import 'package:collectarr_app/features/library/config/library_route_contributor.dart';
import 'package:collectarr_app/features/library/kinds/book/detail/author_page.dart';
import 'package:collectarr_app/features/library/kinds/book/detail/routes.dart';
import 'package:go_router/go_router.dart';

final class BookRouteContributor implements LibraryRouteContributor {
  const BookRouteContributor();

  @override
  List<GoRoute> buildRoutes() => [
        GoRoute(
          path: bookAuthorRoutePath,
          builder: (context, state) => BookAuthorDetailPage(
            authorName: Uri.decodeComponent(state.pathParameters['name']!),
          ),
        ),
      ];
}
