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

    final comicModule = libraryKindModuleForKind(CatalogMediaKind.comic);
    expect(comicModule.metadata.supportsServerCompare, isTrue);
    expect(comicModule.metadata.compareBuilder, isNotNull);
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
      'series': {'series_title': 'The Beatles'},
      'music': {
        'catalog_number': 'PCS 7088',
        'discs': [
          {'disc_number': 1, 'disc_name': 'Side A'},
        ],
      },
      'creators': [
        {'role': 'Artist', 'name': 'The Beatles'},
      ],
    };
    final serverPayload = {
      'title': 'Abbey Road',
      'series': {'series_title': 'The Beatles'},
      'music': {
        'catalog_number': 'PCS 7088',
        'discs': [
          {'disc_number': 1, 'disc_name': 'Side A'},
          {'disc_number': 2, 'disc_name': 'Side B'},
        ],
      },
      'creators': [
        {'role': 'Artist', 'name': 'The Beatles'},
      ],
    };

    final panels = buildMusicMetadataComparePanels(
      ctx,
      localPayload: localPayload,
      serverPayload: serverPayload,
      accent: Colors.amber,
    );

    expect(panels.length, 3);
    expect(panels.every((p) => p is MetadataDiffPanel), isTrue);

    final musicModule = libraryKindModuleForKind(CatalogMediaKind.music);
    expect(musicModule.metadata.supportsServerCompare, isTrue);
    expect(musicModule.metadata.compareBuilder, isNotNull);
  });
}