import 'package:flutter/material.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'pick_list_selection_dialog.dart';

Future<String?> showPickListSelectDialog({
  required BuildContext context,
  required String label,
  required List<String> options,
  String? selectedValue,
  String? listName,
  String? pluralLabel,
  String? mediaKind,
  bool allowUserValues = false,
  LocalDatabase? db,
}) =>
    showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PickListSelectionDialog(
            label: label,
            options: options,
            selectedValues: [if (selectedValue != null) selectedValue],
            multiple: false,
            listName: listName,
            pluralLabel: pluralLabel,
            mediaKind: mediaKind,
            allowUserValues: allowUserValues,
            db: db));
