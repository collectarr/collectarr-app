import 'package:collectarr_app/features/library/kinds/music/edit/music_online_cover_search.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_online_cover_picker_dialog.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decodes distinct album artwork at the larger image size', () {
    final candidates = decodeMusicOnlineCoverCandidates({
      'results': [
        {
          'collectionName': 'Lupus Dei',
          'artistName': 'Powerwolf',
          'artworkUrl100': 'https://example.com/100x100bb.jpg',
        },
        {
          'collectionName': 'Duplicate artwork row',
          'artistName': 'Powerwolf',
          'artworkUrl100': 'https://example.com/100x100bb.jpg',
        },
        {
          'collectionName': 'Invalid artwork',
          'artistName': 'Powerwolf',
          'artworkUrl100': 'file:///local/100x100bb.jpg',
        },
        {'collectionName': 'Missing artist'},
      ],
    });

    expect(candidates, hasLength(1));
    expect(candidates.single.title, 'Lupus Dei');
    expect(candidates.single.artist, 'Powerwolf');
    expect(candidates.single.imageUrl, 'https://example.com/600x600bb.jpg');
  });

  test('returns no candidates when the provider has no result list', () {
    expect(decodeMusicOnlineCoverCandidates(const {}), isEmpty);
  });

  test('decodes JSON returned with the real text/javascript content type',
      () async {
    final client = Dio();
    client.httpClientAdapter = _CoverAdapter((request) => jsonEncode({
          'results': [
            {
              'collectionName': 'Lupus Dei',
              'artistName': 'Powerwolf',
              'artworkUrl100': 'https://example.com/100x100bb.jpg'
            }
          ]
        }));
    final covers = await MusicOnlineCoverSearch(client: client)
        .search('Powerwolf Lupus Dei');
    expect(covers.single.title, 'Lupus Dei');
    client.close();
  });

  test(
      'barcode lookup returns edition front/back images and supplements artwork',
      () async {
    final requests = <RequestOptions>[];
    final client = Dio();
    client.httpClientAdapter = _CoverAdapter((request) {
      requests.add(request);
      if (request.uri.host == 'musicbrainz.org') {
        return jsonEncode({
          'releases': [
            {'id': '11111111-1111-1111-1111-111111111111', 'title': 'Lupus Dei'}
          ]
        });
      }
      if (request.uri.host == 'coverartarchive.org') {
        return jsonEncode({
          'images': [
            {'image': 'http://example.com/front.jpg', 'front': true},
            {'image': 'https://example.com/back.jpg', 'back': true}
          ]
        });
      }
      return jsonEncode({'results': <Object>[]});
    });
    final covers = await MusicOnlineCoverSearch(client: client)
        .search('Powerwolf Lupus Dei 039841461923', barcode: '039841461923');
    expect(covers.map((c) => c.artist), ['Front cover', 'Back cover']);
    expect(covers.map((c) => c.imageUrl),
        ['https://example.com/front.jpg', 'https://example.com/back.jpg']);
    expect(requests.last.uri.queryParameters['term'], 'Powerwolf Lupus Dei');
    client.close();
  });

  testWidgets(
      'query tokens update artist/title/barcode without losing manual search',
      (tester) async {
    final client = Dio();
    client.httpClientAdapter = _CoverAdapter(
        (_) => jsonEncode({'releases': <Object>[], 'results': <Object>[]}));
    await tester.pumpWidget(MaterialApp(
        home: MusicOnlineCoverPickerDialog(
            artist: 'Powerwolf',
            title: 'Lupus Dei',
            barcode: '039841461923',
            search: MusicOnlineCoverSearch(client: client))));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Powerwolf Lupus Dei 039841461923');
    await tester.tap(find.byType(Checkbox).last);
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Powerwolf Lupus Dei');
    expect(tester.takeException(), isNull);
    client.close();
  });

  testWidgets('cover picker fits a narrow window and prompts for a query',
      (tester) async {
    tester.view.physicalSize = const Size(420, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: MusicOnlineCoverPickerDialog(),
      ),
    );

    expect(find.text('Find Cover'), findsOneWidget);
    expect(
        find.text('Search by album title, artist or barcode.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _CoverAdapter implements HttpClientAdapter {
  _CoverAdapter(this.body);
  final String Function(RequestOptions) body;
  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<List<int>>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromString(body(options), 200, headers: {
        Headers.contentTypeHeader: ['text/javascript; charset=utf-8']
      });
  @override
  void close({bool force = false}) {}
}
