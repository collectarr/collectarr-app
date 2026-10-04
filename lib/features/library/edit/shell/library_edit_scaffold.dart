import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_tab_strip.dart';
import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_action_footer.dart';
import 'package:collectarr_app/features/library/ui/library_dialog_scaffold.dart';
import 'package:collectarr_app/features/library/ui/library_panel_header.dart';
import 'package:collectarr_app/ui/adaptive/window_class.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show listEquals;

enum LibraryEditChromeVariant {
  standard,
  movieDesktop,
}

class LibraryEditDialogScaffold extends StatefulWidget {
  const LibraryEditDialogScaffold({
    super.key,
    required this.formKey,
    required this.accent,
    required this.icon,
    required this.title,
    required this.badges,
    this.tabController,
    this.tabs = const [],
    this.tabIds = const [],
    this.views = const [],
    this.body,
    this.footerContent,
    this.footerOverride,
    this.isBusy = false,
    required this.onClose,
    required this.onCancel,
    required this.onSave,
    this.onProposeToCore,
    this.onPrevious,
    this.onNext,
    this.chromeVariant = LibraryEditChromeVariant.standard,
    this.allowTabReorder = true,
    this.tabOrderKey,
  }) : assert(
          body != null ||
              (tabController != null &&
                  tabs.length > 0 &&
                  tabs.length == views.length),
          'Provide either a custom body or a tab controller with matching tabs and views.',
        );

  final GlobalKey<FormState> formKey;
  final Color accent;
  final IconData icon;
  final String title;
  final List<Widget> badges;
  final TabController? tabController;
  final List<Widget> tabs;

  /// Stable identities in the same source order as [tabs].
  final List<String> tabIds;
  final List<Widget> views;
  final Widget? body;
  final Widget? footerContent;

  /// Replaces the standard Edit actions while retaining the shared dialog
  /// footer slot and layout.
  final Widget? footerOverride;
  final bool isBusy;
  final VoidCallback onClose;
  final VoidCallback onCancel;
  final VoidCallback? onSave;
  final VoidCallback? onProposeToCore;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final LibraryEditChromeVariant chromeVariant;
  final bool allowTabReorder;

  /// If non-null, the tab order is persisted to SharedPreferences under this key.
  final String? tabOrderKey;

  @override
  State<LibraryEditDialogScaffold> createState() =>
      _LibraryEditDialogScaffoldState();
}

class _LibraryEditDialogScaffoldState extends State<LibraryEditDialogScaffold> {
  late List<int> _tabOrder;
  TabController? _observedTabController;

  @override
  void initState() {
    super.initState();
    _tabOrder = List.generate(widget.tabs.length, (i) => i);
    _observeTabController(widget.tabController);
    if (widget.allowTabReorder && widget.tabs.isNotEmpty) {
      _loadSavedTabOrder();
    }
  }

  void _observeTabController(TabController? controller) {
    _observedTabController?.removeListener(_rememberSelectedTab);
    _observedTabController = controller;
    if (controller == null) return;

    _restoreSelectedTab(controller);
    controller.addListener(_rememberSelectedTab);
    _rememberSelectedTab();
  }

  void _restoreSelectedTab(TabController controller) {
    final savedTabId = loadLibraryEditTabSelection(widget.tabOrderKey);
    if (savedTabId == null || controller.length == 0 || widget.tabIds.isEmpty) {
      return;
    }
    final sourceIndex = widget.tabIds.indexOf(savedTabId);
    if (sourceIndex < 0) {
      controller.index = 0;
      return;
    }
    final visibleIndex = _tabOrder.indexOf(sourceIndex);
    controller.index = (visibleIndex < 0 ? 0 : visibleIndex)
        .clamp(0, controller.length - 1)
        .toInt();
  }

  void _rememberSelectedTab() {
    final controller = _observedTabController;
    if (controller == null ||
        controller.length == 0 ||
        controller.index >= _tabOrder.length) {
      return;
    }
    final sourceIndex = _tabOrder[controller.index];
    if (sourceIndex < 0 || sourceIndex >= widget.tabIds.length) return;
    saveLibraryEditTabSelection(
      storageKey: widget.tabOrderKey,
      tabId: widget.tabIds[sourceIndex],
    );
  }

  Future<void> _loadSavedTabOrder() async {
    final order = await loadLibraryEditTabOrder(
      storageKey: widget.tabOrderKey,
      tabCount: widget.tabs.length,
    );
    if (!mounted || order == null) return;
    setState(() => _tabOrder = order);
    final controller = widget.tabController;
    if (controller != null) _restoreSelectedTab(controller);
  }

  Future<void> _saveTabOrder() async {
    await saveLibraryEditTabOrder(
      storageKey: widget.tabOrderKey,
      order: _tabOrder,
    );
  }

