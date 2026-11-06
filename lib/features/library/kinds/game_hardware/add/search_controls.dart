import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/features/library/add/controllers/dialog_requests.dart';
import 'package:collectarr_app/features/library/add/models/advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/search_context.dart';
import 'package:collectarr_app/features/library/ui/primitives/platform_icon.dart';
import 'package:collectarr_app/ui/app_dropdown_menu.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

const gameHardwareAddPlatformId =
    LibraryAddFilterId('game_hardware.search.platform');

enum GameHardwareSearchType {
  consoles('Console', 'Consoles'),
  controllers('Controller', 'Controllers'),
  accessories('Accessory', 'Accessories');

  const GameHardwareSearchType(this.value, this.label);
  final String value;
  final String label;
  LibraryAddFilterId get filterId =>
      LibraryAddFilterId('game_hardware.search.type.$value');
}

final gameHardwareInitialSearchFilters =
    Map<LibraryAddFilterId, LibraryAddFilterValue>.unmodifiable({
  LibraryAddFilterId('game_hardware.search.type.Console'):
      LibraryAddOptionFilterValue('true'),
  gameHardwareAddPlatformId: LibraryAddOptionFilterValue('PC'),
});
String? _platform(LibraryAddSearchContext context) {
  final value = context.textValueFor(gameHardwareAddPlatformId);
  return value.isEmpty ? null : value;
}

bool gameHardwareHasSearchInput(LibraryAddSearchContext context) =>
    context.query.trim().isNotEmpty || context.identifierCode.trim().isNotEmpty;

MetadataSearchQuery gameHardwareCoreSearchInput(LibraryAddSearchContext context,
        {required int limit}) =>
    MetadataSearchQuery(
        query: context.query.trim().isEmpty ? null : context.query.trim(),
        barcode: context.identifierCode.trim().isEmpty
            ? null
            : context.identifierCode.trim(),
        limit: limit,
        fieldFilters: {
          if (_platform(context) case final value?) 'platform': [value],
          'hardware_type': [
            for (final type in GameHardwareSearchType.values)
              if (context.textValueFor(type.filterId) == 'true') type.value
          ],
        });

/// Platforms the Add search narrows hardware to; the Platform pick list
/// itself holds only the platforms entries use.
const _searchPlatforms = [
  'PlayStation 5',
  'PlayStation 4',
  'Nintendo Switch',
  'Xbox Series X',
  'Xbox One',
  'PC',
  'Other'
];

/// The platform inside the title field, as in the reference.
Widget buildGameHardwareAddPlatformControl(
    BuildContext context, LibraryAddModeBarRequest request) {
  final platform = request.advancedFilterText(gameHardwareAddPlatformId);
  final palette = appPalette(context);
  final menu = AppDropdownMenuStyle.of(context);
  final muted = palette.isDark ? const Color(0xff888888) : palette.textMuted;
  return PopupMenuButton<String>(
      key: const ValueKey('game-hardware-add-platform'),
      tooltip: 'Platform',
      popUpAnimationStyle: AnimationStyle.noAnimation,
      position: PopupMenuPosition.under,
      color: menu.background,
      shape: menu.shape,
      elevation: AppDropdownMenuStyle.elevation,
      menuPadding: AppDropdownMenuStyle.padding,
      itemBuilder: (context) => [
            for (final value in const ['', ..._searchPlatforms])
              menu.row(
                  value: value,
                  current: value == platform,
                  child: Text(value.isEmpty ? 'All platforms' : value,
                      style: const TextStyle(fontSize: 14))),
          ],
      onSelected: (value) {
        request.onAdvancedFilterChanged(
            gameHardwareAddPlatformId, LibraryAddOptionFilterValue(value));
        request.onSearch();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (platform.isNotEmpty) ...[
            PlatformIcon(platform, size: 18, color: muted),
            const SizedBox(width: 6),
          ],
          Text(platform.isEmpty ? 'All' : platform,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: muted)),
          const SizedBox(width: 5),
          Icon(AppIcons.chevronDown, size: 12, color: muted),
        ]),
      ));
}

Widget buildGameHardwareAddTypeControls(
    BuildContext context, LibraryAddModeBarRequest request) {
  final palette = appPalette(context);
  return Wrap(spacing: 18, children: [
    for (final type in GameHardwareSearchType.values)
      _HardwareTypeCheckbox(
          label: type.label,
          checked: request.advancedFilterText(type.filterId) == 'true',
          color: palette.link,
          onChanged: (value) {
            request.onAdvancedFilterChanged(type.filterId,
                LibraryAddOptionFilterValue(value ? 'true' : 'false'));
            request.onSearch();
          })
  ]);
}

class _HardwareTypeCheckbox extends StatelessWidget {
  const _HardwareTypeCheckbox(
      {required this.label,
      required this.checked,
      required this.color,
      required this.onChanged});
  final String label;
  final bool checked;
  final Color color;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Semantics(
      label: label,
      checked: checked,
      child: InkWell(
          onTap: () => onChanged(!checked),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
                width: 20,
                height: 24,
                child: Checkbox(
                    value: checked,
                    activeColor: color,
                    visualDensity: VisualDensity.compact,
                    onChanged: (value) => onChanged(value ?? false))),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 14))
          ])));
}
