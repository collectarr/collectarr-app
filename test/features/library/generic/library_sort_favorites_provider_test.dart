import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/generic/library_sort_favorites_provider.dart';
import 'package:collectarr_app/features/library/generic/library_sort_preset_store.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
    final merged = mergeLibrarySortFavorites(type, saved);
    expect(merged.where((favorite) => favorite.id == initial.id), hasLength(1));
    expect(merged.first.label, 'Edited favorite');
    expect(merged.last.id, 'custom-sort');
    expect(
        sanitizeLibraryPinnedSortFavoriteIds(type, ['custom-sort', 'missing'],
            additionalFavorites: saved),
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
