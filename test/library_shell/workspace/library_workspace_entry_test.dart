import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LibraryWorkspaceEntry entry({
    required String id,
    required String title,
    String? itemNumber,
    String? seriesTitle,
    List<String>? storyArcs,
    bool isOwned = false,
    bool isWishlisted = false,
    bool keyComic = false,
    String? grade,
    String? rawOrSlabbed,
    String? gradingCompany,
    String? collectionStatus,
    String? variant,
    String? referenceScopeLabel,
    String? referenceFormatLabel,
    DateTime? addedAt,
    int? pricePaidCents,
    DateTime? releaseDate,
    DateTime? updatedAt,
  }) {
    return LibraryWorkspaceEntry(
      id: id,
      mediaType: 'comic',
      title: title,
      itemNumber: itemNumber,
      series: seriesTitle == null
          ? null
          : CatalogSeriesDetails(seriesTitle: seriesTitle),
      storyArcs: storyArcs,
      isOwned: isOwned,
      isWishlisted: isWishlisted,
      keyComic: keyComic,
      grade: grade,
      rawOrSlabbed: rawOrSlabbed,
      gradingCompany: gradingCompany,
      collectionStatus: collectionStatus,
      variant: variant,
      referenceScopeLabel: referenceScopeLabel,
      referenceFormatLabel: referenceFormatLabel,
      addedAt: addedAt,
      pricePaidCents: pricePaidCents,
      releaseDate: releaseDate,
      updatedAt: updatedAt ?? DateTime.utc(2026),
    );
  }

  List<LibraryWorkspaceEntry> sortByRules(
    List<LibraryWorkspaceEntry> items,
    List<LibrarySortRule> rules,
  ) {
    return List<LibraryWorkspaceEntry>.of(items)
      ..sort(
        (left, right) => comicsMediaAdapter.compareEntriesByRules(
          left,
          right,
          rules,
        ),
      );
  }

  test('uses thumbnail before full cover for display cover', () {
    final item = LibraryWorkspaceEntry(
      id: '1',
      mediaType: 'comic',
      title: 'Superman',
      coverImageUrl: 'https://example.test/cover.jpg',
      thumbnailImageUrl: 'https://example.test/thumb.jpg',
      updatedAt: DateTime.utc(2026),
    );

    expect(item.displayCoverUrl, 'https://example.test/thumb.jpg');
  });

  test('book media falls back to primary release cover and reference ids', () {
    final item = BookWork(
      id: 'book-1',
      title: 'Example Book',
      editions: [
        BookEdition(
          id: 'edition-1',
          title: 'Hardcover',
          variants: [
            BookVariant(
              id: 'variant-1',
              name: 'Hardcover',
              coverImageUrl: 'https://example.test/release-cover.jpg',
              thumbnailImageUrl: 'https://example.test/release-thumb.jpg',
              isPrimary: true,
            ),
          ],
        ),
      ],
    );

    final entry = buildBookWorkspaceEntry(item, const BookPersonalOverlay())
        as BookWorkspaceEntry;

    expect(entry.displayCoverUrl, 'https://example.test/release-thumb.jpg');
    expect(entry.referenceEditionId, 'edition-1');
    expect(entry.referenceVariantId, 'variant-1');
    expect(entry.bookEditions, hasLength(1));
  });

  test('builds media-specific workspace entry subtypes', () {
    final item = LibraryWorkspaceEntry(
      id: 'music-1',
      mediaType: 'music',
      title: 'Discovery',
      music: const MusicCatalogDetails(
        trackCount: 14,
        catalogNumber: 'DISC-2001',
        releaseStatus: 'Official',
      ),
      updatedAt: DateTime.utc(2026),
    );

    expect(item, isA<MusicWorkspaceEntry>());
    expect(item.music, isNotNull);
    expect(item.music!.trackCount, 14);
    expect(item.music!.catalogNumber, 'DISC-2001');
  });

  test('adapter sorts issue-like item numbers numerically', () {
    final items = sortByRules([
      entry(id: '2', title: 'Series', itemNumber: '10'),
      entry(id: '1', title: 'Series', itemNumber: '2'),
      entry(id: '3', title: 'Series', itemNumber: 'A'),
    ], const [
      LibrarySortRule(column: LibrarySortColumn.issue, ascending: true)
    ]);

    expect(items.map((item) => item.itemNumber), ['2', '10', 'A']);
  });

  test('adapter sorts owned entries before missing entries by status', () {
    final items = sortByRules([
      entry(id: '1', title: 'Missing'),
      entry(id: '2', title: 'Owned', isOwned: true),
    ], const [
      LibrarySortRule(column: LibrarySortColumn.status, ascending: true)
    ]);

    expect(items.map((item) => item.title), ['Owned', 'Missing']);
  });

  test('adapter sorts numeric value fields with empty values last', () {
    final items = sortByRules([
      entry(id: '1', title: 'No price'),
      entry(id: '2', title: 'Low price', pricePaidCents: 100),
      entry(id: '3', title: 'High price', pricePaidCents: 500),
    ], const [
      LibrarySortRule(column: LibrarySortColumn.price, ascending: true)
    ]);

    expect(
      items.map((item) => item.title),
      ['Low price', 'High price', 'No price'],
    );
  });

  test('adapter sorts by series title when series sort is selected', () {
    final items = sortByRules([
      entry(id: '2', title: 'Issue B', seriesTitle: 'Zoo Crew'),
      entry(id: '1', title: 'Issue A', seriesTitle: 'Alpha Flight'),
      entry(id: '3', title: 'Issue C'),
    ], const [
      LibrarySortRule(column: LibrarySortColumn.series, ascending: true)
    ]);

    expect(items.map((item) => item.title), ['Issue A', 'Issue B', 'Issue C']);
  });

  test('adapter sorts key comics before non-key comics', () {
    final items = sortByRules([
      entry(id: '1', title: 'Regular issue'),
      entry(id: '2', title: 'Key issue', keyComic: true),
    ], const [
      LibrarySortRule(column: LibrarySortColumn.keyComic, ascending: true)
    ]);

    expect(items.map((item) => item.title), ['Key issue', 'Regular issue']);
  });

  test('adapter applies secondary sort rules before title fallback', () {
    final items = sortByRules([
      entry(
          id: '2', title: 'Owned later issue', isOwned: true, itemNumber: '10'),
      entry(id: '3', title: 'Missing issue', itemNumber: '1'),
      entry(
          id: '1',
          title: 'Owned earlier issue',
          isOwned: true,
          itemNumber: '2'),
    ], const [
      LibrarySortRule(column: LibrarySortColumn.status, ascending: true),
      LibrarySortRule(column: LibrarySortColumn.issue, ascending: true),
    ]);

    expect(
      items.map((item) => item.title),
      ['Owned earlier issue', 'Owned later issue', 'Missing issue'],
    );
  });

  testWidgets('adapter builds variant cell summary text', (tester) async {
    final item = entry(
      id: '1',
      title: 'Issue A',
      variant: 'Foil',
      referenceScopeLabel: 'Edition',
      referenceFormatLabel: 'Hardcover',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: comicsMediaAdapter.buildTableCell(
            item,
            LibraryTableColumn.variant,
          ),
        ),
      ),
    );

    expect(
      find.text('Foil  ·  Scope: Edition  ·  Format: Hardcover'),
      findsOneWidget,
    );
  });

  testWidgets('adapter builds dedicated format and added cells', (
    tester,
  ) async {
    final item = entry(
      id: '1',
      title: 'Issue A',
      referenceFormatLabel: 'Hardcover',
      addedAt: DateTime.utc(2026, 5, 31),
      updatedAt: DateTime.utc(2026, 6, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Column(
            children: [
              comicsMediaAdapter.buildTableCell(
                  item, LibraryTableColumn.format),
              comicsMediaAdapter.buildTableCell(item, LibraryTableColumn.added),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Hardcover'), findsOneWidget);
    expect(find.text('2026-05-31'), findsOneWidget);
  });
}
