import 'dart:math' as math;

import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const double kLibraryEditTabStripHeight = 32;
const double kLibraryEditTabStripContainerHeight = 33;
const Color _clzEditTabBackground = Color(0xFF131313);
const Color _clzEditTabHighlight = Color(0xFF383838);
const Color _clzEditTabBorder = Color(0xFF262626);
const Color _clzEditTabDragShadow = Color(0xFF666666);

// Keep the current selection in memory so Previous/Next can open the next
// item's editor on the same kind-and-scope tab without persisting it as a
// long-term preference. Stable tab IDs survive per-item tab visibility changes.
final Map<String, String> _activeEditTabIds = {};

String? loadLibraryEditTabSelection(String? storageKey) =>
    storageKey == null ? null : _activeEditTabIds[storageKey];

void saveLibraryEditTabSelection({
  required String? storageKey,
  required String tabId,
}) {
  if (storageKey == null || tabId.isEmpty) return;
  _activeEditTabIds[storageKey] = tabId;
}

Future<List<int>?> loadLibraryEditTabOrder({
  required String? storageKey,
  required int tabCount,
}) async {
  if (storageKey == null || tabCount == 0) return null;
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final saved = prefs.getStringList(storageKey);
  if (saved == null || saved.length != tabCount) return null;
  final parsed = saved.map(int.tryParse).toList();
  if (parsed.any((value) => value == null)) return null;
  final order = parsed.cast<int>();
  final sorted = List<int>.of(order)..sort();
  if (sorted.length != tabCount ||
      !sorted.indexed.every((entry) => entry.$1 == entry.$2)) {
    return null;
  }
  return order;
}

Future<void> saveLibraryEditTabOrder({
  required String? storageKey,
  required List<int> order,
}) async {
  if (storageKey == null) return;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    storageKey,
    order.map((index) => index.toString()).toList(growable: false),
  );
}

class LibraryEditTabStripFrame extends StatelessWidget {
  const LibraryEditTabStripFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: BoxDecoration(
        color: palette.panel,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: kLibraryEditTabStripContainerHeight,
        ),
        child: child,
      ),
    );
  }
}

class LibraryEditStyledTabLabel extends StatelessWidget {
  const LibraryEditStyledTabLabel({
    super.key,
    required this.tab,
    required this.accent,
    required this.selected,
    required this.highlighted,
  });

  final Widget tab;
  final Color accent;
  final bool selected;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final idleBackground =
        palette.isDark ? _clzEditTabBackground : palette.surface;
    final activeBackground =
        palette.isDark ? _clzEditTabHighlight : palette.panelRaised;
    final idleForeground =
        palette.isDark ? const Color(0xB3FFFFFF) : palette.textMuted;
    final foreground = selected || highlighted
        ? (palette.isDark ? Colors.white : palette.textPrimary)
        : idleForeground;
    final borderColor = palette.isDark ? _clzEditTabBorder : palette.divider;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
      margin: const EdgeInsets.only(right: 3),
      constraints: const BoxConstraints(minHeight: kLibraryEditTabStripHeight),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: selected
            ? activeBackground
            : highlighted
                ? (palette.isDark
                    ? activeBackground
                    : accent.withValues(alpha: 0.16))
                : idleBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(4),
        ),
        border: Border.all(color: borderColor),
      ),
      alignment: Alignment.center,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 20 / 14,
          letterSpacing: 0,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: foreground, size: 14),
          child: tab,
        ),
      ),
    );
  }
}

/// The tab strip used by every Library edit dialog.
///
/// The controller-backed mode is used by shell-based edit dialogs. The
/// callback-backed mode is used by schema dialogs, where the schema renderer
/// owns the selected tab and visible-tab mapping. Both modes intentionally
/// share the same visual and drag behavior.
class LibraryEditReorderableTabStrip extends StatefulWidget {
  const LibraryEditReorderableTabStrip({
    super.key,
    required this.tabs,
    required this.accent,
    this.tabController,
    this.selectedIndex = 0,
    this.allowReorder = true,
    this.enabled = true,
    this.onReorderItem,
    this.onSelect,
  }) : assert(
          tabController != null || onSelect != null,
          'Provide either a TabController or an onSelect callback.',
        );

  final List<Widget> tabs;
  final Color accent;
  final TabController? tabController;
  final int selectedIndex;
  final bool allowReorder;
  final bool enabled;
  final void Function(int oldIndex, int newIndex)? onReorderItem;
  final ValueChanged<int>? onSelect;

  @override
  State<LibraryEditReorderableTabStrip> createState() =>
      _LibraryEditReorderableTabStripState();
}

