import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/watch_session.dart';

typedef CalendarTitleForItem = String Function(String itemId);

/// Boundary context for a kind calendar contribution.
///
/// Calendar owns loading and merging. The contributor owns interpretation of
/// kind-specific persisted values such as episode coordinates.
final class LibraryCalendarContext {
  const LibraryCalendarContext({
    required this.watchSessions,
    required this.titleForItem,
  });

  final Iterable<WatchSession> watchSessions;
  final CalendarTitleForItem titleForItem;
}

abstract interface class LibraryCalendarContributor {
  CatalogMediaKind get kind;

  Iterable<CalendarEvent> contribute(LibraryCalendarContext context);
}
