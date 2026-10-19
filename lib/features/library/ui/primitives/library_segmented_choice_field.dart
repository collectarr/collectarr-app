import 'package:collectarr_app/features/library/ui/library_metrics.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
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
    final border = palette.isDark ? const Color(0xFF555555) : palette.divider;
    final selectedFill =
        palette.isDark ? const Color(0xFF555555) : const Color(0xFFE6E6E6);
    return LibraryFormField(
      label: label,
      action: action,
      child: Container(
        height: LibraryMetrics.defaultFieldHeight,
        decoration: BoxDecoration(
          color: palette.field,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(2),
        ),
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
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: option.$1 == value ? selectedFill : null,
                        border: index == 0
                            ? null
                            : Border(left: BorderSide(color: border)),
                      ),
                      child: Text(
                        option.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: option.$1 == value
                              ? palette.textPrimary
                              : palette.textMuted,
                        ),
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