class _LibraryEditReorderableTabStripState
    extends State<LibraryEditReorderableTabStrip> {
  final _scroll = ScrollController();
  bool _overflow = false;
  bool _atStart = true;
  bool _atEnd = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_updateScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _updateScroll() {
    if (!mounted ||
        !_scroll.hasClients ||
        !_scroll.position.hasContentDimensions) {
      return;
    }
    final overflow = _scroll.position.maxScrollExtent > 1;
    final atStart = _scroll.offset <= 1;
    final atEnd = _scroll.offset >= _scroll.position.maxScrollExtent - 1;
    if (_overflow != overflow || _atStart != atStart || _atEnd != atEnd) {
      setState(() {
        _overflow = overflow;
        _atStart = atStart;
        _atEnd = atEnd;
      });
    }
  }

  void _step(int direction) {
    _scroll.animateTo(
        (_scroll.offset + direction * 220)
            .clamp(0, _scroll.position.maxScrollExtent),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 250),
        curve: Curves.ease);
  }

  List<Widget> get tabs => widget.tabs;
  Color get accent => widget.accent;
  TabController? get tabController => widget.tabController;
  bool get enabled => widget.enabled;
  bool get allowReorder => widget.allowReorder;
  void Function(int, int)? get onReorderItem => widget.onReorderItem;
  ValueChanged<int>? get onSelect => widget.onSelect;

  @override
  Widget build(BuildContext context) {
    final controller = tabController;
    if (controller == null) {
      return _buildStrip(context, widget.selectedIndex);
    }
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => _buildStrip(context, controller.index),
    );
  }

  Widget _buildStrip(BuildContext context, int currentIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScroll());
    final canReorder = enabled && allowReorder && onReorderItem != null;

    Widget buildTab(int index, {required bool draggable}) {
      final tab = tabs[index];
      final child = _tabButton(
        index: index,
        currentIndex: currentIndex,
        highlighted: false,
        enabled: enabled,
      );
      final key = tab.key ?? ObjectKey(tab);
      return draggable
          ? ReorderableDragStartListener(
              key: key,
              index: index,
              child: child,
            )
          : KeyedSubtree(key: key, child: child);
    }

    final Widget strip = canReorder
        ? ReorderableListView.builder(
            scrollController: _scroll,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            primary: false,
            padding: EdgeInsets.zero,
            clipBehavior: Clip.none,
            dragBoundaryProvider: (_) => null,
            buildDefaultDragHandles: false,
            itemCount: tabs.length,
            onReorderItem: (oldIndex, newIndex) =>
                onReorderItem!(oldIndex, newIndex),
            proxyDecorator: _decorateDraggedTab,
            itemBuilder: (context, index) => buildTab(index, draggable: true),
          )
        : SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0; index < tabs.length; index++)
                  buildTab(index, draggable: false),
              ],
            ),
          );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: kLibraryEditTabStripHeight),
      child: SizedBox(
        width: double.infinity,
        height: kLibraryEditTabStripHeight,
        child: Row(children: [
          if (_overflow)
            SizedBox(
                width: 24,
                child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: 'Scroll tabs left',
                    onPressed: enabled && !_atStart ? () => _step(-1) : null,
                    icon: const Icon(Icons.chevron_left, size: 18))),
          Expanded(child: strip),
          if (_overflow)
            SizedBox(
                width: 24,
                child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: 'Scroll tabs right',
                    onPressed: enabled && !_atEnd ? () => _step(1) : null,
                    icon: const Icon(Icons.chevron_right, size: 18))),
        ]),
      ),
    );
  }

  Widget _decorateDraggedTab(
    Widget child,
    int index,
    Animation<double> animation,
  ) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final progress = Curves.easeOut.transform(animation.value);
        return Transform.rotate(
          angle: math.pi / 180 * progress,
          child: Transform.scale(
            scale: 1 + 0.025 * progress,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                boxShadow: [
                  BoxShadow(
                    color: _clzEditTabDragShadow,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                child: child!,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tabButton({
    required int index,
    required int currentIndex,
    required bool highlighted,
    required bool enabled,
  }) {
    return _LibraryEditTabButton(
      tab: tabs[index],
      accent: accent,
      selected: currentIndex == index,
      highlighted: highlighted,
      enabled: enabled,
      onTap: enabled
          ? () {
              final controller = tabController;
              if (controller != null) {
                controller.animateTo(index);
              } else {
                onSelect!(index);
              }
            }
          : null,
    );
  }
}

class _LibraryEditTabButton extends StatefulWidget {
  const _LibraryEditTabButton({
    required this.tab,
    required this.accent,
    required this.selected,
    required this.highlighted,
    required this.enabled,
    required this.onTap,
  });

  final Widget tab;
  final Color accent;
  final bool selected;
  final bool highlighted;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  State<_LibraryEditTabButton> createState() => _LibraryEditTabButtonState();
}

class _LibraryEditTabButtonState extends State<_LibraryEditTabButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: widget.enabled ? (_) => setState(() => _hovered = true) : null,
      onExit: widget.enabled ? (_) => setState(() => _hovered = false) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: LibraryEditStyledTabLabel(
          tab: widget.tab,
          accent: widget.accent,
          selected: widget.selected,
          highlighted: widget.enabled &&
              !widget.selected &&
              (widget.highlighted || _hovered),
        ),
      ),
    );
  }
}
