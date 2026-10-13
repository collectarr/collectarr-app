import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/library/serial/serial_authority_dialog.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:flutter/material.dart';

/// Series selection mechanics shared by kinds that link catalog entries to a
/// serial authority record.
///
/// The owning kind remains responsible for storing the selected title and ID.
class LibrarySeriesSelectorField extends StatefulWidget {
  const LibrarySeriesSelectorField({
    super.key,
    required this.database,
    required this.mediaKind,
    required this.initialTitle,
    required this.initialSeriesId,
    required this.onChanged,
    this.label = 'Series',
  });

  final LocalDatabase database;
  final String mediaKind;
  final String initialTitle;
  final String? initialSeriesId;
  final void Function(String title, String? coreSeriesId) onChanged;
  final String label;

  @override
  State<LibrarySeriesSelectorField> createState() =>
      _LibrarySeriesSelectorFieldState();
}

class _LibrarySeriesSelectorFieldState
    extends State<LibrarySeriesSelectorField> {
  late final TextEditingController _controller;
  List<SerialAuthorityEntry> _entries = const [];
  String? _selectedSeriesId;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
    _selectedSeriesId = widget.initialSeriesId;
    _loadEntries();
  }

  @override
  void didUpdateWidget(covariant LibrarySeriesSelectorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    var shouldReload = false;
    if (oldWidget.initialTitle != widget.initialTitle &&
        _controller.text != widget.initialTitle) {
      _controller.value = TextEditingValue(
        text: widget.initialTitle,
        selection: TextSelection.collapsed(offset: widget.initialTitle.length),
      );
      shouldReload = true;
    }
    if (oldWidget.initialSeriesId != widget.initialSeriesId) {
      _selectedSeriesId = widget.initialSeriesId;
      shouldReload = true;
    }
    if (oldWidget.database != widget.database ||
        oldWidget.mediaKind != widget.mediaKind) {
      shouldReload = true;
    }
    if (shouldReload) {
      _loadEntries();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final generation = ++_loadGeneration;
    final entries =
        await SerialAuthorityRepository(widget.database).searchEntries(
      mediaKind: widget.mediaKind,
      selectedTitle: _controller.text,
      selectedSeriesId: _selectedSeriesId,
    );
    if (!mounted || generation != _loadGeneration) return;
    setState(() => _entries = entries);
  }

  Future<void> _openPicker() async {
    final selected = await showSeriesPickerDialog(
      context: context,
      db: widget.database,
      mediaKind: widget.mediaKind,
      selectedTitle: _controller.text,
      selectedSeriesId: _selectedSeriesId,
    );
    if (!mounted || selected == null) return;
    _controller.value = TextEditingValue(
      text: selected.title,
      selection: TextSelection.collapsed(offset: selected.title.length),
    );
    _selectedSeriesId = selected.coreSeriesId;
    widget.onChanged(selected.title, selected.coreSeriesId);
    await _loadEntries();
  }

  void _setSeries(String? value) {
    final title = (value ?? '').trim();
    final normalizedTitle = title.toLowerCase();
    SerialAuthorityEntry? match;
    for (final entry in _entries) {
      if (entry.title.trim().toLowerCase() == normalizedTitle) {
        match = entry;
        break;
      }
    }
    _selectedSeriesId = match?.coreSeriesId;
    widget.onChanged(title, _selectedSeriesId);
  }

  @override
  Widget build(BuildContext context) => LibraryVocabularyField(
        controller: _controller,
        options: [for (final entry in _entries) entry.title],
        label: widget.label,
        onChanged: _setSeries,
        onManage: _openPicker,
        manageTooltip: 'Select or manage series',
      );
}
