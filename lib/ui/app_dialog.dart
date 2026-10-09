import 'package:flutter/material.dart';

/// Default alignment for dialogs: positioned ~2/3 of the screen from the bottom
/// (a bit above the middle of the screen).
const Alignment kDefaultDialogAlignment = Alignment(0.0, -0.08);

/// Tracks modal dialog nesting depth and alignment to ensure child dialogs open
/// centered on their parent dialog.
class ModalDialogDepthScope extends InheritedTheme {
  const ModalDialogDepthScope({
    super.key,
    required this.depth,
    this.parentAlignment,
    required super.child,
  });

  final int depth;
  final AlignmentGeometry? parentAlignment;

  static int of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ModalDialogDepthScope>();
    return scope?.depth ?? 0;
  }

  static AlignmentGeometry? parentAlignmentOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ModalDialogDepthScope>();
    return scope?.parentAlignment;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return ModalDialogDepthScope(
      depth: depth,
      parentAlignment: parentAlignment,
      child: child,
    );
  }

  @override
  bool updateShouldNotify(ModalDialogDepthScope oldWidget) =>
      depth != oldWidget.depth || parentAlignment != oldWidget.parentAlignment;
}

/// A dialog route that silences the Windows error beep when clicking outside
/// modal barriers with [barrierDismissible] = false, and cleanly handles dismissals.
class AppDialogRoute<T> extends RawDialogRoute<T> {
  AppDialogRoute({
    required WidgetBuilder builder,
    CapturedThemes? capturedThemes,
    super.barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    super.barrierLabel,
    bool useSafeArea = true,
    super.settings,
    super.anchorPoint,
    super.traversalEdgeBehavior,
  }) : super(
          barrierColor: barrierColor ?? Colors.black54,
          transitionDuration: const Duration(milliseconds: 150),
          transitionBuilder: _buildTransitions,
          pageBuilder: (buildContext, animation, secondaryAnimation) {
            final pageChild = Builder(builder: builder);
            final dialog = capturedThemes?.wrap(pageChild) ?? pageChild;
            return useSafeArea ? SafeArea(child: dialog) : dialog;
          },
        );

  @override
  Widget buildModalBarrier() {
    if (barrierColor != null && (barrierColor!.a * 255.0).round() != 0) {
      final Animation<Color?> color = animation!.drive(
        ColorTween(
          begin: barrierColor!.withValues(alpha: 0.0),
          end: barrierColor,
        ).chain(CurveTween(curve: barrierCurve)),
      );
      return AnimatedBuilder(
        animation: color,
        builder: (context, child) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (barrierDismissible) {
              Navigator.of(context).maybePop();
            }
            // If barrierDismissible is false, silently consume the tap.
            // This prevents Windows from playing the system error/alert ding!
          },
          child: Container(color: color.value),
        ),
      );
    }
    return super.buildModalBarrier();
  }

  static Widget _buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved =
        CurvedAnimation(parent: animation, curve: Curves.easeOutQuad);
    return FadeTransition(
      opacity: curved,
      child: child,
    );
  }
}

/// Drop-in replacement for [showDialog] that silences Windows error beeps on barrier clicks.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor = Colors.black54,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  TraversalEdgeBehavior? traversalEdgeBehavior,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final capturedThemes = InheritedTheme.capture(
    from: context,
    to: navigator.context,
  );
  return navigator.push<T>(
    AppDialogRoute<T>(
      builder: builder,
      capturedThemes: capturedThemes,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      settings: routeSettings,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior: traversalEdgeBehavior,
    ),
  );
}
