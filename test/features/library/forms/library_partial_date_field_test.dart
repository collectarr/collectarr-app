import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('full-date field keeps the calendar in the label row', (
    tester,
  ) async {
    await tester.pumpWidget(const _DateFieldHarness());

    final label = tester.getRect(find.text('Read Date'));
    final calendar = tester.getRect(find.byIcon(AppIcons.calendar));
    expect(calendar.center.dy, closeTo(label.center.dy, 4));

    await tester.enterText(find.byType(TextField).at(0), '2024');
    await tester.pump();
    expect(find.text('empty'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(1), '1');
    await tester.enterText(find.byType(TextField).at(2), '2');
    await tester.pumpAndSettle();
    expect(find.text('2024-01-02'), findsOneWidget);

    for (var part = 0; part < 3; part++) {
      await tester.enterText(find.byType(TextField).at(part), '');
    }
    await tester.pumpAndSettle();
    expect(find.text('empty'), findsOneWidget);
  });
}

class _DateFieldHarness extends StatefulWidget {
  const _DateFieldHarness();

  @override
  State<_DateFieldHarness> createState() => _DateFieldHarnessState();
}

class _DateFieldHarnessState extends State<_DateFieldHarness> {
  DateTime? _value;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            LibraryPartialDateField.fullDate(
              label: 'Read Date',
              date: _value,
              onDateChanged: (value) => setState(() => _value = value),
            ),
            Text(_value == null
                ? 'empty'
                : _value!.toIso8601String().substring(0, 10)),
          ],
        ),
      ),
    );
  }
}
