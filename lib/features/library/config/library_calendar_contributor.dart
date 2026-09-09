import 'dart:async';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/calendar/calendar_event_contributor.dart';

typedef CalendarTitleForRef = String Function(CatalogEntityRef ref);

/// Boundary context for a kind calendar contribution.
///
/// Calendar owns loading and merging. The contributor owns interpretation of
/// kind-specific persisted values such as episode coordinates.
final class LibraryCalendarContext {
  const LibraryCalendarContext({
    this.database,
    this.catalogRefs = const <CatalogEntityRef>{},
    required this.watchSessions,
    required this.titleForRef,
  });

  final LocalDatabase? database;
  final Iterable<CatalogEntityRef> catalogRefs;
  final Iterable<WatchSession> watchSessions;
  final CalendarTitleForRef titleForRef;
}

abstract interface class LibraryCalendarContributor
    implements CalendarEventContributor<LibraryCalendarContext> {
  CatalogMediaKind get kind;

  @override
  FutureOr<Iterable<CalendarEvent>> contribute(LibraryCalendarContext context);
}
