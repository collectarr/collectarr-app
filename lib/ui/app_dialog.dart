import 'package:collectarr_app/ui/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';

/// Shared panel corners, without an outer border.
const ShapeBorder appDialogShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(6)),
);

const double kAppDialogTopInset = 30;
const Alignment kDefaultDialogAlignment = Alignment.topCenter;
const EdgeInsets kAppDialogInsets =
    EdgeInsets.fromLTRB(24, kAppDialogTopInset, 24, 24);

/// Propagates modal depth and alignment to nested dialogs.
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
    super.barrierDismissible = false,
    Color? barrierColor = Colors.black54,
    super.barrierLabel,
    bool useSafeArea = true,
    super.settings,
    super.anchorPoint,
    super.traversalEdgeBehavior,
    this.animationsEnabled = true,
    Duration? transitionDuration,
    RouteTransitionsBuilder? transitionBuilder,
  }) : super(
          barrierColor: barrierColor ?? Colors.black54,
          transitionDuration: transitionDuration ??
              (animationsEnabled ? appDialogFadeDuration : Duration.zero),
          transitionBuilder: transitionBuilder ?? _buildTransitions,
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
      duration: animationsEnabled ? appBackdropFadeDuration : Duration.zero,
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (barrierDismissible) navigator?.maybePop();
      },
      child: const SizedBox.expand(),
    );
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
  bool barrierDismissible = false,
  Color? barrierColor = Colors.black54,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  TraversalEdgeBehavior? traversalEdgeBehavior,
  Duration? transitionDuration,
  RouteTransitionsBuilder? transitionBuilder,
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
      transitionDuration: transitionDuration,
      transitionBuilder: transitionBuilder,
      animationsEnabled: LibraryAccentScope.of(context).animationsEnabled &&
          !MediaQuery.disableAnimationsOf(context),
    ),
  );
}
