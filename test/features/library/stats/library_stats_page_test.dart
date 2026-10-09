import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/stats/library_stats_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';
import '../../../helpers/test_constants.dart';

void main() {
  testWidgets(
      'LibraryStatsPage renders full page with custom music header and sections',
      (tester) async {
    final musicType =
        defaultLibraryKindRegistry.require(CatalogMediaKind.music);

    final track1 = MusicTrack(
      id: const MusicTrackId('track-1'),
      position: 'A1',
      title: 'Song One',
      durationMs: 180000,
    );
    final disc1 = MusicDisc(
      id: const MusicDiscId('disc-1'),
      discNumber: 1,
      format: 'Vinyl',
      tracks: [track1],
    );
    final album1 = MusicAlbum(
      id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'album-1'),
      title: 'Greatest Album',
      artist: 'Rock Band',
      discs: [disc1],
    );

    final entry1 = testLibraryWorkspaceSource(
      itemId: 'album-1',
      kind: 'music',
      title: 'Greatest Album',
      catalogData: MusicWorkspaceData.fromMusic(album1),
    );

    final shelf = ShelfState(
      entries: [entry1],
      entryCount: 1,
      wishlistCount: 0,
      pricedCount: 0,
      totalPaidCents: null,
      primaryCurrency: null,
      hasMixedCurrencies: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryStatsPage(
            type: musicType,
            state: shelf,
          ),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    // Title and back button
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.byKey(const Key('stats.back')), findsOneWidget);

    // Custom music header
    expect(find.textContaining('albums and 1 Artists'), findsOneWidget);
    expect(find.textContaining('tracks / total runtime:'), findsOneWidget);

    // Sections
    expect(find.text('Albums by Format'), findsOneWidget);
    expect(find.text('Played'), findsOneWidget);
    expect(find.text('Most recent additions'), findsOneWidget);
    expect(find.text('Greatest Album'), findsOneWidget);
    expect(find.text('Rock Band'), findsWidgets);
  });
}
