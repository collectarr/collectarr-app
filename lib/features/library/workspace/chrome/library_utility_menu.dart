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
      largeSize: 14,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      label: Text(
        badgeCount.toString(),
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
      ),
      child: PopupMenuButton<Object>(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 30, height: 30),
        icon: Icon(selected?.icon ?? defaultIcon, size: 17),
        onSelected: _handleSelected,
        itemBuilder: (context) => [
          if (quickViews.isNotEmpty) ...[
            const PopupMenuItem<Object>(
              enabled: false,
              height: 28,
              child: Text('Quick views'),
            ),
            for (final view in quickViews)
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
            const PopupMenuDivider(),
          ],
          for (final action in actions)
            PopupMenuItem<Object>(
              value: action,
              enabled: action.enabled && action.onSelected != null,
              height: 34,
              child: ListTile(
                dense: true,
                minLeadingWidth: 18,
                horizontalTitleGap: 8,
                leading: Icon(action.icon, size: 18),
                title: Text(action.label, style: const TextStyle(fontSize: 13)),
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
