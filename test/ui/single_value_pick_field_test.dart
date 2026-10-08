import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('edit status fields use the same control height', (tester) async {
    final fields = [
      SizedBox(
        key: const ValueKey('collection-status'),
        width: 240,
        child: LibraryCollectionStatusField(
          value: 'In Collection',
          onChanged: (_) {},
        ),
      ),
      const SizedBox(
        key: ValueKey('index'),
        width: 120,
        child: LibraryFormField(
          label: 'Index',
          child: LibraryTextFormControl(initialValue: '6'),
        ),
      ),
      const SizedBox(
        key: ValueKey('quantity'),
        width: 120,
        child: LibraryFormField(
          label: 'Quantity',
          child: LibraryTextFormControl(initialValue: '1'),
        ),
      ),
      SizedBox(
        key: const ValueKey('location'),
        width: 240,
        child: LibraryDropdownPickField<String>(
          label: 'Location',
          value: null,
          options: const [],
          onChanged: (_) {},
          showFieldLabel: true,
        ),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: editDialogTheme(),
        home: Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: fields,
          ),
        ),
      ),
    );

    final heights = {
      for (final field in [
        'collection-status',
        'index',
        'quantity',
        'location',
      ])
        field: tester.getSize(find.byKey(ValueKey(field))).height,
    };
    final decorators = find.byType(InputDecorator);
    expect(decorators, findsNWidgets(4));
    for (var index = 0; index < decorators.evaluate().length; index++) {
      expect(
        tester.getSize(decorators.at(index)).height,
        kLibraryFormControlHeight,
      );
    }
    expect(
      heights.values.toSet(),
      {20 + 1 + kLibraryFormControlHeight},
      reason: 'Field heights differ: $heights',
    );
  });

  testWidgets('single value pick field exposes an inline picker menu',
      (tester) async {
    final controller = TextEditingController(text: 'Publisher A');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleValuePickField(
            controller: controller,
            options: const ['Publisher A', 'Publisher B'],
            label: 'Publisher',
          ),
        ),
      ),
    );

    expect(find.byTooltip('Pick Publisher'), findsOneWidget);

    await tester.tap(find.byTooltip('Pick Publisher'));
    await tester.pumpAndSettle();

    expect(find.text('Publisher B'), findsOneWidget);

    await tester.tap(find.text('Publisher B'));
    await tester.pumpAndSettle();

    expect(controller.text, 'Publisher B');
    expect(find.byTooltip('Browse Publisher'), findsNothing);
  });

  testWidgets('single value pick field browse action opens picker dialog',
      (tester) async {
    final controller = TextEditingController(text: 'Publisher A');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleValuePickField(
            controller: controller,
            options: const ['Publisher A', 'Publisher B'],
            label: 'Publisher',
            showPickerListAction: true,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Pick Publisher'), findsOneWidget);
    expect(find.byTooltip('Browse Publisher'), findsOneWidget);

    await tester.tap(find.byTooltip('Browse Publisher'));
    await tester.pumpAndSettle();

    expect(find.text('Pick Publisher'), findsOneWidget);
  });

  testWidgets('single value pick field does not auto-list options on focus',
      (tester) async {
    final controller = TextEditingController(text: 'Publisher A');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleValuePickField(
            controller: controller,
            options: const ['Publisher A', 'Publisher B'],
            label: 'Publisher',
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    expect(find.text('Pick Publisher'), findsNothing);
    expect(find.text('Publisher B'), findsNothing);
  });

  testWidgets(
      'single value pick field keeps dropdown action when empty options',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleValuePickField(
            controller: controller,
            options: const [],
            label: 'Publisher',
          ),
        ),
      ),
    );

    expect(find.byTooltip('Pick Publisher'), findsOneWidget);

    await tester.tap(find.byTooltip('Pick Publisher'));
    await tester.pumpAndSettle();

    expect(find.byType(PopupMenuItem<String>), findsOneWidget);
  });
}
