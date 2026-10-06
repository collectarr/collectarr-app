import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/stats/library_stats_page.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/stats/library_stats_page.dart';

/// Opens the full-page statistics dashboard for any media type.
Future<void> showStatsDashboardDialog(
  BuildContext context, {
  required LibraryKindRegistration type,
  required ShelfState state,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (context) => LibraryStatsPage(type: type, state: state),
    ),
  );
}
