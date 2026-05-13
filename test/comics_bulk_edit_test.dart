import 'package:collectarr_app/features/comics/comics_bulk_edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bulk edit dialog returns selected local fields', (tester) async {
    ComicsBulkEditSelection? selection;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                selection = await showDialog<ComicsBulkEditSelection>(
                  context: context,
                  builder: (_) => const ComicsBulkEditDialog(
                    conditions: ['Near Mint'],
                    grades: ['9.8'],
                  ),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Box A');
    await tester.enterText(find.byType(TextField).last, 'signed,key');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(selection?.storageBox, 'Box A');
    expect(selection?.tags, 'signed,key');
  });
}
