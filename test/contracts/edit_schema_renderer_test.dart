import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final class _RendererDraft {
  _RendererDraft(this.title);

  String title;
  bool enabled = false;
}

void main() {
  testWidgets('renderer displays schema fields and saves a dirty draft',
      (tester) async {
    final draft = _RendererDraft('Initial');
    var saved = false;
    final schema = EditSchema<int, _RendererDraft>(
      isDirty: (_, value) => value.title != 'Initial',
      tabs: [
        EditTabSpec<_RendererDraft>(
          id: 'main',
          label: 'Main',
          sections: [
            EditSectionSpec<_RendererDraft>(
              id: 'details',
              label: 'Details',
              fields: [
                TextEditField<_RendererDraft>(
                  id: 'title',
                  label: 'Title',
                  value: (value) => value.title,
                  setValue: (value, text) => value.title = text,
                ),
                ToggleEditField<_RendererDraft>(
                  id: 'enabled',
                  label: 'Enabled',
                  value: (value) => value.enabled,
                  setValue: (value, enabled) => value.enabled = enabled,
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditSchemaRenderer<int, _RendererDraft>(
            schema: schema,
            model: 1,
            draft: draft,
            onSave: (_) async => saved = true,
          ),
        ),
      ),
    );

    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Updated');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(draft.title, 'Updated');
    expect(saved, isTrue);
  });

  testWidgets('renderer keeps invalid drafts from reaching save callback',
      (tester) async {
    final draft = _RendererDraft('');
    var saved = false;
    final schema = EditSchema<int, _RendererDraft>(
      validate: (_, value) => value.title.trim().isEmpty ? 'Required' : null,
      tabs: [
        EditTabSpec<_RendererDraft>(
          id: 'main',
          label: 'Main',
          sections: [
            EditSectionSpec<_RendererDraft>(
              id: 'details',
              label: 'Details',
              fields: [
                TextEditField<_RendererDraft>(
                  id: 'title',
                  label: 'Title',
                  value: (value) => value.title,
                  setValue: (value, text) => value.title = text,
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditSchemaRenderer<int, _RendererDraft>(
            schema: schema,
            model: 1,
            draft: draft,
            onSave: (_) async => saved = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Required'), findsOneWidget);
    expect(saved, isFalse);
  });
}
