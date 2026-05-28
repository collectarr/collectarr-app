import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryEditDialogScaffold extends StatefulWidget {
  const LibraryEditDialogScaffold({
    super.key,
    required this.formKey,
    required this.accent,
    required this.icon,
    required this.title,
    required this.badges,
    required this.tabController,
    required this.tabs,
    required this.views,
    required this.onClose,
    required this.onSave,
    this.tabOrderKey,
    this.ebaySearchQuery,
  });

  final GlobalKey<FormState> formKey;
  final Color accent;
  final IconData icon;
  final String title;
  final List<Widget> badges;
  final TabController tabController;
  final List<Widget> tabs;
  final List<Widget> views;
  final VoidCallback onClose;
  final VoidCallback onSave;
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
    _loadSavedTabOrder();
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
    if (widget.tabs.length != _tabOrder.length) {
      _tabOrder = List.generate(widget.tabs.length, (i) => i);
    }
  }

  void _onReorderItem(int oldIndex, int newIndex) {
    setState(() {
      final currentTabLogical = _tabOrder[widget.tabController.index];
      final item = _tabOrder.removeAt(oldIndex);
      _tabOrder.insert(newIndex, item);
      // Keep the same logical tab selected after reorder.
      final newSelectedIndex = _tabOrder.indexOf(currentTabLogical);
      if (newSelectedIndex >= 0) {
        widget.tabController.index = newSelectedIndex;
      }
    });
    _saveTabOrder();
  }

  @override
  Widget build(BuildContext context) {
    final orderedTabs = [for (final i in _tabOrder) widget.tabs[i]];
    final orderedViews = [for (final i in _tabOrder) widget.views[i]];
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: editDialogTheme(seedColor: widget.accent, palette: appPalette(context)),
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
              constraints: const BoxConstraints(maxWidth: 960, maxHeight: 740),
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
                      ebaySearchQuery: widget.ebaySearchQuery,
                    ),
                    ColoredBox(
                      color: p.panelRaised,
                      child: _ReorderableTabStrip(
                        tabController: widget.tabController,
                        tabs: orderedTabs,
                        accent: widget.accent,
                        labelColor: p.textPrimary,
                        unselectedLabelColor: p.textMuted,
                        dividerColor: p.divider,
                        onReorderItem: _onReorderItem,
                      ),
                    ),
                    Expanded(
                      child: ColoredBox(
                        color: p.panel,
                        child: TabBarView(
                          controller: widget.tabController,
                          children: orderedViews,
                        ),
                      ),
                    ),
                    _LibraryEditFooter(
                      onSave: widget.onSave,
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
    required this.tabs,
    required this.accent,
    required this.labelColor,
    required this.unselectedLabelColor,
    required this.dividerColor,
    required this.onReorderItem,
  });

  final TabController tabController;
  final List<Widget> tabs;
  final Color accent;
  final Color labelColor;
  final Color unselectedLabelColor;
  final Color dividerColor;
  final void Function(int oldIndex, int newIndex) onReorderItem;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 40,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < tabs.length; i++)
                  DragTarget<int>(
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
                          onTap: () => tabController.animateTo(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 11),
                            decoration: BoxDecoration(
                              color: candidateData.isNotEmpty
                                  ? accent.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              border: Border(
                                bottom: BorderSide(
                                  color: tabController.index == i
                                      ? accent
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: DefaultTextStyle.merge(
                              style: TextStyle(
                                color: tabController.index == i
                                    ? labelColor
                                    : unselectedLabelColor,
                                fontWeight: tabController.index == i
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                              child: IconTheme.merge(
                                data: IconThemeData(
                                  color: tabController.index == i
                                      ? labelColor
                                      : unselectedLabelColor,
                                  size: 18,
                                ),
                                child: tabs[i],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: labelColor,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: labelColor, size: 18),
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
    this.ebaySearchQuery,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final List<Widget> badges;
  final VoidCallback onClose;
  final String? ebaySearchQuery;

  Future<void> _searchOnEbay() async {
    final query = ebaySearchQuery;
    if (query == null) return;
    await launchEbaySearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [appPalette(context).surface, appPalette(context).surfaceDim],
        ),
        border: Border(bottom: BorderSide(color: accent)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 22),
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
                      ?.copyWith(fontWeight: FontWeight.w900, fontSize: 15),
                ),
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
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
              icon: const Icon(Icons.shopping_cart_outlined, size: 20),
            ),
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _LibraryEditFooter extends StatelessWidget {
  const _LibraryEditFooter({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: appPalette(context).toolbar,
        border: Border(top: BorderSide(color: appPalette(context).divider)),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: FilledButton.icon(
          onPressed: onSave,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save'),
        ),
      ),
    );
  }
}