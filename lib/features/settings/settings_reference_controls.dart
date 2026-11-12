import 'package:collectarr_app/ui/app_checkbox.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/app_select.dart';
import 'package:flutter/material.dart';

/// Controls of the reference Settings page: blue group legends over 34 px
/// #444 selects, and compact 20 px checkbox and radio rows.

const _fieldFill = Color(0xFF444444);
const _fieldBorder = Color(0xFF666666);

/// A blue 14/700 group legend.
class SettingsLegend extends StatelessWidget {
  const SettingsLegend(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Text(label,
            style: TextStyle(
                color: appPalette(context).utilityAction,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 20 / 14)),
      );
}

/// A legend with its control, followed by the reference group gap.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.legend, required this.child});

  final String legend;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [SettingsLegend(legend), child],
        ),
      );
}

/// Two groups side by side with the reference 18 px gutter.
class SettingsGroupPair extends StatelessWidget {
  const SettingsGroupPair({super.key, required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 18),
          Expanded(child: right),
        ],
      );
}

/// The 34 px select decoration: #444 fill, #666 outline, 4 px corners.
InputDecoration settingsSelectDecoration(BuildContext context) {
  final palette = appPalette(context);
  OutlineInputBorder border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: color),
      );
  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: palette.isDark ? _fieldFill : palette.panelRaised,
    // A dense text line is 16 px; 9 px above and below make 34 px.
    contentPadding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
    border: border(palette.isDark ? _fieldBorder : palette.divider),
    enabledBorder: border(palette.isDark ? _fieldBorder : palette.divider),
    focusedBorder: border(palette.utilityAction),
  );
}

/// The 34 px select box: the 20 px value line with 7 px above and below, the
/// value 7 px from the left and the arrow 4 px from the right. Padding sets
/// the height because the outline is drawn around the content, not around
/// any larger constraint, and it makes up for the 4 px per density step that
/// a compact theme (desktop and web) takes off the decorator.
InputDecoration settingsDropdownDecoration(BuildContext context) {
  final vertical = 7 - Theme.of(context).visualDensity.vertical * 2;
  return settingsSelectDecoration(context).copyWith(
    contentPadding: EdgeInsets.fromLTRB(7, vertical, 4, vertical),
  );
}

/// The reference select arrow: a bold 9x6 chevron, white in the dark skin
/// and dimmed while the select is disabled.
Widget settingsSelectArrow(BuildContext context, bool enabled) {
  final palette = appPalette(context);
  final color = palette.isDark ? Colors.white : palette.textPrimary;
  return CustomPaint(
    size: const Size(9, 6),
    painter: _SelectChevronPainter(enabled ? color : color.withAlpha(0x66)),
  );
}

class _SelectChevronPainter extends CustomPainter {
  const _SelectChevronPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.miter;
    canvas.drawPath(
      Path()
        ..moveTo(0.7, 0.7)
        ..lineTo(size.width / 2, size.height - 1)
        ..lineTo(size.width - 0.7, 0.7),
      paint,
    );
  }

  @override
  bool shouldRepaint(_SelectChevronPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// A select styled like the reference, without a floating label.
class SettingsSelect<T> extends StatelessWidget {
  const SettingsSelect({
    super.key,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
    this.leadingOf,
    this.isOptionEnabled,
  });

  final T? value;
  final List<T> values;
  final String Function(T value) labelOf;
  final ValueChanged<T>? onChanged;
  final Widget? Function(T value)? leadingOf;
  final bool Function(T value)? isOptionEnabled;

  @override
  Widget build(BuildContext context) => AppSelect<T>(
        value: value,
        // Chrome's highlight for the reference's native select lists.
        optionHighlight: (fill: const Color(0xFF3B68D0), text: Colors.white),
        decoration: settingsDropdownDecoration(context),
        arrow: (enabled) => settingsSelectArrow(context, enabled),
        leadingOf: leadingOf,
        isOptionEnabled: isOptionEnabled,
        options: [for (final option in values) (option, labelOf(option))],
        onChanged: onChanged == null
            ? null
            : (selected) {
                if (selected != null) onChanged!(selected);
              },
      );
}

/// The reference's settings choice row: the mark and its label, which turn
/// #888 over 0.25 s under the pointer, with a hand cursor and no background.
/// [tintsMark] is false for radios, whose native control keeps its color.
class _SettingsChoiceRow extends StatefulWidget {
  const _SettingsChoiceRow({
    required this.label,
    required this.height,
    required this.onTap,
    required this.mark,
    this.tintsMark = true,
  });

  final String label;
  final double height;
  final VoidCallback? onTap;
  final Widget Function(Color ink) mark;
  final bool tintsMark;

  @override
  State<_SettingsChoiceRow> createState() => _SettingsChoiceRowState();
}

class _SettingsChoiceRowState extends State<_SettingsChoiceRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final ink = palette.isDark ? Colors.white : palette.textPrimary;
    final enabled = widget.onTap != null;
    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      heightFactor: 1,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(
                end: _hovered && enabled ? const Color(0xFF888888) : ink),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 250),
            builder: (context, color, _) => SizedBox(
              height: widget.height,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(width: 5),
                widget.mark(widget.tintsMark ? color! : ink),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(widget.label,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 20 / 14,
                          color: color)),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// A compact checkbox row: a 13 px white box and a 14/400 label.
class SettingsCheck extends StatelessWidget {
  const SettingsCheck({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final panel = appPalette(context).panel;
    return Semantics(
      checked: value,
      enabled: onChanged != null,
      label: label,
      child: _SettingsChoiceRow(
        label: label,
        height: 25,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        mark: (ink) => AppCheckMark(
          value: value,
          size: 13,
          look: AppCheckLook(
            fill: Colors.transparent,
            checkedFill: ink,
            check: panel,
            border: ink,
            checkedBorder: ink,
            borderWidth: 1.5,
            radius: 1,
          ),
        ),
      ),
    );
  }
}

/// Settings that fold away under a choice that turns them off, as the
/// reference's eBay options do when all eBay links are hidden: the height
/// eases over 250 ms and the content is clipped from the bottom.
class SettingsCollapse extends StatelessWidget {
  const SettingsCollapse(
      {super.key, required this.expanded, required this.child});

  final bool expanded;
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(end: expanded ? 1 : 0),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 250),
        curve: Curves.ease,
        child: ExcludeFocus(
            excluding: !expanded,
            child: ExcludeSemantics(excluding: !expanded, child: child)),
        builder: (context, height, child) => ClipRect(
            child: Align(
                alignment: Alignment.topCenter,
                heightFactor: height,
                child: child)),
      );
}

/// A compact radio row in the reference style.
class SettingsRadio<T> extends StatelessWidget {
  const SettingsRadio({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String label;
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      label: label,
      child: _SettingsChoiceRow(
        label: label,
        height: 24,
        onTap: () => onChanged(value),
        tintsMark: false,
        mark: (ink) => Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ink, width: 1.5),
          ),
          alignment: Alignment.center,
          child: selected
              ? Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: ink))
              : null,
        ),
      ),
    );
  }
}

/// A full-width 32 px grey button, as "Manage Exceptions" in the reference:
/// #666 with white text in the dark skin, #DDD with #333 text in the light.
class SettingsBlockButton extends StatelessWidget {
  const SettingsBlockButton(
      {super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return SizedBox(
      width: double.infinity,
      height: 32,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor:
              palette.isDark ? const Color(0xFF666666) : palette.divider,
          foregroundColor: palette.isDark ? Colors.white : palette.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
