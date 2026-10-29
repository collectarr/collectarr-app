import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('filtered forms retain wider identity fields beside short codes',
      (tester) async {
    final section = filterLibraryFormSections<Object>(fieldIds: {
      'name',
      'code'
    }, sections: [
      LibraryFormSectionSpec(id: 'identity', label: '', fields: [
        for (final id in ['name', 'code', 'other'])
          LibraryTextFieldSpec<Object>(
              id: id, label: id, value: (_) => '', setValue: (_, value) {}),
      ], columns: const [
        LibraryFormColumnSpec(rows: [
          ['name', 'code'],
          ['other']
        ], fieldFlex: {
          'name': 3,
          'code': 1
        })
      ]),
    ]).single;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: LibraryFieldSpecLayout<Object>(
      maxColumns: section.maxColumns,
      fullWidthFieldIds: section.fullWidthFieldIds,
      fieldColumnSpans: section.fieldColumnSpans,
      rightAlignedFieldIds: section.rightAlignedFieldIds,
      fields: section.fields,
      draft: Object(),
      columns: section.columns,
      buildField: (field) => SizedBox(key: ValueKey(field.id), height: 30),
    ))));
    final nameWidth = tester.getSize(find.byKey(const ValueKey('name'))).width;
    final codeWidth = tester.getSize(find.byKey(const ValueKey('code'))).width;
    expect(nameWidth, closeTo(codeWidth * 3, 0.1));
    expect(tester.takeException(), isNull);
  });
}
