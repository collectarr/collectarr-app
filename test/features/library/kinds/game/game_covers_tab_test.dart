import 'dart:typed_data';

import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/covers_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  testWidgets('removing a front cover emits its deletion', (tester) async {
    final png =
        Uint8List.fromList(img.encodePng(img.Image(width: 2, height: 2)));
    List<ItemImageEdit>? edits;
    tester.view.physicalSize = const Size(2400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 2000,
          child: GameCoversTab(
            images: [
              ItemImageDraft(
                id: 'front-1',
                imageType: 'front_cover',
                imageData: png,
                createdAt: DateTime.utc(2026),
              ),
            ],
            coverImageUrl: '',
            originalCoverImageUrl: '',
            onCoverImageUrlChanged: (_) {},
            onEdits: (value) => edits = value,
            searchTitle: () => 'Halo',
          ),
        ),
      ),
    )));

    expect(find.text('Front Cover'), findsOneWidget);
    expect(find.text('Back Cover'), findsOneWidget);
    expect(find.text('Find Online'), findsNWidgets(2));
    // The reference's 38 px bar centres its 30 px buttons.
    final bar = tester.getRect(find
        .ancestor(
            of: find.text('Find Online').first,
            matching: find.byWidgetPredicate((widget) =>
                widget is Container && widget.constraints?.minHeight == 38))
        .first);
    expect(bar.height, 38);
    for (final label in ['Find Online', 'Upload', 'Remove', 'Crop / Rotate']) {
      final button = tester.getRect(find
          .ancestor(
              of: find.text(label).first, matching: find.byType(TextButton))
          .first);
      expect(button.height, 30, reason: label);
      expect(button.center.dy, bar.center.dy, reason: label);
    }

    await tester.tap(find.text('Remove'));
    await tester.pump();

    expect(edits, hasLength(1));
    expect(edits!.single.id, 'front-1');
    expect(edits!.single.deleted, isTrue);
  });
}
