import 'package:collectarr_app/features/library/ui/metrics.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Equal-width bordered segments for a short closed choice, such as the
/// reference's Completeness or Completed rows. Tapping the selected segment
/// keeps it selected; the owner decides what an empty choice means.
final class LibrarySegmentedChoiceField<T> extends StatelessWidget {
  const LibrarySegmentedChoiceField({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.action,
  });

  final String label;
  final List<(T value, String label)> options;
  final T? value;
  final ValueChanged<T> onChanged;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    // The reference's dark button group: #444 segments in a #666 frame, the
    // selected one filled #666, with a lighter rule between segments.
    final dark = palette.isDark;
    final border = dark ? const Color(0xFF666666) : palette.divider;
    final separator = dark ? const Color(0xFF999999) : palette.divider;
    final fill = dark ? const Color(0xFF444444) : palette.field;
    final selectedFill =
        dark ? const Color(0xFF666666) : const Color(0xFFE6E6E6);
    // Halfway to the selected fill, so a hovered segment reads as selectable.
    final hoverFill = Color.lerp(fill, selectedFill, 0.5)!;
    final mutedText = dark ? const Color(0xFF999999) : palette.textMuted;
    return LibraryFormField(
      label: label,
      action: action,
      child: Container(
        height: LibraryMetrics.defaultFieldHeight,
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(children: [
          for (final (index, option) in options.indexed)
            Expanded(
              child: Semantics(
                button: true,
                selected: option.$1 == value,
                label: option.$2,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(option.$1),
                  child: _Segment(
                    selectedFill: option.$1 == value ? selectedFill : null,
                    hoverFill: hoverFill,
                    border: index == 0
                        ? null
                        : Border(left: BorderSide(color: separator)),
                    child: Text(
                      option.$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: option.$1 == value
                            ? palette.textPrimary
                            : mutedText,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

/// One segment; shades on hover unless it is the selected one.
final class _Segment extends StatefulWidget {
  const _Segment({
    required this.selectedFill,
    required this.hoverFill,
    required this.border,
    required this.child,
  });

  final Color? selectedFill;
  final Color hoverFill;
  final Border? border;
  final Widget child;

  @override
  State<_Segment> createState() => _SegmentState();
}

class _SegmentState extends State<_Segment> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.selectedFill ?? (_hovered ? widget.hoverFill : null),
            border: widget.border,
          ),
          child: widget.child,
        ),
      );
}
