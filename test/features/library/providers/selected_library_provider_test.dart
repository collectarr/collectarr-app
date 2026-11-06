import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> _kindAfterRestart() async {
  await loadStartupLibraryKind();
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container.read(selectedLibraryKindProvider);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('opens on Music until a library is chosen', () async {
    expect(await _kindAfterRestart(), 'music');
  });

  test('reopens on the last chosen library', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(selectedLibraryKindProvider.notifier).select('game');
    await SharedPreferences.getInstance();
    await pumpEventQueue();

    expect(await _kindAfterRestart(), 'game');
  });

  test('a fallback selection keeps the remembered library', () async {
    SharedPreferences.setMockInitialValues(
        {'collectarr.library_nav.selected_kind': 'comic'});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(selectedLibraryKindProvider.notifier)
        .select('music', remember: false);
    await pumpEventQueue();

    expect(await _kindAfterRestart(), 'comic');
  });

  test('a removed library falls back to Music', () async {
    SharedPreferences.setMockInitialValues(
        {'collectarr.library_nav.selected_kind': 'gone'});

    expect(await _kindAfterRestart(), 'music');
  });
}
