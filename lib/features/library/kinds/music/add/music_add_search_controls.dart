import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_search_filters.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Widget buildMusicAddSearchControls(
  BuildContext context,
  LibraryAddModeBarRequest request,
) {
  return MusicAddSearchControls(request: request);
}

class MusicAddSearchControls extends StatelessWidget {
  const MusicAddSearchControls({super.key, required this.request});

  final LibraryAddModeBarRequest request;

  void _update(LibraryAddFilterId id, String value) {
    request.onAdvancedFilterChanged(id, LibraryAddOptionFilterValue(value));
    request.onSearch();
  }

  @override
  Widget build(BuildContext context) {
    final medium = musicAddMediumFilterFromValue(
      request.advancedFilterState[musicAddMediumFilterId],
    );
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              'Medium',
              style: TextStyle(
                color: palette.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 6),
            _MusicChoiceStrip<MusicAddMediumFilter>(
              accent: request.accent,
              selected: medium,
              values: [
                for (final value in MusicAddMediumFilter.values)
                  (value, value.label),
              ],
              onSelected: (value) =>
                  _update(musicAddMediumFilterId, value.value),
            ),
          ],
        ),
      ),
    );
  }
}

class _MusicChoiceStrip<T> extends StatelessWidget {
  const _MusicChoiceStrip({
    required this.accent,
    required this.selected,
    required this.values,
    required this.onSelected,
  });

  final Color accent;
  final T selected;
  final List<(T, String)> values;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < values.length; index++) ...[
            if (index > 0)
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: palette.divider,
              ),
            InkWell(
              mouseCursor: WidgetStateMouseCursor.clickable,
              onTap: () => onSelected(values[index].$1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                color: values[index].$1 == selected
                    ? accent.withValues(alpha: 0.2)
                    : Colors.transparent,
                child: Text(
                  values[index].$2,
                  style: TextStyle(
                    color: values[index].$1 == selected
                        ? accent
                        : palette.textMuted,
                    fontSize: 12,
                    fontWeight: values[index].$1 == selected
                        ? FontWeight.w900
                        : FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
