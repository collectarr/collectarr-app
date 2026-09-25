import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const double kLibraryEditTabStripHeight = 32;
const double kLibraryEditTabStripContainerHeight = 33;

// Keep the current selection in memory so Previous/Next can open the next
// item's editor on the same kind-and-scope tab without persisting it as a
// long-term preference.
final Map<String, int> _activeEditTabIndexes = {};

int? loadLibraryEditTabSelection(String? storageKey) =>
    storageKey == null ? null : _activeEditTabIndexes[storageKey];

void saveLibraryEditTabSelection({
  required String? storageKey,
  required int index,
}) {
  if (storageKey == null || index < 0) return;
  _activeEditTabIndexes[storageKey] = index;
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
      height: kLibraryEditTabStripContainerHeight,
      decoration: BoxDecoration(
        color: palette.panel,
      ),
      child: child,
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
    final foreground =
        selected || highlighted ? palette.textPrimary : palette.textMuted;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: EdgeInsets.fromLTRB(2, 2, 2, selected ? 0 : 2),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: selected
            ? palette.panelRaised
            : highlighted
                ? accent.withValues(alpha: 0.16)
                : palette.surfaceSubtle.withValues(alpha: 0.42),
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(3),
          bottom: Radius.circular(selected ? 0 : 3),
        ),
        border: Border.all(
          color: selected
              ? accent.withValues(alpha: 0.92)
              : highlighted
                  ? accent.withValues(alpha: 0.72)
                  : palette.divider,
          width: selected || highlighted ? 1.1 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: foreground,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          fontSize: 12,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: foreground, size: 14),
          child: tab,
        ),
      ),
    );
  }
}

class LibraryEditDraggedTabLabel extends StatelessWidget {
  const LibraryEditDraggedTabLabel({
    super.key,
    required this.tab,
    required this.accent,
    this.muted = false,
  });

  final Widget tab;
  final Color accent;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final foreground = muted ? palette.textMuted : palette.textPrimary;
    return Container(
      height: kLibraryEditTabStripHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: appPalette(context).surface,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: appPalette(context).divider),
      ),
      alignment: Alignment.center,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
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
/// The controller-backed mode is used by the legacy draft renderer. The
/// callback-backed mode is used by schema dialogs, where the schema renderer
/// owns the selected tab and visible-tab mapping. Both modes intentionally
/// share the same visual and drag behavior.
class LibraryEditReorderableTabStrip extends StatelessWidget {
  const LibraryEditReorderableTabStrip({
    super.key,
    required this.tabs,
    required this.accent,
    this.tabController,
    this.selectedIndex = 0,
    this.allowReorder = true,
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
  final void Function(int oldIndex, int newIndex)? onReorderItem;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final controller = tabController;
    if (controller == null) {
      return _buildStrip(context, selectedIndex);
    }
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => _buildStrip(context, controller.index),
    );
  }

  Widget _buildStrip(BuildContext context, int currentIndex) {
    return SizedBox(
      width: double.infinity,
      height: kLibraryEditTabStripHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < tabs.length; index++)
              allowReorder && onReorderItem != null
                  ? DragTarget<int>(
                      onAcceptWithDetails: (details) {
                        final from = details.data;
                        if (from != index) {
                          onReorderItem!(from, index);
                        }
                      },
                      builder: (context, candidateData, _) {
                        return _MovementThresholdDraggable<int>(
                          data: index,
                          startDistance: kLibraryDialogTabReorderStartDistance,
                          feedback: Material(
                            elevation: 2,
                            color: Colors.transparent,
                            child: LibraryEditDraggedTabLabel(
                              tab: tabs[index],
                              accent: accent,
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.4,
                            child: LibraryEditDraggedTabLabel(
                              tab: tabs[index],
                              accent: accent,
                              muted: true,
                            ),
                          ),
                          child: _tabButton(
                            index: index,
                            currentIndex: currentIndex,
                            highlighted: candidateData.isNotEmpty,
                          ),
                        );
                      },
                    )
                  : _tabButton(
                      index: index,
                      currentIndex: currentIndex,
                      highlighted: false,
                    ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton({
    required int index,
    required int currentIndex,
    required bool highlighted,
  }) {
    return _LibraryEditTabButton(
      tab: tabs[index],
      accent: accent,
      selected: currentIndex == index,
      highlighted: highlighted,
      onTap: () {
        final controller = tabController;
        if (controller != null) {
          controller.animateTo(index);
        } else {
          onSelect!(index);
        }
      },
    );
  }
}

/// Starts a drag only after intentional horizontal movement.
///
/// Unlike [LongPressDraggable], holding the pointer still does not start the
/// drag. The threshold also gives tab taps and small pointer movements room to
/// complete without accidentally reordering the strip.
class _MovementThresholdDraggable<T extends Object> extends Draggable<T> {
  const _MovementThresholdDraggable({
    required super.data,
    required super.feedback,
    required super.child,
    super.childWhenDragging,
    required this.startDistance,
  }) : super(axis: Axis.horizontal);

  final double startDistance;

  @override
  MultiDragGestureRecognizer createRecognizer(
    GestureMultiDragStartCallback onStart,
  ) {
    return _HorizontalMovementThresholdGestureRecognizer(
      startDistance: startDistance,
      debugOwner: this,
      allowedButtonsFilter: allowedButtonsFilter,
    )..onStart = onStart;
  }
}

class _HorizontalMovementThresholdGestureRecognizer
    extends MultiDragGestureRecognizer {
  _HorizontalMovementThresholdGestureRecognizer({
    required this.startDistance,
    required super.debugOwner,
    super.allowedButtonsFilter,
  });

  final double startDistance;

  @override
  MultiDragPointerState createNewPointerState(PointerDownEvent event) {
    return _HorizontalMovementThresholdPointerState(
      event.position,
      startDistance,
      event.kind,
      gestureSettings,
    );
  }

  @override
  String get debugDescription => 'horizontal movement threshold multidrag';
}

class _HorizontalMovementThresholdPointerState extends MultiDragPointerState {
  _HorizontalMovementThresholdPointerState(
    super.initialPosition,
    this.startDistance,
    super.kind,
    super.gestureSettings,
  );

  final double startDistance;

  @override
  void checkForResolutionAfterMove() {
    final delta = pendingDelta!;
    if (delta.dx.abs() >= startDistance && delta.dx.abs() > delta.dy.abs()) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) {
    starter(initialPosition);
  }
}

class _LibraryEditTabButton extends StatefulWidget {
  const _LibraryEditTabButton({
    required this.tab,
    required this.accent,
    required this.selected,
    required this.highlighted,
    required this.onTap,
  });

  final Widget tab;
  final Color accent;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  State<_LibraryEditTabButton> createState() => _LibraryEditTabButtonState();
}

class _LibraryEditTabButtonState extends State<_LibraryEditTabButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: LibraryEditStyledTabLabel(
          tab: widget.tab,
          accent: widget.accent,
          selected: widget.selected,
          highlighted: !widget.selected && (widget.highlighted || _hovered),
        ),
      ),
    );
  }
}
