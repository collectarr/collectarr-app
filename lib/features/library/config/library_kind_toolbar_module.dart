import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/actions/ui_action.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:flutter/widgets.dart';

/// Opens a kind's report of the items missing from its collection.
typedef LibraryMissingItemsReport = Future<void> Function({
  required BuildContext context,
  required LibraryKindRegistration type,
  required LibraryProjection projection,
  required Color accent,
});

/// Structural toolbar contribution supplied by a kind.
final class LibraryKindToolbarModule {
  const LibraryKindToolbarModule({
    this.actions = const [],
    this.missingReport,
  });

  final List<UiAction<LibraryToolbarActionContext>> actions;

  /// Offered in the main menu's Tools section as "Missing ...", as the
  /// reference Comics menu offers Missing Comics.
  final LibraryMissingItemsReport? missingReport;
}
