import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_hierarchy_capability.dart';
import 'package:collectarr_app/features/library/hierarchy/providers/library_hierarchy_provider.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the kind-owned child title builder', () {
    const capability = LibraryHierarchyCapability(
      childrenTitleBuilder: _childrenTitle,
    );

    expect(capability.childrenTitle(3), 'Volumes (3)');
  });

  test('uses a generic contents label when no builder is supplied', () {
    const capability = LibraryHierarchyCapability();

    expect(capability.childrenTitle(2), 'Contents (2)');
  });

  test('unknown kinds fail before hierarchy provider fallback', () {
    expect(
      () => requireLibraryHierarchyForKind(CatalogMediaKind.unknown),
      throwsUnsupportedError,
    );
  });

  test('registered kinds resolve their own hierarchy capability', () {
    expect(
      requireLibraryHierarchyForKind(CatalogMediaKind.comic),
      same(comicKindModule.hierarchy),
    );
  });
}

String _childrenTitle(int count) => 'Volumes ($count)';
