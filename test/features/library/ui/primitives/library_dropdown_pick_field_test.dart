import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'parent updates a populated dropdown without rebuilding Form during build',
      (tester) async {
    var value = 'Shelf';
    late StateSetter updateParent;
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: StatefulBuilder(builder: (context, setState) {
        updateParent = setState;
        return Form(
            child: LibraryDropdownPickField<String>(
          label: 'Location',
          value: value,
          options: const [
            LibraryFieldOption(value: 'Shelf', label: 'Shelf'),
            LibraryFieldOption(
                value: 'Record Cabinet', label: 'Record Cabinet'),
          ],
          onChanged: (_) {},
        ));
      }),
    )));
    await tester.enterText(find.byType(TextFormField), 'Shelf');
    updateParent(() => value = 'Record Cabinet');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        'Record Cabinet');
  });
}
