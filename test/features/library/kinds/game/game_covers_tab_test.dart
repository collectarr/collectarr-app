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
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 1000,
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

    await tester.tap(find.text('Remove'));
    await tester.pump();

    expect(edits, hasLength(1));
    expect(edits!.single.id, 'front-1');
    expect(edits!.single.deleted, isTrue);
  });
}
