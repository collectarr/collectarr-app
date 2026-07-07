import 'dart:async';

import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../layout/library_pane_widths.dart';
import '../layout/library_resizable_pane.dart';
import '../config/library_workspace_config.dart';

export 'library_workspace_actions.dart';
export 'library_workspace_controls.dart';
export 'library_workspace_menus.dart';
export 'library_workspace_search.dart';
export '../config/library_workspace_tokens.dart';

class LibraryDetailsAwareLayout extends StatefulWidget {
  const LibraryDetailsAwareLayout({
    super.key,
    required this.content,
    required this.detailsLayout,
    required this.inspector,
    this.frameInspector = true,
    this.rightWidth = 340,
    this.bottomHeight = kLibraryDetailsDefaultHeight,
    this.onRightWidthChanged,
    this.onBottomHeightChanged,
    this.maxRightWidth = kLibraryDetailsMaxWidth,
    this.maxBottomHeight = kLibraryPaneStoredMaxWidth,
    this.accentColor = kAppAccent,
    this.transitionDuration = kAppAnimNormal,
  });

  final Widget content;
  final LibraryDetailsLayout detailsLayout;
  final Widget inspector;
  final bool frameInspector;
  final double rightWidth;
  final double bottomHeight;
  final ValueChanged<double>? onRightWidthChanged;
  final ValueChanged<double>? onBottomHeightChanged;
  final double maxRightWidth;
  final double maxBottomHeight;
  final Color accentColor;
  final Duration transitionDuration;

  @override
  State<LibraryDetailsAwareLayout> createState() =>
      _LibraryDetailsAwareLayoutState();
}

class _LibraryDetailsAwareLayoutState extends State<LibraryDetailsAwareLayout> {
  late double _rightWidth;
  late double _bottomHeight;
  bool _draggingRight = false;
  bool _draggingBottom = false;
  Timer? _rightPersistDebounce;
  Timer? _bottomPersistDebounce;

  /// The last non-hidden layout, so a transition to [LibraryDetailsLayout.hidden]
  /// can collapse the panel along the axis it was shown in (and reappearing
  /// expands from the same axis) instead of popping instantly.
  LibraryDetailsLayout _lastVisibleLayout = LibraryDetailsLayout.right;

  @override
  void initState() {
    super.initState();
    _rightWidth = widget.rightWidth;
    _bottomHeight = widget.bottomHeight;
    if (widget.detailsLayout != LibraryDetailsLayout.hidden) {
      _lastVisibleLayout = widget.detailsLayout;
    }
  }

