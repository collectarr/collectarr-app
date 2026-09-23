import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/kinds/music/inspector_panel.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';

import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';

void main() {
  testWidgets('music inspector renders CLZ-like panel with disc groups', (
    tester,
  ) async {
    final ownedItem = testOwnedItem(
      id: 'owned-music-1',
      itemId: 'music-1',
      indexNumber: 1,
      createdAt: DateTime.utc(2026, 6, 3, 17, 21, 47),
      updatedAt: DateTime.utc(2026, 6, 3, 17, 21, 48),
    );
    final graph = _musicGraph(
      workId: 'music-1',
      title: 'Lupus Dei',
      artist: 'Powerwolf',
      media: [
        _medium('music-1-medium-1', 'music-1-release', 1, [
          _track('music-1-track-1', 'music-1-medium-1', '1',
              'Lupus Daemonis (Intro)', 77000),
          _track(
              'music-1-track-2', 'music-1-medium-1', '11', 'Lupus Dei', 370000),
        ]),
        _medium('music-1-medium-2', 'music-1-release', 2, [
          _track('music-1-track-3', 'music-1-medium-2', '2',
              'Mr Sinister (Live)', 287000),
        ]),
      ],
    );
    final source = LibraryWorkspaceSource(
      itemId: 'music-1',
      catalogData: graph.catalog,
      ownedSummary: testOwnedSummary(ownedItem),
    );
    final node = graph.ref;
    final dto = const MusicReleaseWorkspaceProjector().project(
      source: source,
      entity: node,
    );
    final item = LibraryProjectionItem(source: source, node: node, dto: dto);

    final inspectorRequest = LibraryInspectorRequest(
      type: const MusicRegistration(),
      item: item,
      ownedItem: testOwnedSummary(ownedItem),
      ownedCopies: [testOwnedSummary(ownedItem)],
      accent: const Color(0xFFFDAD49),
      detailsLayout: LibraryDetailsLayout.hidden,
      onFilterByValue: (_) {},
      searchQuery: null,
      searchTarget: LibrarySearchTarget.all,
    );
    final request = LibraryInspectorPanelRequest(
      inspector: inspectorRequest,
      hero: const SizedBox.shrink(),
      primarySections: const [],
      trailingSections: const [],
      ownedCopies: [testOwnedSummary(ownedItem)],
      selectedOwnedItemRef: testOwnedSummary(ownedItem).ref,
      extraActions: const [],
      onAddCopy: () {},
      onOpenDetails: () {},
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 760,
              child: MusicInspectorPanel(request: request),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(MusicInspectorPanel), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text('Powerwolf'), findsWidgets);
    expect(find.text('Disc #1'), findsWidgets);
    expect(find.text('Disc #2'), findsWidgets);
    expect(find.text('Front cover'), findsOneWidget);
    expect(find.text('Back cover'), findsOneWidget);
    expect(find.text('Back cover not in metadata'), findsOneWidget);
  });

  testWidgets('music inspector highlights matching tracks for track search', (
    tester,
  ) async {
    final ownedItem = testOwnedItem(
      id: 'owned-music-2',
      itemId: 'music-2',
      createdAt: DateTime.utc(2026, 6, 3, 17, 21, 47),
      updatedAt: DateTime.utc(2026, 6, 3, 17, 21, 48),
    );
    final graph = _musicGraph(
      workId: 'music-2',
      title: 'Lupus Dei',
      artist: 'Powerwolf',
      media: [
        _medium('music-2-medium-1', 'music-2-release', 1, [
          _track('music-2-track-1', 'music-2-medium-1', '1',
              'Lupus Daemonis (Intro)', null),
          _track('music-2-track-2', 'music-2-medium-1', '3',
              'Prayer In The Dark', null),
        ]),
      ],
    );
    final source = LibraryWorkspaceSource(
      itemId: 'music-2',
      catalogData: graph.catalog,
      ownedSummary: testOwnedSummary(ownedItem),
    );
    final node = graph.ref;
    final dto = const MusicReleaseWorkspaceProjector().project(
      source: source,
      entity: node,
    );
    final item = LibraryProjectionItem(source: source, node: node, dto: dto);

    final inspectorRequest = LibraryInspectorRequest(
      type: const MusicRegistration(),
      item: item,
      ownedItem: testOwnedSummary(ownedItem),
      ownedCopies: [testOwnedSummary(ownedItem)],
      accent: const Color(0xFFFDAD49),
      detailsLayout: LibraryDetailsLayout.hidden,
      onFilterByValue: (_) {},
      searchQuery: 'prayer',
      searchTarget: LibrarySearchTarget.tracksOnly,
    );

    final request = LibraryInspectorPanelRequest(
      inspector: inspectorRequest,
      hero: const SizedBox.shrink(),
      primarySections: const [],
      trailingSections: const [],
      ownedCopies: [testOwnedSummary(ownedItem)],
      selectedOwnedItemRef: testOwnedSummary(ownedItem).ref,
      extraActions: const [],
      onAddCopy: () {},
      onOpenDetails: () {},
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 760,
              child: MusicInspectorPanel(request: request),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final matchingRow = find.byKey(
      const ValueKey('music-track-row-1-3-Prayer In The Dark'),
    );
    final nonMatchingRow = find.byKey(
      const ValueKey('music-track-row-1-1-Lupus Daemonis (Intro)'),
    );
    expect(matchingRow, findsOneWidget);
    expect(nonMatchingRow, findsOneWidget);

    final matchingDecoratedBox = tester.widget<DecoratedBox>(matchingRow);
    final nonMatchingDecoratedBox = tester.widget<DecoratedBox>(nonMatchingRow);
    final matchingDecoration = matchingDecoratedBox.decoration as BoxDecoration;
    final nonMatchingDecoration =
        nonMatchingDecoratedBox.decoration as BoxDecoration;
    expect(matchingDecoration.color, isNot(equals(Colors.transparent)));
    expect(nonMatchingDecoration.color, equals(Colors.transparent));
  });
}

({MusicWorkspaceCatalogData catalog, LibraryReleaseRef ref}) _musicGraph({
  required String workId,
  required String title,
  required String artist,
  required List<MusicMedium> media,
}) {
  final releaseId = '$workId-release';
  final release = MusicRelease(
    id: MusicReleaseId(releaseId),
    releaseGroupId: MusicReleaseGroupId(workId),
    title: title,
    mediums: media,
  );
  final group = MusicReleaseGroup(
    id: MusicReleaseGroupId(workId),
    title: title,
    artist: artist,
    releases: [release],
  );
  return (
    catalog: MusicWorkspaceCatalogData.fromMusic(group, release: release),
    ref: LibraryReleaseRef(
      workId: workId,
      releaseId: releaseId,
      release: LibraryWorkspaceReleaseSummary(id: releaseId, title: title),
    ),
  );
}

MusicMedium _medium(
  String id,
  String releaseId,
  int number,
  List<MusicTrack> tracks,
) =>
    MusicMedium(
      id: MusicMediumId(id),
      releaseId: MusicReleaseId(releaseId),
      mediumNumber: number,
      mediumType: 'CD',
      tracks: tracks,
    );

MusicTrack _track(
  String id,
  String mediumId,
  String position,
  String title,
  int? durationMs,
) =>
    MusicTrack(
      id: MusicTrackId(id),
      mediumId: MusicMediumId(mediumId),
      position: position,
      title: title,
      durationMs: durationMs,
    );
