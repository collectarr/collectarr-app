import 'dart:convert';

import 'package:collectarr_app/features/settings/provider_imports_dialog.dart';
import 'package:collectarr_app/features/settings/provider_import_models.dart';
import 'package:collectarr_app/features/settings/tmdb_import_service.dart';

import '../../helpers/test_constants.dart';
import 'package:collectarr_app/features/settings/tmdb_import_settings.dart';
import 'package:collectarr_app/features/settings/tmdb_pending_import_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('provider imports dialog keeps the TMDB overview clean', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.provider_import.history': jsonEncode([
        ProviderImportHistoryEntry(
          id: 'history-1',
          provider: ProviderImportId.tmdb,
          status: ProviderImportHistoryStatus.success,
          collectionLabel: 'Rated movies',
          sourceLabel: 'TMDB account sync',
          message: 'Imported 2 items. Sent 1 metadata proposals.',
          createdAt: DateTime.utc(2026, 5, 25, 9, 30),
          rows: 3,
          matched: 2,
          unmatched: 1,
          imported: 2,
          proposed: 1,
        ).toJson(),
      ]),
      'collectarr.tmdb.pending_local_imports': jsonEncode([
        TmdbPendingImportRecord(
          localItemId: 'tmdb-local:movie:604',
          entry: const TmdbImportEntry(
            tmdbId: 604,
            mediaType: TmdbMediaType.movie,
            collection: TmdbImportCollection.watchlistMovies,
            title: 'The Matrix Reloaded',
            rawPayload: <String, dynamic>{'id': 604, 'title': 'The Matrix Reloaded'},
          ),
          createdAt: DateTime.utc(2026, 5, 25, 10, 15),
        ).toJson(),
      ]),
    });
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProviderImportsDialog(
            initialTmdbSettings: TmdbImportSettings(isLoaded: true),
          ),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('TMDB overview'), findsOneWidget);
    expect(find.text('Account sync'), findsWidgets);
    expect(find.text('JSON / CSV import'), findsWidgets);
    expect(find.text('Recent activity'), findsNothing);
    expect(find.text('Pending reconciliation'), findsNothing);
    expect(find.text('Imported 2 items. Sent 1 metadata proposals.'), findsNothing);
    expect(find.text('The Matrix Reloaded'), findsNothing);
    expect(find.text('1 pending rows'), findsNothing);
  });
}