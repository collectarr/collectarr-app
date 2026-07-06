import 'package:collectarr_app/core/utils/text_utils.dart'
    show formatCompactDate;
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/ui/theme/theme_palette.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/core/utils/text_utils.dart'
    show noNewlineFormatter, formatCompactDate;

const double kCompactControlHeight = 30;
const double kCompactMenuItemHeight = 30;

/// Derives a dark background tinted by [accent] for popup menus and buttons.
Color compactMenuBackgroundFor(Color accent, AppThemePalette palette) {
  if (palette.isDark) {
    return Color.alphaBlend(
      accent.withValues(alpha: 0.18),
      palette.surfaceDim,
    );
  }
  return Color.alphaBlend(
    accent.withValues(alpha: 0.08),
    palette.surfaceSubtle,
  );
}

/// Derives a light text color tinted by [accent] for popup menus and buttons.
Color compactMenuTextFor(Color accent, AppThemePalette palette) {
  if (palette.isDark) {
    return Color.alphaBlend(
        accent.withValues(alpha: 0.40), palette.textPrimary);
  }
  return palette.textPrimary;
}

Color compactMenuBorderFor(Color accent, AppThemePalette palette) {
  return palette.isDark
      ? accent.withValues(alpha: 0.74)
      : Color.alphaBlend(accent.withValues(alpha: 0.22), palette.divider);
}

class CompactDropdown extends StatelessWidget {
  const CompactDropdown({
    super.key,
    required this.width,
    required this.value,
    required this.items,
    required this.label,
    required this.accent,
    required this.onChanged,
  });

  final double width;
  final String? value;
  final List<String> items;
  final String label;
  final Color accent;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedValue = items.contains(value) ? value : null;
    final palette = appPalette(context);
    final bg = compactMenuBackgroundFor(accent, palette);
    return PopupMenuButton<String?>(
      initialValue: selectedValue,
      tooltip: label,
      position: PopupMenuPosition.under,
      color: bg,
      elevation: 10,
      constraints: BoxConstraints(minWidth: width, maxWidth: 220),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: compactMenuBorderFor(accent, palette)),
      ),
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final item in items)
          PopupMenuItem<String?>(
            value: item,
            height: kCompactMenuItemHeight,
            padding: EdgeInsets.zero,
            child: CompactPopupMenuRow(
              label: item,
              selected: item == selectedValue,
              accent: accent,
            ),
          ),
      ],
      child: CompactMenuButton(
        width: width,
        label: selectedValue ?? label,
        accent: accent,
      ),
    );
  }
}

class CompactDropdownWithNone extends StatelessWidget {
  const CompactDropdownWithNone({
    super.key,
    required this.width,
    required this.value,
    required this.items,
    required this.label,
    required this.accent,
    required this.onChanged,
  });

  final double width;
  final String? value;
  final List<String> items;
  final String label;
  final Color accent;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedValue = items.contains(value) ? value : null;
    final palette = appPalette(context);
    final bg = compactMenuBackgroundFor(accent, palette);
    return PopupMenuButton<String?>(
      initialValue: selectedValue,
      tooltip: label,
      position: PopupMenuPosition.under,
      color: bg,
      elevation: 10,
      constraints: BoxConstraints(minWidth: width, maxWidth: 220),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: compactMenuBorderFor(accent, palette)),
      ),
      onSelected: onChanged,
      itemBuilder: (context) => [
        compactPopupMenuItem<String?>(
          value: null,
          label: '$label: none',
          selected: selectedValue == null,
          accent: accent,
        ),
        for (final item in items)
          compactPopupMenuItem<String?>(
            value: item,
            label: item,
            selected: item == selectedValue,
            accent: accent,
          ),
      ],
      child: CompactMenuButton(
        width: width,
        label: selectedValue ?? label,
        accent: accent,
      ),
    );
  }
}

PopupMenuItem<T> compactPopupMenuItem<T>({
  required T value,
  required String label,
  required bool selected,
  required Color accent,
}) {
  return PopupMenuItem<T>(
    value: value,
    height: kCompactMenuItemHeight,
    padding: EdgeInsets.zero,
    child: CompactPopupMenuRow(
      label: label,
      selected: selected,
      accent: accent,
    ),
  );
}

class CompactPopupMenuRow extends StatelessWidget {
  const CompactPopupMenuRow({
    super.key,
    required this.label,
    required this.selected,
    required this.accent,
  });

  final String label;
  final bool selected;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final textColor = compactMenuTextFor(accent, palette);
    return Container(
      height: kCompactMenuItemHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: selected
            ? (palette.isDark
                ? accent.withValues(alpha: 0.26)
                : palette.selection)
            : Colors.transparent,
        border:
            selected ? Border(left: BorderSide(color: accent, width: 3)) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child:
                selected ? Icon(Icons.check, color: textColor, size: 15) : null,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompactInputShell extends StatelessWidget {
  const CompactInputShell({
    super.key,
    required this.accent,
    required this.child,
  });

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      height: kCompactControlHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: compactMenuBackgroundFor(accent, palette),
        border: Border.all(color: compactMenuBorderFor(accent, palette)),
        borderRadius: BorderRadius.zero,
      ),
      child: child,
    );
  }
}

class CompactDateButton extends StatelessWidget {
  const CompactDateButton({
    super.key,
    required this.label,
    required this.accent,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final Color accent;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showLibraryDateEntryDialog(
          context,
          label: 'Purchase date',
          initialDate: value,
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      borderRadius: BorderRadius.zero,
      child: CompactMenuFrame(
        width: 150,
        label: value == null ? label : formatCompactDate(value!),
        accent: accent,
        leading: Icons.calendar_today,
      ),
    );
  }
}

class CompactMenuButton extends StatelessWidget {
  const CompactMenuButton({
    super.key,
    required this.width,
    required this.label,
    required this.accent,
    this.enabled = true,
  });

  final double width;
  final String label;
  final Color accent;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final textColor = compactMenuTextFor(accent, palette);
    final color = enabled ? textColor : palette.textMuted;
    return Opacity(
      opacity: enabled ? 1 : 0.62,
      child: CompactMenuFrame(
        width: width,
        label: label,
        accent: accent,
        enabledColor: color,
        trailing: Icons.arrow_drop_down,
      ),
    );
  }
}

class CompactMenuFrame extends StatelessWidget {
  const CompactMenuFrame({
    super.key,
    required this.width,
    required this.label,
    required this.accent,
    this.enabledColor,
    this.leading,
    this.trailing,
  });

  final double width;
  final String label;
  final Color accent;
  final Color? enabledColor;
  final IconData? leading;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final color = enabledColor ?? compactMenuTextFor(accent, palette);
    return Container(
      width: width,
      height: kCompactControlHeight,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: compactMenuBackgroundFor(accent, palette),
        border: Border.all(color: compactMenuBorderFor(accent, palette)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            Icon(leading, color: color, size: 15),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (trailing != null) Icon(trailing, color: color, size: 18),
        ],
      ),
    );
  }
}
