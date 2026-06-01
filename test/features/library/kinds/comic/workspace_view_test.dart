import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('comic workspace view profile defaults to right-side details', () {
    final defaults = comicsWorkspaceViewProfile.defaults();

    expect(comicsWorkspaceViewProfile.defaultDetailsLayout, LibraryDetailsLayout.right);
    expect(comicsWorkspaceViewProfile.defaultDetailsWidth, 350);
    expect(comicsWorkspaceViewProfile.hideDetailsWhenSelectionEmpty, isTrue);
    expect(defaults.detailsLayout, LibraryDetailsLayout.right);
    expect(defaults.detailsWidth, 350);
  });

  test('comic workspace presets keep details on the right', () {
    for (final preset in LibraryWorkspacePreset.values) {
      expect(
        comicsViewPresetConfig(preset).detailsLayout,
        LibraryDetailsLayout.right,
      );
    }
  });
}