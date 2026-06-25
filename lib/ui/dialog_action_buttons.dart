import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:flutter/material.dart';

class DialogActionButtons {
  const DialogActionButtons._();

  static Widget cancel({
    Key? key,
    required VoidCallback? onPressed,
    String label = 'Cancel',
    double width = 112,
  }) {
    return SizedBox(
      key: key,
      width: width,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: kLibraryDialogFooterButtonShape,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          minimumSize: const Size(112, kLibraryDialogFooterButtonHeight),
          visualDensity: VisualDensity.compact,
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  static Widget save({
    Key? key,
    required VoidCallback? onPressed,
    String label = 'Save',
    double width = 112,
    Color? accent,
  }) {
    return SizedBox(
      key: key,
      width: width,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          minimumSize: const Size(112, kLibraryDialogFooterButtonHeight),
          shape: kLibraryDialogFooterButtonShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          visualDensity: VisualDensity.compact,
        ),
        onPressed: onPressed,
        icon: const Icon(Icons.save_outlined),
        label: Text(label),
      ),
    );
  }
}
