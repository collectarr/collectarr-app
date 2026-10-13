import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:flutter/material.dart';

/// Labelled, segmented popup used by custom-field definition options.
class CustomFieldSelect<T> extends StatelessWidget {
  const CustomFieldSelect(
      {super.key,
      required this.label,
      required this.value,
      required this.items,
      required this.onChanged,
      this.display,
      this.height = 34});
  final String label;
  final T? value;
  final List<(T, Widget)> items;
  final ValueChanged<T>? onChanged;
  final Widget? display;
  final double height;
  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return CustomFieldDefinitionField(
        label: label,
        labelStyle: const TextStyle(fontSize: 13, height: 20 / 13),
        child: PopupMenuButton<T>(
          tooltip: 'Choose $label',
          enabled: onChanged != null,
          popUpAnimationStyle: AnimationStyle.noAnimation,
          position: PopupMenuPosition.under,
          color: palette.panelRaised,
          shape:
              RoundedRectangleBorder(side: BorderSide(color: palette.divider)),
          constraints: const BoxConstraints(
              minWidth: 250, maxWidth: 570, maxHeight: 460),
          onSelected: onChanged,
          itemBuilder: (_) => [
            for (final item in items)
              PopupMenuItem<T>(value: item.$1, height: height, child: item.$2)
          ],
          child: Container(
              height: height,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  color: palette.panelRaised,
                  border: Border.all(color: palette.divider),
                  borderRadius: BorderRadius.circular(3)),
              child: Row(children: [
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: display ??
                            (value == null
                                ? const SizedBox.shrink()
                                : items
                                    .firstWhere((item) => item.$1 == value)
                                    .$2))),
                if (onChanged != null)
                  Container(
                      width: 33,
                      height: height,
                      color: palette.divider,
                      child: Icon(AppIcons.caretDown,
                          size: 12, color: palette.textPrimary)),
              ])),
        ));
  }
}

/// The five-pixel field insets used by definition and tab-settings forms.
class CustomFieldDefinitionField extends StatelessWidget {
  const CustomFieldDefinitionField(
      {super.key,
      required this.label,
      required this.child,
      this.action,
      this.labelStyle});
  final String label;
  final Widget child;
  final Widget? action;
  final TextStyle? labelStyle;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: LibraryFormField(
          label: label,
          action: action,
          labelStyle:
              labelStyle ?? const TextStyle(fontSize: 13, height: 20 / 13),
          child: child));
}
