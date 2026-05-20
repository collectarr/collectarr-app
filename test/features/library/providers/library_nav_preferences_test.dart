import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('orders visible library kinds with unknown kinds appended', () {
    final preferences = LibraryNavPreferences(
      order: const ['games', 'comic'],
      hiddenKinds: const {'movie'},
      placement: LibraryNavPlacement.left,
    );

    expect(
      preferences.orderedKinds(['comic', 'manga', 'movie', 'games']),
      ['games', 'comic', 'manga', 'movie'],
    );
    expect(preferences.isVisible('movie'), isFalse);
    expect(preferences.isVisible('manga'), isTrue);
  });

  test('persists library nav order visibility and placement', () async {
    SharedPreferences.setMockInitialValues({});
    const store = LibraryNavPreferencesStore();

    await store.write(
      LibraryNavPreferences(
        order: const ['manga', 'comic', 'games'],
        hiddenKinds: const {'music', 'tv'},
        placement: LibraryNavPlacement.left,
      ),
    );

    final restored = await store.read();

    expect(restored.order, ['manga', 'comic', 'games']);
    expect(restored.hiddenKinds, {'music', 'tv'});
    expect(restored.placement, LibraryNavPlacement.left);
  });
}
