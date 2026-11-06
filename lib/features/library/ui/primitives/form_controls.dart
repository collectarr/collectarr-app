import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/ui/metrics.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/ui/anchored_calendar.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enables the native editor's taller, internally labelled text fields while
/// leaving the shared desktop/web controls and draft ownership untouched.
class LibraryMobileEditFormScope extends InheritedWidget {
  const LibraryMobileEditFormScope({super.key, required super.child});

  static bool active(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<LibraryMobileEditFormScope>() !=
      null;

  @override
  bool updateShouldNotify(LibraryMobileEditFormScope oldWidget) => false;
}

class _MobileFieldLabel extends InheritedWidget {
  const _MobileFieldLabel({required this.label, required super.child});

  final String label;

  static String? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_MobileFieldLabel>()?.label;

  @override
  bool updateShouldNotify(_MobileFieldLabel oldWidget) =>
      label != oldWidget.label;
}

/// A composite control whose inner text input can receive the field label.
abstract interface class LibraryMobileInlineLabelControl {}

/// Compact external labels shared by catalog and personal forms.
class LibraryFormField extends StatelessWidget {
  const LibraryFormField(
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
  Widget build(BuildContext context) {
    if (LibraryMobileEditFormScope.active(context) &&
        (child is LibraryTextFormControl ||
            child is LibraryMobileInlineLabelControl)) {
      final field = _MobileFieldLabel(label: label, child: child);
      if (action == null) return field;
      return Row(children: [
        Expanded(child: field),
        SizedBox(width: 32, height: 56, child: Center(child: action)),
      ]);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 20,
          child: Row(children: [
            Expanded(
                child: Text(label,
                    style: TextStyle(
                      // The reference draws labels white at 70% (#C4C4C4
                      // on the dialog panel) and #333 in the light skin.
                      color: appPalette(context).isDark
                          ? appPalette(context)
                              .textPrimary
                              .withValues(alpha: 0.7)
                          : appPalette(context).textPrimary,
                      fontSize: 13,
                      fontWeight: kAppBoldFontWeight,
                      height: 20 / 14,
                      letterSpacing: 0,
                    ).merge(labelStyle))),
            if (action != null) action!,
          ]),
        ),
        const SizedBox(height: 1),
        child,
      ],
    );
  }
}

/// Shared unlabelled text input used inside the common labelled form chrome.
/// Callers own field meaning and draft updates; this owns input appearance.
class LibraryTextFormControl extends StatelessWidget {
  const LibraryTextFormControl({
    super.key,
    this.controller,
    this.initialValue,
    this.validator,
    this.autovalidateMode,
    this.onChanged,
    this.decoration,
    this.minimumHeight = LibraryMetrics.defaultFieldHeight,
    this.keyboardType,
    this.inputFormatters,
    this.minLines,
    this.maxLines = 1,
    this.expands = false,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.style,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.onFieldSubmitted,
    this.cursorColor,
  }) : assert(controller == null || initialValue == null);

  final TextEditingController? controller;
  final String? initialValue;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final ValueChanged<String>? onChanged;
  final InputDecoration? decoration;
  final double minimumHeight;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? minLines;
  final int? maxLines;
  final bool expands;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Color? cursorColor;

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = appPalette(context).utilityAction;
    final effectiveCursorColor = cursorColor ?? effectiveAccent;
    final mobileLabel = _MobileFieldLabel.of(context);
    final nativeField = mobileLabel != null;
    final mobileDecoration = nativeField
        ? (decoration ?? const InputDecoration()).copyWith(
            labelText: mobileLabel,
            labelStyle: const TextStyle(fontSize: 16),
            floatingLabelStyle: const TextStyle(fontSize: 12),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: false,
            fillColor: Colors.transparent,
            border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: appPalette(context).divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                  color: appPalette(context).utilityAction, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            constraints: const BoxConstraints(minHeight: 56),
          )
        : null;
    return TextFormField(
      controller: controller,
      cursorColor: effectiveCursorColor,
      initialValue: initialValue,
      focusNode: focusNode,
      autofocus: autofocus,
      validator: validator,
      autovalidateMode: autovalidateMode,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      minLines: minLines,
      maxLines: maxLines,
      expands: expands,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      style: style ??
          (nativeField
              ? context.libraryTextTheme.controlText.copyWith(fontSize: 16)
              : context.libraryTextTheme.controlText),
      textAlign: textAlign,
      textAlignVertical: TextAlignVertical.center,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      decoration: mobileDecoration ??
          (decoration ?? const InputDecoration()).copyWith(
            constraints: BoxConstraints(minHeight: minimumHeight),
            contentPadding: (maxLines == 1 &&
                    minimumHeight == LibraryMetrics.defaultFieldHeight)
                // The outline and fill follow the content, not the minimum
                // height, so the padding itself makes the 34 px field.
                ? const EdgeInsets.symmetric(horizontal: 7, vertical: 7)
                : decoration?.contentPadding,
          ),
    );
  }
}

