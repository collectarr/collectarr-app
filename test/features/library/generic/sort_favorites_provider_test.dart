import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/generic/sort_favorites_provider.dart';
import 'package:collectarr_app/features/library/generic/sort_preset_store.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('sorting favorite defaults initialize once and remain editable',
      () async {
    SharedPreferences.setMockInitialValues({});
    final type = libraryKindRegistrationForKind(CatalogMediaKind.game);
    final store = LibrarySortPresetStore(type);
    final initial = (await store.read()).single;
    expect(initial.id, 'platform_title');
    await store
        .savePreset(id: initial.id, label: 'My title order', rules: const [
      LibrarySortRule(column: 'game.title', ascending: false),
    ]);
    final edited = (await LibrarySortPresetStore(type).read()).single;
    expect(edited.label, 'My title order');
    expect(edited.rules.single.column, 'game.title');
    expect(edited.rules.single.ascending, isFalse);
    expect(
        (await store.deletePreset(initial.id!)).single.label, 'My title order');
    expect(
        (await store.savePreset(id: initial.id, label: 'Empty', rules: []))
            .single
            .label,
        'My title order');
  });

  test('removed sorting favorites do not return as built-in choices', () async {
    SharedPreferences.setMockInitialValues({});
    final type = libraryKindRegistrationForKind(CatalogMediaKind.game);
    final store = LibrarySortPresetStore(type);
    final initial = (await store.read()).single;
    await store.savePreset(id: 'mine', label: 'My title', rules: const [
      LibrarySortRule(column: 'game.title', ascending: true),
    ]);
    await store.deletePreset(initial.id!);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final favorites =
        await container.read(librarySavedSortFavoritesProvider(type).future);
    expect(favorites.map((favorite) => favorite.id), ['mine']);
    expect((await store.deletePreset('mine')).single.id, 'mine');
    await expectLater(store.saveFavorites([]), throwsArgumentError);
  });

  test('saved favorites override defaults and custom pins survive hydration',
      () async {
    SharedPreferences.setMockInitialValues({});
    final type = libraryKindRegistrationForKind(CatalogMediaKind.music);
    final initial = librarySortFavoritesForType(type).first;
    final store = LibrarySortPresetStore(type);
    final rules = [initial.rules.first.copyWith(ascending: false)];
    await store.savePreset(
        id: initial.id, label: 'Edited favorite', rules: rules);
    await store.savePreset(
        id: 'custom-sort', label: 'Custom favorite', rules: rules);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final saved =
        await container.read(librarySavedSortFavoritesProvider(type).future);
    final merged = saved;
    expect(merged.where((favorite) => favorite.id == initial.id), hasLength(1));
    expect(merged.first.label, 'Edited favorite');
    expect(merged.last.id, 'custom-sort');
    expect(
        sanitizeLibraryPinnedSortFavoriteIds(['custom-sort', 'missing'],
            favorites: saved),
        {'custom-sort'});
    expect(librarySortFavoritesForType(type).first.label, initial.label);
    await store.deletePreset('custom-sort');
    container.invalidate(librarySavedSortFavoritesProvider(type));
    expect(
        (await container.read(librarySavedSortFavoritesProvider(type).future))
            .where((favorite) => favorite.id == 'custom-sort'),
        isEmpty);
  });
}
