import 'dart:io';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/comic/settings/custom_label_icons.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/slab.dart';
import 'package:collectarr_app/features/library/ui/primitives/platform_icon.dart';
import 'package:collectarr_app/features/pick_lists/list_value_images.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'loaded label icons appear on slabs and removal keeps Games icons',
      (tester) async {
    tester.view.physicalSize = const Size(390, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    final scratch =
        Directory.systemTemp.createTempSync('collectarr-label-icons-');
    const selector = MethodChannel('plugins.flutter.io/file_selector');
    const svg =
        '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="24">'
        '<rect width="64" height="24" fill="#008800"/></svg>';
    final image = File('${scratch.path}${Platform.pathSeparator}Test label.svg')
      ..writeAsStringSync(svg);
    final invalid = File('${scratch.path}${Platform.pathSeparator}invalid.txt')
      ..writeAsStringSync('invalid');
    final images = ListValueImages(db);
    await tester.runAsync(() => images.save(
        platformIconsList, 'Nintendo Switch', image.readAsBytesSync()));
    addTearDown(() async {
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(selector, null);
      await db.close();
      scratch.deleteSync(recursive: true);
    });
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(selector,
        (call) async {
      expect(call.method, 'openFile');
      expect((call.arguments as Map)['multiple'], isTrue);
      return [image.path, invalid.path];
    });
    await tester.pumpWidget(ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
            home: Scaffold(
                body: SingleChildScrollView(
                    child: Builder(
                        builder: (context) => Column(children: [
                              buildComicCustomLabelIconsSettings(
                                  context, CatalogMediaKind.comic),
                              const SizedBox(
                                  width: 200,
                                  height: 260,
                                  child: ComicSlab(
                                      customLabel: 'Test label',
                                      child: SizedBox.expand())),
                            ])))))));
    await tester.pumpAndSettle();
    expect(find.text('Custom label icons'), findsOneWidget);
    final slabImage = find.descendant(
        of: find.byType(ComicSlab), matching: find.byType(ListValueImageView));
    expect(slabImage, findsNothing);
    await tester.tap(find.text('Load icons from files...'));
    for (var i = 0; i < 30; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)));
      await tester.pump();
      if (find
          .text('Loaded 1 image. Skipped: invalid.txt.')
          .evaluate()
          .isNotEmpty) {
        break;
      }
    }
    await tester.pumpAndSettle();
    expect(
        await tester.runAsync(() =>
            images.watchValues(ComicVocabularyIds.customLabel.value).first),
        ['Test label']);
    expect(find.text('Test label'), findsOneWidget);
    expect(slabImage, findsOneWidget);
    expect(find.text('Loaded 1 image. Skipped: invalid.txt.'), findsOneWidget);
    await tester.tap(find.text('Remove all 1 loaded icons'));
    await tester.pumpAndSettle();
    expect(slabImage, findsNothing);
    expect(
        await tester.runAsync(() =>
            images.watchValues(ComicVocabularyIds.customLabel.value).first),
        isEmpty);
    expect(
        await tester
            .runAsync(() => images.watchValues(platformIconsList).first),
        ['Nintendo Switch']);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  },
      variant: TargetPlatformVariant({
        TargetPlatform.windows,
        TargetPlatform.android,
        TargetPlatform.iOS
      }));
}
