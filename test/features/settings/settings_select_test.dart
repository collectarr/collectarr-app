import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:collectarr_app/ui/theme/shell_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a settings select is 34 px tall on every platform',
      variant: TargetPlatformVariant.all(), (tester) async {
    await tester.pumpWidget(MaterialApp(
      // Each platform's default density: compact on desktop, standard on
      // mobile.
      theme: buildAppShellTheme(),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 300,
            child: SettingsSelect<String>(
              value: 'USD',
              values: const ['USD', 'EUR'],
              labelOf: (value) => value,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    ));

    // The outline is drawn around the decorator's content, so the content
    // itself must make the 34 px.
    final decoration =
        tester.renderObject<RenderBox>(find.byType(InputDecorator));
    expect(decoration.size.height, 34);
    RenderBox? content;
    decoration.visitChildren((child) {
      child.visitChildren((inner) {
        if (inner is RenderBox && inner.size.width == decoration.size.width) {
          content = inner;
        }
      });
    });
    expect(content?.size.height, 34);
  });
}
