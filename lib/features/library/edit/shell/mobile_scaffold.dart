import 'dart:math' as math;

import 'package:collectarr_app/ui/app_bottom_sheet.dart';
import 'package:collectarr_app/ui/adaptive/mobile_page.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';

/// Provides the active editor header tabs notifier to descendants, allowing
/// embedded schema renderers to hoist their tab strip directly into the toolbar.
class LibraryMobileEditorHeaderTabsScope extends InheritedWidget {
  const LibraryMobileEditorHeaderTabsScope({
    super.key,
    required this.tabsNotifier,
    required super.child,
  });

  final ValueNotifier<Widget?> tabsNotifier;

  static ValueNotifier<Widget?>? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<LibraryMobileEditorHeaderTabsScope>()
      ?.tabsNotifier;

  @override
  bool updateShouldNotify(LibraryMobileEditorHeaderTabsScope oldWidget) =>
      tabsNotifier != oldWidget.tabsNotifier;
}

/// Native editor chrome around the shared form, tabs and guarded commands.
class LibraryMobileEditorScaffold extends StatefulWidget {
  const LibraryMobileEditorScaffold({
    super.key,
    required this.title,
    required this.accent,
    required this.onBack,
    required this.onSave,
    required this.body,
    this.isBusy = false,
    this.onDelete,
    this.onPropose,
    this.onPrevious,
    this.onNext,
    this.primaryAction,
    this.tabs,
    this.footer,
  });

  final String title;
  final Color accent;
  final VoidCallback onBack;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;
  final VoidCallback? onPropose;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool isBusy;
  final Widget? primaryAction;
  final Widget? tabs;
  final Widget? footer;
  final Widget body;

  @override
  State<LibraryMobileEditorScaffold> createState() =>
      _LibraryMobileEditorScaffoldState();
}

class _LibraryMobileEditorScaffoldState
    extends State<LibraryMobileEditorScaffold> {
  late final _collectionContent = ValueNotifier<Widget?>(widget.footer);
  late final _headerTabs = ValueNotifier<Widget?>(widget.tabs);

  @override
  void didUpdateWidget(LibraryMobileEditorScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabs != null) {
      _headerTabs.value = widget.tabs;
    }
    // The sheet is on another route; update its presentation after the parent
    // frame, while draft values and commands remain owned by the editor.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _collectionContent.value = widget.footer;
    });
  }

  @override
  void dispose() {
    _collectionContent.dispose();
    _headerTabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LibraryMobileEditorScaffold(
      :title,
      :accent,
      :onBack,
      :onSave,
      :onDelete,
      :onPropose,
      :onPrevious,
      :onNext,
      :isBusy,
      :primaryAction,
      :tabs,
      :footer,
      :body
    ) = widget;

    final viewport = MediaQuery.sizeOf(context);
    final isTablet = viewport.width >= 720;

    final page = ValueListenableBuilder<Widget?>(
      valueListenable: _headerTabs,
      builder: (context, headerTabs, _) {
        return MobilePage(
          key: const Key('library.mobile-editor'),
          title: title,
          headerColor: accent,
          backgroundColor: appPalette(context).surfaceBright,
          onBack: onBack,
          canGoBack: !isBusy,
          actions: [
            if (onDelete != null)
              IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.delete_outline),
                onPressed: isBusy ? null : onDelete,
              ),
            if (primaryAction == null || onPrevious != null)
              IconButton(
                tooltip: 'Previous item',
                icon: const Icon(Icons.chevron_left),
                onPressed: (isBusy || onPrevious == null) ? null : onPrevious,
              ),
            if (primaryAction == null || onNext != null)
              IconButton(
                tooltip: 'Next item',
                icon: const Icon(Icons.chevron_right),
                onPressed: (isBusy || onNext == null) ? null : onNext,
              ),
            if (footer != null)
              IconButton(
                tooltip: 'Collection details',
                icon: const Icon(Icons.inventory_2_outlined),
                onPressed:
                    isBusy ? null : () => _showCollectionDetails(context),
              ),
            if (primaryAction != null)
              primaryAction
            else
              TextButton(
                key: const Key('library.mobile-editor.save'),
                onPressed: isBusy ? null : onSave,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(60, 48),
                ),
                child: isBusy
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'DONE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            if (onPropose != null || onPrevious != null || onNext != null)
              PopupMenuButton<VoidCallback>(
                tooltip: 'More editor actions',
                enabled: !isBusy,
                onSelected: (action) => action(),
                itemBuilder: (_) => [
                  if (onPropose != null)
                    PopupMenuItem(
                      value: onPropose,
                      child: const Text('Propose to Core'),
                    ),
                  if (onPrevious != null)
                    PopupMenuItem(
                      value: onPrevious,
                      child: const Text('Previous item'),
                    ),
                  if (onNext != null)
                    PopupMenuItem(
                      value: onNext,
                      child: const Text('Next item'),
                    ),
                ],
              ),
          ],
          contextBar: headerTabs ?? tabs,
          body: LibraryMobileEditorHeaderTabsScope(
            tabsNotifier: _headerTabs,
            child: body,
          ),
        );
      },
    );

    if (!isTablet) return page;

    final cardWidth = math.min(768.0, viewport.width - 32);

    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: SizedBox(
          width: cardWidth,
          height: double.infinity,
          child: page,
        ),
      ),
    );
  }

  void _showCollectionDetails(BuildContext context) {
    FocusScope.of(context).unfocus();
    showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Collection details',
                              style:
                                  Theme.of(sheetContext).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<Widget?>(
                              valueListenable: _collectionContent,
                              builder: (context, content, child) =>
                                  content ?? const SizedBox.shrink()),
                          const SizedBox(height: 16),
                          FilledButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              child: const Text('Done')),
                        ]))),
          )),
    );
  }
}
