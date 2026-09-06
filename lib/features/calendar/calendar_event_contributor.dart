import 'package:collectarr_app/core/models/calendar_event.dart';

/// Structural projection contract shared by calendar hosts and contributors.
///
/// A contributor returns already-projected events. It does not expose a
/// domain object to the calendar renderer.
abstract interface class CalendarEventContributor<TContext> {
  Iterable<CalendarEvent> contribute(TContext context);
}
