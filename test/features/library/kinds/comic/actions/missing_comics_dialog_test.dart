import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/actions/missing_issues_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/actions/missing_issues_report.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/dto.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

LibraryProjectionItem _issue(String number, {bool owned = false}) {
  final comic = ComicCatalogItem(
      title: 'Fixture #$number', seriesTitle: 'Fixture', issueNumber: number);
  final entry = owned
      ? ComicLibraryEntry(
          id: LibraryEntryId('entry-$number'),
          metadata: comic,
          personal: const ComicPersonalData(),
          updatedAt: DateTime.utc(2026),
        )
      : null;
  return LibraryProjectionItem(
    source: LibraryWorkspaceContext(
      item: WorkspaceItem(
          target: CatalogTargetRef(CatalogItemRef(
              kind: CatalogMediaKind.comic, id: 'issue-$number'))),
      personal: const PersonalOverlay(),
    ),
    dto: ComicWorkspaceDto(
      common: WorkspaceCommonProjection(title: comic.title),
      personal: PersonalEntryProjection(),
      comic: comic,
      libraryEntry: entry,
    ),
  );
}

void main() {
  test('missing issues read as the reference\'s compact runs', () {
    final reports = buildMissingComicSeriesReports(
        [_issue('1', owned: true), _issue('2'), _issue('3'), _issue('5')]);
    final report = reports.single;
    expect(report.entryIssueCount, 1);
    expect(report.missingIssueCount, 3);
    expect(missingComicIssuesText(report, const MissingComicReportOptions()),
        '2–3 5');
    expect(
        missingComicIssuesText(
            report, const MissingComicReportOptions(verbose: true)),
        '2 3 5');
  });

  testWidgets('Missing Comics lists series in the reference table',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final items = [
      _issue('1', owned: true),
      _issue('2'),
      _issue('3'),
      _issue('5')
    ];
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => showComicMissingComicsDialog(
            context: context,
            type: defaultLibraryKindRegistry.require(CatalogMediaKind.comic),
            projection: LibraryProjection(
              allItems: items,
              filteredItems: items,
              buckets: const [],
              selectedItem: null,
              counts: const LibraryToolbarCounts(),
            ),
            accent: const Color(0xFF00AEE6),
          ),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Missing Comics'), findsOneWidget);
    for (final heading in ['Series', 'Owned', 'Missing', 'Missing Issues']) {
      expect(find.text(heading), findsOneWidget);
    }
    expect(find.text('Fixture'), findsOneWidget);
    expect(find.text('2–3 5'), findsOneWidget);
    expect(find.text('Download PDF'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    await tester.tap(find.text('Compact list'));
    await tester.pump();
    expect(find.text('2 3 5'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('missing-comics-sort')));
    await tester.pump();
    expect(find.text('5 3 2'), findsOneWidget);

    await tester.enterText(
        find.byKey(const ValueKey('missing-comics-filter')), 'other');
    await tester.pump();
    expect(find.text('Fixture'), findsNothing);
    await tester.enterText(
        find.byKey(const ValueKey('missing-comics-filter')), 'fix');
    await tester.pump();
    expect(find.text('Fixture'), findsOneWidget);

    await tester.tap(find.text('Hide'));
    await tester.pump();
    expect(find.text('Fixture'), findsNothing);
  });
}
