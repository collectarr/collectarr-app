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
  });

  final String label;
  final IconData icon;
  final VoidCallback? onSelected;
  final bool enabled;
  final Widget? trailing;
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
  });

  final List<LibraryUtilityQuickView<T>> quickViews;
  final T? selectedQuickView;
  final ValueChanged<T> onQuickViewSelected;
  final List<LibraryUtilityMenuAction> actions;
  final int badgeCount;
  final String tooltip;
  final IconData defaultIcon;

  @override
  Widget build(BuildContext context) {
    final selected = _selectedQuickView();
    return Badge(
      isLabelVisible: badgeCount > 0,
      label: Text(badgeCount.toString()),
      child: PopupMenuButton<Object>(
        tooltip: tooltip,
        icon: Icon(selected?.icon ?? defaultIcon, size: 18),
        onSelected: _handleSelected,
        itemBuilder: (context) => [
          if (quickViews.isNotEmpty) ...[
            const PopupMenuItem<Object>(
              enabled: false,
              child: Text('Quick views'),
            ),
            for (final view in quickViews)
              PopupMenuItem<Object>(
                value: _LibraryUtilityQuickViewSelection<T>(view.value),
                child: ListTile(
                  dense: true,
                  leading: Icon(view.icon),
                  title: Text(view.label),
                  trailing: selectedQuickView == view.value
                      ? const Icon(Icons.check, size: 18)
                      : null,
                ),
              ),
            const PopupMenuDivider(),
          ],
          for (final action in actions)
            PopupMenuItem<Object>(
              value: action,
              enabled: action.enabled && action.onSelected != null,
              child: ListTile(
                dense: true,
                leading: Icon(action.icon),
                title: Text(action.label),
                trailing: action.trailing,
              ),
            ),
        ],
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
