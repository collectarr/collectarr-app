import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_controller.dart';
import 'package:flutter/material.dart';

class MovieEditEditionTab extends StatelessWidget {
  const MovieEditEditionTab({
    super.key,
    required this.movieEdit,
    required this.accent,
    required this.physicalFormats,
  });

  final MovieEditController movieEdit;
  final Color accent;
  final List<PhysicalMediaFormat> physicalFormats;

  @override
  Widget build(BuildContext context) {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Edition',
          accent: accent,
          child: LibraryReleaseIdentityFields(
            editionTitleController: movieEdit.editionTitleController,
            variantController: movieEdit.variantController,
            barcodeController: movieEdit.barcodeController,
            releaseDateController: movieEdit.releaseDateController,
            releaseYearController: movieEdit.releaseYearController,
            physicalFormatController: movieEdit.physicalFormatLabelController,
            physicalFormatOptions: [
              for (final format in physicalFormats) format.label,
            ],
            onPhysicalFormatChanged: (value) {
              final normalized = emptyToNull(value ?? '');
              final selected = _physicalFormatForLabel(normalized);
              final previousLabel =
                  _physicalFormatLabelForId(movieEdit.physicalFormatId);
              final variant = movieEdit.variantController.text.trim();
              final shouldReplaceVariant =
                  variant.isEmpty || previousLabel == variant;
              movieEdit.physicalFormatId = selected?.id;
              if (selected != null && shouldReplaceVariant) {
                movieEdit.variantController.text = selected.label;
              }
            },
            editionTitleLabel: 'Edition title',
            variantLabel: 'Variant',
            barcodeLabel: 'Barcode',
            releaseDateLabel: 'Release Date',
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
