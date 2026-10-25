import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_choice_menu.dart';
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
});
String? _platform(LibraryAddSearchContext context) {
  final value = context.textValueFor(gameHardwareAddPlatformId);
  return value.isEmpty ? null : value;
}

bool gameHardwareHasSearchInput(LibraryAddSearchContext context) =>
    context.query.trim().isNotEmpty ||
    context.identifierCode.trim().isNotEmpty ||
    _platform(context) != null;

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

Widget buildGameHardwareAddPlatformControl(
    BuildContext context, LibraryAddModeBarRequest request) {
  final platform = request.advancedFilterText(gameHardwareAddPlatformId);
  return LibraryAddChoiceMenu<String>(
      key: const ValueKey('game-hardware-add-platform'),
      tooltip: 'Platform',
      width: 160,
      label: platform.isEmpty ? 'All platforms' : platform,
      values: const ['', ..._searchPlatforms],
      labelFor: (value) => value.isEmpty ? 'All platforms' : value,
      onSelected: (value) {
        request.onAdvancedFilterChanged(
            gameHardwareAddPlatformId, LibraryAddOptionFilterValue(value));
        request.onSearch();
      });
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
