import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/settings/tmdb_import_preview_dialog.dart';
import 'package:collectarr_app/features/settings/tmdb_import_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_constants.dart';

void main() {
  testWidgets('preview dialog can skip unmatched rows on import', (
    tester,
  ) async {
    final preview = TmdbImportPreview(
      collection: TmdbImportCollection.ratedMovies,
      matches: [
        TmdbImportMatch(
          entry: const TmdbImportEntry(
            tmdbId: 603,
            collection: TmdbImportCollection.ratedMovies,
            title: 'The Matrix',
            rating: 9,
            rawPayload: <String, dynamic>{'id': 603, 'title': 'The Matrix'},
          ),
          catalogItem: CatalogItem(
            id: 'movie-603',
            kind: 'movie',
            title: 'The Matrix',
            releaseYear: 1999,
          ),
          quality: TmdbImportMatchQuality.exactTitleAndYear,
        ),
        TmdbImportMatch(
          entry: const TmdbImportEntry(
            tmdbId: 680,
            collection: TmdbImportCollection.ratedMovies,
            title: 'Pulp Fiction',
            rawPayload: <String, dynamic>{'id': 680, 'title': 'Pulp Fiction'},
          ),
          quality: TmdbImportMatchQuality.none,
        ),
      ],
    );

    bool? receivedSkipUnmatchedRows;
    String? dialogResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () async {
                  dialogResult = await showTmdbImportPreviewDialog(
                    context: context,
                    preview: preview,
                    sourceLabel: 'TMDB export file',
                    keepUnmatchedLocally: true,
                    hasApiKey: true,
                    importButtonLabel: 'Import completed',
                    onImport: ({required skipUnmatchedRows}) async {
                      receivedSkipUnmatchedRows = skipUnmatchedRows;
                      return 'Imported 1 items. Skipped 1 unmatched rows.';
                    },
                    mapImportError: (error) => error.toString(),
                  );
                },
                child: const Text('Open preview'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open preview'));
    await pumpUntilSettled(tester);

    expect(
      find.text('1 unmatched rows will create metadata proposals.'),
      findsOneWidget,
    );
    expect(find.text('Skip unmatched rows'), findsOneWidget);

    await tester.tap(find.text('Skip unmatched rows'));
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Import completed'));
    await pumpUntilSettled(tester);

    expect(receivedSkipUnmatchedRows, isTrue);
    expect(dialogResult, 'Imported 1 items. Skipped 1 unmatched rows.');
  });
}