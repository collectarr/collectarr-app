import 'package:go_router/go_router.dart';

/// A kind-owned route contribution assembled by the generic application
/// router. The route host owns ordering and authentication plumbing; the kind
/// owns its path and page semantics.
abstract interface class LibraryRouteContributor {
  GoRoute build();
}
