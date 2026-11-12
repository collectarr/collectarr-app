import 'package:collectarr_app/features/library/workspace/config/config.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/workspace/config/preferences.dart';
import 'package:collectarr_app/features/library/workspace/entry/view_state.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/schema/identifier_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final runtime = libraryKindRegistrationForKind(CatalogMediaKind.music);
  final workspace = musicKindWorkspace;
  LibraryFieldIdRuntime field(String value) =>
      workspace.fields.decodeColumnId(value);
  LibrarySortIdRuntime sort(String value) =>
      workspace.fields.decodeSortId(value);

  final profile = LibraryWorkspaceViewProfile(
    registrationResolver: () => runtime,
    defaultCoverSize: 128,
    minCoverSize: 100,
    maxCoverSize: 200,
    presetConfig: (preset) {
      return switch (preset) {
        LibraryWorkspacePreset.list => LibraryWorkspaceViewPresetConfig(
            viewMode: LibraryViewMode.list,
            detailsLayout: LibraryDetailsLayout.bottom,
            coverSize: 128,
            visibleColumns: {
              field('title'),
              field('grade'),
            },
          ),
        _ => LibraryWorkspaceViewPresetConfig(
            viewMode: LibraryViewMode.grid,
            detailsLayout: LibraryDetailsLayout.right,
            coverSize: 144,
            visibleColumns: {
              field('title'),
              field('artist_summary'),
            },
          ),
      };
    },
    clampColumnWidth: (column, width) => width.clamp(80, 240).toDouble(),
  );

  setUp(() {
    LibraryWorkspacePreferences.resetCachedChromeForTesting();
    SharedPreferences.setMockInitialValues({});
  });

  test('workspace view profile builds defaults and applies presets', () {
    final defaults = profile.defaults();

    expect(defaults.viewMode, LibraryViewMode.grid);
    expect(defaults.detailsLayout, LibraryDetailsLayout.bottom);
    expect(defaults.sortId, workspace.fields.defaultSort);
    expect(defaults.coverSize, 128);
    expect(defaults.sidebarWidth, 250);
    expect(defaults.detailsWidth, 340);
    expect(defaults.detailsHeight, 300);
    expect(defaults.visibleColumnIds, workspace.fields.defaultVisibleColumns);

    final list = defaults.withPreset(LibraryWorkspacePreset.list, profile);
    expect(list.viewMode, LibraryViewMode.list);
    expect(list.detailsLayout, LibraryDetailsLayout.bottom);
    expect(list.visibleColumnIds, {
      field('title'),
      field('grade'),
    });
  });

  test('workspace view state toggles sort and clamps column widths', () {
    final state = profile
        .defaults()
        .withSortColumn(sort('grade'), profile)
        .withColumnWidth(field('title'), 999, profile);

    expect(state.sortId, sort('grade'));
    expect(state.sortAscending, isTrue);
    expect(state.columnWidths[field('title')], 240);

    final toggled = state.withSortColumn(sort('grade'), profile);
    expect(toggled.sortAscending, isFalse);
    expect(toggled.sortRules,
        [LibrarySortRuleRuntime(sortId: sort('grade'), ascending: false)]);
  });

  for (final kind in [
    CatalogMediaKind.game,
    CatalogMediaKind.music,
    CatalogMediaKind.gameHardware,
    CatalogMediaKind.gameToy
  ]) {
    test(
        '${kind.name} image widths resize together in both directions and persist',
        () {
      final kindProfile = libraryViewProfileForKind(kind);
      final fields = libraryKindWorkspaceForKind(kind).workspaceFields;
      final images = fields.columns
          .where((column) => column.imageAspectRatio != null)
          .toList();
      expect(images.length, greaterThanOrEqualTo(2));
      final text = fields.columns
          .firstWhere((column) =>
              column.imageAspectRatio == null &&
              (column.minWidth == null || column.minWidth != column.maxWidth))
          .id;
      var state =
          kindProfile.defaults().withColumnWidth(text, 300, kindProfile);
      final textWidth = state.columnWidths[text];
      // Hidden covers keep the same width when selected again later.
      state = state.copyWith(visibleColumnIds: {images.first.id, text});
      for (final (image, width) in [
        (images.last, 220.0),
        (images.first, 80.0)
      ]) {
        state = state.withColumnWidth(image.id, width, kindProfile);
        for (final cover in images) {
          expect(state.columnWidths[cover.id], width);
        }
        expect(state.columnWidths[text], textWidth);
        expect(state.visibleColumnIds, {images.first.id, text});
      }
      state = state.withColumnWidth(text, 400, kindProfile);
      for (final image in images) {
        expect(state.columnWidths[image.id], 80);
      }
      final restored =
          kindProfile.fromPreferences(state.toPreferenceSnapshot());
      for (final image in images) {
        expect(restored.columnWidths[image.id], 80);
      }
    });
  }

  test('a header click sorts by that column alone, as in the reference', () {
    final state = profile.defaults().withSortRules([
      LibrarySortRuleRuntime(
        sortId: sort('publisher'),
        ascending: true,
      ),
      LibrarySortRuleRuntime(
        sortId: sort('updated'),
        ascending: false,
      ),
    ], profile);

    final updated = state.withSortColumn(sort('grade'), profile);
    expect(updated.sortRules, [
      LibrarySortRuleRuntime(sortId: sort('grade'), ascending: true),
    ]);

    // The leading column of a multi-field sort reverses and stands alone.
    final reversed = state.withSortColumn(sort('publisher'), profile);
    expect(reversed.sortRules, [
      LibrarySortRuleRuntime(sortId: sort('publisher'), ascending: false),
    ]);
  });

  test('a sort keeps at most five fields, as in the reference', () {
    final ids = [for (final sort in workspace.fields.sorts) sort.id];
    expect(ids.length, greaterThan(kLibraryMaxSortRules));
    final state = profile.defaults().withSortRules([
      for (final id in ids.take(kLibraryMaxSortRules + 1))
        LibrarySortRuleRuntime(sortId: id, ascending: true),
    ], profile);
    expect(state.sortRules, hasLength(kLibraryMaxSortRules));
  });

  test('workspace view profile controls initial sort direction', () {
    final newestFirstProfile = LibraryWorkspaceViewProfile(
      registrationResolver: () => runtime,
      defaultCoverSize: 128,
      minCoverSize: 100,
      maxCoverSize: 200,
      presetConfig: profile.presetConfig,
      clampColumnWidth: profile.clampColumnWidth,
      sortAscendingForColumn: (column) => column != sort('updated'),
    );

    final state = newestFirstProfile.defaults().withSortColumn(
          sort('updated'),
          newestFirstProfile,
        );

    expect(state.sortId, sort('updated'));
    expect(state.sortAscending, isFalse);
  });

  test('workspace view profile persists through shared preferences', () async {
    final state = profile.defaults().copyWith(
          viewMode: LibraryViewMode.card,
          sortRules: const [
            LibrarySortRuleRuntime(
              sortId: LibrarySortId<MusicKind>('music.artist_summary'),
              ascending: true,
            ),
            LibrarySortRuleRuntime(
              sortId: LibrarySortId<MusicKind>('music.title'),
              ascending: false,
            ),
          ],
          coverSize: 180,
          sidebarWidth: 300,
          detailsWidth: 420,
          detailsHeight: 280,
        );

    await profile.save(state);
    final restored = await profile.load();

    expect(restored.viewMode, LibraryViewMode.card);
    expect(restored.sortRules, [
      const LibrarySortRuleRuntime(
        sortId: LibrarySortId<MusicKind>('music.artist_summary'),
        ascending: true,
      ),
      const LibrarySortRuleRuntime(
        sortId: LibrarySortId<MusicKind>('music.title'),
        ascending: false,
      ),
    ]);
    expect(restored.coverSize, 180);
    expect(restored.sidebarWidth, 300);
    expect(restored.detailsWidth, 420);
    expect(restored.detailsHeight, 280);
  });

  test('workspace view defaults reuse cached library chrome', () async {
    await LibraryWorkspacePreferences(runtime).write(
      profile
          .defaults()
          .copyWith(
            detailsLayout: LibraryDetailsLayout.bottom,
            sidebarWidth: 310,
            detailsWidth: 450,
          )
          .toPreferenceSnapshot(),
    );

    final defaults = profile.defaults();

    expect(defaults.detailsLayout, LibraryDetailsLayout.bottom);
    expect(defaults.sidebarWidth, 310);
    expect(defaults.detailsWidth, 450);
  });
}
