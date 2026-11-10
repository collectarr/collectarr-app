import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';

final class BookAudioLengthField extends StatefulWidget {
  const BookAudioLengthField(
      {super.key, required this.minutes, required this.onChanged});
  final int? minutes;
  final ValueChanged<int?> onChanged;
  @override
  State<BookAudioLengthField> createState() => _BookAudioLengthFieldState();
}

final class _BookAudioLengthFieldState extends State<BookAudioLengthField> {
  late final TextEditingController _hours;
  late final TextEditingController _minutes;
  @override
  void initState() {
    super.initState();
    _hours = TextEditingController(
        text: widget.minutes == null ? '' : '${widget.minutes! ~/ 60}');
    _minutes = TextEditingController(
        text: widget.minutes == null ? '' : '${widget.minutes! % 60}');
  }

  void _changed(String _) => widget.onChanged(
        _hours.text.isEmpty && _minutes.text.isEmpty
            ? null
            : (int.tryParse(_hours.text) ?? 0) * 60 +
                (int.tryParse(_minutes.text) ?? 0),
      );
  String? _validate(String? text, {bool minutes = false}) {
    if (text == null || text.isEmpty) return null;
    final number = int.tryParse(text);
    return number == null || number < 0 || (minutes && number > 59)
        ? (minutes ? 'Enter 0–59 minutes' : 'Enter valid hours')
        : null;
  }

  @override
  void dispose() {
    _hours.dispose();
    _minutes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LibraryFormField(
      label: 'Audiobook Length',
      child: Row(children: [
        Expanded(
            child: LibraryTextFormControl(
                controller: _hours,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Hours'),
                validator: _validate,
                onChanged: _changed)),
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8), child: Text(':')),
        Expanded(
            child: LibraryTextFormControl(
                controller: _minutes,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Minutes'),
                validator: (value) => _validate(value, minutes: true),
                onChanged: _changed)),
      ]));
}
