import 'package:collectarr_app/features/library/edit/fields/external_links_draft_editor.dart';
import 'package:collectarr_app/features/library/generic/link_preview.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('YouTube video ids come from watch, short and embed URLs only', () {
    expect(youTubeVideoId('https://www.youtube.com/watch?v=G203e1HhixY'),
        'G203e1HhixY');
    expect(youTubeVideoId('https://youtu.be/G203e1HhixY?t=4'), 'G203e1HhixY');
    expect(youTubeVideoId('https://m.youtube.com/embed/G203e1HhixY'),
        'G203e1HhixY');
    expect(youTubeVideoId('https://www.youtube.com/@PlayStation'), isNull);
    expect(youTubeVideoId('https://notyoutube.com/watch?v=x'), isNull);
    expect(youTubeThumbnailUrl('https://youtu.be/abc'),
        'https://img.youtube.com/vi/abc/hqdefault.jpg');
  });

  test('page titles are unescaped and kept on one line', () {
    expect(
        htmlDocumentTitle('<html><head><TITLE lang="en">\n  Bloodborne &amp; '
            'the &#8220;Hunt&#x201D; - Wikipedia\n</TITLE></head></html>'),
        'Bloodborne & the “Hunt” - Wikipedia');
    expect(htmlDocumentTitle('<title> </title>'), isNull);
    expect(htmlDocumentTitle('<p>no title</p>'), isNull);
  });

  test('YouTube titles come from oEmbed with the page suffix', () async {
    final adapter = _PageAdapter(
        {'www.youtube.com': '{"title":"Bloodborne Debut Trailer"}'});
    final client = Dio()..httpClientAdapter = adapter;
    addTearDown(client.close);

    expect(
        await fetchLinkTitle('https://www.youtube.com/watch?v=G203e1HhixY',
            client: client),
        'Bloodborne Debut Trailer - YouTube');
    expect(adapter.requests.single.path, '/oembed');
    expect(adapter.requests.single.queryParameters['url'],
        'https://www.youtube.com/watch?v=G203e1HhixY');
  });

  test('other pages give their title; failures and non-web URLs give none',
      () async {
    final client = Dio()
      ..httpClientAdapter = _PageAdapter(
          {'en.wikipedia.org': '<title>Bloodborne - Wikipedia</title>'});
    addTearDown(client.close);

    expect(
        await fetchLinkTitle('https://en.wikipedia.org/wiki/Bloodborne',
            client: client),
        'Bloodborne - Wikipedia');
    expect(await fetchLinkTitle('https://offline.example/', client: client),
        isNull);
    expect(await fetchLinkTitle('mailto:someone@example.com', client: client),
        isNull);
  });

  testWidgets('leaving a URL fills only an empty description', (tester) async {
    final looked = <String>[];
    var links = <LibraryExternalLinkValue>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LibraryExternalLinksEditSection(
          links: const [
            LibraryExternalLinkValue(url: ''),
            LibraryExternalLinkValue(url: '', description: 'Mine'),
          ],
          accent: Colors.blue,
          showTitleColumn: false,
          showThumbnails: true,
          titleLookup: (url) async {
            looked.add(url);
            return 'Bloodborne Debut Trailer - YouTube';
          },
          onChanged: (value) => links = value,
        ),
      ),
    ));
    final urls = find.byWidgetPredicate((widget) =>
        widget is TextField && widget.keyboardType == TextInputType.url);

    for (var row = 0; row < 2; row++) {
      await tester.enterText(
          urls.at(row), 'https://www.youtube.com/watch?v=G203e1HhixY');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    }

    expect(looked, ['https://www.youtube.com/watch?v=G203e1HhixY']);
    expect(links.map((link) => link.description),
        ['Bloodborne Debut Trailer - YouTube', 'Mine']);
    expect(find.byType(Image), findsNWidgets(2));
  });
}

/// Answers each host with its page, and fails for unknown hosts.
class _PageAdapter implements HttpClientAdapter {
  _PageAdapter(this.pages);

  final Map<String, String> pages;
  final requests = <Uri>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options.uri);
    final page = pages[options.uri.host];
    if (page == null) {
      throw DioException.connectionError(
          requestOptions: options, reason: 'Offline');
    }
    return ResponseBody.fromString(page, 200);
  }

  @override
  void close({bool force = false}) {}
}
