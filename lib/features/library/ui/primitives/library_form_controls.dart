import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Compact external labels shared by catalog and personal forms.
class LibraryFormField extends StatelessWidget {
  const LibraryFormField({super.key, required this.label, required this.child, this.action});
  final String label;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(child: Text(label, style: TextStyle(
              color: appPalette(context).textMuted, fontSize: 13, fontWeight: FontWeight.w600,
            ))),
            if (action != null) action!,
          ]),
          const SizedBox(height: 3),
          child,
        ],
      );
}

/// Shared unlabelled text input used inside the common labelled form chrome.
/// Callers own field meaning and draft updates; this owns input appearance.
class LibraryTextFormControl extends StatelessWidget {
  const LibraryTextFormControl({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
    this.decoration,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscureText;
  final bool enabled;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        validator: validator,
        onChanged: onChanged,
        keyboardType: keyboardType,
        maxLines: maxLines,
        obscureText: obscureText,
        enabled: enabled,
        decoration: (decoration ?? const InputDecoration()).copyWith(
          constraints: const BoxConstraints(
            minHeight: kLibraryFormControlHeight,
          ),
        ),
      );
}

class LibraryFormGroup extends StatelessWidget {
  const LibraryFormGroup({super.key, required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Stack(children: [
    Padding(padding: const EdgeInsets.only(top: 9), child: Container(
      width: double.infinity, padding: const EdgeInsets.fromLTRB(10, 19, 10, 10),
      decoration: BoxDecoration(border: Border.all(color: appPalette(context).divider), borderRadius: BorderRadius.circular(3)),
      child: child,
    )),
    Align(alignment: Alignment.topCenter, child: ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Text(title, style: TextStyle(color: appPalette(context).textMuted, fontWeight: FontWeight.w600, fontSize: 15))),
    )),
  ]);
}

class LibraryPartialDateInput extends StatefulWidget {
  const LibraryPartialDateInput({super.key, this.value, required this.onChanged});
  final PartialDate? value;
  final ValueChanged<PartialDate?> onChanged;

  @override
  State<LibraryPartialDateInput> createState() => _LibraryPartialDateInputState();
}

class _LibraryPartialDateInputState extends State<LibraryPartialDateInput> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = [
      TextEditingController(text: widget.value?.year?.toString() ?? ''),
      TextEditingController(text: widget.value?.month?.toString().padLeft(2, '0') ?? ''),
      TextEditingController(text: widget.value?.day?.toString().padLeft(2, '0') ?? ''),
    ];
  }

  @override
  void didUpdateWidget(LibraryPartialDateInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value || widget.value == _read()) return;
    final parts = [widget.value?.year, widget.value?.month, widget.value?.day];
    for (var i = 0; i < 3; i++) {
      _controllers[i].text = parts[i]?.toString().padLeft(i == 0 ? 4 : 2, '0') ?? '';
    }
  }

  PartialDate? _read() {
    final parts = _controllers.map((c) => int.tryParse(c.text)).toList();
    if (parts.every((part) => part == null)) return null;
    if ((parts[0] != null && (parts[0]! < 1 || parts[0]! > 9999)) ||
        (parts[1] != null && (parts[1]! < 1 || parts[1]! > 12)) ||
        (parts[2] != null && (parts[2]! < 1 || parts[2]! > 31))) return widget.value;
    return PartialDate(year: parts[0], month: parts[1], day: parts[2]);
  }

  @override
  void dispose() {
    for (final controller in _controllers) { controller.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(flex: i == 0 ? 3 : 2, child: TextFormField(
            controller: _controllers[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(i == 0 ? 4 : 2)],
            decoration: InputDecoration(hintText: ['YYYY', 'MM', 'DD'][i]),
            validator: (raw) {
              if (raw == null || raw.isEmpty) return null;
              final value = int.tryParse(raw);
              final max = [9999, 12, 31][i];
              if (value == null || value < 1 || value > max) return 'Invalid';
              final date = _read();
              if (date?.isFullDate == true && date?.asDateTime == null) return 'Invalid';
              return null;
            },
            onChanged: (_) => widget.onChanged(_read()),
          )),
        ],
      ]);
}

/// CLZ-style mutually exclusive choices; shared by enum and boolean fields.
class LibrarySegmentedField<T> extends StatelessWidget {
  const LibrarySegmentedField({super.key, required this.value, required this.options, required this.onChanged});
  final T? value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Row(children: [
        for (final entry in options.entries)
          Expanded(child: SizedBox(height: 34, child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: value == entry.key ? appPalette(context).surfaceBright : appPalette(context).surface,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              foregroundColor: value == entry.key ? appPalette(context).textPrimary : appPalette(context).textMuted,
              shape: const RoundedRectangleBorder(),
            ),
            onPressed: () => onChanged(entry.key),
            child: Text(entry.value),
          ))),
      ]);
}