class LibraryFormGroup extends StatelessWidget {
  const LibraryFormGroup(
      {super.key,
      required this.title,
      required this.child,
      this.titleSize = 16.8});
  final String title;
  final Widget child;
  final double titleSize;
  @override
  Widget build(BuildContext context) => Stack(children: [
        Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 19, 10, 10),
              decoration: BoxDecoration(
                  border: Border.all(color: appPalette(context).divider),
                  borderRadius: BorderRadius.circular(3)),
              child: child,
            )),
        Align(
            alignment: Alignment.topCenter,
            child: ColoredBox(
              color: appPalette(context).panelRaised,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Text(title,
                      style: TextStyle(
                          color: appPalette(context).isDark
                              ? const Color(0xFF999999)
                              : appPalette(context).textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: titleSize,
                          height: 24 / titleSize))),
            )),
      ]);
}

/// The one labelled date field: the calendar sits in the label row and the
/// YYYY, MM and DD boxes follow the entry order chosen in Settings.
class LibraryPartialDateField extends StatelessWidget {
  const LibraryPartialDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.focusNode,
    this.labelStyle,
  });

  /// Binds a full [DateTime]: only a complete date or a cleared field is
  /// reported, so typing a year alone keeps the stored date.
  LibraryPartialDateField.fullDate({
    super.key,
    required this.label,
    required DateTime? date,
    required ValueChanged<DateTime?> onDateChanged,
    this.focusNode,
    this.labelStyle,
  })  : value = date == null ? null : PartialDate.fromDateTime(date.toLocal()),
        onChanged = ((parts) {
          if (parts == null || parts.isEmpty) {
            onDateChanged(null);
          } else if (parts.asDateTime != null) {
            onDateChanged(DateTime(parts.year!, parts.month!, parts.day!));
          }
        });

  final String label;
  final PartialDate? value;
  final ValueChanged<PartialDate?> onChanged;
  final FocusNode? focusNode;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    if (LibraryMobileEditFormScope.active(context)) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final showCalendar = constraints.maxWidth >= 140;
          return InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: appPalette(context).divider),
              ),
              contentPadding: const EdgeInsets.fromLTRB(6, 4, 4, 4),
              constraints: const BoxConstraints(minHeight: 56),
            ),
            child: Row(children: [
              Expanded(
                child: LibraryPartialDateInput(
                  value: value,
                  focusNode: focusNode,
                  onChanged: onChanged,
                ),
              ),
              if (showCalendar)
                IconButton(
                  tooltip: 'Choose $label',
                  icon: Icon(AppIcons.calendar,
                      size: 18, color: appPalette(context).utilityAction),
                  constraints:
                      const BoxConstraints.tightFor(width: 32, height: 40),
                  padding: EdgeInsets.zero,
                  onPressed: () => _chooseDate(context),
                ),
            ]),
          );
        },
      );
    }
    return LibraryFormField(
      label: label,
      labelStyle: labelStyle,
      action: Builder(
        builder: (context) => Tooltip(
          message: 'Choose $label',
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            onTap: () => _chooseDate(context),
            child: SizedBox(
              width: 22,
              height: 16,
              child: Center(
                child: Icon(
                  AppIcons.calendar,
                  size: 14,
                  color: appPalette(context).textMuted,
                ),
              ),
            ),
          ),
        ),
      ),
      child: LibraryPartialDateInput(
        value: value,
        focusNode: focusNode,
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _chooseDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showAppAnchoredCalendar(
      context: context,
      initialDate: value?.asDateTime ??
          DateTime(value?.year ?? now.year, value?.month ?? 1),
      firstDate: DateTime(1),
      lastDate: DateTime(9999, 12, 31),
    );
    if (picked != null) onChanged(PartialDate.fromDateTime(picked));
  }
}

class LibraryPartialDateInput extends StatefulWidget {
  const LibraryPartialDateInput({
    super.key,
    this.value,
    required this.onChanged,
    this.focusNode,
  });
  final PartialDate? value;
  final ValueChanged<PartialDate?> onChanged;
  final FocusNode? focusNode;

  @override
  State<LibraryPartialDateInput> createState() =>
      _LibraryPartialDateInputState();
}

