import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_structure_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'empty Tracks tab hides the empty message and right-aligns Add Disc',
      (tester) async {
    final draft = MusicAlbumEditDraft.fromAlbum(
      MusicAlbum(
        id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'empty'),
        title: 'Empty release',
        discs: const [],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                key: const ValueKey('tracks-content'),
                width: 600,
                child: MusicAlbumStructureTab(
                  draft: draft,
                  accent: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
        find.text('This release does not have any discs yet.'), findsNothing);
    final addDiscButton = find
        .ancestor(
          of: find.text('Add Disc'),
          matching: find.byType(InkWell),
        )
        .first;
    expect(addDiscButton, findsOneWidget);
    expect(
      tester.getRect(addDiscButton).right,
      tester.getRect(find.byKey(const ValueKey('tracks-content'))).right,
    );
  });
}
