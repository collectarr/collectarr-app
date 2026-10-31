import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/stats/page.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/features/library/config/kind_style.dart';

export 'package:collectarr_app/features/library/stats/page.dart';

/// Opens the full-page statistics dashboard for any media type.
Future<void> showStatsDashboardDialog(
  BuildContext context, {
  required LibraryKindRegistration type,
  required ShelfState state,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (context) => LibraryAccentScope(
          kind: type.kind.apiValue,
          accent: libraryAccentForKind(type.kind),
          animationsEnabled: true,
          child: LibraryStatsPage(type: type, state: state)),
    ),
  );
}
