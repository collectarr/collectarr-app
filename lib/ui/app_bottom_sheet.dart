import 'package:flutter/material.dart';

/// Mobile sheets use the same silent outside-click policy as app dialogs.
class _AppBottomSheetRoute<T> extends ModalBottomSheetRoute<T> {
  _AppBottomSheetRoute({
    required super.builder,
    required super.capturedThemes,
    required super.isScrollControlled,
    super.backgroundColor,
    super.shape,
    super.useSafeArea,
  }) : super(isDismissible: false);

  @override
  Widget buildModalBarrier() => AnimatedBuilder(
        animation: animation!,
        builder: (_, __) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: SizedBox.expand(
            child: ColoredBox(
                color: Color.lerp(
                        Colors.transparent, barrierColor, animation!.value) ??
                    Colors.transparent),
          ),
        ),
      );
}

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useSafeArea = false,
  Color? backgroundColor,
  ShapeBorder? shape,
}) {
  final navigator = Navigator.of(context);
  return navigator.push(_AppBottomSheetRoute<T>(
    builder: builder,
    capturedThemes:
        InheritedTheme.capture(from: context, to: navigator.context),
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    backgroundColor: backgroundColor,
    shape: shape,
  ));
}
