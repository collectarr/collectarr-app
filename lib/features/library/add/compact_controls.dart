import 'package:flutter/material.dart';

export 'package:collectarr_app/core/utils/text_utils.dart'
    show noNewlineFormatter, formatCompactDate;

const double kCompactControlHeight = 30;
const double kCompactMenuItemHeight = 30;
const Color kCompactMenuBackground = Color(0xFF183246);
const Color kCompactMenuText = Color(0xFFBFEFFF);

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
    return PopupMenuButton<String?>(
      initialValue: selectedValue,
      tooltip: label,
      position: PopupMenuPosition.under,
      color: kCompactMenuBackground,
      elevation: 10,
      constraints: BoxConstraints(minWidth: width, maxWidth: 220),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
        side: BorderSide(color: accent.withValues(alpha: 0.74)),
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
    return PopupMenuButton<String?>(
      initialValue: selectedValue,
      tooltip: label,
      position: PopupMenuPosition.under,
      color: kCompactMenuBackground,
      elevation: 10,
      constraints: BoxConstraints(minWidth: width, maxWidth: 220),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
        side: BorderSide(color: accent.withValues(alpha: 0.74)),
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
    return Container(
      height: kCompactMenuItemHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: selected ? accent.withValues(alpha: 0.26) : Colors.transparent,
        border: selected
            ? Border(left: BorderSide(color: accent, width: 3))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: selected
                ? const Icon(Icons.check, color: kCompactMenuText, size: 15)
                : null,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: kCompactMenuText,
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
    return Container(
      height: kCompactControlHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kCompactMenuBackground,
        border: Border.all(color: accent.withValues(alpha: 0.82)),
        borderRadius: BorderRadius.circular(3),
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
    required this.onPressed,
  });

  final String label;
  final Color accent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(3),
      child: CompactMenuFrame(
        width: 150,
        label: label,
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
    final color = enabled ? kCompactMenuText : const Color(0xFF7B8790);
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
    this.enabledColor = kCompactMenuText,
    this.leading,
    this.trailing,
  });

  final double width;
  final String label;
  final Color accent;
  final Color enabledColor;
  final IconData? leading;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: kCompactControlHeight,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: kCompactMenuBackground,
        border: Border.all(color: accent.withValues(alpha: 0.82)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            Icon(leading, color: enabledColor, size: 15),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: enabledColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (trailing != null) Icon(trailing, color: enabledColor, size: 18),
        ],
      ),
    );
  }
}
