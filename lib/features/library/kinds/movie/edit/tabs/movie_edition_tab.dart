import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_draft_contract.dart';
import 'package:flutter/material.dart';

class MovieEditEditionTab extends StatelessWidget {
  const MovieEditEditionTab({
    super.key,
    required this.draft,
    required this.accent,
    required this.physicalFormats,
  });

  final LibraryEditDraft draft;
  final Color accent;
  final List<PhysicalMediaFormat> physicalFormats;

  @override
  Widget build(BuildContext context) {
    final movieEdit = (draft.kindDetails is MovieEditDraftContract)
        ? (draft.kindDetails as MovieEditDraftContract).movieEdit
        : null;

    final editionTitleController =
        movieEdit?.editionTitleController ?? TextEditingController();
    final variantController =
        movieEdit?.variantController ?? TextEditingController();
    final barcodeController =
        movieEdit?.barcodeController ?? TextEditingController();
    final physicalFormatController =
        movieEdit?.physicalFormatLabelController ?? TextEditingController();

    return EditTabShell(
      children: [
        EditSection(
          title: 'Edition',
          accent: accent,
          child: LibraryReleaseIdentityFields(
            editionTitleController: editionTitleController,
            variantController: variantController,
            barcodeController: barcodeController,
            releaseDateController:
                movieEdit?.releaseDateController ?? TextEditingController(),
            releaseYearController:
                movieEdit?.releaseYearController ?? TextEditingController(),
            physicalFormatController: physicalFormatController,
            physicalFormatOptions: [
              for (final format in physicalFormats) format.label,
            ],
            onPhysicalFormatChanged: (value) {
              final normalized = emptyToNull(value ?? '');
              final selected = _physicalFormatForLabel(normalized);
              final previousLabel =
                  _physicalFormatLabelForId(movieEdit?.physicalFormatId);
              final variant = variantController.text.trim();
              final shouldReplaceVariant =
                  variant.isEmpty || previousLabel == variant;
              if (movieEdit != null) {
                movieEdit.physicalFormatId = selected?.id;
              }
              if (selected != null && shouldReplaceVariant) {
                variantController.text = selected.label;
              }
            },
            editionTitleLabel: 'Edition title',
            variantLabel: 'Variant',
            barcodeLabel: 'Barcode',
            releaseDateLabel: 'Release date',
          ),
        ),
      ],
    );
  }

  PhysicalMediaFormat? _physicalFormatForLabel(String? label) {
    final normalized = label?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) {
      return null;
    }
    for (final format in physicalFormats) {
      if (format.label.trim().toLowerCase() == normalized ||
          format.id.trim().toLowerCase() == normalized ||
          format.aliases.contains(normalized)) {
        return format;
      }
    }
    return null;
  }

  String? _physicalFormatLabelForId(String? id) {
    final normalized = id?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) {
      return null;
    }
    for (final format in physicalFormats) {
      if (format.id.trim().toLowerCase() == normalized) {
        return format.label;
      }
    }
    return null;
  }
}
