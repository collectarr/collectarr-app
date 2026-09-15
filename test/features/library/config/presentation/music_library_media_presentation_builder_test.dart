import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation_builder.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('music search result display formats album metadata', () {
    const builder = MusicLibraryMediaPresentationBuilder();
    final display = builder.buildSearchResultDisplay(
      item: testCatalogItemFromJson({
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
      }).asSearchCandidate,
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
      item: testCatalogItemFromJson({
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
      }).asSearchCandidate,
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
      item: testCatalogItemFromJson({
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
      }).asSearchCandidate,
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

  testWidgets('music provider preview groups tracks by disc', (tester) async {
    const builder = MusicLibraryMediaPresentationBuilder();
    const candidate = ProviderCandidate(
      provider: 'musicbrainz',
      providerItemId: 'release-1',
      title: 'Multidisc album',
      kind: CatalogMediaKind.music,
      candidateType: musicReleaseCandidateType,
    );
    const preview = AdminProviderPreview(
      provider: 'musicbrainz',
      providerItemId: 'release-1',
      kind: 'music',
      title: 'Multidisc album',
      music: {
        'track_count': 4,
        'tracks': [
          {'position': 1, 'title': 'Side A one', 'disc_number': 1},
          {'position': 2, 'title': 'Side A two', 'disc_number': 1},
          {'position': 1, 'title': 'Side B one', 'disc_number': 2},
          {'position': 2, 'title': 'Side B two', 'disc_number': 2},
        ],
      },
    );
    final widget = builder.buildAddPreviewPane(
      context: _TestBuildContext(),
      accent: const Color(0xFF0E81A6),
      singularLabel: 'Music',
      previewLabels: const LibraryMediaPreviewLabels(),
      item: null,
      candidate: candidate,
      preview: preview,
      isFetchingPreview: false,
      providerLabel: 'MusicBrainz',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 800, height: 700, child: widget),
        ),
      ),
    );

    expect(find.text('Disc 1'), findsOneWidget);
    expect(find.text('Disc 2'), findsOneWidget);
    expect(find.text('Side A one'), findsOneWidget);
    expect(find.text('Side B two'), findsOneWidget);
  });
}

class _TestBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