  @override
  void didUpdateWidget(covariant LibraryDetailsAwareLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_draggingRight && widget.rightWidth != oldWidget.rightWidth) {
      _rightWidth = widget.rightWidth;
    }
    if (!_draggingBottom && widget.bottomHeight != oldWidget.bottomHeight) {
      _bottomHeight = widget.bottomHeight;
    }
    if (widget.detailsLayout != LibraryDetailsLayout.hidden) {
      _lastVisibleLayout = widget.detailsLayout;
    }
  }

  @override
  void dispose() {
    _rightPersistDebounce?.cancel();
    _bottomPersistDebounce?.cancel();
    super.dispose();
  }

  void _scheduleRightWidthPersist(double width) {
    _rightPersistDebounce?.cancel();
    _rightPersistDebounce = Timer(const Duration(milliseconds: 16), () {
      widget.onRightWidthChanged?.call(width);
    });
  }

  void _scheduleBottomHeightPersist(double height) {
    _bottomPersistDebounce?.cancel();
    _bottomPersistDebounce = Timer(const Duration(milliseconds: 16), () {
      widget.onBottomHeightChanged?.call(height);
    });
  }

  void _flushRightWidthPersist() {
    _rightPersistDebounce?.cancel();
    widget.onRightWidthChanged?.call(_rightWidth);
  }

  void _flushBottomHeightPersist() {
    _bottomPersistDebounce?.cancel();
    widget.onBottomHeightChanged?.call(_bottomHeight);
  }

  void _handleRightDrag(double delta) {
    final nextWidth = clampLibraryPaneWidth(
      _rightWidth - delta,
      minWidth: kLibraryDetailsMinWidth,
      maxWidth: widget.maxRightWidth,
    );
    if ((_rightWidth - nextWidth).abs() < 0.01) {
      return;
    }
    setState(() => _rightWidth = nextWidth);
    _scheduleRightWidthPersist(nextWidth);
  }

  void _handleBottomDrag(double delta) {
    final nextHeight = clampLibraryPaneHeight(
      _bottomHeight - delta,
      minHeight: kLibraryDetailsMinHeight,
      maxHeight: widget.maxBottomHeight,
    );
    if ((_bottomHeight - nextHeight).abs() < 0.01) {
      return;
    }
    setState(() => _bottomHeight = nextHeight);
    _scheduleBottomHeightPersist(nextHeight);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRightWidth = clampLibraryPaneWidth(
      _rightWidth,
      minWidth: kLibraryDetailsMinWidth,
      maxWidth: widget.maxRightWidth,
    );
    final effectiveBottomHeight = clampLibraryPaneHeight(
      _bottomHeight,
      minHeight: kLibraryDetailsMinHeight,
      maxHeight: widget.maxBottomHeight,
    );
    final inspectorPane = widget.frameInspector
        ? LibraryDetailsPaneFrame(
            accentColor: widget.accentColor,
            child: widget.inspector,
          )
        : widget.inspector;

    final isHidden = widget.detailsLayout == LibraryDetailsLayout.hidden;
    // When hidden, keep the last visible orientation so the panel collapses
    // (and later expands) along the same axis instead of popping.
    final panelLayout = isHidden ? _lastVisibleLayout : widget.detailsLayout;
    final duration = widget.transitionDuration;

    final Widget layout = switch (panelLayout) {
      LibraryDetailsLayout.bottom => _buildBottomLayout(
          inspectorPane: inspectorPane,
          height: effectiveBottomHeight,
          collapsed: isHidden,
          duration: duration,
        ),
      // right, plus the hidden fallback which never resolves here because
      // panelLayout is derived from the last visible orientation.
      LibraryDetailsLayout.right ||
      LibraryDetailsLayout.hidden =>
        _buildRightLayout(
          inspectorPane: inspectorPane,
          width: effectiveRightWidth,
          collapsed: isHidden,
          duration: duration,
        ),
    };

    // Cross-fade when the orientation itself flips (right <-> bottom); the
    // axis-collapse animation alone can't morph between a Row and a Column.
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) => Stack(
        fit: StackFit.expand,
        children: [
          ...previousChildren,
          if (currentChild != null) currentChild,
        ],
      ),
      child: KeyedSubtree(
        key: ValueKey(panelLayout),
        child: layout,
      ),
    );
  }

  Widget _buildRightLayout({
    required Widget inspectorPane,
    required double width,
    required bool collapsed,
    required Duration duration,
  }) {
    return Row(
      children: [
        Expanded(child: widget.content),
        if (!collapsed)
          if (widget.onRightWidthChanged == null)
            const VerticalDivider(width: 1)
          else
            LibraryResizableDivider(
              accentColor: widget.accentColor,
              onDragStart: () => _draggingRight = true,
              onDragEnd: () {
                _draggingRight = false;
                _flushRightWidthPersist();
              },
              onDragDelta: _handleRightDrag,
            ),
        AnimatedContainer(
          duration: _draggingRight ? Duration.zero : duration,
          curve: Curves.easeOutCubic,
          width: collapsed ? 0.0 : width,
          child: ClipRect(
            child: OverflowBox(
              minWidth: 0,
              maxWidth: width,
              alignment: Alignment.centerLeft,
              child: SizedBox(width: width, child: inspectorPane),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomLayout({
    required Widget inspectorPane,
    required double height,
    required bool collapsed,
    required Duration duration,
  }) {
    return Column(
      children: [
        Expanded(child: widget.content),
        if (!collapsed)
          if (widget.onBottomHeightChanged == null)
            const Divider(height: 1)
          else
            LibraryResizableDivider(
              axis: Axis.vertical,
              accentColor: widget.accentColor,
              onDragStart: () => _draggingBottom = true,
              onDragEnd: () {
                _draggingBottom = false;
                _flushBottomHeightPersist();
              },
              onDragDelta: _handleBottomDrag,
            ),
        AnimatedContainer(
          duration: _draggingBottom ? Duration.zero : duration,
          curve: Curves.easeOutCubic,
          height: collapsed ? 0.0 : height,
          child: ClipRect(
            child: OverflowBox(
              minHeight: 0,
              maxHeight: height,
              alignment: Alignment.topCenter,
              child: SizedBox(height: height, child: inspectorPane),
            ),
          ),
        ),
      ],
    );
  }
}

class LibraryDetailsPaneFrame extends StatelessWidget {
  const LibraryDetailsPaneFrame({
    required this.child,
    required this.accentColor,
    this.title = 'Details',
    this.icon = Icons.info_outline,
    super.key,
  });

  final Widget child;
  final Color accentColor;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accentDivider = accentColor.withValues(alpha: 0.3);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accentColor.withValues(alpha: 0.028),
          palette.panel,
        ),
        border: Border(
          left: BorderSide(color: accentDivider),
          top: BorderSide(color: accentDivider),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color.alphaBlend(
                    accentColor.withValues(alpha: 0.12),
                    palette.surface,
                  ),
                  palette.surface,
                ],
              ),
              border: Border(
                bottom: BorderSide(color: accentDivider),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 13, color: accentColor),
                const SizedBox(width: 5),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
