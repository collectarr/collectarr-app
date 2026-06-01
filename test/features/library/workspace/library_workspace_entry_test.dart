import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
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
      pricePaidCents: pricePaidCents,
      releaseDate: releaseDate,
      updatedAt: updatedAt ?? DateTime.utc(2026),
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

  test('sorts issue-like item numbers numerically', () {
    final items = [
      entry(id: '2', title: 'Series', itemNumber: '10'),
      entry(id: '1', title: 'Series', itemNumber: '2'),
      entry(id: '3', title: 'Series', itemNumber: 'A'),
    ]..sort(
        (left, right) => compareLibraryWorkspaceEntries(
          left,
          right,
          LibrarySortColumn.issue,
          true,
        ),
      );

    expect(items.map((item) => item.itemNumber), ['2', '10', 'A']);
  });

  test('sorts owned entries before missing entries by status', () {
    final items = [
      entry(id: '1', title: 'Missing'),
      entry(id: '2', title: 'Owned', isOwned: true),
    ]..sort(
        (left, right) => compareLibraryWorkspaceEntries(
          left,
          right,
          LibrarySortColumn.status,
          true,
        ),
      );

    expect(items.map((item) => item.title), ['Owned', 'Missing']);
  });

  test('sorts numeric value fields with empty values last', () {
    final items = [
      entry(id: '1', title: 'No price'),
      entry(id: '2', title: 'Low price', pricePaidCents: 100),
      entry(id: '3', title: 'High price', pricePaidCents: 500),
    ]..sort(
        (left, right) => compareLibraryWorkspaceEntries(
          left,
          right,
          LibrarySortColumn.price,
          true,
        ),
      );

    expect(
      items.map((item) => item.title),
      ['Low price', 'High price', 'No price'],
    );
  });

  test('sorts by series title when series sort is selected', () {
    final items = [
      entry(id: '2', title: 'Issue B', seriesTitle: 'Zoo Crew'),
      entry(id: '1', title: 'Issue A', seriesTitle: 'Alpha Flight'),
      entry(id: '3', title: 'Issue C'),
    ]..sort(
        (left, right) => compareLibraryWorkspaceEntries(
          left,
          right,
          LibrarySortColumn.series,
          true,
        ),
      );

    expect(items.map((item) => item.title), ['Issue A', 'Issue B', 'Issue C']);
  });

  test('sorts key comics before non-key comics', () {
    final items = [
      entry(id: '1', title: 'Regular issue'),
      entry(id: '2', title: 'Key issue', keyComic: true),
    ]..sort(
        (left, right) => compareLibraryWorkspaceEntries(
          left,
          right,
          LibrarySortColumn.keyComic,
          true,
        ),
      );

    expect(items.map((item) => item.title), ['Key issue', 'Regular issue']);
  });
}
