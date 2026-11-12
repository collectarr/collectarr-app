import 'dart:async';
import 'dart:convert';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/tokens.dart';
import 'package:collectarr_app/features/library/workspace/tiles/card.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_image.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../support/builders/library_entry_builder.dart';
import '../../../../support/builders/workspace_item_builder.dart';

void main() {
  for (final kind in ['game', 'music', 'comic']) {
    for (final (aspect, encoded) in [
      (
        0.8,
        'iVBORw0KGgoAAAANSUhEUgAAAEAAAABQCAIAAAAm3eQSAAAAkElEQVR4nO3PUQkAIBTAwNfFYHY2kSH8OITBAtzm7PV1wwUNaEEDWtCAFjSgBQ1oQQNa0IAWNKAFDWhBA1rQgBY0oAUNaEEDWtCAFjSgBQ1oQQNa0IAWNKAFDWhBA1rQgBY0oAUNaEEDWtCAFjSgBQ1oQQNa0IAWNKAFDWhBA1rQgBY0oAUNaEEDWtCAFjx2AVs9kYc2K6DrAAAAAElFTkSuQmCC'
      ),
      (
        1.25,
        'iVBORw0KGgoAAAANSUhEUgAAAFAAAABACAIAAAACpWdhAAAAZElEQVR4nO3PAQkAIBDAQLsYzM4mMoawP1iA3bpnj2p9PwAGBgYGBgYeE3A94HrA9YDrAdcDrgdcD7gecD3gesD1gOsB1wOuB1wPuB5wPeB6wPWA6wHXA64HXA+4HnA94HrA9R7OspGHWbBuogAAAABJRU5ErkJggg=='
      )
    ]) {
      testWidgets('$kind horizontal cover fills card height at aspect $aspect',
          (tester) async {
        SharedPreferences.setMockInitialValues({});
        final database = LocalDatabase(NativeDatabase.memory());
        final entry =
            testLibraryEntry(kind: kind, id: 'horizontal-$kind-$aspect');
        final source = testLibraryWorkspaceSource(
            itemId: entry.itemId,
            kind: kind,
            title: 'Test',
            libraryEntry: entry);
        final item = LibraryProjectionItem.fromShelf(
            source, libraryKindRegistrationForKind(source.mediaKind));
        final png = base64Decode(encoded);
        try {
          for (final height in [120.0, 180.0]) {
            await tester.pumpWidget(ProviderScope(
                overrides: [
                  localDatabaseProvider.overrideWithValue(database),
                  localItemImageProvider
                      .overrideWith((ref, request) => Stream.value(png)),
                ],
                child: MaterialApp(
                    home: Scaffold(
                        body: Center(
                            child: SizedBox(
                  width: 500,
                  height: height,
                  child: LibraryWorkspaceCard(
                      item: item,
                      selected: true,
                      onTap: () {},
                      coverWidth: 80,
                      cardLayout: LibraryCardLayout.horizontal),
                ))))));
            await tester.pumpAndSettle();
            final image = find.descendant(
                of: find.byType(LibraryCoverImage),
                matching: find.byType(Image));
            await tester.runAsync(() async {
              final stream = tester
                  .widget<Image>(image)
                  .image
                  .resolve(ImageConfiguration.empty);
              final ready = Completer<void>();
              final listener = ImageStreamListener((info, _) {
                info.dispose();
                if (!ready.isCompleted) ready.complete();
              },
                  onError: (Object error, StackTrace? stack) =>
                      ready.completeError(error, stack));
              stream.addListener(listener);
              try {
                await ready.future;
              } finally {
                stream.removeListener(listener);
              }
            });
            await tester.pumpAndSettle();
            final card = tester.getRect(find.byType(LibraryWorkspaceCard));
            final pixels = tester.getRect(image);
            expect(pixels.height,
                closeTo(height - kLibraryHorizontalCardPadding.vertical, 0.01));
            expect(pixels.width / pixels.height, closeTo(aspect, 0.01));
            expect(pixels.top,
                closeTo(card.top + kLibraryHorizontalCardPadding.top, 0.01));
            expect(
                pixels.bottom,
                closeTo(
                    card.bottom - kLibraryHorizontalCardPadding.bottom, 0.01));
            expect(tester.takeException(), isNull);
          }
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
          await database.close();
        }
      });
    }
  }
}
