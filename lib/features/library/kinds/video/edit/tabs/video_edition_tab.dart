import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:flutter/material.dart';

class VideoEditEditionTab extends StatelessWidget {
  const VideoEditEditionTab({
    super.key,
    required this.type,
    required this.draft,
    required this.accent,
    required this.physicalFormats,
  });

  final LibraryTypeConfig type;
  final LibraryEditDraft draft;
  final Color accent;
  final List<PhysicalMediaFormat> physicalFormats;

  @override
  Widget build(BuildContext context) {
    final releaseFields = type.releaseFields;
    return EditTabShell(
      children: [
        EditSection(
          title: 'Edition',
          accent: accent,
          child: LibraryReleaseIdentityFields(
            editionTitleController: draft.editionTitleController,
            variantController: draft.variantController,
            barcodeController: draft.barcodeController,
            releaseDateController: draft.releaseDateController,
            releaseYearController: draft.releaseYearController,
            physicalFormatController: draft.physicalFormatLabelController,
            physicalFormatOptions: [
              for (final format in physicalFormats) format.label,
            ],
            onPhysicalFormatChanged: (value) {
              final normalized = emptyToNull(value ?? '');
              final selected = _physicalFormatForLabel(normalized);
              final previousLabel =
                  _physicalFormatLabelForId(draft.physicalFormatId);
              final variant = draft.variantController.text.trim();
              final shouldReplaceVariant =
                  variant.isEmpty || previousLabel == variant;
              draft.physicalFormatId = selected?.id;
              if (selected != null && shouldReplaceVariant) {
                draft.variantController.text = selected.label;
              }
            },
            editionTitleLabel: releaseFields.editionTitleLabel,
            variantLabel: releaseFields.variantLabel,
            barcodeLabel: releaseFields.barcodeLabel,
            releaseDateLabel: type.mediaFields.releaseDateLabel,
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
