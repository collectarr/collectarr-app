import 'package:collectarr_app/features/library/generic/mobile_folder_chooser.dart';
import 'package:collectarr_app/features/library/workspace/layout/bucket_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('native folder list searches and enters the chosen folder',
      (tester) async {
    String? selected;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LibraryMobileFolderChooser(
          buckets: const [
            LibraryBucket(title: '[All Comics]', count: 2),
            LibraryBucket(title: 'Batman', count: 1),
            LibraryBucket(title: '[None]', count: 1),
          ],
          folderLabel: 'Series',
          allBucketLabel: '[All Comics]',
          onSelected: (value) => selected = value,
        ),
      ),
    ));
    expect(find.byKey(const Key('library.mobile-folder-list')), findsOneWidget);
    expect(find.text('1 series'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Search series...'), findsOneWidget);
    await tester.enterText(
        find.byKey(const Key('library.mobile-folder-search')), 'bat');
    await tester.pump();
    expect(find.text('1 series'), findsOneWidget);
    expect(find.text('Batman'), findsOneWidget);
    expect(find.text('[None]'), findsNothing);
    await tester.tap(find.text('Batman'));
    expect(selected, 'Batman');
  });
}
