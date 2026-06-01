import 'package:collectarr_app/features/library/generic/body.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('details layout hides when configured and nothing is selected', () {
    final layout = resolveEffectiveLibraryDetailsLayout(
      preferredLayout: LibraryDetailsLayout.right,
      compact: false,
      hasSelection: false,
      hideWhenSelectionEmpty: true,
    );

    expect(layout, LibraryDetailsLayout.hidden);
  });

  test('details layout stays right on desktop when selection exists', () {
    final layout = resolveEffectiveLibraryDetailsLayout(
      preferredLayout: LibraryDetailsLayout.right,
      compact: false,
      hasSelection: true,
      hideWhenSelectionEmpty: true,
    );

    expect(layout, LibraryDetailsLayout.right);
  });

  test('right details collapse to bottom in compact mode', () {
    final layout = resolveEffectiveLibraryDetailsLayout(
      preferredLayout: LibraryDetailsLayout.right,
      compact: true,
      hasSelection: true,
      hideWhenSelectionEmpty: true,
    );

    expect(layout, LibraryDetailsLayout.bottom);
  });
}