import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Shortest time the progress dialog stays up, so quick local work does not
/// flash it.
const Duration kAppProgressMinimumDuration = Duration(milliseconds: 600);

/// Shows the reference's modal progress window (title, message and a striped
/// bar) while [task] runs, then closes it and returns the result.
Future<T> runWithProgressDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  required Future<T> Function() task,
}) =>
    runWithReportedProgressDialog(
        context: context, title: title, message: message, task: (_) => task());

/// Reports how far a task has got: the filled share of the bar (0 to 1) and
/// an optional caption under it.
typedef AppProgressReporter = void Function(double fraction, [String? caption]);

/// The share of the bar to fill and the caption shown under it.
typedef AppProgress = ({double fraction, String? caption});

/// [runWithProgressDialog] for a task that reports how far it has got: the
/// bar fills as the reference's import bar does, with a caption under it.
Future<T> runWithReportedProgressDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  required Future<T> Function(AppProgressReporter report) task,
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  final progress = ValueNotifier<AppProgress?>(null);
  final shown = showAppDialog<void>(
    context: context,
    builder: (_) =>
        AppProgressDialog(title: title, message: message, progress: progress),
  );
  try {
    // Let the dialog paint before synchronous work can block the frame.
    await WidgetsBinding.instance.endOfFrame;
    final results = await Future.wait<Object?>([
      task((fraction, [caption]) =>
          progress.value = (fraction: fraction, caption: caption)),
      Future<void>.delayed(kAppProgressMinimumDuration),
    ]);
    return results.first as T;
  } finally {
    navigator.pop();
    await shown;
    progress.dispose();
  }
}

/// Centred 600 px modal on #262626 with a bold title, the message and an
/// animated striped bar, as the reference shows while it works.
class AppProgressDialog extends StatelessWidget {
  const AppProgressDialog(
      {super.key, required this.title, required this.message, this.progress});
  final String title;
  final String message;

  /// Fills the bar and captions it once the task reports; until then the bar
  /// is full and moving.
  final ValueListenable<AppProgress?>? progress;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        alignment: Alignment.center,
        backgroundColor: const Color(0xff262626),
        surfaceTintColor: Colors.transparent,
        shape: appDialogShape,
        elevation: 0,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.1)),
                  const SizedBox(height: 10),
                  Text(message, style: const TextStyle(height: 20 / 14)),
                  const SizedBox(height: 20),
                  _ProgressBar(progress),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar(this.progress);
  final ValueListenable<AppProgress?>? progress;

  @override
  Widget build(BuildContext context) {
    final listenable = progress;
    if (listenable == null) return const AppStripedProgressBar();
    return ValueListenableBuilder<AppProgress?>(
        valueListenable: listenable,
        builder: (context, value, _) =>
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              AppStripedProgressBar(value: value?.fraction),
              if (value?.caption case final caption?) ...[
                const SizedBox(height: 10),
                Text(caption, style: const TextStyle(color: Color(0xffaaaaaa))),
              ],
            ]));
  }
}

/// The reference's animated striped bar; [value] (0 to 1) fills that share of
/// the track from the left, and null fills it all.
class AppStripedProgressBar extends StatefulWidget {
  const AppStripedProgressBar(
      {super.key,
      this.value,
      this.height = 20,
      this.radius = 4,
      this.animate = true,
      this.child});

  final double? value;
  final double height;
  final double radius;

  /// Whether the stripes move; a resting bar lets the UI settle.
  final bool animate;

  /// Drawn centred over the track, such as a status caption.
  final Widget? child;

  @override
  State<AppStripedProgressBar> createState() => _AppStripedProgressBarState();
}

class _AppStripedProgressBarState extends State<AppStripedProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(AppStripedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xfff5f5f5),
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(alignment: Alignment.center, children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
                painter: _StripePainter(_controller.value, widget.value ?? 1)),
          ),
        ),
        if (widget.child != null) widget.child!,
      ]),
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter(this.phase, this.fraction);
  final double phase;
  final double fraction;

  static const double _stripe = 40;

  @override
  void paint(Canvas canvas, Size size) {
    final filled = Size(size.width * fraction.clamp(0.0, 1.0), size.height);
    canvas.clipRect(Offset.zero & filled);
    canvas.drawRect(
        Offset.zero & filled, Paint()..color = const Color(0xff5bc0de));
    final light = Paint()..color = const Color(0x26ffffff);
    final shift = phase * _stripe;
    for (var x = -_stripe * 2 + shift;
        x < size.width + size.height;
        x += _stripe) {
      canvas.drawPath(
          Path()
            ..moveTo(x, size.height)
            ..lineTo(x + _stripe / 2, size.height)
            ..lineTo(x + _stripe / 2 + size.height, 0)
            ..lineTo(x + size.height, 0)
            ..close(),
          light);
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) =>
      old.phase != phase || old.fraction != fraction;
}
