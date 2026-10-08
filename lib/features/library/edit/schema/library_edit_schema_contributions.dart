import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_draft_editor.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_personal_fields_layout.dart';
import 'package:flutter/material.dart';

typedef LibraryEditPersonalAdditionalFieldsBuilder = Map<String, Widget>
    Function(LibraryEntryEditDraft draft);

typedef LibraryEditPersonalHistoryBuilder = Widget? Function(
    LibraryEntryEditDraft draft);

/// Kind-owned data and field builders for the shared Personal tab lifecycle.
///
/// The schema dialog owns the tab and section. A kind contributes only its
/// personal layout and controls that do not belong to the shared entry draft.
final class LibraryEditPersonalTabContribution {
  const LibraryEditPersonalTabContribution({
    this.id = 'personal',
    this.label = 'Personal',
    this.icon = Icons.person_outline,
    this.svgAsset,
    this.afterTabId,
    this.layoutBuilder,
    this.additionalFieldsBuilder,
    this.historyBuilder,
  }) : assert(icon != null || svgAsset != null);

  final String id;
  final String label;
  final IconData? icon;
  final String? svgAsset;
  final String? afterTabId;
  final LibraryPersonalLayoutBuilder? layoutBuilder;
  final LibraryEditPersonalAdditionalFieldsBuilder? additionalFieldsBuilder;
  final LibraryEditPersonalHistoryBuilder? historyBuilder;
}

/// Kind-owned field data and change collection for the shared Custom Fields
/// tab lifecycle.
final class LibraryEditCustomFieldsTabContribution {
  const LibraryEditCustomFieldsTabContribution({
    required this.definitions,
    required this.values,
    required this.onChanged,
    this.id = 'custom_fields',
    this.label = 'Custom Fields',
    this.icon = Icons.edit_note,
    this.svgAsset,
    this.afterTabId = 'personal',
    this.onCustomValueChanged,
  }) : assert(icon != null || svgAsset != null);

  final String id;
  final String label;
  final IconData? icon;
  final String? svgAsset;
  final String? afterTabId;
  final List<CustomFieldDefinition> definitions;
  final Map<String, String?> values;
  final ValueChanged<Map<String, String?>> onChanged;
  final void Function(String fieldDefinitionId, String? value)?
      onCustomValueChanged;
}

/// Kind-owned image policy for the shared editable item-image tab.
final class LibraryEditImagesTabContribution {
  const LibraryEditImagesTabContribution({
    required this.images,
    required this.onChanged,
    this.id = 'my_images',
    this.label = 'My Images',
    this.icon = Icons.image_outlined,
    this.svgAsset,
    this.afterTabId,
    this.title = 'My Images',
    this.emptyMessage =
        'No photos attached. Use the tools below to add supporting shots.',
    this.maximumImages = 5,
    this.defaultImageType = 'auxiliary',
    this.uniqueImageTypes = const {'front_cover', 'back_cover'},
    this.showCoverActions = true,
    this.imageTypeFieldBuilder,
    this.imageTypeLabelBuilder,
  }) : assert(icon != null || svgAsset != null);

  final String id;
  final String label;
  final IconData? icon;
  final String? svgAsset;
  final String? afterTabId;
  final List<ItemImageContent> images;
  final ValueChanged<List<ItemImageEdit>> onChanged;
  final String title;
  final String emptyMessage;
  final int maximumImages;
  final String defaultImageType;
  final Set<String> uniqueImageTypes;
  final bool showCoverActions;
  final ItemImageTypeFieldBuilder? imageTypeFieldBuilder;
  final ItemImageTypeLabelBuilder? imageTypeLabelBuilder;
}

/// Kind-owned values for the shared URL/title/description Links tab.
final class LibraryEditLinksTabContribution {
  const LibraryEditLinksTabContribution({
    required this.links,
    required this.onChanged,
    this.id = 'links',
    this.label = 'Links',
    this.icon = Icons.public,
    this.svgAsset,
    this.afterTabId,
    this.addLabel = 'Add Link',
    this.showTitleColumn = true,
    this.emptyMessage = 'No external links added.',
  }) : assert(icon != null || svgAsset != null);

  final String id;
  final String label;
  final IconData? icon;
  final String? svgAsset;
  final String? afterTabId;
  final List<LibraryExternalLinkValue> links;
  final ValueChanged<List<LibraryExternalLinkValue>> onChanged;
  final String addLabel;
  final bool showTitleColumn;
  final String emptyMessage;
}

/// Standard edit tabs that the shared schema dialog can compose itself.
final class LibraryEditSchemaContributions {
  const LibraryEditSchemaContributions({
    this.personal,
    this.customFields,
    this.images,
    this.links,
  });

  final LibraryEditPersonalTabContribution? personal;
  final LibraryEditCustomFieldsTabContribution? customFields;
  final LibraryEditImagesTabContribution? images;
  final LibraryEditLinksTabContribution? links;
}
