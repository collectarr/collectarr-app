import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
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
    required this.onClose,
    required this.onSave,
    this.chromeVariant = LibraryEditChromeVariant.standard,
    this.allowTabReorder = true,
    this.tabOrderKey,
    this.ebaySearchQuery,
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
  final VoidCallback onClose;
  final VoidCallback onSave;
  final LibraryEditChromeVariant chromeVariant;
  final bool allowTabReorder;
  /// If non-null, the tab order is persisted to SharedPreferences under this key.
  final String? tabOrderKey;
  /// If non-null, an eBay search button appears in the title bar.
  final String? ebaySearchQuery;

  @override
  State<LibraryEditDialogScaffold> createState() =>
      _LibraryEditDialogScaffoldState();
}

class _LibraryEditDialogScaffoldState
    extends State<LibraryEditDialogScaffold> {
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
    setState(() {
      final item = _tabOrder.removeAt(oldIndex);
      _tabOrder.insert(newIndex, item);
    });
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
    final viewport = MediaQuery.sizeOf(context);
    final maxWidth = isMovieDesktop
        ? (viewport.width > 1440 ? 1180.0 : 1100.0)
        : (viewport.width > 1440 ? 1120.0 : 1040.0);
    final maxHeight = viewport.height > 900 ? 820.0 : viewport.height - 40;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMovieDesktop ? 2 : 8),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: editDialogTheme(
          seedColor: widget.accent,
          palette: appPalette(context),
          compactDesktop: isMovieDesktop,
        ),
        child: Builder(builder: (context) {
          final p = appPalette(context);
          return DecoratedBox(
            decoration: BoxDecoration(
              color: p.panel,
              border: Border.all(color: p.divider),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xCC000000),
                  blurRadius: 22,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
              child: Form(
                key: widget.formKey,
                child: Column(
                  children: [
                    _LibraryEditTitleBar(
                      accent: widget.accent,
                      icon: widget.icon,
                      title: widget.title,
                      badges: widget.badges,
                      onClose: widget.onClose,
                      chromeVariant: widget.chromeVariant,
                      ebaySearchQuery: widget.ebaySearchQuery,
                    ),
                    if (hasTabStrip)
                      ColoredBox(
                        color: p.panelRaised,
                        child: _ReorderableTabStrip(
                          tabController: widget.tabController!,
                          tabOrder: tabOrder,
                          tabs: orderedTabs,
                          accent: widget.accent,
                          labelColor: p.textPrimary,
                          unselectedLabelColor: p.textMuted,
                          dividerColor: p.divider,
                          allowReorder: widget.allowTabReorder,
                          onReorderItem: _onReorderItem,
                        ),
                      ),
                    Expanded(
                      child: ColoredBox(
                        color: p.panel,
                        child: hasTabStrip
                            ? TabBarView(
                                controller: widget.tabController,
                                children: widget.views,
                              )
                            : widget.body!,
                      ),
                    ),
                    _LibraryEditFooter(
                      onSave: widget.onSave,
                      chromeVariant: widget.chromeVariant,
                      accent: widget.accent,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
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
    required this.tabOrder,
    required this.tabs,
    required this.accent,
    required this.labelColor,
    required this.unselectedLabelColor,
    required this.dividerColor,
    required this.allowReorder,
    required this.onReorderItem,
  });

  final TabController tabController;
  final List<int> tabOrder;
  final List<Widget> tabs;
  final Color accent;
  final Color labelColor;
  final Color unselectedLabelColor;
  final Color dividerColor;
  final bool allowReorder;
  final void Function(int oldIndex, int newIndex) onReorderItem;

  Widget _tabChild({
    required int index,
    required Widget tab,
    required bool selected,
    required bool highlighted,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: highlighted ? accent.withValues(alpha: 0.12) : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: selected ? accent : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: selected ? labelColor : unselectedLabelColor,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
        ),
        child: IconTheme.merge(
          data: IconThemeData(
            color: selected ? labelColor : unselectedLabelColor,
            size: 16,
          ),
          child: tab,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 38,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
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
                              feedback: Material(
                                elevation: 4,
                                color: Colors.transparent,
                                child: _DraggableTabContent(
                                  tab: tabs[i],
                                  accent: accent,
                                  labelColor: labelColor,
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: _DraggableTabContent(
                                  tab: tabs[i],
                                  accent: accent,
                                  labelColor: unselectedLabelColor,
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () => tabController.animateTo(tabOrder[i]),
                                child: _tabChild(
                                  index: i,
                                  tab: tabs[i],
                                  selected: tabController.index == tabOrder[i],
                                  highlighted: candidateData.isNotEmpty,
                                ),
                              ),
                            );
                          },
                        )
                      : GestureDetector(
                          onTap: () => tabController.animateTo(tabOrder[i]),
                          child: _tabChild(
                            index: i,
                            tab: tabs[i],
                            selected: tabController.index == tabOrder[i],
                            highlighted: false,
                          ),
                        ),
              ],
            ),
          ),
        ),
            Divider(height: 1, thickness: 1, color: dividerColor),
          ],
        );
      },
    );
  }
}

class _DraggableTabContent extends StatelessWidget {
  const _DraggableTabContent({
    required this.tab,
    required this.accent,
    required this.labelColor,
  });

  final Widget tab;
  final Color accent;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: labelColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: labelColor, size: 16),
          child: tab,
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
    this.ebaySearchQuery,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final List<Widget> badges;
  final VoidCallback onClose;
  final LibraryEditChromeVariant chromeVariant;
  final String? ebaySearchQuery;

  Future<void> _searchOnEbay() async {
    final query = ebaySearchQuery;
    if (query == null) return;
    await launchEbaySearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final isMovieDesktop = chromeVariant == LibraryEditChromeVariant.movieDesktop;
    final headerHeight =
        (isMovieDesktop ? 54.0 : 58.0) + (badges.isNotEmpty ? 6.0 : 0.0);
    return Container(
      height: headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isMovieDesktop ? palette.toolbar : palette.surface,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: isMovieDesktop ? 18 : 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: isMovieDesktop ? 14 : 15,
                      ),
                ),
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 6,
                    runSpacing: 3,
                    children: badges,
                  ),
                ],
              ],
            ),
          ),
          if (ebaySearchQuery != null)
            IconButton(
              tooltip: 'Search on eBay',
              onPressed: _searchOnEbay,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.shopping_cart_outlined,
                size: isMovieDesktop ? 18 : 20,
              ),
            ),
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close, size: isMovieDesktop ? 20 : 24),
          ),
        ],
      ),
    );
  }
}

class _LibraryEditFooter extends StatelessWidget {
  const _LibraryEditFooter({
    required this.onSave,
    required this.chromeVariant,
    required this.accent,
  });

  final VoidCallback onSave;
  final LibraryEditChromeVariant chromeVariant;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isMovieDesktop = chromeVariant == LibraryEditChromeVariant.movieDesktop;
    final saveBackground = isMovieDesktop
        ? Color.lerp(accent, Colors.white, 0.58) ?? accent
        : null;
    final saveForeground = isMovieDesktop ? Colors.black87 : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isMovieDesktop ? appPalette(context).toolbar : appPalette(context).surface,
        border: Border(top: BorderSide(color: appPalette(context).divider)),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: FilledButton.icon(
          style: isMovieDesktop
              ? FilledButton.styleFrom(
                  backgroundColor: saveBackground,
                  foregroundColor: saveForeground,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                )
              : null,
          onPressed: onSave,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save'),
        ),
      ),
    );
  }
}