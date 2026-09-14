import 'package:collectarr_app/core/models/activity_event.dart';

/// Structural activity projection contract shared by Activity hosts and
/// universal or kind-owned contributors.
abstract interface class ActivityEventContributor<TContext> {
  Iterable<ActivityEvent> contribute(TContext context);
}
