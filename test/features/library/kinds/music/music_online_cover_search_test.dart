import 'package:collectarr_app/features/library/kinds/music/edit/music_online_cover_search.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_online_cover_picker_dialog.dart';
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

  testWidgets('cover picker fits a narrow window and prompts for a query',
      (tester) async {
    tester.view.physicalSize = const Size(420, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: MusicOnlineCoverPickerDialog(initialQuery: ''),
      ),
    );

    expect(find.text('Find Online Cover'), findsOneWidget);
    expect(find.text('Search by album title or artist.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
