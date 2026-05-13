import 'package:collectarr_app/features/comics/comics_inspector.dart';
import 'package:collectarr_app/features/library/library_item_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('comic inspector renders empty selection state', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ComicInspector(
              item: null,
              libraryState: LibraryItemState(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('No comic selected'), findsOneWidget);
  });

  test('comic inspector exposes shared condition presets', () {
    expect(ComicInspector.conditions, contains('Near Mint'));
    expect(ComicInspector.grades, contains('9.8'));
  });
}
