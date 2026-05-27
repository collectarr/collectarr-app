import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_media_adapters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registry resolves adapters for normalized kind values', () {
    expect(collectarrMediaAdapters.byKind(' COMIC '), same(comicsMediaAdapter));
    expect(
      collectarrMediaAdapters.byKind(CatalogMediaKind.comic),
      same(comicsMediaAdapter),
    );
    expect(collectarrMediaAdapters.byKind('unknown-kind'), isNull);
  });

  test('supportedKinds stays unique across built-in adapters', () {
    final supportedKinds = collectarrMediaAdapters.supportedKinds;

    expect(supportedKinds, containsAll(['comic', 'book', 'game', 'music']));
    expect(supportedKinds.toSet().length, supportedKinds.length);
    expect(supportedKinds.length, collectarrMediaAdapters.adapters.length);
  });
}