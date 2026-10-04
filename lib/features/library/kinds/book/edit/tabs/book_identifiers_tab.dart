import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/book_edit_draft.dart';
import 'package:flutter/material.dart';

final class BookIdentifiersTab extends StatelessWidget {
  const BookIdentifiersTab({
    super.key,
    required this.draft,
    required this.accent,
    required this.markDirty,
  });

  final BookEditDraft draft;
  final Color accent;
  final VoidCallback markDirty;

  @override
  Widget build(BuildContext context) => EditTabShell(
        children: [
          EditSection(
            title: 'Identifiers',
            accent: accent,
            child: LibraryEditResponsiveRow(
              children: [
                LibraryEditTextField(
                  controller: draft.isbnController,
                  label: 'ISBN',
                  onChanged: (_) => markDirty(),
                ),
                LibraryEditTextField(
                  controller: draft.barcodeController,
                  label: 'Barcode',
                  onChanged: (_) => markDirty(),
                ),
              ],
            ),
          ),
        ],
      );
}
