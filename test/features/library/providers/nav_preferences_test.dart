import 'package:collectarr_app/features/library/providers/nav_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
      'at least one available kind remains enabled and hidden kinds can be restored',
      () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(libraryNavPreferencesProvider);
    final controller = container.read(libraryNavPreferencesProvider.notifier);
    await controller.load();
    await controller
        .setKindVisible('comic', false, availableKinds: ['comic', 'music']);
    await controller
        .setKindVisible('music', false, availableKinds: ['comic', 'music']);
    expect(container.read(libraryNavPreferencesProvider).isVisible('music'),
        isTrue);
    await controller
        .setKindVisible('comic', true, availableKinds: ['comic', 'music']);
    expect(container.read(libraryNavPreferencesProvider).isVisible('comic'),
        isTrue);
    expect(
        (await const LibraryNavPreferencesStore().read()).hiddenKinds, isEmpty);
  });
  test('orders visible library kinds with unknown kinds appended', () {
    final preferences = LibraryNavPreferences(
      order: const ['games', 'comic'],
      hiddenKinds: const {'movie'},
      placement: LibraryNavPlacement.left,
    );

    expect(
      preferences.orderedKinds(['comic', 'book', 'movie', 'games']),
      ['games', 'comic', 'book', 'movie'],
    );
    expect(preferences.isVisible('movie'), isFalse);
    expect(preferences.isVisible('book'), isTrue);
  });

  test('persists library nav order visibility and placement', () async {
    SharedPreferences.setMockInitialValues({});
    const store = LibraryNavPreferencesStore();

    await store.write(
      LibraryNavPreferences(
        order: const ['book', 'comic', 'games'],
        hiddenKinds: const {'music', 'movie'},
        placement: LibraryNavPlacement.left,
      ),
    );

    final restored = await store.read();

    expect(restored.order, ['book', 'comic', 'games']);
    expect(restored.hiddenKinds, {'music', 'movie'});
    expect(restored.placement, LibraryNavPlacement.left);
  });
}
