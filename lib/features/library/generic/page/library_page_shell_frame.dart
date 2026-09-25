import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/keyboard/library_keyboard_shortcuts.dart';
import 'package:flutter/material.dart';

class LibraryPageShellFrame extends StatelessWidget {
  const LibraryPageShellFrame({
    super.key,
    required this.topBar,
    required this.toolbar,
    required this.content,
    required this.bottomBar,
    required this.accent,
    required this.showAddButton,
    required this.isScanningCover,
    required this.onAdd,
    required this.onEscape,
    this.onSelectAll,
    this.onDelete,
    this.onNextItem,
    this.onPreviousItem,
  });

  final Widget topBar;
  final Widget toolbar;
  final Widget content;
  final Widget bottomBar;
  final Color accent;
  final bool showAddButton;
  final bool isScanningCover;
  final VoidCallback onAdd;
  final VoidCallback onEscape;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDelete;
  final VoidCallback? onNextItem;
  final VoidCallback? onPreviousItem;

  @override
  Widget build(BuildContext context) {
    return LibraryKeyboardShortcuts(
      onSelectAll: onSelectAll,
      onDelete: onDelete,
      onNextItem: onNextItem,
      onPreviousItem: onPreviousItem,
      onEscape: onEscape,
      child: Scaffold(
        backgroundColor: appPalette(context).canvas,
        floatingActionButton: showAddButton
            ? FloatingActionButton(
                onPressed: onAdd,
                backgroundColor: libraryAccentActionColor(accent),
                child: Icon(
                  Icons.add,
                  color:
                      appContrastingTextColor(libraryAccentActionColor(accent)),
                ),
              )
            : null,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  topBar,
                  toolbar,
                  Expanded(child: content),
                  bottomBar,
                ],
              ),
              if (isScanningCover)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: ColoredBox(
                      color: appPalette(context).panel.withValues(alpha: 0.48),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
