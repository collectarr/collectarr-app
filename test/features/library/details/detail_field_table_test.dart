import 'package:collectarr_app/features/library/details/field_table.dart';
import 'package:collectarr_app/features/library/details/field_row.dart';
import 'package:collectarr_app/features/library/details/models.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('native detail fields stay in one column on wide devices',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          child: LibraryDetailFieldTable(fields: [
            LibraryDetailField(label: 'Read', value: 'Yes'),
            LibraryDetailField(label: 'Index', value: '1'),
          ]),
        ),
      ),
    ));
    expect(find.byKey(const ValueKey('library-detail-field-table-1')),
        findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('detail field table wraps to one column when narrow',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LibraryAccentScope(
          kind: 'comic',
          accent: Colors.orange,
          animationsEnabled: false,
          child: const Material(
            child: SizedBox(
              width: 320,
              child: LibraryDetailFieldTable(
                minCellWidth: 999,
                fields: [
                  LibraryDetailField(label: 'Series', value: 'Dune'),
                  LibraryDetailField(label: 'Publisher', value: 'Ace'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(LibraryDetailFieldRow), findsNWidgets(2));
    expect(find.byKey(const ValueKey('library-detail-field-table-1')),
        findsOneWidget);
    expect(find.text('Field'), findsOneWidget);
    expect(find.text('Value'), findsOneWidget);
  });

  testWidgets('desktop detail field table uses multiple columns when wider',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LibraryAccentScope(
          kind: 'comic',
          accent: Colors.orange,
          animationsEnabled: false,
          child: const Material(
            child: SizedBox(
              width: 1000,
              child: LibraryDetailFieldTable(
                minCellWidth: 200,
                fields: [
                  LibraryDetailField(label: 'Series', value: 'Dune'),
                  LibraryDetailField(label: 'Publisher', value: 'Ace'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(LibraryDetailFieldRow), findsNWidgets(2));
    expect(find.byKey(const ValueKey('library-detail-field-table-3')),
        findsOneWidget);
    expect(find.text('Field'), findsOneWidget);
    expect(find.text('Value'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
}
