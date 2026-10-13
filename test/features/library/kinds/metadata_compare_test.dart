import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/comic/metadata/comic_metadata_compare.dart';
import 'package:collectarr_app/features/library/kinds/music/metadata/music_metadata_compare.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/metadata/metadata_diff_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('comic compare builder builds diff panels', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      ),
    );

    final localPayload = {
      'title': 'Spider-Man #1',
      'publisher': 'Marvel',
      'series': {'series_title': 'Spider-Man'},
      'item_number': '1',
      'creators': [
        {'role': 'Writer', 'name': 'Stan Lee'},
      ],
      'character_details': [
        {'name': 'Peter Parker', 'real_name': 'Spider-Man'},
      ],
    };
    final serverPayload = {
      'title': 'Spider-Man #1',
      'publisher': 'Marvel Comics',
      'series': {'series_title': 'Spider-Man'},
      'item_number': '1',
      'creators': [
        {'role': 'Writer', 'name': 'Stan Lee'},
        {'role': 'Artist', 'name': 'Steve Ditko'},
      ],
      'character_details': [
        {'name': 'Peter Parker', 'real_name': 'Spider-Man'},
      ],
    };

    final panels = buildComicMetadataComparePanels(
      ctx,
      localPayload: localPayload,
      serverPayload: serverPayload,
      accent: Colors.blue,
    );

    expect(panels.length, 3);
    expect(panels.every((p) => p is MetadataDiffPanel), isTrue);

    expect(libraryMetadataForKind(CatalogMediaKind.comic).supportsServerCompare,
        isTrue);
    expect(libraryMetadataForKind(CatalogMediaKind.comic).compareBuilder,
        isNotNull);
  });

  testWidgets('music compare builder builds diff panels with discs',
      (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      ),
    );

    final localPayload = {
      'title': 'Abbey Road',
      'music': {
        'title': 'Abbey Road',
        'label': 'Apple Records',
        'catalog_number': 'PCS 7088',
        'credits': [
          {
            'id': 'album-credit-1',
            'name': 'George Martin',
            'role': 'Producer',
            'instruments': <String>[],
            'sequence': 1,
          },
        ],
        'discs': [
          {
            'id': 'disc-a',
            'disc_number': 1,
            'format_family': 'vinyl',
            'format': 'LP',
            'recording_date': {'year': 1969},
            'recording_locations': ['Abbey Road'],
            'is_live': false,
            'sound_types': <String>[],
            'credits': <Map<String, Object>>[],
            'tracks': <Map<String, Object>>[],
          },
        ],
      },
    };
    final serverPayload = {
      'title': 'Abbey Road',
      'music': {
        'title': 'Abbey Road',
        'label': 'Apple Records',
        'catalog_number': 'PCS 7088',
        'credits': [
          {
            'id': 'album-credit-1',
            'name': 'George Martin',
            'role': 'Producer',
            'instruments': <String>[],
            'sequence': 1,
          },
        ],
        'discs': [
          {
            'id': 'disc-a',
            'disc_number': 1,
            'format_family': 'vinyl',
            'format': 'LP',
            'recording_date': {'year': 1969},
            'recording_locations': ['Abbey Road'],
            'is_live': false,
            'sound_types': <String>[],
            'credits': <Map<String, Object>>[],
            'tracks': <Map<String, Object>>[],
          },
          {
            'id': 'disc-b',
            'disc_number': 2,
            'format_family': 'opticalDisc',
            'format': 'CD',
            'recording_date': {'year': 2026, 'month': 2, 'day': 18},
            'recording_locations': ['Wembley'],
            'is_live': true,
            'spars_code': 'ADD',
            'sound_types': <String>[],
            'credits': <Map<String, Object>>[],
            'tracks': <Map<String, Object>>[],
          },
        ],
      },
    };

    final panels = buildMusicMetadataComparePanels(
      ctx,
      localPayload: localPayload,
      serverPayload: serverPayload,
      accent: Colors.amber,
    );

    expect(panels.length, 3);
    expect(panels.every((p) => p is MetadataDiffPanel), isTrue);
    final creditPanel = panels[1] as MetadataDiffPanel;
    expect(creditPanel.title, 'Album credits (Local vs Server)');
    expect(creditPanel.entries.single.label, 'Credit album-credit-1');
    final discPanel = panels[2] as MetadataDiffPanel;
    expect(discPanel.entries.map((entry) => entry.label), [
      'Disc 1 (disc-a)',
      'Disc 2 (disc-b)',
    ]);
    expect(discPanel.entries.last.serverValue,
        contains('Recording date: 2026-02-18'));
    expect(discPanel.entries.last.serverValue,
        contains('Recording locations: Wembley'));

    expect(libraryMetadataForKind(CatalogMediaKind.music).supportsServerCompare,
        isTrue);
    expect(libraryMetadataForKind(CatalogMediaKind.music).compareBuilder,
        isNotNull);
  });
}
