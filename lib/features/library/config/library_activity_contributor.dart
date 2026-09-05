import 'package:collectarr_app/core/models/activity_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/watch_session.dart';

/// Context supplied by the Activity host to a kind-owned activity projector.
///
/// The host owns loading and merging. A kind owns interpretation of its
/// semantic coordinates, such as TV/Anime episode numbers.
final class LibraryActivityContext {
  const LibraryActivityContext({required this.watchSessions});

  final Iterable<WatchSession> watchSessions;
}

abstract interface class LibraryActivityContributor {
  CatalogMediaKind get kind;

  Iterable<ActivityEvent> contribute(LibraryActivityContext context);
}
