import 'dart:async';
import 'package:collectarr_app/features/library/workspace/table/table.dart';
import 'package:collectarr_app/features/library/workspace/table/row.dart';
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
      expect(column.minRowHeight, isNull);
      expect(column.cellPadding!.vertical, 0);
      expect(column.imageAspectRatio, 2 / 3);
      final context = LibraryProjectionContext(
        item: WorkspaceItem(target: const EntryTargetRef(entryRef)),
        personal: const PersonalOverlay(),
        dto: GameWorkspaceDto(
          common: const WorkspaceCommonProjection(title: 'Local Game'),
          personal: PersonalEntryProjection(),
          metadata: const GameCatalogMetadata(title: 'Local Game'),
        ),
      );
      final aspect = imageType == 'front_cover' ? 0.8 : 1.25;
      final png = base64Decode(imageType == 'front_cover'
          ? 'iVBORw0KGgoAAAANSUhEUgAAAEAAAABQCAIAAAAm3eQSAAAAkElEQVR4nO3PUQkAIBTAwNfFYHY2kSH8OITBAtzm7PV1wwUNaEEDWtCAFjSgBQ1oQQNa0IAWNKAFDWhBA1rQgBY0oAUNaEEDWtCAFjSgBQ1oQQNa0IAWNKAFDWhBA1rQgBY0oAUNaEEDWtCAFjSgBQ1oQQNa0IAWNKAFDWhBA1rQgBY0oAUNaEEDWtCAFjx2AVs9kYc2K6DrAAAAAElFTkSuQmCC'
          : 'iVBORw0KGgoAAAANSUhEUgAAAFAAAABACAIAAAACpWdhAAAAZElEQVR4nO3PAQkAIBDAQLsYzM4mMoawP1iA3bpnj2p9PwAGBgYGBgYeE3A94HrA9YDrAdcDrgdcD7gecD3gesD1gOsB1wOuB1wPuB5wPeB6wPWA6wHXA64HXA+4HnA94HrA9R7OspGHWbBuogAAAABJRU5ErkJggg==');
      final requests = <LocalItemImageRequest>[];
      double? textTop;
      for (final width in [90.0, 170.0]) {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            localItemImageProvider.overrideWith((ref, request) {
              requests.add(request);
              return Stream.value(png);
            })
          ],
          child: MaterialApp(
              home: Scaffold(
                  body: Center(
                      child: SizedBox(
            width: 500,
            height: 500,
            child: LibraryWorkspaceTable<String>(
              entries: const ['local-cover'],
              columns: [column.id.value, 'title'],
              sortColumn: 'title',
              sortAscending: true,
              columnWidthFor: (id) => id == 'title' ? 240 : width,
              defaultColumnWidthFor: (_) => width,
              columnSortFor: (id) => id,
              columnLabelFor: (id) => id,
              columnIsNumeric: (_) => false,
              columnImageAspectRatioFor: (id) =>
                  id == 'title' ? null : column.imageAspectRatio,
              columnCellPaddingFor: (id) =>
                  id == 'title' ? null : column.cellPadding,
              cellBuilder: (_, id) => id == 'title'
                  ? const Text('Local Game')
                  : column.cellValue!(context),
              isSelected: (_) => true,
              onEntryTap: (_) {},
              onSortChanged: (_) {},
              onColumnWidthChanged: (_, __) {},
            ),
          )))),
        ));
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final stream = tester
              .widget<Image>(find.byType(Image))
              .image
              .resolve(ImageConfiguration.empty);
          final decoded = Completer<void>();
          final listener = ImageStreamListener((info, _) {
            info.dispose();
            if (!decoded.isCompleted) decoded.complete();
          },
              onError: (Object error, StackTrace? stack) =>
                  decoded.completeError(error, stack));
          stream.addListener(listener);
          try {
            await decoded.future;
          } finally {
            stream.removeListener(listener);
          }
        });
        await tester.pumpAndSettle();
        final cover =
            tester.widget<LibraryCoverImage>(find.byType(LibraryCoverImage));
        expect(cover.libraryEntryRef, entryRef);
        expect(cover.localImageType, imageType);
        expect(requests,
            contains((libraryEntryRef: entryRef, imageType: imageType)));
        final row = tester.getRect(find.byType(LibraryTableInkRow));
        final image = tester.getRect(find.byType(Image));
        expect(image.width, width - column.cellPadding!.horizontal);
        expect(image.height, closeTo((width - 10) / aspect, 0.01));
        expect(image.top, row.top);
        expect(image.bottom, closeTo(row.bottom, 0.01));
        final top = tester.getTopLeft(find.text('Local Game')).dy;
        expect(top, textTop ?? top);
        textTop = top;
        final provider = tester.widget<Image>(find.byType(Image)).image;
        expect(provider is ResizeImage ? provider.imageProvider : provider,
            isA<MemoryImage>());
        expect(tester.takeException(), isNull);
      }
    });
  }
}
