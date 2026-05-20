import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bulk edit dialog returns selected local fields', (tester) async {
    LibraryBulkEditSelection? selection;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                selection = await showDialog<LibraryBulkEditSelection>(
                  context: context,
                  builder: (_) => const LibraryBulkEditDialog(
                    type: comicsLibraryConfig,
                    selectedCount: 3,
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
