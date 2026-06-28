import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:flutter/material.dart';

class EditableNameListField extends StatefulWidget {
  const EditableNameListField({
    super.key,
    required this.values,
    required this.onChanged,
    required this.hintText,
  });

  final List<String> values;
  final ValueChanged<List<String>> onChanged;
  final String hintText;

  @override
  State<EditableNameListField> createState() => _EditableNameListFieldState();
}

class _EditableNameListFieldState extends State<EditableNameListField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addValue() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      return;
    }
    final exists = widget.values.any(
      (existing) => existing.toLowerCase() == value.toLowerCase(),
    );
    if (!exists) {
      widget.onChanged([...widget.values, value]);
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final values = widget.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (values.isEmpty)
          const Text('No entries', style: TextStyle(color: kEditTextMuted))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var index = 0; index < values.length; index++)
                InputChip(
                  label: Text(values[index]),
                  onDeleted: () {
                    final updated = List<String>.from(values)..removeAt(index);
                    widget.onChanged(updated);
                  },
                ),
            ],
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _addValue(),
                decoration: InputDecoration(
                  labelText: widget.hintText,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _addValue,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }
}

class EditableChipField extends StatefulWidget {
  const EditableChipField({
    super.key,
    required this.label,
    required this.values,
    required this.suggestions,
    required this.onChanged,
  });

  final String label;
  final List<String> values;
  final List<String> suggestions;
  final ValueChanged<List<String>> onChanged;

  @override
  State<EditableChipField> createState() => _EditableChipFieldState();
}

class _EditableChipFieldState extends State<EditableChipField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addValue([String? initial]) {
    final raw = (initial ?? _controller.text).trim();
    if (raw.isEmpty) {
      return;
    }
    final exists = widget.values.any(
      (value) => value.toLowerCase() == raw.toLowerCase(),
    );
    if (!exists) {
      widget.onChanged([...widget.values, raw]);
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final values = widget.values;
    final suggestions = widget.suggestions
        .where(
          (candidate) => !values.any(
            (value) => value.toLowerCase() == candidate.toLowerCase(),
          ),
        )
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (values.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var index = 0; index < values.length; index++)
                InputChip(
                  label: Text(values[index]),
                  onDeleted: () {
                    final updated = List<String>.from(values)..removeAt(index);
                    widget.onChanged(updated);
                  },
                ),
            ],
          ),
        if (values.isNotEmpty) const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _addValue(),
                decoration: InputDecoration(
                  labelText: 'Add ${widget.label}',
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _addValue,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final suggestion in suggestions)
                ActionChip(
                  label: Text(suggestion),
                  onPressed: () => _addValue(suggestion),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class EditableMusicianListField extends StatefulWidget {
  const EditableMusicianListField({
    super.key,
    required this.values,
    required this.onChanged,
    required this.hintName,
    required this.hintInstrument,
  });

  final List<MusicCreditEntry> values;
  final ValueChanged<List<MusicCreditEntry>> onChanged;
  final String hintName;
  final String hintInstrument;

  @override
  State<EditableMusicianListField> createState() =>
      _EditableMusicianListFieldState();
}

class _EditableMusicianListFieldState extends State<EditableMusicianListField> {
  late final TextEditingController _nameController;
  late final TextEditingController _instrumentController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _instrumentController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instrumentController.dispose();
    super.dispose();
  }

  void _addValue() {
    final name = _nameController.text.trim();
    final instrument = emptyToNull(_instrumentController.text);
    if (name.isEmpty) {
      return;
    }
    final exists = widget.values.any(
      (value) =>
          value.name.toLowerCase() == name.toLowerCase() &&
          (value.instrument ?? '').toLowerCase() ==
              (instrument ?? '').toLowerCase(),
    );
    if (!exists) {
      widget.onChanged([
        ...widget.values,
        MusicCreditEntry(
          name: name,
          instrument: instrument,
        ),
      ]);
    }
    _nameController.clear();
    _instrumentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final values = widget.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (values.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var index = 0; index < values.length; index++)
                InputChip(
                  label: Text(values[index].label),
                  onDeleted: () {
                    final updated = List<MusicCreditEntry>.from(values)
                      ..removeAt(index);
                    widget.onChanged(updated);
                  },
                ),
            ],
          ),
        if (values.isNotEmpty) const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: widget.hintName),
                onSubmitted: (_) => _addValue(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _instrumentController,
                decoration: InputDecoration(labelText: widget.hintInstrument),
                onSubmitted: (_) => _addValue(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _addValue,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }
}

class MusicCreditEntry {
  const MusicCreditEntry({
    required this.name,
    this.instrument,
  });

  final String name;
  final String? instrument;

  String get label => instrument == null || instrument!.trim().isEmpty
      ? name
      : '$name (${instrument!.trim()})';
}

class EditablePersonCreditRow extends StatelessWidget {
  const EditablePersonCreditRow({
    super.key,
    required this.dragHandle,
    required this.primaryField,
    this.avatar = const Icon(Icons.person, size: 18),
    this.secondaryField,
    this.trailingActions = const [],
    this.stacked = false,
  });

  final Widget dragHandle;
  final Widget avatar;
  final Widget primaryField;
  final Widget? secondaryField;
  final List<Widget> trailingActions;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final gap = const SizedBox(width: 8);
    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              dragHandle,
              gap,
              SizedBox(width: 28, child: Center(child: avatar)),
              gap,
              Expanded(child: primaryField),
              ...trailingActions,
            ],
          ),
          if (secondaryField != null) ...[
            const SizedBox(height: 8),
            secondaryField!,
          ],
        ],
      );
    }
    return Row(
      children: [
        dragHandle,
        gap,
        SizedBox(width: 28, child: Center(child: avatar)),
        gap,
        SizedBox(width: 180, child: primaryField),
        if (secondaryField != null) ...[
          gap,
          Expanded(child: secondaryField!),
        ],
        ...trailingActions,
      ],
    );
  }
}
