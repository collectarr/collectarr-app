import 'package:collectarr_app/features/library/add/controllers/dialog_requests.dart';
import 'package:collectarr_app/features/library/add/models/advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/search_context.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/platform_tile.dart';
import 'package:collectarr_app/features/library/ui/primitives/platform_icon.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'platform_picker_dialog.dart';

const gameAddPlatformFilterId = LibraryAddFilterId('game.search.platform');

/// Release regions of the reference Add Games results.
enum GameAddRegion {
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

void _update(
    LibraryAddModeBarRequest request, LibraryAddFilterId id, String value) {
  request.onAdvancedFilterChanged(id, LibraryAddOptionFilterValue(value));
  request.onSearch();
}

/// The Platform tab's own select: logo, name and chevron, opening Pick Platform.
Widget buildGameAddListingPlatform(
  BuildContext context,
  LibraryAddModeBarRequest request,
) {
  final platform =
      _option(request.advancedFilterState[gameAddPlatformFilterId]) ?? '';
  final palette = appPalette(context);
  return InkWell(
    key: const ValueKey('game-add-listing-platform'),
    mouseCursor: WidgetStateMouseCursor.clickable,
    onTap: () async {
      final chosen = await showGamePlatformPicker(context, selected: platform);
      if (chosen != null && chosen.isNotEmpty) {
        _update(request, gameAddPlatformFilterId, chosen);
      }
    },
    child: Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: palette.isDark ? const Color(0xff444444) : palette.field,
      child: Row(children: [
        GamePlatformTile(platform),
        const SizedBox(width: 8),
        Expanded(
          child: Text(platform,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary)),
        ),
        Icon(AppIcons.chevronDown, size: 12, color: palette.textPrimary),
      ]),
    ),
  );
}

/// The platform inside the title field, opening Pick Platform, as in the
/// reference.
Widget buildGameAddPlatformControl(
  BuildContext context,
  LibraryAddModeBarRequest request,
) {
  final platform =
      _option(request.advancedFilterState[gameAddPlatformFilterId]) ?? '';
  final palette = appPalette(context);
  final muted = palette.isDark ? const Color(0xff888888) : palette.textMuted;
  return Tooltip(
    message: 'Platform',
    child: InkWell(
      key: const ValueKey('game-add-platform-filter'),
      mouseCursor: WidgetStateMouseCursor.clickable,
      onTap: () async {
        final chosen =
            await showGamePlatformPicker(context, selected: platform);
        if (chosen != null) _update(request, gameAddPlatformFilterId, chosen);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (platform.isNotEmpty) ...[
            PlatformIcon(platform, size: 18, color: muted),
            const SizedBox(width: 6),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(platform.isEmpty ? 'All' : platform,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: muted)),
          ),
          const SizedBox(width: 5),
          Icon(AppIcons.chevronDown, size: 12, color: muted),
        ]),
      ),
    ),
  );
}
