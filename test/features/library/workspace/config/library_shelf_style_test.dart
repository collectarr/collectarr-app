import 'package:collectarr_app/features/library/workspace/config/library_shelf_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('shelf style survives a new preferences reader', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(await container.read(libraryShelfStyleProvider.future),
        LibraryShelfStyle.woodLight);
    await container
        .read(libraryShelfStyleProvider.notifier)
        .select(LibraryShelfStyle.carbon);
    final reopened = ProviderContainer();
    addTearDown(reopened.dispose);
    expect(await reopened.read(libraryShelfStyleProvider.future),
        LibraryShelfStyle.carbon);
  });

  test('unknown shelf style uses the default without rewriting preferences',
      () async {
    SharedPreferences.setMockInitialValues(
        {LibraryShelfStyleController.preferenceKey: 'unknown'});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(await container.read(libraryShelfStyleProvider.future),
        LibraryShelfStyle.woodLight);
    expect(
        (await SharedPreferences.getInstance())
            .getString(LibraryShelfStyleController.preferenceKey),
        'unknown');
  });
}
