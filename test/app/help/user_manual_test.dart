import 'package:collectarr_app/app/help/user_manual.dart';
import 'package:collectarr_app/app/shell/app_navigation_model.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all kinds open their chapter in one shared manual', () {
    for (final kind in CatalogMediaKind.values) {
      if (kind.isUnknown) continue;
      expect(userManualUri(kind: kind).toString(),
          'https://collectarr.github.io/collectarr-page/manual/kinds/${kind.apiValue}/');
    }
    expect(userManualUri().path, '/collectarr-page/manual/');
    expect(userManualUri(kind: CatalogMediaKind.unknown), userManualUri());
  });

  test('server hosting and preview roots retain their own path', () {
    expect(
        userManualUri(
                kind: CatalogMediaKind.music,
                baseUrl: 'http://127.0.0.1:4321/collectarr-page/manual')
            .toString(),
        'http://127.0.0.1:4321/collectarr-page/manual/kinds/music/');
    expect(userManualUri(baseUrl: 'https://docs.example.com/manual/').path,
        '/manual/');
  });

  test('invalid roots are rejected instead of launching unintended targets',
      () {
    for (final url in [
      'file:///manual',
      '/manual',
      'https://host/manual?token=x',
      'https://host/manual#topic',
      'https://user:password@host/manual'
    ]) {
      expect(() => userManualUri(baseUrl: url), throwsArgumentError);
    }
  });

  test('manual opens externally without resetting library navigation', () {
    final destination = appDrawerDestination(DrawerAction.userManual);
    expect(destination.section, AppDrawerSection.help);
    expect(destination.routesAway, isFalse);
    expect(destination.resetsToLibrary, isFalse);
    expect(destination.routePath, isNull);
  });
}
