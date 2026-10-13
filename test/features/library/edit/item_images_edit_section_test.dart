import 'dart:typed_data';

import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_image_intake.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  testWidgets('empty image tab matches the CLZ add-image tile', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemImagesEditSection(
            images: const [],
            accent: Colors.teal,
            onChanged: (_) {},
            helperText:
                'Add your own images (max. 5), set a description and an image type (Signature, Booklet, etc.).',
          ),
        ),
      ),
    );

    expect(
        find.text(
            'Add your own images (max. 5), set a description and an image type (Signature, Booklet, etc.).'),
        findsOneWidget);
    expect(
        find.text('Drop, paste or click to add a new image'), findsOneWidget);
    expect(
        tester.getSize(find.byType(LibraryImageIntake)), const Size(164, 300));
    expect(find.text('Upload'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('image cards show description and type fields inline', (
    tester,
  ) async {
    final imageBytes = Uint8List.fromList(
      img.encodePng(img.Image(width: 1, height: 1)),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemImagesEditSection(
            images: [
              ItemImageDraft(
                id: 'image-1',
                imageType: 'booklet',
                imageData: imageBytes,
                caption: 'Booklet',
                createdAt: DateTime.utc(2026),
              ),
            ],
            accent: Colors.teal,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Image Type'), findsOneWidget);
    expect(find.text('Booklet'), findsNWidgets(2));
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('item-image-image-1'))),
      const Size(164, 300),
    );
    expect(find.text('Edit image details'), findsNothing);

    await tester.tap(find.byTooltip('Edit image'));
    await tester.pumpAndSettle();
    expect(find.text('Upload'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);
    expect(find.text('Rotate'), findsOneWidget);
    expect(find.text('Crop / Rotate'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
