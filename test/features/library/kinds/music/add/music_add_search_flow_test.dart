import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_session_controller.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_contribution.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('typing preserves results and selection until explicit Search',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
        overrides: [localDatabaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    final controller = LibraryAddSessionController(
      kind: CatalogMediaKind.music,
      entryMutations: container.read(libraryEntryMutationsProvider),
      wishlistMutations: container.read(wishlistMutationsProvider),
      trackingMutations: container.read(trackingMutationsProvider),
    );
    addTearDown(controller.dispose);
    final item = CatalogSearchCandidate.fromItem(
        MusicCatalogMapper.toCatalogItemDto(MusicAlbum(
            id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'album'),
            title: 'Album')));
    controller.selectSuggestion(item);
    controller.updateQuery('Another album');
    await tester.pump(const Duration(seconds: 1));
    expect(controller.state.search.results.single, item);
    expect(controller.state.selection.selectedResultId, 'album');
    expect(controller.state.search.isSearching, isFalse);
    await controller.executeSearch();
    expect(controller.state.selection.selectedResultId, isNull);
    expect(controller.state.search.showSuggestions, isFalse);
    expect(controller.state.search.results.single, item);
  });

  test('the Catalog No. tab searches Core by catalog number', () {
    final tab = musicKindAdd.search.input.codeSearchTab;
    expect(tab?.label, 'Catalog No.');
    final query = buildMusicCoreSearchInput(
        LibraryAddSearchContext(codeQuery: ' CDP 7 46 '),
        limit: 25);
    expect(query.catalogNumber, 'CDP 7 46');
    expect(query.query, isNull);
  });
}
