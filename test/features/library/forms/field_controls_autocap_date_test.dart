import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/catalog_field_specs.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec_control_builder.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('partial date edits emit the changed component value',
      (tester) async {
    PartialDate? changedDate;
    await tester.pumpWidget(MaterialApp(
      theme: buildLibraryTheme(palette: kDefaultAppThemePalette),
      home: Scaffold(
          body: LibraryPartialDateInput(
        value: const PartialDate(year: 2024, month: 10, day: 6),
        onChanged: (value) => changedDate = value,
      )),
    ));
    expect(find.text('2024'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('06'), findsOneWidget);
    expect(changedDate, isNull);
    await tester.enterText(find.byType(TextFormField).at(1), '11');
    await tester.pump();
    expect(changedDate, const PartialDate(year: 2024, month: 11, day: 6));
  });

  testWidgets('Autocap action renders Aa instead of Tt glyph in field header',
      (tester) async {
    final spec = LibraryTextFieldSpec<Map<String, String>>(
      id: 'title',
      label: 'Title',
      value: (draft) => draft['title'] ?? '',
      setValue: (draft, val) => draft['title'] = val,
      actions: musicTitleActions,
    );

    final draft = <String, String>{'title': 'the dark side of the moon'};
    final controllers = <String, TextEditingController>{};

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildLibraryTheme(palette: kDefaultAppThemePalette),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final builder =
                    LibraryFieldSpecControlBuilder<Map<String, String>>(
                  context: context,
                  draft: draft,
                  mode: LibraryFieldSpecControlMode.edit,
                  controllerFor: (id, initial) => controllers.putIfAbsent(
                      id, () => TextEditingController(text: initial)),
                );
                return builder.build(spec);
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Aa'), findsOneWidget);
    expect(find.byIcon(Icons.text_fields), findsNothing);

    // Tapping Aa applies autocap
    await tester.tap(find.text('Aa'));
    await tester.pump();

    expect(draft['title'], 'The Dark Side of the Moon');
  });

  testWidgets('LibraryPartialDateFieldSpec renders the shared calendar action',
      (tester) async {
    final spec = LibraryPartialDateFieldSpec<Map<String, Object?>>(
      id: 'recording_date',
      label: 'Recording Date',
      value: (draft) => draft['recording_date'] as PartialDate?,
      setValue: (draft, val) => draft['recording_date'] = val,
    );

    final draft = <String, Object?>{
      'recording_date': const PartialDate(year: 1973, month: 3, day: 1),
    };
    final controllers = <String, TextEditingController>{};

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildLibraryTheme(palette: kDefaultAppThemePalette),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final builder =
                    LibraryFieldSpecControlBuilder<Map<String, Object?>>(
                  context: context,
                  draft: draft,
                  mode: LibraryFieldSpecControlMode.edit,
                  controllerFor: (id, initial) => controllers.putIfAbsent(
                      id, () => TextEditingController(text: initial)),
                );
                return builder.build(spec);
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Recording Date'), findsOneWidget);
    expect(find.byIcon(AppIcons.calendar), findsOneWidget);
  });
}
