import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/keyboard/shortcuts.dart';
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
    this.addButtonEndInset = 0,
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
  final Widget? bottomBar;
  final Color accent;
  final bool showAddButton;

  /// Keeps the button over the items when a tablet's details pane is beside
  /// them, as in the reference.
  final double addButtonEndInset;
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
        resizeToAvoidBottomInset: !appPresentationPlatform.isNativeMobile,
        backgroundColor: appPalette(context).canvas,
        bottomNavigationBar:
            bottomBar == null ? null : SafeArea(top: false, child: bottomBar!),
        floatingActionButton: showAddButton
            ? Padding(
                padding: EdgeInsetsDirectional.only(end: addButtonEndInset),
                child: FloatingActionButton(
                  heroTag: null,
                  onPressed: onAdd,
                  tooltip: 'Add',
                  shape: const CircleBorder(),
                  backgroundColor: appPalette(context).utilityAction,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Colors.white),
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
