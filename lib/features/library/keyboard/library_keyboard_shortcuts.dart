import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Defines the keyboard shortcuts available in the library view.
/// Wrap this around the library page to enable shortcuts.
class LibraryKeyboardShortcuts extends StatelessWidget {
  const LibraryKeyboardShortcuts({
    super.key,
    required this.child,
    this.onSearch,
    this.onAdd,
    this.onScan,
    this.onRefresh,
    this.onSelectAll,
    this.onEscape,
    this.onDelete,
    this.onNextItem,
    this.onPreviousItem,
    this.onToggleInspector,
  });

  final Widget child;
  final VoidCallback? onSearch;
  final VoidCallback? onAdd;
  final VoidCallback? onScan;
  final VoidCallback? onRefresh;
  final VoidCallback? onSelectAll;
  final VoidCallback? onEscape;
  final VoidCallback? onDelete;
  final VoidCallback? onNextItem;
  final VoidCallback? onPreviousItem;
  final VoidCallback? onToggleInspector;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        // Ctrl+F / Cmd+F: Focus search
        if (onSearch != null)
          const SingleActivator(LogicalKeyboardKey.keyF, control: true):
              onSearch!,
        // Ctrl+N / Cmd+N: Add new item
        if (onAdd != null)
          const SingleActivator(LogicalKeyboardKey.keyN, control: true):
              onAdd!,
        // Ctrl+B: Scan barcode
        if (onScan != null)
          const SingleActivator(LogicalKeyboardKey.keyB, control: true):
              onScan!,
        // F5 / Ctrl+R: Refresh
        if (onRefresh != null) ...<ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.f5): onRefresh!,
          const SingleActivator(LogicalKeyboardKey.keyR, control: true):
              onRefresh!,
        },
        // Ctrl+A: Select all
        if (onSelectAll != null)
          const SingleActivator(LogicalKeyboardKey.keyA, control: true):
              onSelectAll!,
        // Escape: Clear selection / close panels
        if (onEscape != null)
          const SingleActivator(LogicalKeyboardKey.escape): onEscape!,
        // Delete: Remove selected item
        if (onDelete != null)
          const SingleActivator(LogicalKeyboardKey.delete): onDelete!,
        // Arrow Down / J: Next item
        if (onNextItem != null) ...<ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.arrowDown): onNextItem!,
          const SingleActivator(LogicalKeyboardKey.keyJ): onNextItem!,
        },
        // Arrow Up / K: Previous item
        if (onPreviousItem != null) ...<ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.arrowUp): onPreviousItem!,
          const SingleActivator(LogicalKeyboardKey.keyK): onPreviousItem!,
        },
        // Ctrl+I: Toggle inspector/details panel
        if (onToggleInspector != null)
          const SingleActivator(LogicalKeyboardKey.keyI, control: true):
              onToggleInspector!,
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}

/// A help dialog showing available keyboard shortcuts.
void showKeyboardShortcutsDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (_) => const _KeyboardShortcutsDialog(),
  );
}

class _KeyboardShortcutsDialog extends StatelessWidget {
  const _KeyboardShortcutsDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Keyboard Shortcuts'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _shortcutRow('Ctrl+F', 'Search'),
            _shortcutRow('Ctrl+N', 'Add item'),
            _shortcutRow('Ctrl+B', 'Scan barcode'),
            _shortcutRow('F5 / Ctrl+R', 'Refresh'),
            _shortcutRow('Ctrl+A', 'Select all'),
            _shortcutRow('Escape', 'Clear / Close'),
            _shortcutRow('Delete', 'Remove item'),
            _shortcutRow('↓ / J', 'Next item'),
            _shortcutRow('↑ / K', 'Previous item'),
            _shortcutRow('Ctrl+I', 'Toggle inspector'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _shortcutRow(String shortcut, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                shortcut,
                style: const TextStyle(
                    fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(description, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
