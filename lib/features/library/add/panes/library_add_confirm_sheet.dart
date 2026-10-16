import 'dart:math' as math;

import 'library_add_pane_dependencies.dart';

/// "Confirm your selection": the chosen result rises from the bottom of the
/// Add dialog over a dimmed backdrop, with its own Add button, as in the
/// reference. Clicking the backdrop or pressing Escape closes it.
class LibraryAddConfirmSheet extends StatelessWidget {
  const LibraryAddConfirmSheet({
    super.key,
    required this.accent,
    required this.content,
    required this.footer,
    required this.onDismiss,
  });

  final Color accent;
  final Widget content;
  final Widget footer;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): onDismiss,
      },
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = (constraints.maxHeight * 0.65)
                .clamp(math.min(360.0, constraints.maxHeight),
                    constraints.maxHeight)
                .toDouble();
            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    key: const ValueKey('library-add-confirm-backdrop'),
                    behavior: HitTestBehavior.opaque,
                    onTap: onDismiss,
                    child: const ColoredBox(color: Color(0x80000000)),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 0,
                  height: height,
                  child: Column(
                    key: const ValueKey('library-add-confirm-sheet'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                        ),
                        child: const Text(
                          'Confirm your selection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ColoredBox(
                          color: palette.isDark
                              ? const Color(0xff262626)
                              : palette.panel,
                          child: content,
                        ),
                      ),
                      footer,
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
