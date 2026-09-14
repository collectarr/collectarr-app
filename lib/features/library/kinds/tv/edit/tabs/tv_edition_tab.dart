import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft_contract.dart';
import 'package:flutter/material.dart';

class TvEditEditionTab extends StatelessWidget {
  const TvEditEditionTab({
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
    final tvEdit = (draft.kindDetails is TvEditDraftContract)
        ? (draft.kindDetails as TvEditDraftContract).tvEdit
        : null;

    final editionTitleController =
        tvEdit?.editionTitleController ?? TextEditingController();
    final variantController =
        tvEdit?.variantController ?? TextEditingController();
    final barcodeController =
        tvEdit?.barcodeController ?? TextEditingController();
    final physicalFormatController =
        tvEdit?.physicalFormatLabelController ?? TextEditingController();

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
                tvEdit?.releaseDateController ?? TextEditingController(),
            releaseYearController:
                tvEdit?.releaseYearController ?? TextEditingController(),
            physicalFormatController: physicalFormatController,
            physicalFormatOptions: [
              for (final format in physicalFormats) format.label,
            ],
            onPhysicalFormatChanged: (value) {
              final normalized = emptyToNull(value ?? '');
              final selected = _physicalFormatForLabel(normalized);
              final previousLabel =
                  _physicalFormatLabelForId(tvEdit?.physicalFormatId);
              final variant = variantController.text.trim();
              final shouldReplaceVariant =
                  variant.isEmpty || previousLabel == variant;
              if (tvEdit != null) {
                tvEdit.physicalFormatId = selected?.id;
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
