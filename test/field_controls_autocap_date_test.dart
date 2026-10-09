import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec_control_builder.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'LibraryPartialDateInput renders divider lines between date fields',
      (tester) async {
    PartialDate? changedDate;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLibraryTheme(palette: kDefaultAppThemePalette),
        home: Scaffold(
          body: LibraryPartialDateInput(
            value: const PartialDate(year: 2024, month: 10, day: 6),
            onChanged: (val) => changedDate = val,
          ),
        ),
      ),
    );

    // Verify 3 input text controls for YYYY, MM, DD
    expect(changedDate, isNull);
    expect(find.byType(LibraryTextFormControl), findsNWidgets(3));
    expect(find.text('2024'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('06'), findsOneWidget);

    // Verify 2 divider line containers connecting the fields
    final containers =
        tester.widgetList<Container>(find.byType(Container)).where((c) {
      final constraints = c.constraints;
      return constraints != null &&
          constraints.minWidth == 8 &&
          constraints.maxWidth == 8 &&
          constraints.minHeight == 1 &&
          constraints.maxHeight == 1;
    }).toList();

    expect(containers.length, 2);
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

  testWidgets('LibraryPartialDateFieldSpec renders calendar-days svg action',
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
    expect(find.byType(SvgPicture), findsOneWidget);
  });
}
