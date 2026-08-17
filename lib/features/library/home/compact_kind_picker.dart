import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/home/home_catalog.dart';
import 'package:collectarr_app/features/library/home/home_counts.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A touch-friendly, compact kind picker designed for mobile and compact window sizes.
class CompactLibraryKindPicker extends StatelessWidget {
  const CompactLibraryKindPicker({
    super.key,
    required this.types,
    required this.counts,
    required this.registry,
    required this.selectedKind,
    required this.onSelected,
  });

  final List<CatalogMediaType> types;
  final Map<String, LibraryKindCount> counts;
  final LibraryTypeRegistry registry;
  final String selectedKind;
  final ValueChanged<CatalogMediaType> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = selectedLibraryHomeType(types, selectedKind);
    final count = counts[selected.kind]?.owned ?? 0;
    final icon = registry.byKind(selected.mediaKind)?.workspace.icon ??
        libraryIconForKind(selected.mediaKind);
    final palette = appPalette(context);
    final accentData = LibraryAccentScope.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showKindPickerSheet(context),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: accentData.accent
                .withValues(alpha: palette.isDark ? 0.16 : 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: accentData.accent
                  .withValues(alpha: palette.isDark ? 0.35 : 0.22),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: accentData.accent),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  selected.pluralLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: accentData.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: accentData.accent,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Icon(Icons.unfold_more, size: 16, color: palette.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  void _showKindPickerSheet(BuildContext context) {
    final palette = appPalette(context);
    final selected = selectedLibraryHomeType(types, selectedKind);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'Switch Library',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: types.length,
                    itemBuilder: (ctx, index) {
                      final itemType = types[index];
                      final isCurrent = itemType.kind == selected.kind;
                      final icon =
                          registry.byKind(itemType.mediaKind)?.workspace.icon ??
                              libraryIconForKind(itemType.mediaKind);
                      final count = counts[itemType.kind]?.owned ?? 0;
                      final kindAccent =
                          libraryAccentForKind(itemType.mediaKind);

                      return ListTile(
                        key: ValueKey('kind_picker_item_${itemType.kind}'),
                        leading: Icon(
                          icon,
                          color: isCurrent ? kindAccent : palette.textMuted,
                          size: 20,
                        ),
                        title: Text(
                          itemType.pluralLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isCurrent ? FontWeight.w800 : FontWeight.w600,
                            color: isCurrent ? kindAccent : palette.textPrimary,
                          ),
                        ),
                        trailing: count > 0
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: (isCurrent
                                          ? kindAccent
                                          : palette.textMuted)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isCurrent
                                        ? kindAccent
                                        : palette.textMuted,
                                  ),
                                ),
                              )
                            : null,
                        selected: isCurrent,
                        selectedTileColor: kindAccent.withValues(alpha: 0.08),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          if (!isCurrent) {
                            onSelected(itemType);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
