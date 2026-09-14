import 'package:collectarr_app/features/library/ui/primitives/library_result_table.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_result_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Result {
  const _Result(this.series, this.issue);

  final String series;
  final int issue;
}

void main() {
  testWidgets('renders typed columns and rows with shared table chrome',
      (tester) async {
    var tapped = false;
    const item = _Result('Saga', 12);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 640,
          height: 360,
          child: LibraryResultTable<_Result>(
            columns: [
              LibraryResultColumn<_Result>(
                id: 'series',
                label: 'Series',
                cellBuilder: (_, value) => Text(value.series),
              ),
              LibraryResultColumn<_Result>(
                id: 'issue',
                label: 'Issue',
                numeric: true,
                cellBuilder: (_, value) => Text('${value.issue}'),
              ),
            ],
            rows: [
              LibraryResultRow<_Result>(
                item: item,
                onTap: () => tapped = true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Series'), findsOneWidget);
    expect(find.text('Issue'), findsOneWidget);
    expect(find.text('Saga'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);

    await tester.tap(find.text('Saga'));
    expect(tapped, isTrue);
  });
}
