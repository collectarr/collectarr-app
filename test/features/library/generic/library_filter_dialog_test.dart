import 'package:collectarr_app/features/library/config/planned_library_configs.dart';
import 'package:collectarr_app/features/library/generic/library_filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('music filter dialog uses artist and label labels',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                showLibraryFilterDialog(
                  context: context,
                  type: musicLibraryConfig,
                  current: LibraryFilterSelection.none,
                  options: const LibraryFilterOptions(
                    series: ['Daft Punk'],
                    publishers: ['Virgin'],
                    releaseYears: ['2001'],
                  ),
                );
              },
              child: const Text('Open filters'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();

    expect(find.text('Artist'), findsOneWidget);
    expect(find.text('Label'), findsOneWidget);
    expect(find.text('Year'), findsOneWidget);
    expect(find.text('Series'), findsNothing);
    expect(find.text('Publisher'), findsNothing);
  });
}