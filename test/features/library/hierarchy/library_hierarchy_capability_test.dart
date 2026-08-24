import 'package:collectarr_app/features/library/config/library_hierarchy_capability.dart';
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
}

String _childrenTitle(int count) => 'Volumes ($count)';
