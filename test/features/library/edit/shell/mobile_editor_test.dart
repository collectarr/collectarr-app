import 'package:collectarr_app/features/library/edit/fields/layout_widgets.dart';
import 'package:collectarr_app/features/library/edit/shell/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final width in [320.0, 390.0, 600.0, 840.0, 1024.0]) {
    testWidgets('native editor keeps Save, draft and tab state at $width dp',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final harnessKey = GlobalKey<_EditorHarnessState>();
      await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
              data: MediaQueryData(
                  size: Size(width, 900), textScaler: TextScaler.linear(1.3)),
              child: _EditorHarness(key: harnessKey))));
      await tester.pumpAndSettle();
      final save = find.byKey(const Key('library.mobile-editor.save'));
      expect(save, findsOneWidget);
      expect(tester.getRect(save).top, lessThan(80));
      await tester.enterText(
          find.byKey(const Key('draft.title')), 'Changed draft');
      await tester.tap(find.text('Personal'));
      await tester.pumpAndSettle();
      expect(find.text('Personal tab'), findsOneWidget);
      await tester.tap(find.text('Main'));
      await tester.pumpAndSettle();
      expect(find.text('Changed draft'), findsOneWidget);
      await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
              data: MediaQueryData(
                  size: Size(width, 900),
                  textScaler: TextScaler.linear(1.3),
                  viewInsets: const EdgeInsets.only(bottom: 300)),
              child: _EditorHarness(key: harnessKey))));
      await tester.pumpAndSettle();
      expect(tester.getRect(save).top, lessThan(80));
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(harnessKey.currentState!.saved, 'Changed draft');
      await tester.tap(find.byTooltip('More editor actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next item'));
      await tester.pumpAndSettle();
      expect(harnessKey.currentState!.nextCount, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
        variant: TargetPlatformVariant(
            {TargetPlatform.android, TargetPlatform.iOS}));
  }
}

class _EditorHarness extends StatefulWidget {
  const _EditorHarness({super.key});
  @override
  State<_EditorHarness> createState() => _EditorHarnessState();
}

class _EditorHarnessState extends State<_EditorHarness>
    with SingleTickerProviderStateMixin {
  late final tabs = TabController(length: 2, vsync: this);
  final title = TextEditingController(text: 'Original');
  final form = GlobalKey<FormState>();
  String? saved;
  int nextCount = 0;
  @override
  void dispose() {
    tabs.dispose();
    title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LibraryEditDialogScaffold(
        formKey: form,
        accent: Colors.teal,
        icon: Icons.edit,
        title: 'Edit item',
        badges: const [],
        tabController: tabs,
        tabIds: const ['main', 'personal'],
        tabs: const [Text('Main'), Text('Personal')],
        views: [
          EditTabShell(children: [
            TextFormField(
                key: const Key('draft.title'),
                controller: title,
                validator: (v) => v!.isEmpty ? 'Required' : null)
          ]),
          const EditTabShell(children: [Text('Personal tab')]),
        ],
        onClose: () {},
        onCancel: () {},
        onSave: () {
          if (form.currentState!.validate()) saved = title.text;
        },
        onNext: () {
          nextCount++;
        },
      );
}
