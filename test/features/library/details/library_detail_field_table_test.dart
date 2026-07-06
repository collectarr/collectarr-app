import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_row.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('detail field table wraps to one column when narrow',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LibraryAccentScope(
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

  testWidgets('detail field table wraps to two columns when wider',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LibraryAccentScope(
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
  });
}
