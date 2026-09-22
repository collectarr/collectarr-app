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
    this.views = const [],
    this.body,
    this.footerContent,
    required this.onClose,
    required this.onCancel,
    required this.onSave,
    this.onProposeToCore,
    this.onPrevious,
    this.onNext,
    this.chromeVariant = LibraryEditChromeVariant.standard,
    this.allowTabReorder = true,
    this.tabReorderLongPressDelay = kLibraryDialogTabReorderLongPressDelay,
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
  final List<Widget> views;
  final Widget? body;
  final Widget? footerContent;
  final VoidCallback onClose;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final VoidCallback? onProposeToCore;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final LibraryEditChromeVariant chromeVariant;
  final bool allowTabReorder;
  final Duration tabReorderLongPressDelay;

  /// If non-null, the tab order is persisted to SharedPreferences under this key.
  final String? tabOrderKey;

  @override
  State<LibraryEditDialogScaffold> createState() =>
      _LibraryEditDialogScaffoldState();
}

class _LibraryEditDialogScaffoldState extends State<LibraryEditDialogScaffold> {
  late List<int> _tabOrder;

  @override
  void initState() {
    super.initState();
    _tabOrder = List.generate(widget.tabs.length, (i) => i);
    if (widget.allowTabReorder && widget.tabs.isNotEmpty) {
      _loadSavedTabOrder();
    }
  }

  Future<void> _loadSavedTabOrder() async {
    final order = await loadLibraryEditTabOrder(
      storageKey: widget.tabOrderKey,
      tabCount: widget.tabs.length,
    );
    if (!mounted || order == null) return;
    setState(() => _tabOrder = order);
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
    if (!widget.allowTabReorder) {
      _tabOrder = List.generate(widget.tabs.length, (i) => i);
      return;
    }
    if (widget.tabs.length != _tabOrder.length) {
      _tabOrder = List.generate(widget.tabs.length, (i) => i);
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
    _saveTabOrder();
  }

  @override
  Widget build(BuildContext context) {
    final isWideDesktop =
        widget.chromeVariant == LibraryEditChromeVariant.movieDesktop;
    final hasTabStrip = widget.body == null;
    final tabOrder = widget.allowTabReorder
        ? _tabOrder
        : List<int>.generate(widget.tabs.length, (i) => i);
    final orderedTabs = [for (final i in tabOrder) widget.tabs[i]];
    final orderedViews = [for (final i in tabOrder) widget.views[i]];
    final viewport = MediaQuery.sizeOf(context);
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
          accent: widget.accent,
          icon: widget.icon,
          title: widget.title,
          badges: widget.badges,
          onClose: widget.onClose,
          chromeVariant: widget.chromeVariant,
        ),
        footer: _LibraryEditFooter(
          onCancel: widget.onCancel,
          onSave: widget.onSave,
          onProposeToCore: widget.onProposeToCore,
          onPrevious: widget.onPrevious,
          onNext: widget.onNext,
          chromeVariant: widget.chromeVariant,
          accent: widget.accent,
        ),
        maxWidth: maxWidth,
        minHeight: 0,
        maxHeight: maxHeight,
        density: LibraryDensity.comfortable,
        expandBody: false,
        body: AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
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
                        allowReorder: widget.allowTabReorder,
                        longPressDelay: widget.tabReorderLongPressDelay,
                        onReorderItem: _onReorderItem,
                      ),
                    ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Material(
                      color: p.panel,
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
      ),
    );
  }
}

class _LibraryEditTitleBar extends StatelessWidget {
  const _LibraryEditTitleBar({
    required this.accent,
    required this.icon,
    required this.title,
    required this.badges,
    required this.onClose,
    required this.chromeVariant,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final List<Widget> badges;
  final VoidCallback onClose;
  final LibraryEditChromeVariant chromeVariant;

  @override
  Widget build(BuildContext context) {
    final isWideDesktop =
        chromeVariant == LibraryEditChromeVariant.movieDesktop;
    final headerMinHeight = isWideDesktop ? 46.0 : 48.0;
    return LibraryPanelHeader(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      borderColor: accent.withValues(alpha: 0.92),
      onClose: onClose,
      minHeight: headerMinHeight,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
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
                    fontWeight: FontWeight.w800,
                    fontSize: isWideDesktop ? 13 : 13.5,
                    color: Colors.white,
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
  });
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final VoidCallback? onProposeToCore;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final LibraryEditChromeVariant chromeVariant;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isWideDesktop =
        chromeVariant == LibraryEditChromeVariant.movieDesktop;
    final navButtonStyle = OutlinedButton.styleFrom(
      shape: kLibraryDialogFooterButtonShape,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      minimumSize: const Size(112, kLibraryDialogFooterButtonHeight),
      visualDensity: VisualDensity.compact,
    );
    final compactIconButtonStyle = OutlinedButton.styleFrom(
      shape: kLibraryDialogFooterButtonShape,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      minimumSize: const Size(44, kLibraryDialogFooterButtonHeight),
      visualDensity: VisualDensity.compact,
    );
    final windowClass = AppWindowClass.of(context);
    final showNav =
        !windowClass.isCompact || onPrevious != null || onNext != null;

    return LibraryActionFooter(
      backgroundColor: appPalette(context).toolbar,
      borderColor: appPalette(context).divider,
      child: Row(
        children: [
          if (showNav) ...[
            SizedBox(
              width: isWideDesktop || windowClass.isCompact ? 44 : 112,
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
              width: isWideDesktop || windowClass.isCompact ? 44 : 112,
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
          const Spacer(),
          if (onProposeToCore != null) ...[
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: kLibraryDialogFooterButtonShape,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                minimumSize: const Size(0, kLibraryDialogFooterButtonHeight),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: onProposeToCore,
              icon: const Icon(Icons.cloud_upload_outlined, size: 17),
              label: const Text('Propose to Core'),
            ),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: isWideDesktop ? 44 : (windowClass.isCompact ? 92 : 112),
            child: OutlinedButton(
              style: isWideDesktop
                  ? compactIconButtonStyle
                  : OutlinedButton.styleFrom(
                      shape: kLibraryDialogFooterButtonShape,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 9),
                      minimumSize: Size(windowClass.isCompact ? 92 : 112,
                          kLibraryDialogFooterButtonHeight),
                      visualDensity: VisualDensity.compact,
                    ),
              onPressed: onCancel,
              child: isWideDesktop
                  ? const Icon(Icons.close, size: 16)
                  : const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: windowClass.isCompact ? 96 : 112,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: isWideDesktop
                    ? Color.alphaBlend(
                        accent.withValues(alpha: 0.18), Colors.white)
                    : accent,
                foregroundColor: isWideDesktop ? Colors.black87 : null,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                minimumSize: Size(windowClass.isCompact ? 96 : 112,
                    kLibraryDialogFooterButtonHeight),
                shape: kLibraryDialogFooterButtonShape,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: onSave,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
