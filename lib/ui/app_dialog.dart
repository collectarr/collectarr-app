import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';

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
    this.animationsEnabled = true,
  }) : super(
          barrierColor: barrierColor ?? Colors.black54,
          transitionDuration: animationsEnabled
              ? const Duration(milliseconds: 200)
              : Duration.zero,
          transitionBuilder: _buildTransitions,
          pageBuilder: (buildContext, animation, secondaryAnimation) {
            final pageChild = Builder(builder: builder);
            final dialog = capturedThemes?.wrap(pageChild) ?? pageChild;
            return useSafeArea ? SafeArea(child: dialog) : dialog;
          },
        );

  final bool animationsEnabled;
  late final AnimationController _backdrop;

  @override
  void install() {
    super.install();
    _backdrop = AnimationController(
      vsync: navigator!,
      duration:
          animationsEnabled ? const Duration(milliseconds: 100) : Duration.zero,
    );
    animation!.addStatusListener(_animateBackdrop);
  }

  void _animateBackdrop(AnimationStatus status) {
    if (status == AnimationStatus.forward) _backdrop.forward();
    if (status == AnimationStatus.reverse) _backdrop.reverse();
    if (status == AnimationStatus.completed) _backdrop.value = 1;
    if (status == AnimationStatus.dismissed) _backdrop.value = 0;
  }

  @override
  void dispose() {
    animation!.removeStatusListener(_animateBackdrop);
    _backdrop.dispose();
    super.dispose();
  }

  @override
  Widget buildModalBarrier() {
    if (barrierColor != null && (barrierColor!.a * 255.0).round() != 0) {
      final Animation<Color?> color = _backdrop.drive(
        ColorTween(
          begin: barrierColor!.withValues(alpha: 0.0),
          end: barrierColor,
        ),
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
    return FadeTransition(
      opacity: animation,
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
      animationsEnabled: LibraryAccentScope.of(context).animationsEnabled &&
          !MediaQuery.disableAnimationsOf(context),
    ),
  );
}
