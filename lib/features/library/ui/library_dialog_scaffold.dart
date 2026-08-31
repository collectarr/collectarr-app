import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_density_scope.dart';
import 'package:collectarr_app/features/library/ui/library_panel_header.dart';
import 'package:collectarr_app/features/library/ui/library_resizable_surface.dart';
import 'package:collectarr_app/ui/adaptive/window_class.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum LibraryDialogSidePanelPosition {
  start,
  end,
}

/// Unified dialog scaffold for all library dialogs (Add, Edit, Inspector, Metadata, Admin).
///
/// Features:
/// - Desktop Dialog with constrained max/min dimensions or explicit width/height
/// - Compact / mobile fullscreen presentation without Dialog card wrapper
/// - Shared title/header slot (or auto-constructed LibraryPanelHeader from [title])
/// - Optional [contextBar] below the header (e.g. mode bar, tab bar, banner)
/// - Optional [sidePanel] (preview pane, drawer) at start or end
/// - Optional [footer] (action footer, pagination bar)
/// - Integrated [LibraryResizableSurface] for draggable resize support
/// - Standard padding, density, and optional custom theme overrides
class LibraryDialogScaffold extends StatelessWidget {
  const LibraryDialogScaffold({
    super.key,
    this.header,
    this.title,
    this.contextBar,
    this.sidePanel,
    this.sidePanelPosition = LibraryDialogSidePanelPosition.end,
    this.footer,
    this.accent,
    this.onClose,
    this.width,
    this.height,
    this.minWidth = 360,
    this.maxWidth = double.infinity,
    this.minHeight = 400,
    this.maxHeight = double.infinity,
    this.onResizeWidth,
    this.onResizeHeight,
    this.isResizable = false,
    this.padding,
    this.density = LibraryDensity.comfortable,
    this.expandBody = true,
    this.themeData,
    this.insetPadding,
    this.child,
    this.body,
  }) : assert(
          header != null || title != null || child != null || body != null,
          'LibraryDialogScaffold requires a header, title, child, or body.',
        );

  final Widget? header;
  final Widget? title;
  final Widget? contextBar;
  final Widget? sidePanel;
  final LibraryDialogSidePanelPosition sidePanelPosition;
  final Widget? footer;
  final Color? accent;
  final VoidCallback? onClose;
  final double? width;
  final double? height;
  final double minWidth;
  final double maxWidth;
  final double minHeight;
  final double maxHeight;
  final ValueChanged<double>? onResizeWidth;
  final ValueChanged<double>? onResizeHeight;
  final bool isResizable;
  final EdgeInsets? padding;
  final LibraryDensity density;
  final bool expandBody;
  final ThemeData? themeData;
  final EdgeInsets? insetPadding;

  /// Main body child (alias for [body] for backwards compatibility).
  final Widget? child;

  /// Main body content widget.
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final resolvedAccent = accent ?? LibraryAccentScope.accentOf(context);
    final windowClass = AppWindowClass.of(context);
    final effectiveBody = body ?? child ?? const SizedBox.shrink();
    final effectivePadding = padding ?? (body != null ? EdgeInsets.zero : const EdgeInsets.all(12));

    final effectiveHeader = header ??
        (title != null
            ? LibraryPanelHeader(
                backgroundColor: resolvedAccent,
                foregroundColor: Colors.white,
                borderColor: resolvedAccent.withValues(alpha: 0.92),
                onClose: onClose,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                density: density,
                child: title!,
              )
            : null);

    Widget contentBody = effectivePadding != EdgeInsets.zero
        ? Padding(padding: effectivePadding, child: effectiveBody)
        : effectiveBody;

    if (sidePanel != null) {
      final isSideStart = sidePanelPosition == LibraryDialogSidePanelPosition.start;
      contentBody = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isSideStart) sidePanel!,
          Expanded(child: contentBody),
          if (!isSideStart) sidePanel!,
        ],
      );
    }

    final scaffoldColumn = Column(
      mainAxisSize: expandBody || windowClass.isCompact ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (effectiveHeader != null) effectiveHeader,
        if (contextBar != null) contextBar!,
        if (expandBody || windowClass.isCompact)
          Expanded(child: contentBody)
        else
          Flexible(fit: FlexFit.loose, child: contentBody),
        if (footer != null) footer!,
      ],
    );

    Widget result;

    if (windowClass.isCompact) {
      result = DecoratedBox(
        decoration: BoxDecoration(color: palette.panel),
        child: scaffoldColumn,
      );
    } else {
      final effectiveMinWidth = width != null ? width!.clamp(minWidth, maxWidth) : minWidth;
      final effectiveMaxWidth = width != null ? width!.clamp(minWidth, maxWidth) : maxWidth;
      final effectiveMinHeight = height != null ? height!.clamp(minHeight, maxHeight) : minHeight;
      final effectiveMaxHeight = height != null ? height!.clamp(minHeight, maxHeight) : maxHeight;

      final resizable = isResizable || onResizeWidth != null || onResizeHeight != null;

      Widget dialogBody = resizable
          ? LibraryResizableSurface(
              accent: resolvedAccent,
              onResizeWidth: onResizeWidth,
              onResizeHeight: onResizeHeight,
              child: scaffoldColumn,
            )
          : scaffoldColumn;

      result = Dialog(
        backgroundColor: palette.panel,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        insetPadding: insetPadding ??
            EdgeInsets.symmetric(
              horizontal: windowClass.isMedium ? 16 : 32,
              vertical: windowClass.isMedium ? 16 : 24,
            ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: effectiveMinWidth,
            maxWidth: effectiveMaxWidth,
            minHeight: effectiveMinHeight,
            maxHeight: effectiveMaxHeight,
          ),
          child: dialogBody,
        ),
      );
    }

    if (themeData != null) {
      result = Theme(data: themeData!, child: result);
    }

    return LibraryDensityScope(
      density: density,
      child: result,
    );
  }
}
