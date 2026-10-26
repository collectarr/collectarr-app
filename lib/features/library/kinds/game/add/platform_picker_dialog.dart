import 'package:collectarr_app/features/library/ui/primitives/platform_icon.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_chrome.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _favoritesKey = 'game.add.platformFavorites';

/// The reference lists platforms by console generation, newest first, then
/// the rest alphabetically.
const _generations = [
  ['PlayStation 5', 'Xbox Series X/S'],
  ['PlayStation 4', 'Xbox One', 'Nintendo Switch'],
  [
    'PC',
    'PlayStation 3',
    'Xbox 360',
    'Nintendo Wii U',
    'Nintendo Wii',
    'Nintendo 3DS',
    'PlayStation Vita',
  ],
  [
    'Nintendo DS',
    'PlayStation Portable',
    'Game Boy Advance',
    'PlayStation 2',
    'Xbox',
    'Sega Dreamcast',
  ],
  [
    'PlayStation',
    'Nintendo 64',
    'Nintendo GameCube',
    'Sega Saturn',
    'Game Boy Color',
  ],
  [
    'Sega Genesis',
    'Super Nintendo Entertainment System',
    'Nintendo Entertainment System',
    'Game Boy',
  ],
];

/// Platform groups for the picker: the generations, then [current] when it
/// is not one of them.
List<List<String>> gamePlatformPickerGroups([String? current]) {
  final listed = {for (final group in _generations) ...group};
  final other = current?.trim() ?? '';
  return [
    ..._generations,
    if (other.isNotEmpty && !listed.contains(other)) [other]
  ];
}

/// Opens the reference's Pick Platform list; resolves to the chosen platform,
/// '' for All platforms, or null when closed.
Future<String?> showGamePlatformPicker(BuildContext context,
        {required String selected}) =>
    showAppDialog<String>(
        context: context,
        builder: (_) => GamePlatformPickerDialog(selected: selected));

class GamePlatformPickerDialog extends StatefulWidget {
  const GamePlatformPickerDialog({super.key, required this.selected});

  final String selected;

  @override
  State<GamePlatformPickerDialog> createState() =>
      _GamePlatformPickerDialogState();
}

class _GamePlatformPickerDialogState extends State<GamePlatformPickerDialog> {
  final _search = TextEditingController();
  List<String> _favorites = const [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _favorites = prefs.getStringList(_favoritesKey) ?? []);
  }

  Future<void> _toggleFavorite(String platform) async {
    final favorites = _favorites.contains(platform)
        ? [..._favorites.where((value) => value != platform)]
        : [..._favorites, platform];
    setState(() => _favorites = favorites);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites);
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    bool matches(String platform) =>
        query.isEmpty || platform.toLowerCase().contains(query);
    final groups = [
      for (final group in gamePlatformPickerGroups(widget.selected))
        [...group.where(matches)]
    ].where((group) => group.isNotEmpty).toList();
    final favorites = _favorites.where(matches).toList();
    return PickListDialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Material(
          color: pickListSurface(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PickListHeader(
                  title: 'Pick Platform',
                  icon: AppIcons.gamepad,
                  onClose: () => Navigator.pop(context)),
              Container(
                color: pickListToolbar(context),
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 408,
                  height: 34,
                  child: TextField(
                    key: const ValueKey('game-platform-picker-search'),
                    controller: _search,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 14),
                    decoration: pickListInputDecoration(context,
                        hintText: 'Search...',
                        suffixIcon: Icon(Icons.search,
                            size: 16, color: appPalette(context).textMuted)),
                  ),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    const _Heading('Favorites'),
                    if (query.isEmpty) _row('', 0, favorite: null),
                    for (final (index, platform) in favorites.indexed)
                      _row(platform, index + 1, favorite: true),
                    for (final group in groups) ...[
                      const _Separator(),
                      for (final (index, platform) in group.indexed)
                        _row(platform, index,
                            favorite: _favorites.contains(platform)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String platform, int index, {required bool? favorite}) =>
      _PlatformRow(
        platform: platform,
        odd: index.isEven,
        selected: platform == widget.selected,
        favorite: favorite,
        onSelect: () => Navigator.pop(context, platform),
        onToggleFavorite:
            favorite == null ? null : () => _toggleFavorite(platform),
      );
}

class _Heading extends StatelessWidget {
  const _Heading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
        height: 36,
        color: _band(context),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.centerLeft,
        child: Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: appPalette(context).textPrimary)),
      );
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) =>
      Container(height: 8, color: _band(context));
}

Color _band(BuildContext context) => appPalette(context).isDark
    ? const Color(0xff111111)
    : appPalette(context).panelRaised;

class _PlatformRow extends StatelessWidget {
  const _PlatformRow({
    required this.platform,
    required this.odd,
    required this.selected,
    required this.favorite,
    required this.onSelect,
    required this.onToggleFavorite,
  });

  final String platform;
  final bool odd;
  final bool selected;

  /// Null for All platforms, which cannot be starred.
  final bool? favorite;
  final VoidCallback onSelect;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final color = palette.isDark
        ? odd
            ? const Color(0xff2e3035)
            : const Color(0xff383838)
        : odd
            ? palette.tableOddRow
            : palette.tableEvenRow;
    return Material(
      color: color,
      child: InkWell(
        key: ValueKey('game-platform-option-$platform'),
        mouseCursor: WidgetStateMouseCursor.clickable,
        onTap: onSelect,
        child: SizedBox(
          height: 35,
          child: Row(children: [
            const SizedBox(width: 10),
            Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 16,
                color: palette.textPrimary),
            const SizedBox(width: 10),
            if (platform.isNotEmpty) ...[
              PlatformIcon(platform, size: 18, color: palette.textPrimary),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(platform.isEmpty ? 'All platforms' : platform,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary)),
            ),
            if (favorite != null)
              IconButton(
                key: ValueKey('game-platform-favorite-$platform'),
                tooltip:
                    favorite! ? 'Remove from favorites' : 'Add to favorites',
                onPressed: onToggleFavorite,
                iconSize: 14,
                visualDensity: VisualDensity.compact,
                color: palette.textPrimary,
                icon: Icon(favorite! ? Icons.star : Icons.star_border),
              ),
            const SizedBox(width: 6),
          ]),
        ),
      ),
    );
  }
}
