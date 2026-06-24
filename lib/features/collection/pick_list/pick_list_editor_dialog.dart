import 'dart:async';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/repositories/pick_list_repository.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';

/// Shows a dialog to manage pick list values for a given list.
Future<void> showPickListEditorDialog({
  required BuildContext context,
  required LocalDatabase db,
  required String listName,
  required String label,
  String? mediaKind,
  List<String> builtInValues = const [],
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _PickListEditorDialog(
      db: db,
      listName: listName,
      label: label,
      mediaKind: mediaKind,
      builtInValues: builtInValues,
    ),
  );
}

class _PickListEditorDialog extends StatefulWidget {
  const _PickListEditorDialog({
    required this.db,
    required this.listName,
    required this.label,
    this.mediaKind,
    this.builtInValues = const [],
  });

  final LocalDatabase db;
  final String listName;
  final String label;
  final String? mediaKind;
  final List<String> builtInValues;

  @override
  State<_PickListEditorDialog> createState() => _PickListEditorDialogState();
}

class _PickListEditorDialogState extends State<_PickListEditorDialog> {
  List<String> _customValues = [];
  bool _loading = true;
  final _addCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = PickListRepository(widget.db);
    final values = await repo.getValues(widget.listName,
        mediaKind: widget.mediaKind);
    if (mounted) {
      setState(() {
        _customValues = values;
        _loading = false;
      });
    }
  }

  Future<void> _addValue() async {
    final value = _addCtrl.text.trim();
    if (value.isEmpty) return;
    final repo = PickListRepository(widget.db);
    final added = await repo.addValue(widget.listName, value,
        mediaKind: widget.mediaKind);
    if (added) {
      _addCtrl.clear();
      unawaited(_load());
    }
  }

  Future<void> _removeValue(String value) async {
    final repo = PickListRepository(widget.db);
    await repo.removeValue(widget.listName, value);
    unawaited(_load());
  }

  @override
  Widget build(BuildContext context) {
    final allValues = [...widget.builtInValues, ..._customValues];

    return AccentAlertDialog(
      backgroundColor: kAppPanel,
      titlePadding: EdgeInsets.zero,
      title: AccentDialogHeader(
        title: 'Edit ${widget.label} Values',
        icon: Icons.list,
      ),
      content: SizedBox(
        width: 320,
        height: 360,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _addCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Add new value...',
                            isDense: true,
                          ),
                          onSubmitted: (_) => _addValue(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Add',
                        icon: const Icon(Icons.add),
                        onPressed: _addValue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: allValues.length,
                      itemBuilder: (context, i) {
                        final value = allValues[i];
                        final isBuiltIn =
                            i < widget.builtInValues.length;
                        return ListTile(
                          dense: true,
                          title: Text(value),
                          trailing: isBuiltIn
                              ? Chip(
                                  label: const Text('built-in'),
                                  labelStyle: TextStyle(
                                      fontSize: 10, color: kAppTextMuted),
                                  visualDensity: VisualDensity.compact,
                                )
                              : IconButton(
                                  tooltip: 'Remove',
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18),
                                  onPressed: () => _removeValue(value),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
