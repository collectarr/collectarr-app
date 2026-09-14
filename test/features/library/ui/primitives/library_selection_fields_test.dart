import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LibrarySelectField renders typed value and label',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibrarySelectField<String>(
            label: 'Format',
            value: 'Digital',
            items: const [
              DropdownMenuItem(value: 'Digital', child: Text('Digital')),
              DropdownMenuItem(value: 'Physical', child: Text('Physical')),
            ],
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Format'), findsOneWidget);
    expect(find.text('Digital'), findsOneWidget);
  });

  testWidgets('LibraryVocabularyField delegates to the single-value picker',
      (tester) async {
    final controller = TextEditingController(text: 'Blu-ray');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryVocabularyField(
            label: 'Format',
            controller: controller,
            options: const ['Blu-ray', 'DVD'],
          ),
        ),
      ),
    );

    expect(find.text('Format'), findsOneWidget);
    expect(find.text('Blu-ray'), findsOneWidget);
  });
}
