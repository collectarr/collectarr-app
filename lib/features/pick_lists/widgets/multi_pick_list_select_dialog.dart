import 'package:flutter/material.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'pick_list_selection_dialog.dart';

Future<Set<String>?> showMultiPickListSelectDialog({
  required BuildContext context,
  required String label,
  required List<String> options,
  required Set<String> selectedValues,
  String? listName,
  String? pluralLabel,
  String? mediaKind,
  bool allowUserValues = true,
  LocalDatabase? db,
}) =>
    showDialog<Set<String>>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PickListSelectionDialog(
            label: label,
            options: options,
            selectedValues: selectedValues.toList(),
            multiple: true,
            listName: listName,
            pluralLabel: pluralLabel,
            mediaKind: mediaKind,
            allowUserValues: allowUserValues,
            db: db));
