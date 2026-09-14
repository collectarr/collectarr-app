import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final class _RendererDraft {
  _RendererDraft(this.title);

  String title;
  bool enabled = true;
  String? status = 'active';
  Set<String> tags = {'one'};
}

AddSchema<_RendererDraft> _schema(
    {String? Function(_RendererDraft)? validate}) {
  return AddSchema<_RendererDraft>(
    title: (_) => 'Add item',
    validate: validate,
    sections: [
      AddSectionSpec<_RendererDraft>(
        id: 'main',
        label: 'Main',
        fields: [
          TextAddField<_RendererDraft>(
            id: 'title',
            label: 'Title',
            value: (draft) => draft.title,
            setValue: (draft, value) => draft.title = value,
          ),
          ToggleAddField<_RendererDraft>(
            id: 'enabled',
            label: 'Enabled',
            value: (draft) => draft.enabled,
            setValue: (draft, value) => draft.enabled = value,
          ),
          SelectAddField<_RendererDraft, String>(
            id: 'status',
            label: 'Status',
            value: (draft) => draft.status,
            setValue: (draft, value) => draft.status = value,
            options: const [
              EditOption(value: 'active', label: 'Active'),
              EditOption(value: 'archived', label: 'Archived'),
            ],
          ),
          VocabularyAddField<_RendererDraft, String>(
            id: 'vocabulary',
            label: 'Vocabulary',
            value: (draft) => draft.status,
            setValue: (draft, value) => draft.status = value,
            options: const [EditOption(value: 'active', label: 'Active')],
          ),
          MultiVocabularyAddField<_RendererDraft, String>(
            id: 'tags',
            label: 'Tags',
            values: (draft) => draft.tags,
            setValues: (draft, values) => draft.tags = values,
            options: const [EditOption(value: 'one', label: 'One')],
          ),
          DateAddField<_RendererDraft>(
            id: 'date',
            label: 'Date',
            value: (_) => DateTime(2026),
            setValue: (_, __) {},
          ),
          ImageAddField<_RendererDraft, String>(
            id: 'image',
            label: 'Image',
            value: (_) => null,
            setValue: (_, __) {},
          ),
          ReadOnlyAddField<_RendererDraft, String>(
            id: 'readOnly',
            label: 'Read only',
            value: (draft) => draft.status,
            display: (value) => value ?? 'None',
          ),
          CustomAddField<_RendererDraft>(
            id: 'custom',
            label: 'Custom',
            builder: (context, draft) => Text('Custom ${draft.title}'),
          ),
        ],
      ),
    ],
  );
}

Widget _testHost({
  required AddSchema<_RendererDraft> schema,
  required _RendererDraft draft,
  required Future<void> Function(_RendererDraft draft) onSubmit,
}) {
  return MaterialApp(
    home: Scaffold(
      body: AddSchemaRenderer<_RendererDraft>(
        schema: schema,
        draft: draft,
        onSubmit: onSubmit,
      ),
    ),
  );
}

void main() {
  testWidgets('renderer displays fields and submits the draft', (tester) async {
    final draft = _RendererDraft('Initial');
    var submitted = false;

    await tester.pumpWidget(
      _testHost(
        schema: _schema(),
        draft: draft,
        onSubmit: (_) async => submitted = true,
      ),
    );

    expect(find.text('Add item'), findsOneWidget);
    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Enabled'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Vocabulary'), findsOneWidget);
    expect(find.text('Tags'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Image'), findsOneWidget);
    expect(find.text('Read only'), findsOneWidget);
    expect(find.text('Custom Initial'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Updated');
    await tester.pump();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(draft.title, 'Updated');
    expect(submitted, isTrue);
  });

  testWidgets('renderer blocks submit when the draft is invalid',
      (tester) async {
    final draft = _RendererDraft('');
    var submitted = false;

    await tester.pumpWidget(
      _testHost(
        schema: _schema(
          validate: (draft) =>
              draft.title.trim().isEmpty ? 'Title required' : null,
        ),
        draft: draft,
        onSubmit: (_) async => submitted = true,
      ),
    );

    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(find.text('Title required'), findsOneWidget);
    expect(submitted, isFalse);
  });
}
