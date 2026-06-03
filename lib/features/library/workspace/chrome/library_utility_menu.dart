import 'package:flutter/material.dart';

class LibraryUtilityQuickView<T> {
  const LibraryUtilityQuickView({
    required this.value,
    required this.label,
    required this.icon,
  });

  final T value;
  final String label;
  final IconData icon;
}

class LibraryUtilityMenuAction {
  const LibraryUtilityMenuAction({
    required this.label,
    required this.icon,
    this.onSelected,
    this.enabled = true,
    this.trailing,
    this.section,
    this.description,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onSelected;
  final bool enabled;
  final Widget? trailing;
  final String? section;
  final String? description;
}

class LibraryUtilityMenu<T> extends StatelessWidget {
  const LibraryUtilityMenu({
    super.key,
    required this.quickViews,
    required this.selectedQuickView,
    required this.onQuickViewSelected,
    required this.actions,
    required this.badgeCount,
    this.tooltip = 'Library tools',
    this.defaultIcon = Icons.tune,
    this.buttonLabel = 'Tools',
    this.quickViewsLabel = 'Quick Views',
  });

  final List<LibraryUtilityQuickView<T>> quickViews;
  final T? selectedQuickView;
  final ValueChanged<T> onQuickViewSelected;
  final List<LibraryUtilityMenuAction> actions;
  final int badgeCount;
  final String tooltip;
  final IconData defaultIcon;
  final String buttonLabel;
  final String quickViewsLabel;

  @override
  Widget build(BuildContext context) {
    final selected = _selectedQuickView();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final trigger = DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colorScheme.surface.withValues(alpha: 0.88),
          colorScheme.surfaceContainerLow,
        ),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected?.icon ?? defaultIcon, size: 15),
            const SizedBox(width: 5),
            Text(
              buttonLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 1),
            Icon(
              Icons.expand_more,
              size: 15,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
    return Badge(
      isLabelVisible: badgeCount > 0,
      largeSize: 14,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      label: Text(
        badgeCount.toString(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
      child: PopupMenuButton<Object>(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        position: PopupMenuPosition.under,
        onSelected: _handleSelected,
        itemBuilder: (context) => _buildMenuItems(context),
        child: trigger,
      ),
    );
  }

  List<PopupMenuEntry<Object>> _buildMenuItems(BuildContext context) {
    final items = <PopupMenuEntry<Object>>[];

    if (quickViews.isNotEmpty) {
      items.add(_buildSectionHeader(quickViewsLabel));
      for (final view in quickViews) {
        items.add(
          PopupMenuItem<Object>(
            value: _LibraryUtilityQuickViewSelection<T>(view.value),
            height: 34,
            child: ListTile(
              dense: true,
              minLeadingWidth: 18,
              horizontalTitleGap: 8,
              leading: Icon(view.icon, size: 18),
              title: Text(view.label, style: const TextStyle(fontSize: 13)),
              trailing: selectedQuickView == view.value
                  ? const Icon(Icons.check, size: 16)
                  : null,
            ),
          ),
        );
      }
    }

    String? currentSection;
    var addedAction = false;
    for (final action in actions) {
      final section = action.section;
      if (section != currentSection) {
        if (items.isNotEmpty) {
          items.add(const PopupMenuDivider(height: 8));
        }
        if (section != null && section.isNotEmpty) {
          items.add(_buildSectionHeader(section));
        }
        currentSection = section;
      }
      items.add(
        PopupMenuItem<Object>(
          value: action,
          enabled: action.enabled && action.onSelected != null,
          height: action.description == null ? 34 : 46,
          child: ListTile(
            dense: true,
            minLeadingWidth: 18,
            horizontalTitleGap: 8,
            leading: Icon(action.icon, size: 18),
            title: Text(action.label, style: const TextStyle(fontSize: 13)),
            subtitle: action.description == null
                ? null
                : Text(
                    action.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                  ),
            trailing: action.trailing,
          ),
        ),
      );
      addedAction = true;
    }

    if (!addedAction && items.isNotEmpty && items.last is PopupMenuDivider) {
      items.removeLast();
    }
    return items;
  }

  PopupMenuEntry<Object> _buildSectionHeader(String label) {
    return PopupMenuItem<Object>(
      enabled: false,
      height: 24,
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.24,
        ),
      ),
    );
  }

  LibraryUtilityQuickView<T>? _selectedQuickView() {
    for (final view in quickViews) {
      if (view.value == selectedQuickView) {
        return view;
      }
    }
    return null;
  }

  void _handleSelected(Object selection) {
    if (selection is _LibraryUtilityQuickViewSelection<T>) {
      onQuickViewSelected(selection.value);
      return;
    }
    if (selection is LibraryUtilityMenuAction) {
      selection.onSelected?.call();
    }
  }
}

class _LibraryUtilityQuickViewSelection<T> {
  const _LibraryUtilityQuickViewSelection(this.value);

  final T value;
}
