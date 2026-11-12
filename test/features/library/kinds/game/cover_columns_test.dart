import 'dart:convert';

import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';
import 'package:collectarr_app/features/library/domain/target_ref.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/entry_schema.dart';
import 'package:collectarr_app/features/library/workspace/config/typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/item.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/schema/projections.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final imageType in ['front_cover', 'back_cover']) {
    testWidgets(
        'Games $imageType column loads local images without a catalog URL',
        (tester) async {
      const entryRef = LibraryEntryRef(
          kind: CatalogMediaKind.game, id: LibraryEntryId('local-cover'));
      final fields =
          gameLibraryEntryWorkspaceSchema.toRegistry().asStructural();
      final column = fields.columns.singleWhere((column) =>
          column.id.value ==
          (imageType == 'front_cover' ? 'game.cover' : 'game.back_cover'));
      expect(column.minRowHeight, greaterThanOrEqualTo(56));
      final context = LibraryProjectionContext(
        item: WorkspaceItem(target: const EntryTargetRef(entryRef)),
        personal: const PersonalOverlay(),
        dto: GameWorkspaceDto(
          common: const WorkspaceCommonProjection(title: 'Local Game'),
          personal: PersonalEntryProjection(),
          metadata: const GameCatalogMetadata(title: 'Local Game'),
        ),
      );
      final png = base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aX9kAAAAASUVORK5CYII=');
      final requests = <LocalItemImageRequest>[];
      await tester.pumpWidget(ProviderScope(
          overrides: [
            localItemImageProvider.overrideWith((ref, request) {
              requests.add(request);
              return Stream.value(png);
            }),
          ],
          child: MaterialApp(
              home: Scaffold(
                  body: Center(
            child: column.cellValue!(context),
          )))));
      await tester.pumpAndSettle();
      final cover =
          tester.widget<LibraryCoverImage>(find.byType(LibraryCoverImage));
      expect(cover.libraryEntryRef, entryRef);
      expect(cover.localImageType, imageType);
      expect(requests,
          contains((libraryEntryRef: entryRef, imageType: imageType)));
      expect(tester.getSize(find.byType(LibraryCoverImage)).height, 48);
      final image = tester.widget<Image>(find.byType(Image)).image;
      expect(image is ResizeImage ? image.imageProvider : image,
          isA<MemoryImage>());
      expect(tester.takeException(), isNull);
    });
  }
}
