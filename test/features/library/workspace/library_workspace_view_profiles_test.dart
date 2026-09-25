import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_preferences.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_pane_widths.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final kinds = CatalogMediaKind.values.where((kind) => !kind.isUnknown);

  setUp(() {
    LibraryWorkspacePreferences.resetCachedChromeForTesting();
    SharedPreferences.setMockInitialValues({});
  });

  test('all nine kinds share the standard workspace profile and presets', () {
    for (final kind in kinds) {
      final profile = libraryViewProfileForKind(kind);
      final defaults = profile.defaults();

      expect(profile.defaultCoverSize, 128, reason: kind.apiValue);
      expect(profile.minCoverSize, 96, reason: kind.apiValue);
      expect(profile.maxCoverSize, 275, reason: kind.apiValue);
      expect(profile.defaultDetailsLayout, LibraryDetailsLayout.bottom);
      expect(defaults.detailsLayout, LibraryDetailsLayout.bottom);
      expect(defaults.detailsWidth, kLibraryDetailsDefaultWidth);
      final fields = libraryWorkspaceForKind(kind).fields;
      expect(
        profile.initialSortAscending(fields.defaultSort),
        fields.findSortDefinition(fields.defaultSort)?.defaultAscending ?? true,
        reason: kind.apiValue,
      );

      for (final preset in LibraryWorkspacePreset.values) {
        final config = profile.presetConfig(preset);
        expect(
          config.detailsLayout,
          LibraryDetailsLayout.bottom,
          reason: '${kind.apiValue}: ${preset.name}',
        );
        expect(
          config.viewMode,
          switch (preset) {
            LibraryWorkspacePreset.cover => LibraryViewMode.grid,
            LibraryWorkspacePreset.card => LibraryViewMode.card,
            LibraryWorkspacePreset.details => LibraryViewMode.grid,
            LibraryWorkspacePreset.list => LibraryViewMode.list,
          },
          reason: '${kind.apiValue}: ${preset.name}',
        );
        expect(
          config.coverSize,
          switch (preset) {
            LibraryWorkspacePreset.cover => 128,
            LibraryWorkspacePreset.card => 150,
            LibraryWorkspacePreset.details => 144,
            LibraryWorkspacePreset.list => 100,
          },
          reason: '${kind.apiValue}: ${preset.name}',
        );
      }
    }
  });

  test('profile loading uses bottom details when no preference is saved',
      () async {
    for (final kind in kinds) {
      final loaded = await libraryViewProfileForKind(kind).load();
      expect(
        loaded.detailsLayout,
        LibraryDetailsLayout.bottom,
        reason: kind.apiValue,
      );
      expect(
        loaded.detailsWidth,
        kLibraryDetailsDefaultWidth,
        reason: kind.apiValue,
      );
    }
  });

  test('profile loading keeps an explicitly saved details position', () async {
    final profile = libraryViewProfileForKind(CatalogMediaKind.comic);
    await profile.save(
      profile.defaults().copyWith(detailsLayout: LibraryDetailsLayout.right),
    );

    final loaded = await profile.load();

    expect(loaded.detailsLayout, LibraryDetailsLayout.right);
  });

  test('removed Comic favorite pins are filtered from the common lists', () {
    final registration = libraryKindRegistrationForKind(CatalogMediaKind.comic);

    expect(
      sanitizeLibraryPinnedSortFavoriteIds(
        registration,
        {'series_issue', 'publisher_date', 'recent'},
      ),
      {'recent'},
    );
    expect(
      sanitizeLibraryPinnedColumnFavoriteKeys(
        registration,
        {
          'builtin:ownership',
          'builtin:value',
          'builtin:essential',
          'saved:my_columns'
        },
      ),
      {'builtin:essential', 'saved:my_columns'},
    );
  });
}
