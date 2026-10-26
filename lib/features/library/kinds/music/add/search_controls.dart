import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/kinds/music/add/search_filters.dart';
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
    final disc = musicAddDiscFilterFromValue(
      request.advancedFilterState[musicAddDiscFilterId],
    );
    final palette = appPalette(context);
    final menuText = TextStyle(color: palette.textPrimary, fontSize: 14);
    return PopupMenuButton<MusicAddDiscFilter>(
      key: const ValueKey('music-add-format-filter'),
      tooltip: 'Format',
      initialValue: disc,
      popUpAnimationStyle: AnimationStyle.noAnimation,
      position: PopupMenuPosition.under,
      color: palette.isDark ? const Color(0xff444444) : palette.panelRaised,
      surfaceTintColor: Colors.transparent,
      menuPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: palette.isDark ? const Color(0xff666666) : palette.divider),
      ),
      onSelected: (value) => _update(musicAddDiscFilterId, value.value),
      itemBuilder: (context) => [
        for (final value in MusicAddDiscFilter.values)
          PopupMenuItem(
            value: value,
            height: 30,
            child: Text(value.label, style: menuText),
          ),
      ],
      child: Container(
        width: 77,
        height: 24,
        padding: const EdgeInsets.only(left: 4, right: 2),
        decoration: BoxDecoration(
          color: palette.isDark ? const Color(0xff383838) : palette.field,
          border: Border.all(color: const Color(0xff767676)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                disc.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 16,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down,
                size: 14, color: palette.textPrimary),
          ],
        ),
      ),
    );
  }
}
