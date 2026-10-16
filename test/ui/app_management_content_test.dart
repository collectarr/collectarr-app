import 'package:collectarr_app/ui/app_management_content.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [1440.0, 390.0]) {
    testWidgets('management canvas centers bounded content at $width px',
        (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const contentKey = Key('content');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AppManagementContent(
            child: Column(children: [
              const Text('Management'),
              Expanded(
                  child: ListView(key: contentKey, children: const [
                SizedBox(height: 1600, child: Text('Scrollable content')),
              ])),
            ]),
          ),
          bottomNavigationBar: const AppManagementContent(
            child: SizedBox(height: 48, child: Text('Actions')),
          ),
        ),
      ));
      final rect = tester.getRect(find.byKey(contentKey));
      expect(rect.width, width > 930 ? 930 : width);
      expect(rect.center.dx, width / 2);
      expect(rect.bottom, 752);
      expect(tester.getSize(find.text('Actions')).height, 48);
      final canvas = tester.widget<Material>(find
          .descendant(
              of: find.byType(AppManagementContent).first,
              matching: find.byType(Material))
          .first);
      expect(canvas.color,
          appManagementCanvasColor(tester.element(find.byKey(contentKey))));
      await tester.drag(find.byKey(contentKey), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
