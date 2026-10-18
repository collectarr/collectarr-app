import 'package:collectarr_app/ui/app_dialog.dart';
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
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  final shown = showAppDialog<void>(
    context: context,
    builder: (_) => AppProgressDialog(title: title, message: message),
  );
  try {
    // Let the dialog paint before synchronous work can block the frame.
    await WidgetsBinding.instance.endOfFrame;
    final results = await Future.wait<Object?>([
      task(),
      Future<void>.delayed(kAppProgressMinimumDuration),
    ]);
    return results.first as T;
  } finally {
    navigator.pop();
    await shown;
  }
}

/// Centred 600 px modal on #262626 with a bold title, the message and an
/// animated striped bar, as the reference shows while it works.
class AppProgressDialog extends StatelessWidget {
  const AppProgressDialog(
      {super.key, required this.title, required this.message});
  final String title;
  final String message;

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
                  const _StripedProgressBar(),
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

class _StripedProgressBar extends StatefulWidget {
  const _StripedProgressBar();

  @override
  State<_StripedProgressBar> createState() => _StripedProgressBarState();
}

class _StripedProgressBarState extends State<_StripedProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: const Color(0xfff5f5f5),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
            size: const Size.fromHeight(20),
            painter: _StripePainter(_controller.value)),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter(this.phase);
  final double phase;

  static const double _stripe = 40;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xff5bc0de));
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
  bool shouldRepaint(_StripePainter old) => old.phase != phase;
}
