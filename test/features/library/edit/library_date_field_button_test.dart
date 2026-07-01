import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('date field shows inline parts and emits combined value', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _DateFieldHarness(),
    );

    expect(find.byIcon(Icons.calendar_today), findsOneWidget);

    await tester.enterText(
      find.byType(TextField).at(0),
      '2024',
    );
    await tester.enterText(
      find.byType(TextField).at(1),
      '1',
    );
    await tester.enterText(
      find.byType(TextField).at(2),
      '2',
    );

    await tester.pumpAndSettle();

    expect(find.text('2024-01-02'), findsOneWidget);
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
            LibraryDateFieldButton(
              label: 'Release date',
              value: _value,
              onChanged: (value) => setState(() => _value = value),
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
