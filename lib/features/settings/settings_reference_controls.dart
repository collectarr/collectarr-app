import 'package:collectarr_app/ui/app_icons.dart';
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
    fillColor: palette.isDark ? _fieldFill : palette.surface,
    // A dense dropdown line is 16 px; 9 px above and below make 34 px.
    contentPadding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
    border: border(palette.isDark ? _fieldBorder : palette.divider),
    enabledBorder: border(palette.isDark ? _fieldBorder : palette.divider),
    focusedBorder: border(palette.utilityAction),
  );
}

/// A select styled like the reference, without a floating label.
class SettingsSelect<T> extends StatelessWidget {
  const SettingsSelect({
    super.key,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
  });

  final T? value;
  final List<T> values;
  final String Function(T value) labelOf;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) => AppSelect<T>(
        value: value,
        decoration: settingsSelectDecoration(context),
        options: [for (final option in values) (option, labelOf(option))],
        onChanged: onChanged == null
            ? null
            : (selected) {
                if (selected != null) onChanged!(selected);
              },
      );
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
    final palette = appPalette(context);
    final ink = palette.isDark ? Colors.white : palette.textPrimary;
    return Semantics(
      checked: value,
      label: label,
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: SizedBox(
          height: 25,
          child: Row(children: [
            const SizedBox(width: 5),
            Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: value ? ink : Colors.transparent,
                border: Border.all(color: ink, width: 1.5),
                borderRadius: BorderRadius.circular(1),
              ),
              child: value
                  ? Icon(AppIcons.check, size: 10, color: palette.panel)
                  : null,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w400, height: 1)),
            ),
          ]),
        ),
      ),
    );
  }
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
    final palette = appPalette(context);
    final ink = palette.isDark ? Colors.white : palette.textPrimary;
    final selected = value == groupValue;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      label: label,
      child: InkWell(
        onTap: () => onChanged(value),
        child: SizedBox(
          height: 24,
          child: Row(children: [
            const SizedBox(width: 5),
            Container(
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
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, color: ink))
                  : null,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w400, height: 1)),
            ),
          ]),
        ),
      ),
    );
  }
}

/// A full-width 32 px grey button, as "Manage Exceptions" in the reference.
class SettingsBlockButton extends StatelessWidget {
  const SettingsBlockButton(
      {super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 32,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF666666),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            textStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          onPressed: onPressed,
          child: Text(label),
        ),
      );
}
