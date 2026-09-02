import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation_builder.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('music search result display formats album metadata', () {
    const builder = MusicLibraryMediaPresentationBuilder();
    final display = builder.buildSearchResultDisplay(
      item: LibraryMetadataItem.fromMetadataMap({
        'id': 'music-search-1',
        'kind': 'music',
        'title': 'Kinesis - Deluxe Edition',
        'physical_format_label': 'CD',
        'barcode': '1234567890',
        'series': {
          'series_title': 'Ad Infinitum',
          'volume_name': 'Deluxe Edition',
        },
        'music': {
          'track_count': 3,
          'catalog_number': 'KDCD 1022',
        },
      }),
    );

    expect(display, isNotNull);
    expect(display!.title, 'Kinesis');
    expect(display.secondaryLine, 'Ad Infinitum');
    expect(display.detailLine,
        'Deluxe Edition - CD - 3 tracks - 1234567890 - KDCD 1022');
  });

  testWidgets('music add preview renders album-style inspector layout', (
    tester,
  ) async {
    const builder = MusicLibraryMediaPresentationBuilder();
    final widget = builder.buildAddPreviewPane(
      context: _TestBuildContext(),
      accent: const Color(0xFF0E81A6),
      singularLabel: 'Music',
      previewLabels: const LibraryMediaPreviewLabels(
        values: {'series': 'Artist', 'item_count': 'Releases'},
      ),
      item: LibraryMetadataItem.fromMetadataMap({
        'id': 'music-1',
        'kind': 'music',
        'title': 'Kinesis',
        'variant': 'CD',
        'publisher': 'Inside Out',
        'release_year': 1998,
        'series': {
          'series_title': 'Ad Infinitum',
        },
        'genres': [
          'Rock',
          'Progressive Rock',
          'Art Rock',
          'Progressive',
        ],
        'music': {
          'track_count': 3,
          'catalog_number': 'KDCD 1022',
          'release_status': 'Album',
          'tracks': [
            {
              'title': 'Ad Infinitum',
              'position': '1',
              'duration_seconds': 506,
            },
            {
              'title': 'Immortality',
              'position': '2',
              'duration_seconds': 421,
            },
            {
              'title': 'Waterline',
              'position': '3',
              'duration_seconds': 659,
            },
          ],
        },
      }),
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
    expect(find.text('Rock, Progressive Rock, Art Rock, Progressive'),
        findsOneWidget);
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
      previewLabels: const LibraryMediaPreviewLabels(
        values: {'series': 'Artist', 'item_count': 'Releases'},
      ),
      item: LibraryMetadataItem.fromMetadataMap({
        'id': 'music-1',
        'kind': 'music',
        'title': 'Kinesis',
        'variant': 'CD',
        'publisher': 'Inside Out',
        'release_year': 1998,
        'series': {
          'series_title': 'Ad Infinitum',
        },
        'genres': [
          'Rock',
          'Progressive Rock',
          'Art Rock',
          'Progressive',
        ],
        'music': {
          'track_count': 3,
          'catalog_number': 'KDCD 1022',
          'release_status': 'Album',
          'tracks': [
            {
              'title': 'Ad Infinitum',
              'position': '1',
              'duration_seconds': 506,
            },
            {
              'title': 'Immortality',
              'position': '2',
              'duration_seconds': 421,
            },
            {
              'title': 'Waterline',
              'position': '3',
              'duration_seconds': 659,
            },
          ],
        },
      }),
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
