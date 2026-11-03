import 'package:collectarr_app/features/library/edit/schema/renderer.dart';
import 'package:collectarr_app/features/library/edit/schema/schema.dart';
import 'package:collectarr_app/features/library/edit/shell/mobile_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('mobile editor header updates when tab labels and ids change',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final header = ValueNotifier<Widget?>(null);
    addTearDown(header.dispose);
    late StateSetter update;
    var label = 'Before';
    var id = 'before';
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: StatefulBuilder(
      builder: (context, setState) {
        update = setState;
        return LibraryMobileEditorHeaderTabsScope(
          tabsNotifier: header,
          child: Column(children: [
            ValueListenableBuilder<Widget?>(
                valueListenable: header,
                builder: (_, tabs, __) => tabs ?? const SizedBox()),
            Expanded(
                child: EditSchemaRenderer<int, int>.embedded(
              schema: EditSchema(tabs: [
                EditTabSpec(id: id, label: label, sections: const [])
              ]),
              model: 0,
              draft: 0,
            )),
          ]),
        );
      },
    ))));
    await tester.pumpAndSettle();
    expect(find.text('Before'), findsOneWidget);
    update(() {
      label = 'After';
      id = 'after';
    });
    await tester.pumpAndSettle();
    expect(find.text('Before'), findsNothing);
    expect(find.text('After'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
