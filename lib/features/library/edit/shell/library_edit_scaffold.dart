import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_tab_strip.dart';
import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_action_footer.dart';
import 'package:collectarr_app/features/library/ui/library_dialog_scaffold.dart';
import 'package:collectarr_app/features/library/ui/library_panel_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final key = widget.tabOrderKey;
    if (key == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final saved = prefs.getStringList(key);
    if (saved != null && saved.length == widget.tabs.length) {
      final parsed = saved.map(int.tryParse).toList();
      if (!parsed.contains(null)) {
        final order = parsed.cast<int>();
        // Validate: must be a permutation of 0..<length.
        final check = List.of(order)..sort();
        if (check.length == widget.tabs.length &&
            check.indexed.every((e) => e.$2 == e.$1)) {
          if (!mounted) return;
          setState(() => _tabOrder = order);
        }
      }
    }
  }

  Future<void> _saveTabOrder() async {
    final key = widget.tabOrderKey;
    if (key == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, _tabOrder.map((e) => e.toString()).toList());
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
    final isMovieDesktop =
        widget.chromeVariant == LibraryEditChromeVariant.movieDesktop;
    final hasTabStrip = widget.body == null;
    final tabOrder = widget.allowTabReorder
        ? _tabOrder
        : List<int>.generate(widget.tabs.length, (i) => i);
    final orderedTabs = [for (final i in tabOrder) widget.tabs[i]];
    final orderedViews = [for (final i in tabOrder) widget.views[i]];
    final viewport = MediaQuery.sizeOf(context);
    final maxWidth = isMovieDesktop
        ? (viewport.width > 1440 ? 1220.0 : 1140.0)
        : (viewport.width > 1440 ? 1180.0 : 1100.0);
    final maxHeight = viewport.height > 900 ? 850.0 : viewport.height - 24;
    final p = appPalette(context);
    return Theme(
      data: editDialogTheme(
        seedColor: widget.accent,
        palette: p,
        compactDesktop: isMovieDesktop,
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
          onPrevious: widget.onPrevious,
          onNext: widget.onNext,
          chromeVariant: widget.chromeVariant,
          accent: widget.accent,
        ),
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        density: LibraryDensity.comfortable,
        expandBody: false,
        child: AnimatedSize(
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
                      child: _ReorderableTabStrip(
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
                    child: ColoredBox(
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

/// A horizontal reorderable tab strip that replaces the standard [TabBar].
///
/// Uses [LongPressDraggable] + [DragTarget] so all tabs are always in the
/// widget tree (unlike [ReorderableListView] which lazily builds items).
class _ReorderableTabStrip extends StatelessWidget {
  const _ReorderableTabStrip({
    required this.tabController,
    required this.tabs,
    required this.accent,
    required this.allowReorder,
    required this.longPressDelay,
    required this.onReorderItem,
  });
  final TabController tabController;
  final List<Widget> tabs;
  final Color accent;
  final bool allowReorder;
  final Duration longPressDelay;
  final void Function(int oldIndex, int newIndex) onReorderItem;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return SizedBox(
          width: double.infinity,
          height: kLibraryEditTabStripHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < tabs.length; i++)
                  allowReorder
                      ? DragTarget<int>(
                          onAcceptWithDetails: (details) {
                            final from = details.data;
                            if (from != i) {
                              onReorderItem(from, i);
                            }
                          },
                          builder: (context, candidateData, _) {
                            return LongPressDraggable<int>(
                              data: i,
                              axis: Axis.horizontal,
                              delay: longPressDelay,
                              feedback: Material(
                                elevation: 2,
                                color: Colors.transparent,
                                child: LibraryEditDraggedTabLabel(
                                  tab: tabs[i],
                                  accent: accent,
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.4,
                                child: LibraryEditDraggedTabLabel(
                                  tab: tabs[i],
                                  accent: accent,
                                  muted: true,
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () => tabController.animateTo(i),
                                child: LibraryEditStyledTabLabel(
                                  tab: tabs[i],
                                  accent: accent,
                                  selected: tabController.index == i,
                                  highlighted: candidateData.isNotEmpty,
                                ),
                              ),
                            );
                          },
                        )
                      : GestureDetector(
                          onTap: () => tabController.animateTo(i),
                          child: LibraryEditStyledTabLabel(
                            tab: tabs[i],
                            accent: accent,
                            selected: tabController.index == i,
                            highlighted: false,
                          ),
                        ),
              ],
            ),
          ),
        );
      },
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
    final isMovieDesktop =
        chromeVariant == LibraryEditChromeVariant.movieDesktop;
    final headerMinHeight = isMovieDesktop ? 46.0 : 48.0;
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
                    fontSize: isMovieDesktop ? 13 : 13.5,
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
    this.onPrevious,
    this.onNext,
    required this.chromeVariant,
    required this.accent,
  });
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final LibraryEditChromeVariant chromeVariant;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isMovieDesktop =
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
    return LibraryActionFooter(
      backgroundColor: appPalette(context).toolbar,
      borderColor: appPalette(context).divider,
      child: Row(
        children: [
          SizedBox(
            width: isMovieDesktop ? 44 : 112,
            child: isMovieDesktop
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
            width: isMovieDesktop ? 44 : 112,
            child: isMovieDesktop
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
          const Spacer(),
          SizedBox(
            width: isMovieDesktop ? 44 : 112,
            child: OutlinedButton(
              style: isMovieDesktop ? compactIconButtonStyle : OutlinedButton.styleFrom(
                shape: kLibraryDialogFooterButtonShape,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                minimumSize: const Size(112, kLibraryDialogFooterButtonHeight),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: onCancel,
              child: isMovieDesktop
                  ? const Icon(Icons.close, size: 16)
                  : const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 112,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: isMovieDesktop
                    ? Color.alphaBlend(
                        accent.withValues(alpha: 0.18), Colors.white)
                    : accent,
                foregroundColor: isMovieDesktop ? Colors.black87 : null,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                minimumSize: const Size(112, kLibraryDialogFooterButtonHeight),
                shape: kLibraryDialogFooterButtonShape,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: onSave,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
