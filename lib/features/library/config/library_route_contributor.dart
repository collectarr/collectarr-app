import 'package:go_router/go_router.dart';

/// Zero or more kind-owned routes assembled by the generic application router.
/// The route host owns ordering and authentication plumbing; each kind owns
/// its paths and page semantics.
abstract interface class LibraryRouteContributor {
  List<GoRoute> buildRoutes();
}
