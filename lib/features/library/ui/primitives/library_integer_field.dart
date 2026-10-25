import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Digits only, with leading zeros dropped ("007" becomes "7", "000" "0").
final class _WholeNumberFormatter extends TextInputFormatter {
  const _WholeNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final text =
        digits.isEmpty ? '' : digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    return TextEditingValue(
        text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

/// A whole-number field with the reference's hover up/down arrows for quick
/// increments. Typing accepts only digits and drops leading zeros.
final class LibraryIntegerField extends StatefulWidget {
  const LibraryIntegerField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.validator,
    this.minimum = 0,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final int minimum;

  @override
  State<LibraryIntegerField> createState() => _LibraryIntegerFieldState();
}

final class _LibraryIntegerFieldState extends State<LibraryIntegerField> {
  late final _controller = TextEditingController(text: widget.initialValue);
  var _hovered = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _step(int delta) {
    final current = int.tryParse(_controller.text);
    final next = current == null ? widget.minimum : current + delta;
    _controller.text = '${next < widget.minimum ? widget.minimum : next}';
    widget.onChanged(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    Widget arrow(IconData icon, int delta) => Expanded(
        child: InkWell(
            onTap: () => _step(delta),
            child: SizedBox(
                width: 20,
                child: Icon(icon, size: 10, color: palette.textMuted))));
    return MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Stack(children: [
          LibraryTextFormControl(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: const [_WholeNumberFormatter()],
              validator: widget.validator,
              onChanged: widget.onChanged),
          if (_hovered)
            Positioned(
                right: 1,
                top: 1,
                bottom: 1,
                child: SizedBox(
                    width: 20,
                    child: Column(children: [
                      arrow(AppIcons.caretUp, 1),
                      arrow(AppIcons.caretDown, -1),
                    ]))),
        ]));
  }
}
