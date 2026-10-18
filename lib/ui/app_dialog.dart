import 'package:collectarr_app/ui/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';

/// Shared panel corners, without an outer border.
const ShapeBorder appDialogShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(6)),
);

/// Modal backdrop: black at 50 %, as in the reference.
const Color kAppDialogBarrierColor = Color(0x80000000);

const double kAppDialogTopInset = 30;

/// Item editors sit higher than other modals, as in the reference.
const double kAppEditorTopInset = 10;
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
    Color? barrierColor = kAppDialogBarrierColor,
    super.barrierLabel,
    bool useSafeArea = true,
    super.settings,
    super.anchorPoint,
    super.traversalEdgeBehavior,
    this.animationsEnabled = true,
    Duration? transitionDuration,
    RouteTransitionsBuilder? transitionBuilder,
  }) : super(
          barrierColor: barrierColor ?? kAppDialogBarrierColor,
          transitionDuration: transitionDuration ??
              (animationsEnabled ? appDialogTransitionDuration : Duration.zero),
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
    return _DialogSlideTransition(animation: animation, child: child);
  }
}

/// Fades the dialog over the first half of the transition while it slides
/// from a quarter of its own height above its place, as the reference's
/// modals do on open and close.
class _DialogSlideTransition extends StatefulWidget {
  const _DialogSlideTransition({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  State<_DialogSlideTransition> createState() => _DialogSlideTransitionState();
}

class _DialogSlideTransitionState extends State<_DialogSlideTransition> {
  final GlobalKey _pageKey = GlobalKey();
  late CurvedAnimation _fade;
  late CurvedAnimation _slide;

  @override
  void initState() {
    super.initState();
    _curve();
  }

  @override
  void didUpdateWidget(_DialogSlideTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation == widget.animation) return;
    _disposeCurves();
    _curve();
  }

  @override
  void dispose() {
    _disposeCurves();
    super.dispose();
  }

  void _curve() {
    _fade = CurvedAnimation(
        parent: widget.animation, curve: const Interval(0, 0.5));
    _slide = CurvedAnimation(parent: widget.animation, curve: Curves.easeOut);
  }

  void _disposeCurves() {
    _fade.dispose();
    _slide.dispose();
  }

  /// Height of the dialog box inside the full-screen page, else the page.
  double _dialogHeight() {
    final root = _pageKey.currentContext?.findRenderObject();
    if (root is! RenderBox || !root.hasSize) return 0;
    double? found;
    void visit(RenderObject object) {
      if (found != null) return;
      if (object is RenderBox &&
          object != root &&
          object.hasSize &&
          object.size.height < root.size.height) {
        found = object.size.height;
        return;
      }
      object.visitChildren(visit);
    }

    root.visitChildren(visit);
    return found ?? root.size.height;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: AnimatedBuilder(
        animation: _slide,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -0.25 * _dialogHeight() * (1 - _slide.value)),
          child: child,
        ),
        child: KeyedSubtree(key: _pageKey, child: widget.child),
      ),
    );
  }
}

/// Drop-in replacement for [showDialog] that silences Windows error beeps on barrier clicks.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = false,
  Color? barrierColor = kAppDialogBarrierColor,
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
