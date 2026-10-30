import 'package:collectarr_app/features/library/ui/library_metrics.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('edit status fields use the same control height', (tester) async {
    String? changedStatus;
    final fields = [
      SizedBox(
        key: const ValueKey('collection-status'),
        width: 240,
        child: LibraryCollectionStatusField(
          value: 'In Collection',
          onChanged: (value) => changedStatus = value,
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
    expect(decorators, findsNWidgets(3));
    for (var index = 0; index < decorators.evaluate().length; index++) {
      expect(
        tester.getSize(decorators.at(index)).height,
        LibraryMetrics.defaultFieldHeight,
      );
    }
    expect(
      heights.values.toSet(),
      {20 + 1 + LibraryMetrics.defaultFieldHeight},
      reason: 'Field heights differ: $heights',
    );
    await tester.tap(find.byTooltip('Choose collection status'));
    await tester.pumpAndSettle();
    expect(find.text('Collection'), findsOneWidget);
    expect(find.text('Wish List'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Wish List')).style?.fontWeight,
        FontWeight.w700);
    Color? shade(String status) => tester
        .widget<Container>(find
            .ancestor(
                of: find.text(status).last, matching: find.byType(Container))
            .first)
        .color;
    expect(shade('In Collection'), isNotNull);
    expect(shade('For Sale'), isNull);
    expect(
        tester.getTopLeft(find.text('For Sale')).dx -
            tester.getTopLeft(find.text('Collection')).dx,
        17);
    await tester.tap(find.text('For Sale'));
    await tester.pumpAndSettle();
    expect(changedStatus, 'For Sale');
    expect(tester.takeException(), isNull);
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
    // The reference's empty menu: 5 px above and below inside its border.
    final menu = find
        .ancestor(
            of: find.byType(PopupMenuItem<String>),
            matching: find.byType(Material))
        .first;
    expect(tester.getSize(menu).height, 12);
  });
}
