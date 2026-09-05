import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

const libraryAddVideoKindFilterId = LibraryAddFilterId('video.provider-kinds');

Map<LibraryAddFilterId, Object?> buildLibraryAddVideoInitialFilters(
  LibraryKindRuntime type,
) {
  return {
    libraryAddVideoKindFilterId:
        Set<String>.unmodifiable(type.addChrome.defaultVideoKindFilters),
  };
}

Iterable<String> libraryAddVideoKindOverrides(
  LibraryKindRuntime type,
  LibraryAddSearchContext context,
) {
  return libraryAddVideoKindOverridesForChrome(type.addChrome, context);
}

Iterable<String> libraryAddVideoKindOverridesForChrome(
  LibraryAddChromeConfig chrome,
  LibraryAddSearchContext context,
) {
  final rawSelected = context.valueFor(libraryAddVideoKindFilterId);
  final selected = rawSelected is Set<String> ? rawSelected : const <String>{};
  if (selected.isNotEmpty) return selected;
  return chrome.videoKindFilterOptions.map((option) => option.kind);
}

bool libraryAddVideoHasSearchInput(LibraryAddSearchContext context) {
  if (context.query.trim().isNotEmpty || context.barcode.trim().isNotEmpty) {
    return true;
  }
  return context.advancedFilters.entries.any((entry) {
    if (entry.key == libraryAddVideoKindFilterId) return false;
    final value = entry.value;
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is Iterable) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  });
}

Widget buildLibraryAddVideoKindFilterRow(
  BuildContext context,
  LibraryAddModeBarRequest request,
) {
  return LibraryAddVideoKindFilterRow(request: request);
}

class LibraryAddVideoKindFilterRow extends StatelessWidget {
  const LibraryAddVideoKindFilterRow({super.key, required this.request});

  final LibraryAddModeBarRequest request;

  @override
  Widget build(BuildContext context) {
    final options = request.type.addChrome.videoKindFilterOptions;
    if (options.isEmpty) return const SizedBox.shrink();

    final rawSelected =
        request.advancedFilterState[libraryAddVideoKindFilterId];
    final selected =
        rawSelected is Set<String> ? rawSelected : const <String>{};
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          for (final option in options) ...[
            _VideoKindCheckbox(
              label: option.label,
              icon: option.icon,
              checked: selected.contains(option.kind),
              accent: request.accent,
              textColor: palette.textMuted,
              onChanged: (checked) {
                final next = Set<String>.from(selected);
                if (checked) {
                  next.add(option.kind);
                } else {
                  next.remove(option.kind);
                }
                request.onAdvancedFilterChanged(
                  libraryAddVideoKindFilterId,
                  next,
                );
              },
            ),
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _VideoKindCheckbox extends StatelessWidget {
  const _VideoKindCheckbox({
    required this.label,
    required this.icon,
    required this.checked,
    required this.accent,
    required this.textColor,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool checked;
  final Color accent;
  final Color textColor;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () => onChanged(!checked),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: checked,
                onChanged: (value) => onChanged(value ?? false),
                activeColor: accent,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, size: 14, color: checked ? accent : textColor),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                color: checked ? accent : textColor,
                fontSize: 11,
                fontWeight: checked ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
