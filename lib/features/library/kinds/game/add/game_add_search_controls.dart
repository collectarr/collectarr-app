import 'package:collectarr_app/features/library/add/panes/library_add_choice_menu.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

const gameAddPlatformFilterId = LibraryAddFilterId('game.search.platform');
const gameAddRegionFilterId = LibraryAddFilterId('game.search.region');

/// Release regions of the reference Add Games results.
enum GameAddRegion {
  all('all', 'All', []),
  us('us', 'US', ['ntsc-u', 'us', 'usa', 'north america', 'canada']),
  eu('eu', 'EU', ['pal', 'eu', 'europe', 'uk']),
  au('au', 'AU', ['au', 'australia']),
  jp('jp', 'JP', ['ntsc-j', 'jp', 'japan']),
  other('other', 'Other', []);

  const GameAddRegion(this.value, this.label, this.matches);

  final String value;
  final String label;
  final List<String> matches;
}

String? _option(LibraryAddFilterValue? value) => switch (value) {
      LibraryAddOptionFilterValue(:final value) => value,
      _ => null,
    };

String? gameAddPlatform(LibraryAddSearchContext context) {
  final value = _option(context.valueFor(gameAddPlatformFilterId))?.trim();
  return value == null || value.isEmpty ? null : value;
}

GameAddRegion gameAddRegion(LibraryAddFilterValue? value) =>
    GameAddRegion.values.firstWhere((region) => region.value == _option(value),
        orElse: () => GameAddRegion.all);

/// The Add Games region of a release region text, null when unknown.
GameAddRegion? gameAddRegionFor(String? releaseRegion) {
  final text = releaseRegion?.toLowerCase().trim() ?? '';
  if (text.isEmpty) return null;
  // Whole words, so "Australia" is not read as "US".
  final words = text.split(RegExp(r'[^a-z0-9-]+')).toSet();
  for (final region in GameAddRegion.values) {
    if (region.matches.any((match) =>
        match.contains(' ') ? text.contains(match) : words.contains(match))) {
      return region;
    }
  }
  return GameAddRegion.other;
}

/// Keeps Core results of the chosen region; items without a region stay.
bool gameAddCandidateMatchesRegion(
  CatalogSearchCandidate item,
  LibraryAddSearchContext context,
) {
  final wanted = gameAddRegion(context.valueFor(gameAddRegionFilterId));
  if (wanted == GameAddRegion.all) return true;
  final metadata = item.kindCapability.mapTransport(
      (transport) => GameCatalogMetadata.fromJson(transport.kindData));
  final region = gameAddRegionFor(metadata.releaseRegion);
  return region == null || region == wanted;
}

void _update(
    LibraryAddModeBarRequest request, LibraryAddFilterId id, String value) {
  request.onAdvancedFilterChanged(id, LibraryAddOptionFilterValue(value));
  request.onSearch();
}

/// Platform picker beside the title field, as in the reference.
Widget buildGameAddPlatformControl(
  BuildContext context,
  LibraryAddModeBarRequest request,
) {
  final platform =
      _option(request.advancedFilterState[gameAddPlatformFilterId]) ?? '';
  return LibraryAddChoiceMenu<String>(
    key: const ValueKey('game-add-platform-filter'),
    tooltip: 'Platform',
    width: 160,
    label: platform.isEmpty ? 'All platforms' : platform,
    values: ['', ...GameVocabularies.platform.builtIns],
    labelFor: (value) => value.isEmpty ? 'All platforms' : value,
    onSelected: (value) => _update(request, gameAddPlatformFilterId, value),
  );
}

/// Region segments above the editions, as in the reference.
Widget buildGameAddRegionControl(
  BuildContext context,
  LibraryAddModeBarRequest request,
) {
  final palette = appPalette(context);
  final region =
      gameAddRegion(request.advancedFilterState[gameAddRegionFilterId]);
  const radius = Radius.circular(4);
  final last = GameAddRegion.values.length - 1;
  return Row(
    key: const ValueKey('game-add-region-filter'),
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final (index, value) in GameAddRegion.values.indexed)
        Material(
          color: value == region
              ? palette.utilityAction
              : palette.isDark
                  ? const Color(0xff444444)
                  : const Color(0xffe6e6e6),
          borderRadius: BorderRadius.horizontal(
            left: index == 0 ? radius : Radius.zero,
            right: index == last ? radius : Radius.zero,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _update(request, gameAddRegionFilterId, value.value),
            child: Container(
              width: 65,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: index == 0
                    ? null
                    : Border(left: BorderSide(color: palette.divider)),
              ),
              child: Text(value.label,
                  style: TextStyle(
                      fontSize: 14,
                      color: value == region
                          ? Colors.white
                          : palette.textPrimary)),
            ),
          ),
        ),
    ],
  );
}
