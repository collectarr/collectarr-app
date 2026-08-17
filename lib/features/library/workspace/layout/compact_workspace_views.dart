import 'package:collectarr_app/ui/adaptive/window_class.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Item tap callback with touch gesture details.
typedef CompactItemTapCallback<T> = void Function(T item);

/// Item selection callback.
typedef CompactItemSelectCallback<T> = void Function(T item, bool selected);

/// Item cover image builder.
typedef CompactItemCoverBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  double width,
  double height,
);

/// Item title builder.
typedef CompactItemTitleBuilder<T> = String Function(T item);

/// Item subtitle / metadata builder.
typedef CompactItemSubtitleBuilder<T> = String? Function(T item);

/// Item ID extractor for selection tracking.
typedef CompactItemIdExtractor<T> = String Function(T item);

/// A touch-optimized responsive List View for mobile and compact viewports.
class CompactWorkspaceListView<T> extends StatelessWidget {
  const CompactWorkspaceListView({
    super.key,
    required this.items,
    required this.titleBuilder,
    this.subtitleBuilder,
    this.coverBuilder,
    this.idExtractor,
    this.onItemTap,
    this.onItemLongPress,
    this.onItemSelect,
    this.selectedIds = const {},
    this.selectionMode = false,
    this.emptyBuilder,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.itemExtent = 68.0,
  });

  final List<T> items;
  final CompactItemTitleBuilder<T> titleBuilder;
  final CompactItemSubtitleBuilder<T>? subtitleBuilder;
  final CompactItemCoverBuilder<T>? coverBuilder;
  final CompactItemIdExtractor<T>? idExtractor;
  final CompactItemTapCallback<T>? onItemTap;
  final CompactItemTapCallback<T>? onItemLongPress;
  final CompactItemSelectCallback<T>? onItemSelect;
  final Set<String> selectedIds;
  final bool selectionMode;
  final WidgetBuilder? emptyBuilder;
  final EdgeInsetsGeometry padding;
  final double itemExtent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accentData = LibraryAccentScope.of(context);

    if (items.isEmpty) {
      return emptyBuilder != null
          ? emptyBuilder!(context)
          : Center(
              child: Text(
                'No items found',
                style: TextStyle(color: palette.textMuted, fontSize: 14),
              ),
            );
    }

    return ListView.separated(
      padding: padding,
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        thickness: 1,
        color: palette.divider,
        indent: coverBuilder != null ? 64 : 16,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final id = idExtractor != null ? idExtractor!(item) : index.toString();
        final isSelected = selectedIds.contains(id);
        final title = titleBuilder(item);
        final subtitle = subtitleBuilder?.call(item);

        return Material(
          color: isSelected
              ? accentData.accent
                  .withValues(alpha: palette.isDark ? 0.22 : 0.12)
              : Colors.transparent,
          child: InkWell(
            onTap: () {
              if (selectionMode) {
                onItemSelect?.call(item, !isSelected);
              } else {
                onItemTap?.call(item);
              }
            },
            onLongPress: () {
              onItemLongPress?.call(item);
            },
            child: SizedBox(
              height: itemExtent,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    if (selectionMode) ...[
                      Checkbox(
                        value: isSelected,
                        activeColor: accentData.accent,
                        visualDensity: VisualDensity.compact,
                        onChanged: (val) =>
                            onItemSelect?.call(item, val ?? false),
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (coverBuilder != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: coverBuilder!(context, item, 40, 56),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? accentData.accent
                                  : palette.textPrimary,
                            ),
                          ),
                          if (subtitle != null && subtitle.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: palette.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: palette.textMuted.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A touch-optimized responsive Grid View for mobile and compact viewports.
class CompactWorkspaceGridView<T> extends StatelessWidget {
  const CompactWorkspaceGridView({
    super.key,
    required this.items,
    required this.titleBuilder,
    this.subtitleBuilder,
    this.coverBuilder,
    this.idExtractor,
    this.onItemTap,
    this.onItemLongPress,
    this.onItemSelect,
    this.selectedIds = const {},
    this.selectionMode = false,
    this.emptyBuilder,
    this.padding = const EdgeInsets.all(10),
    this.childAspectRatio = 0.68,
    this.spacing = 10.0,
  });

  final List<T> items;
  final CompactItemTitleBuilder<T> titleBuilder;
  final CompactItemSubtitleBuilder<T>? subtitleBuilder;
  final CompactItemCoverBuilder<T>? coverBuilder;
  final CompactItemIdExtractor<T>? idExtractor;
  final CompactItemTapCallback<T>? onItemTap;
  final CompactItemTapCallback<T>? onItemLongPress;
  final CompactItemSelectCallback<T>? onItemSelect;
  final Set<String> selectedIds;
  final bool selectionMode;
  final WidgetBuilder? emptyBuilder;
  final EdgeInsetsGeometry padding;
  final double childAspectRatio;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accentData = LibraryAccentScope.of(context);
    final windowClass = AppWindowClass.of(context);

    if (items.isEmpty) {
      return emptyBuilder != null
          ? emptyBuilder!(context)
          : Center(
              child: Text(
                'No items found',
                style: TextStyle(color: palette.textMuted, fontSize: 14),
              ),
            );
    }

    final crossAxisCount = switch (windowClass.widthClass) {
      WindowWidthClass.compact => 2,
      WindowWidthClass.medium => 3,
      WindowWidthClass.expanded => 4,
      WindowWidthClass.large => 5,
      WindowWidthClass.extraLarge => 6,
    };

    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final id = idExtractor != null ? idExtractor!(item) : index.toString();
        final isSelected = selectedIds.contains(id);
        final title = titleBuilder(item);
        final subtitle = subtitleBuilder?.call(item);

        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: isSelected ? 3 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? accentData.accent : palette.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          color: isSelected
              ? accentData.accent
                  .withValues(alpha: palette.isDark ? 0.22 : 0.12)
              : palette.surface,
          child: InkWell(
            onTap: () {
              if (selectionMode) {
                onItemSelect?.call(item, !isSelected);
              } else {
                onItemTap?.call(item);
              }
            },
            onLongPress: () {
              onItemLongPress?.call(item);
            },
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: coverBuilder != null
                          ? coverBuilder!(
                              context, item, double.infinity, double.infinity)
                          : Container(
                              color: palette.surfaceSubtle,
                              child: Center(
                                child: Icon(
                                  Icons.image,
                                  size: 32,
                                  color: palette.textMuted,
                                ),
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? accentData.accent
                                  : palette.textPrimary,
                            ),
                          ),
                          if (subtitle != null && subtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: palette.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (selectionMode)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: palette.surface.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Checkbox(
                        value: isSelected,
                        activeColor: accentData.accent,
                        visualDensity: VisualDensity.compact,
                        shape: const CircleBorder(),
                        onChanged: (val) =>
                            onItemSelect?.call(item, val ?? false),
                      ),
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
