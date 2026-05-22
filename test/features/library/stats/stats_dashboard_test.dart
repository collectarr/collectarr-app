import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/planned_library_configs.dart';
import 'package:collectarr_app/features/library/stats/stats_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('music stats dashboard uses artist and label metadata alerts', (
    tester,
  ) async {
    final state = ShelfState(
      entries: const [
        ShelfEntry(
          itemId: 'music-1',
          catalogItem: CatalogItem(
            id: 'music-1',
            kind: 'music',
            title: 'Discovery',
          ),
        ),
      ],
      ownedCount: 0,
      wishlistCount: 0,
      missingGradeCount: 0,
      pricedCount: 0,
      totalPaidCents: null,
      primaryCurrency: null,
      hasMixedCurrencies: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showStatsDashboardDialog(
                  context,
                  type: musicLibraryConfig,
                  state: state,
                ),
                child: const Text('Open stats'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open stats'));
    await tester.pumpAndSettle();

    expect(find.text('Top Artists'), findsOneWidget);
    expect(find.text('Top Labels'), findsOneWidget);
    expect(find.text('Top Series'), findsNothing);
    expect(find.text('Top Publishers'), findsNothing);
    expect(find.text('Metadata Alerts'), findsOneWidget);
    expect(find.text('Missing artist'), findsOneWidget);
    expect(find.text('Missing label'), findsOneWidget);
    expect(find.text('Missing series'), findsNothing);
    expect(find.text('Missing publisher'), findsNothing);
  });
}