import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/draft/video_kind_edit_draft.dart';
import 'package:flutter/material.dart';

class VideoEditEditionTab extends StatelessWidget {
  const VideoEditEditionTab({
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
    final videoEdit = (draft.kindDetails is VideoKindEditDraft)
        ? (draft.kindDetails as VideoKindEditDraft).videoEdit
        : null;

    final editionTitleController =
        videoEdit?.editionTitleController ?? TextEditingController();
    final variantController =
        videoEdit?.variantController ?? TextEditingController();
    final barcodeController =
        videoEdit?.barcodeController ?? TextEditingController();
    final physicalFormatController =
        videoEdit?.physicalFormatLabelController ?? TextEditingController();

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
                videoEdit?.releaseDateController ?? TextEditingController(),
            releaseYearController:
                videoEdit?.releaseYearController ?? TextEditingController(),
            physicalFormatController: physicalFormatController,
            physicalFormatOptions: [
              for (final format in physicalFormats) format.label,
            ],
            onPhysicalFormatChanged: (value) {
              final normalized = emptyToNull(value ?? '');
              final selected = _physicalFormatForLabel(normalized);
              final previousLabel =
                  _physicalFormatLabelForId(videoEdit?.physicalFormatId);
              final variant = variantController.text.trim();
              final shouldReplaceVariant =
                  variant.isEmpty || previousLabel == variant;
              if (videoEdit != null) {
                videoEdit.physicalFormatId = selected?.id;
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
