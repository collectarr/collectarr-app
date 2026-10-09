import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/kinds/music/music_physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_schema.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('music edit header uses album and artist without an Edit prefix', () {
    final title = musicAlbumEditSchema.title!(
      MusicAlbum(
        title: 'Test Album',
        artist: 'Test Artist',
      ),
    );

    expect(title, 'Test Album / Test Artist');
    expect(title, isNot(startsWith('Edit')));
  });

  testWidgets('music links tab exposes editable external links',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final type = const MusicRegistration();
    final item = testCatalogItemWithKindMetadata(
      testCatalogItem(
        id: 'music-1',
        kind: 'music',
        title: 'Test Album',
      ),
    );
    final request = LibraryEditDialogRequest(
      type: type,
      item: CatalogSearchCandidate.fromItem(item),
      libraryEntry: null,
      accent: Colors.deepPurple,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  await showDialog<void>(
                    context: context,
                    builder: (context) =>
                        buildMusicAlbumLibraryEditDialog(context, request),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final coversTab = find.text('Covers').last;
    await tester.ensureVisible(coversTab);
    await tester.tap(coversTab);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('musicAlbumCoverImageUrlField')),
      findsNothing,
    );

    final linksTab = find.text('Links').last;
    await tester.ensureVisible(linksTab);
    await tester.tap(linksTab);
    await tester.pumpAndSettle();
    expect(find.text('Add Link'), findsOneWidget);
    await tester.tap(find.text('Add Link'));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is LibraryTextFormControl &&
            widget.decoration?.hintText == 'https://example.com',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
      'music edit dialog handles Vinyl format and custom fields cleanly',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final type = const MusicRegistration();
    final item = CatalogItemDto.raw(
      id: 'music-vinyl',
      mediaKind: CatalogMediaKind.music,
      kindData: const {
        'title': 'Dark Side of the Moon',
        'revision': 1,
        'artist_credits': <Map<String, Object?>>[],
        'genres': <String>[],
        'extra': <String>[],
        'credits': <Map<String, Object?>>[],
        'external_links': <Map<String, Object?>>[],
        'discs': [
          {
            'id': 'd-1',
            'disc_number': 1,
            'format': 'Vinyl (12" LP)',
            'format_family': 'vinyl',
            'sound_types': <String>[],
            'recording_locations': <String>[],
            'credits': <Map<String, Object?>>[],
            'tracks': [],
          },
        ],
      },
    );
    final request = LibraryEditDialogRequest(
      type: type,
      item: CatalogSearchCandidate.fromItem(item),
      libraryEntry: null,
      accent: Colors.deepPurple,
      physicalFormats: musicPhysicalMediaFormats,
      customFieldDefinitions: [
        CustomFieldDefinition(
          id: 'custom-1',
          name: 'Pressing',
          fieldType: 'text',
          createdAt: DateTime(2026),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  await showDialog<void>(
                    context: context,
                    builder: (context) =>
                        buildMusicAlbumLibraryEditDialog(context, request),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Main').last);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Format'), findsOneWidget);
  });
}
