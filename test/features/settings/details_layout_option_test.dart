import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/settings/library_layout_setting.dart';
import 'package:collectarr_app/features/settings/standard_kind_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<bool> offered(WidgetTester tester, TargetPlatform platform) async {
    debugDefaultTargetPlatformOverride = platform;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Builder(
              builder: (context) =>
                  buildStandardKindSettings(context, CatalogMediaKind.music),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    final found = find.byType(LibraryLayoutSetting).evaluate().isNotEmpty;
    await tester.pumpWidget(const SizedBox());
    debugDefaultTargetPlatformOverride = null;
    return found;
  }

  testWidgets('desktop settings offer the details layout', (tester) async {
    expect(await offered(tester, TargetPlatform.windows), isTrue);
  });

  testWidgets('phone and tablet settings do not', (tester) async {
    expect(await offered(tester, TargetPlatform.android), isFalse);
  });
}