class _LibraryPartialDateInputState extends State<LibraryPartialDateInput> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = [
      TextEditingController(text: widget.value?.year?.toString() ?? ''),
      TextEditingController(
          text: widget.value?.month?.toString().padLeft(2, '0') ?? ''),
      TextEditingController(
          text: widget.value?.day?.toString().padLeft(2, '0') ?? ''),
    ];
  }

  @override
  void didUpdateWidget(LibraryPartialDateInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value || widget.value == _read()) return;
    final parts = [widget.value?.year, widget.value?.month, widget.value?.day];
    for (var i = 0; i < 3; i++) {
      _controllers[i].text =
          parts[i]?.toString().padLeft(i == 0 ? 4 : 2, '0') ?? '';
    }
  }

  PartialDate? _read() {
    final parts = _controllers.map((c) => int.tryParse(c.text)).toList();
    if (parts.every((part) => part == null)) return null;
    if ((parts[0] != null && (parts[0]! < 1 || parts[0]! > 9999)) ||
        (parts[1] != null && (parts[1]! < 1 || parts[1]! > 12)) ||
        (parts[2] != null && (parts[2]! < 1 || parts[2]! > 31))) {
      return widget.value;
    }
    return PartialDate(year: parts[0], month: parts[1], day: parts[2]);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Parts are stored year, month, day; Settings chooses the entry order.
    final order = dateEntryPartOrder(AppFormats.current.dateEntry);
    final nativeEditor = LibraryMobileEditFormScope.active(context);
    return Row(children: [
      for (var position = 0; position < 3; position++)
        for (final i in [order[position]]) ...[
          if (position > 0 && nativeEditor)
            Text('/', style: TextStyle(color: appPalette(context).textMuted))
          else if (position > 0)
            Container(
              key: ValueKey('partial-date-separator-$position'),
              width: 8,
              height: 1,
              color: appPalette(context).divider,
            ),
          Expanded(
              flex: i == 0 ? 3 : 2,
              child: LibraryTextFormControl(
                controller: _controllers[i],
                focusNode: position == 0 ? widget.focusNode : null,
                textAlign: TextAlign.center,
                style: nativeEditor
                    ? context.libraryTextTheme.controlText
                        .copyWith(fontSize: 14)
                    : null,
                minimumHeight:
                    nativeEditor ? 40 : LibraryMetrics.defaultFieldHeight,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(i == 0 ? 4 : 2)
                ],
                decoration: InputDecoration(
                  hintText: ['YYYY', 'MM', 'DD'][i],
                  hintStyle:
                      nativeEditor ? const TextStyle(fontSize: 14) : null,
                  border: nativeEditor ? InputBorder.none : null,
                  enabledBorder: nativeEditor ? InputBorder.none : null,
                  focusedBorder: nativeEditor ? InputBorder.none : null,
                  contentPadding: nativeEditor
                      ? const EdgeInsets.symmetric(horizontal: 1, vertical: 8)
                      : null,
                ),
                validator: (raw) {
                  if (raw == null || raw.isEmpty) return null;
                  final value = int.tryParse(raw);
                  final max = [9999, 12, 31][i];
                  if (value == null || value < 1 || value > max) {
                    return 'Invalid';
                  }
                  final date = _read();
                  if (date?.isFullDate == true && date?.asDateTime == null) {
                    return 'Invalid';
                  }
                  return null;
                },
                onChanged: (_) => widget.onChanged(_read()),
              )),
        ],
    ]);
  }
}

/// Indexes of year (0), month (1) and day (2) in the on-screen order.
List<int> dateEntryPartOrder(DateEntryOrder order) => switch (order) {
      DateEntryOrder.yearMonthDay => const [0, 1, 2],
      DateEntryOrder.dayMonthYear => const [2, 1, 0],
      DateEntryOrder.monthDayYear => const [1, 2, 0],
    };

/// CLZ-style mutually exclusive choices; shared by enum and boolean fields.
class LibrarySegmentedField<T> extends StatelessWidget {
  const LibrarySegmentedField(
      {super.key,
      required this.value,
      required this.options,
      required this.onChanged});
  final T? value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Row(children: [
        for (final entry in options.entries)
          Expanded(
              child: SizedBox(
                  height: LibraryMetrics.defaultFieldHeight,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: value == entry.key
                          ? appPalette(context).surfaceBright
                          : appPalette(context).surface,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      foregroundColor: value == entry.key
                          ? appPalette(context).textPrimary
                          : appPalette(context).textMuted,
                      shape: const RoundedRectangleBorder(),
                    ),
                    onPressed: () => onChanged(entry.key),
                    child: Text(entry.value),
                  ))),
      ]);
}