  @override
  void didUpdateWidget(LibraryEditDialogScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabController != widget.tabController ||
        oldWidget.tabOrderKey != widget.tabOrderKey ||
        !listEquals(oldWidget.tabIds, widget.tabIds)) {
      _observeTabController(widget.tabController);
    }
    if (!widget.allowTabReorder) {
      _tabOrder = List.generate(widget.tabs.length, (i) => i);
      return;
    }
    if (widget.tabs.length != _tabOrder.length) {
      _tabOrder = List.generate(widget.tabs.length, (i) => i);
      final controller = widget.tabController;
      if (controller != null) _restoreSelectedTab(controller);
    }
  }

  void _onReorderItem(int oldIndex, int newIndex) {
    final controller = widget.tabController;
    final selectedSourceIndex = controller == null || _tabOrder.isEmpty
        ? null
        : _tabOrder[controller.index];
    setState(() {
      final item = _tabOrder.removeAt(oldIndex);
      _tabOrder.insert(newIndex, item);
    });
    if (controller != null && selectedSourceIndex != null) {
      final remappedIndex = _tabOrder.indexOf(selectedSourceIndex);
      if (remappedIndex >= 0 && remappedIndex != controller.index) {
        controller.animateTo(remappedIndex);
      }
    }
    _rememberSelectedTab();
    _saveTabOrder();
  }

  @override
  void dispose() {
    _observedTabController?.removeListener(_rememberSelectedTab);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWideDesktop =
        widget.chromeVariant == LibraryEditChromeVariant.movieDesktop;
    final hasTabStrip = widget.body == null;
    final tabOrder = widget.allowTabReorder
        ? _tabOrder
        : List<int>.generate(widget.tabs.length, (i) => i);
    final orderedTabs = [
      for (final i in tabOrder)
        KeyedSubtree(
          key: ValueKey<String>('library-edit-tab-$i'),
          child: widget.tabs[i],
        ),
    ];
    final orderedViews = [for (final i in tabOrder) widget.views[i]];
    final viewport = MediaQuery.sizeOf(context);
    final windowClass = AppWindowClass.of(context);
    final maxWidth = isWideDesktop
        ? (viewport.width > 1440 ? 1220.0 : 1140.0)
        : (viewport.width > 1440 ? 1180.0 : 1100.0);
    final maxHeight = viewport.height > 900 ? 850.0 : viewport.height - 24;
    final p = appPalette(context);
    return Theme(
      data: editDialogTheme(
        seedColor: widget.accent,
        palette: p,
        compactDesktop: isWideDesktop,
      ),
      child: LibraryDialogScaffold(
        header: _LibraryEditTitleBar(
          icon: widget.icon,
          title: widget.title,
          badges: widget.badges,
          onClose: widget.onClose,
          chromeVariant: widget.chromeVariant,
          accent: widget.accent,
          isBusy: widget.isBusy,
        ),
        footer: widget.footerOverride ??
            _LibraryEditFooter(
              onCancel: widget.onCancel,
              onSave: widget.onSave,
              onProposeToCore: widget.onProposeToCore,
              onPrevious: widget.onPrevious,
              onNext: widget.onNext,
              chromeVariant: widget.chromeVariant,
              accent: widget.accent,
              isBusy: widget.isBusy,
            ),
        maxWidth: maxWidth,
        minHeight: 0,
        maxHeight: maxHeight,
        alignment: Alignment.topCenter,
        insetPadding: EdgeInsets.fromLTRB(
          windowClass.isMedium ? 16 : 32,
          8,
          windowClass.isMedium ? 16 : 32,
          16,
        ),
        density: LibraryDensity.comfortable,
        expandBody: false,
        body: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Form(
            key: widget.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasTabStrip)
                  LibraryEditTabStripFrame(
                    child: LibraryEditReorderableTabStrip(
                      tabController: widget.tabController!,
                      tabs: orderedTabs,
                      accent: widget.accent,
                      allowReorder: widget.allowTabReorder && !widget.isBusy,
                      onReorderItem: _onReorderItem,
                    ),
                  ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Material(
                    color: p.surfaceBright,
                    child: hasTabStrip
                        ? AnimatedBuilder(
                            animation: widget.tabController!,
                            builder: (context, _) {
                              final rawIndex = widget.tabController!.index;
                              final currentIndex = rawIndex < 0
                                  ? 0
                                  : rawIndex >= orderedViews.length
                                      ? orderedViews.length - 1
                                      : rawIndex;
                              return orderedViews[currentIndex];
                            },
                          )
                        : widget.body!,
                  ),
                ),
                if (widget.footerContent != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    decoration: BoxDecoration(
                      color: p.panelRaised,
                      border: Border(
                        top: BorderSide(color: p.divider),
                      ),
                    ),
                    child: widget.footerContent!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LibraryEditTitleBar extends StatelessWidget {
  const _LibraryEditTitleBar({
    required this.icon,
    required this.title,
    required this.badges,
    required this.onClose,
    required this.chromeVariant,
    required this.accent,
    required this.isBusy,
  });

  final IconData icon;
  final String title;
  final List<Widget> badges;
  final VoidCallback onClose;
  final LibraryEditChromeVariant chromeVariant;
  final Color accent;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final isWideDesktop =
        chromeVariant == LibraryEditChromeVariant.movieDesktop;
    final headerMinHeight = 38.0;
    final foreground = appContrastingTextColor(accent);
    return LibraryPanelHeader(
      backgroundColor: accent,
      foregroundColor: foreground,
      borderColor: accent.withValues(alpha: 0.92),
      onClose: isBusy ? null : onClose,
      minHeight: headerMinHeight,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: Row(
        children: [
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
                    fontWeight: FontWeight.w700,
                    fontSize: isWideDesktop ? 16 : 18,
                    color: foreground,
                  ),
                ),
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: badges,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryEditFooter extends StatelessWidget {
  const _LibraryEditFooter({
    required this.onCancel,
    required this.onSave,
    this.onProposeToCore,
    this.onPrevious,
    this.onNext,
    required this.chromeVariant,
    required this.accent,
    required this.isBusy,
  });
  final VoidCallback onCancel;
  final VoidCallback? onSave;
  final VoidCallback? onProposeToCore;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final LibraryEditChromeVariant chromeVariant;
  final Color accent;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final isWideDesktop =
        chromeVariant == LibraryEditChromeVariant.movieDesktop;
    final navButtonStyle = OutlinedButton.styleFrom(
      shape: kLibraryDialogFooterButtonShape,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      minimumSize: const Size(100, kLibraryDialogFooterButtonHeight),
      visualDensity: VisualDensity.compact,
    );
    final compactIconButtonStyle = OutlinedButton.styleFrom(
      shape: kLibraryDialogFooterButtonShape,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      minimumSize: const Size(44, kLibraryDialogFooterButtonHeight),
      visualDensity: VisualDensity.compact,
    );
    final windowClass = AppWindowClass.of(context);
    final proposalBackground = Color.alphaBlend(
      accent.withValues(alpha: 0.18),
      Colors.white,
    );
    final showNav =
        !windowClass.isCompact || onPrevious != null || onNext != null;

    final footerContent = Row(
      mainAxisSize: windowClass.isCompact ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (showNav) ...[
          SizedBox(
            width: isWideDesktop || windowClass.isCompact ? 44 : 100,
            child: isWideDesktop || windowClass.isCompact
                ? OutlinedButton(
                    style: compactIconButtonStyle,
                    onPressed: onPrevious,
                    child: const Icon(Icons.chevron_left, size: 16),
                  )
                : OutlinedButton.icon(
                    style: navButtonStyle,
                    onPressed: onPrevious,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Previous'),
                  ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: isWideDesktop || windowClass.isCompact ? 44 : 100,
            child: isWideDesktop || windowClass.isCompact
                ? OutlinedButton(
                    style: compactIconButtonStyle,
                    onPressed: onNext,
                    child: const Icon(Icons.chevron_right, size: 16),
                  )
                : OutlinedButton(
                    style: navButtonStyle,
                    onPressed: onNext,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Next'),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
          ),
        ],
        if (!windowClass.isCompact) const Spacer(),
        if (onProposeToCore != null) ...[
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              shape: kLibraryDialogFooterButtonShape,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              minimumSize: const Size(0, kLibraryDialogFooterButtonHeight),
              visualDensity: VisualDensity.compact,
            ),
            onPressed: isBusy ? null : onProposeToCore,
            icon: const Icon(Icons.cloud_upload_outlined, size: 17),
            label: const Text('Propose to Core'),
          ),
          const SizedBox(width: 8),
        ],
        SizedBox(
          width: isWideDesktop ? 44 : (windowClass.isCompact ? 92 : 100),
          child: OutlinedButton(
            style: isWideDesktop
                ? compactIconButtonStyle
                : OutlinedButton.styleFrom(
                    shape: kLibraryDialogFooterButtonShape,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    minimumSize: Size(windowClass.isCompact ? 92 : 100,
                        kLibraryDialogFooterButtonHeight),
                    visualDensity: VisualDensity.compact,
                  ),
            onPressed: isBusy ? null : onCancel,
            child: isWideDesktop
                ? const Icon(Icons.close, size: 16)
                : const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: windowClass.isCompact ? 96 : 100,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF5EB1DE),
              foregroundColor: isWideDesktop
                  ? appContrastingTextColor(proposalBackground)
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              minimumSize: Size(windowClass.isCompact ? 96 : 112,
                  kLibraryDialogFooterButtonHeight),
              shape: kLibraryDialogFooterButtonShape,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
              visualDensity: VisualDensity.compact,
            ),
            onPressed: isBusy ? null : onSave,
            child: const Text('Save'),
          ),
        ),
      ],
    );

    return LibraryActionFooter(
      backgroundColor: appPalette(context).toolbar,
      borderColor: appPalette(context).divider,
      child: windowClass.isCompact
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: footerContent,
            )
          : footerContent,
    );
  }
}
