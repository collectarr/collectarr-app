import 'package:collectarr_app/features/library/ui/library_form_layout.dart';
import 'package:flutter/material.dart';

/// Item wrapper for [LibraryResponsiveFormRow] specifying flex proportions.
class LibraryResponsiveFormItem {
  const LibraryResponsiveFormItem({
    required this.child,
    this.flex = 1,
  });

  final Widget child;
  final int flex;
}

/// A standard responsive form row for Library UI.
///
/// Owns:
/// - Stacking breakpoint (defaults to [kLibraryFormTwoColumnMinWidth])
/// - Horizontal gap between items
/// - Vertical gap when stacked
/// - Flex layout distribution
class LibraryResponsiveFormRow extends StatelessWidget {
  const LibraryResponsiveFormRow({
    super.key,
    required this.children,
    this.breakpoint = kLibraryFormTwoColumnMinWidth,
    this.horizontalGap = 10.0,
    this.verticalGap = 10.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.stackedMainAxisSize = MainAxisSize.min,
  });

  final List<LibraryResponsiveFormItem> children;
  final double breakpoint;
  final double horizontalGap;
  final double verticalGap;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize stackedMainAxisSize;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isStacked = constraints.maxWidth < breakpoint;
        if (isStacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: stackedMainAxisSize,
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index].child,
                if (index != children.length - 1) SizedBox(height: verticalGap),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              Expanded(
                flex: children[index].flex,
                child: children[index].child,
              ),
              if (index != children.length - 1) SizedBox(width: horizontalGap),
            ],
          ],
        );
      },
    );
  }
}
