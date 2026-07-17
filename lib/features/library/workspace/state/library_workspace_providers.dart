/// Barrel export for the Riverpod workspace state layer.
///
/// Import this single file to access all workspace providers and state types:
///
/// ```dart
/// import 'package:collectarr_app/features/library/workspace/state/library_workspace_providers.dart';
/// ```
// ignore: unnecessary_library_name
library library_workspace_providers;

// Phase 1 – Scoping key
export 'library_workspace_key.dart';

// Phase 2 – Immutable filter state
export 'library_filter_state.dart';

// Phase 3 – Filter state notifier
export 'library_filters_provider.dart';

// Phase 4 – Derived display stream
export 'library_display_provider.dart';

// Phase 8 – Visual config state + notifier
export 'library_view_config_state.dart';
export 'library_view_config_provider.dart';

// Phase 9 – Grouped display stream
export 'library_grouped_entries_provider.dart';

// Phase 10 – Available sorts/groups/columns menu descriptors
export 'library_field_options_providers.dart';

// Phase 11 – Persistence (hydration + auto-save)
export 'library_workspace_persistence.dart';

// Phase 12 – Single dispatch facade
export 'library_workspace_intent.dart';
