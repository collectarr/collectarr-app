import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_creator.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/data.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/entry_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/group_mode_categories.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:flutter_test/flutter_test.dart';

const _registration = ComicRegistration();

LibraryProjectionItem _comic(String id, ComicCatalogItem comic) =>
    LibraryProjectionItem.fromShelf(
      LibraryWorkspaceContext(
        item: WorkspaceItem(
          target: CatalogTargetRef(
              CatalogItemRef(kind: CatalogMediaKind.comic, id: id)),
          kindPresentationData: ComicWorkspaceData(comic: comic),
        ),
        personal: const PersonalOverlay(),
      ),
      _registration,
    );

void main() {
  test('the folder menu lists the reference categories in order', () {
    final modes = [
      for (final group in comicLibraryEntryWorkspaceSchema.groups)
        group.id.value,
    ];
    final categories = buildComicGroupModeCategories(modes);
    expect(categories.map((category) => category.label), [
      'Images',
      'Main',
      'Value',
      'Edition',
      'Creators & Characters',
      'Personal',
    ]);
    expect(categories[1].modes, [
      'comic.age',
      'comic.country',
      'comic.crossover',
      'comic.genre',
      'comic.imprint',
      'comic.language',
      'comic.publisher',
      'comic.release_date',
      'comic.release_month',
      'comic.release_year',
      'comic.series',
      'comic.series_group',
      'comic.story_arc',
    ]);
    expect(categories.expand((category) => category.modes),
        hasLength(modes.length));
  });

  test('genre and writer folders hold a comic under each value', () {
    final items = [
      _comic(
          '1',
          const ComicCatalogItem(
            title: '',
            seriesTitle: 'Example',
            genres: ['Action', 'Fantasy'],
            creators: [
              ComicCreator(name: 'Writer One', role: 'Writer'),
              ComicCreator(name: 'Artist One', role: 'Artist'),
            ],
          )),
    ];
    List<String> titles(String id) => const LibraryGroupingEngine()
        .buildBuckets(
            items, _registration, LibraryGroupId<ComicKind, Object?>(id))
        .map((bucket) => bucket.title)
        .where((title) => !title.startsWith('['))
        .toList();
    expect(titles('comic.genre'), containsAll(['Action', 'Fantasy']));
    expect(titles('comic.creator_writer'), ['Writer One']);
  });
}
