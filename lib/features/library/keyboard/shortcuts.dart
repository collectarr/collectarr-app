import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/services.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';

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
    final bindings = <ShortcutActivator, _LibraryShortcutIntent>{};
    void bind(ShortcutActivator activator, VoidCallback? callback,
        {bool whileTyping = true}) {
      if (callback == null) return;
      bindings[activator] = _LibraryShortcutIntent(callback, whileTyping);
    }

    // Ctrl+F / Cmd+F: Focus search
    bind(const SingleActivator(LogicalKeyboardKey.keyF, control: true),
        onSearch);
    // Ctrl+N / Cmd+N: Add new item
    bind(const SingleActivator(LogicalKeyboardKey.keyN, control: true), onAdd);
    // Ctrl+B: Scan barcode
    bind(const SingleActivator(LogicalKeyboardKey.keyB, control: true), onScan);
    // F5 / Ctrl+R: Refresh
    bind(const SingleActivator(LogicalKeyboardKey.f5), onRefresh);
    bind(const SingleActivator(LogicalKeyboardKey.keyR, control: true),
        onRefresh);
    // Escape: Clear selection / close panels
    bind(const SingleActivator(LogicalKeyboardKey.escape), onEscape);
    // Ctrl+I: Toggle inspector/details panel
    bind(const SingleActivator(LogicalKeyboardKey.keyI, control: true),
        onToggleInspector);
    // These keys also edit text, so a focused text field keeps them: K and J
    // type letters in the search box, Ctrl+A selects its text.
    // Ctrl+A: Select all
    bind(const SingleActivator(LogicalKeyboardKey.keyA, control: true),
        onSelectAll,
        whileTyping: false);
    // Delete: Remove selected item
    bind(const SingleActivator(LogicalKeyboardKey.delete), onDelete,
        whileTyping: false);
    // Arrow Down / J: Next item
    bind(const SingleActivator(LogicalKeyboardKey.arrowDown), onNextItem,
        whileTyping: false);
    bind(const SingleActivator(LogicalKeyboardKey.keyJ), onNextItem,
        whileTyping: false);
    // Arrow Up / K: Previous item
    bind(const SingleActivator(LogicalKeyboardKey.arrowUp), onPreviousItem,
        whileTyping: false);
    bind(const SingleActivator(LogicalKeyboardKey.keyK), onPreviousItem,
        whileTyping: false);

    return Shortcuts(
      shortcuts: bindings,
      child: Actions(
        actions: {_LibraryShortcutIntent: _LibraryShortcutAction()},
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}

final class _LibraryShortcutIntent extends Intent {
  const _LibraryShortcutIntent(this.callback, this.whileTyping);
  final VoidCallback callback;
  final bool whileTyping;
}

/// Runs a shortcut, except one that would steal a key from a focused text
/// field: that shortcut is disabled so the key reaches the field.
final class _LibraryShortcutAction extends Action<_LibraryShortcutIntent> {
  @override
  bool isEnabled(_LibraryShortcutIntent intent) =>
      intent.whileTyping || !_isTyping();

  static bool _isTyping() {
    final context = FocusManager.instance.primaryFocus?.context;
    if (context == null) return false;
    return context.widget is EditableText ||
        context.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  @override
  void invoke(_LibraryShortcutIntent intent) => intent.callback();
}

/// A help dialog showing available keyboard shortcuts.
void showKeyboardShortcutsDialog(BuildContext context) {
  showAppDialog<void>(
    context: context,
    builder: (_) => const _KeyboardShortcutsDialog(),
  );
}

class _KeyboardShortcutsDialog extends StatelessWidget {
  const _KeyboardShortcutsDialog();

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return AccentAlertDialog(
      backgroundColor: palette.panel,
      titlePadding: EdgeInsets.zero,
      title: const AccentDialogHeader(
        title: 'Keyboard Shortcuts',
        icon: Icons.keyboard,
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _shortcutRow(context, 'Search', [
              ['Ctrl', 'F']
            ]),
            _shortcutRow(context, 'Add item', [
              ['Ctrl', 'N']
            ]),
            _shortcutRow(context, 'Scan barcode', [
              ['Ctrl', 'B']
            ]),
            _shortcutRow(context, 'Refresh', [
              ['F5'],
              ['Ctrl', 'R']
            ]),
            _shortcutRow(context, 'Select all', [
              ['Ctrl', 'A']
            ]),
            _shortcutRow(context, 'Clear / Close', [
              ['Esc']
            ]),
            _shortcutRow(context, 'Remove item', [
              ['Del']
            ]),
            _shortcutRow(context, 'Next item', [
              [Icons.arrow_downward],
              ['J']
            ]),
            _shortcutRow(context, 'Previous item', [
              [Icons.arrow_upward],
              ['K']
            ]),
            _shortcutRow(context, 'Toggle inspector', [
              ['Ctrl', 'I']
            ]),
          ],
        ),
      ),
      actions: [
        DialogActionButton(
          label: 'Close',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  /// One shortcut: each alternative is a chord of key caps, a [String] label
  /// or an [IconData] glyph.
  Widget _shortcutRow(
      BuildContext context, String description, List<List<Object>> chords) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              child: Text(description,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w400))),
          for (var i = 0; i < chords.length; i++) ...[
            if (i > 0)
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text('or',
                      style:
                          TextStyle(fontSize: 12, color: palette.textMuted))),
            for (var k = 0; k < chords[i].length; k++) ...[
              if (k > 0)
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Text('+',
                        style:
                            TextStyle(fontSize: 12, color: palette.textMuted))),
              _KeyCap(chords[i][k]),
            ],
          ],
        ],
      ),
    );
  }
}

/// A raised key cap showing a key name or an arrow glyph.
class _KeyCap extends StatelessWidget {
  const _KeyCap(this.keyLabel);

  final Object keyLabel;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final border = palette.isDark ? const Color(0xFF666666) : palette.divider;
    return Container(
      constraints: const BoxConstraints(minWidth: 26, minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.isDark ? const Color(0xFF444444) : palette.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border(
          left: BorderSide(color: border),
          top: BorderSide(color: border),
          right: BorderSide(color: border),
          bottom: BorderSide(color: border, width: 2),
        ),
      ),
      child: keyLabel is IconData
          ? Icon(keyLabel as IconData, size: 14, color: palette.textPrimary)
          : Text(keyLabel as String,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: palette.textPrimary)),
    );
  }
}
