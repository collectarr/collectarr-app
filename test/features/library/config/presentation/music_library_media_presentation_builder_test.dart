import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/music_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('music add preview renders album-style inspector layout', (
    tester,
  ) async {
    const builder = MusicLibraryMediaPresentationBuilder();
    final widget = builder.buildAddPreviewPane(
      context: _TestBuildContext(),
      accent: const Color(0xFF0E81A6),
      singularLabel: 'Music',
      labels: const LibraryMediaFieldLabels(
        number: 'Disc / Volume',
        publisher: 'Label / Artist',
        variant: 'Format / Edition',
        barcode: 'Barcode / Catalog no.',
      ),
      previewLabels: const LibraryMediaPreviewLabels(
        series: 'Artist',
        itemCount: 'Releases',
      ),
      item: LibraryMetadataItem(
        id: 'music-1',
        kind: 'music',
        title: 'Kinesis',
        variant: 'CD',
        publisher: 'Inside Out',
        releaseYear: 1998,
        series: const CatalogSeriesDetails(seriesTitle: 'Ad Infinitum'),
        genres: const [
          'Rock',
          'Progressive Rock',
          'Art Rock',
          'Progressive',
        ],
        music: const MusicCatalogDetails(
          trackCount: 3,
          catalogNumber: 'KDCD 1022',
          releaseStatus: 'Album',
          tracks: [
            CatalogTrack(title: 'Ad Infinitum', position: 1, durationSeconds: 506),
            CatalogTrack(title: 'Immortality', position: 2, durationSeconds: 421),
            CatalogTrack(title: 'Waterline', position: 3, durationSeconds: 659),
          ],
        ),
      ),
      candidate: null,
      preview: null,
      isFetchingPreview: false,
      providerLabel: 'MusicBrainz',
    );

    expect(widget, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: widget!),
      ),
    );

    expect(find.text('Ad Infinitum'), findsWidgets);
    expect(find.text('Kinesis'), findsWidgets);
    expect(find.text('Kinesis (1998)'), findsOneWidget);
    expect(find.text('CD  KDCD 1022'), findsOneWidget);
    expect(find.text('Rock, Progressive Rock, Art Rock, Progressive'), findsOneWidget);
    expect(find.text('Inside Out / Album'), findsOneWidget);
    expect(find.text('3 tracks (26:26)'), findsOneWidget);
    expect(find.text('Ad Infinitum'), findsWidgets);
    expect(find.text('Immortality'), findsOneWidget);
    expect(find.text('Waterline'), findsOneWidget);
  });

  testWidgets('music add preview avoids overflow in narrow panes', (
    tester,
  ) async {
    const builder = MusicLibraryMediaPresentationBuilder();
    final widget = builder.buildAddPreviewPane(
      context: _TestBuildContext(),
      accent: const Color(0xFF0E81A6),
      singularLabel: 'Music',
      labels: const LibraryMediaFieldLabels(
        number: 'Disc / Volume',
        publisher: 'Label / Artist',
        variant: 'Format / Edition',
        barcode: 'Barcode / Catalog no.',
      ),
      previewLabels: const LibraryMediaPreviewLabels(
        series: 'Artist',
        itemCount: 'Releases',
      ),
      item: LibraryMetadataItem(
        id: 'music-1',
        kind: 'music',
        title: 'Kinesis',
        variant: 'CD',
        publisher: 'Inside Out',
        releaseYear: 1998,
        series: const CatalogSeriesDetails(seriesTitle: 'Ad Infinitum'),
        genres: const [
          'Rock',
          'Progressive Rock',
          'Art Rock',
          'Progressive',
        ],
        music: const MusicCatalogDetails(
          trackCount: 3,
          catalogNumber: 'KDCD 1022',
          releaseStatus: 'Album',
          tracks: [
            CatalogTrack(title: 'Ad Infinitum', position: 1, durationSeconds: 506),
            CatalogTrack(title: 'Immortality', position: 2, durationSeconds: 421),
            CatalogTrack(title: 'Waterline', position: 3, durationSeconds: 659),
          ],
        ),
      ),
      candidate: null,
      preview: null,
      isFetchingPreview: false,
      providerLabel: 'MusicBrainz',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 536,
              height: 179,
              child: widget!,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Kinesis (1998)'), findsOneWidget);
    expect(find.text('Waterline'), findsOneWidget);
  });
}

class _TestBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}