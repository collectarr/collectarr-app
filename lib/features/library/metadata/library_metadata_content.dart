import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_widgets.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

LibraryMetadataPresentation buildLibraryMetadataPresentation({
  required LibraryTypeConfig type,
  required LibraryWorkspaceEntry entry,
  ValueChanged<String>? onFilterByValue,
  bool includeIdentityFacts = false,
}) {
  VoidCallback? tapFor(String? value) {
    if (onFilterByValue == null || value == null || value.trim().isEmpty) {
      return null;
    }
    return () => onFilterByValue(value.trim());
  }

  return type.presentation.builder.buildMetadataPresentation(
    singularLabel: type.singularLabel,
    mediaFields: type.mediaFields,
    releaseFields: type.releaseFields,
    entry: entry,
    includeIdentityFacts: includeIdentityFacts,
    tapFor: tapFor,
  );
}

class LibraryMetadataContent extends StatelessWidget {
  const LibraryMetadataContent({
    super.key,
    required this.type,
    required this.entry,
    this.onFilterByValue,
    this.includeIdentityFacts = false,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final ValueChanged<String>? onFilterByValue;
  final bool includeIdentityFacts;

  @override
  Widget build(BuildContext context) {
    final presentation = buildLibraryMetadataPresentation(
      type: type,
      entry: entry,
      onFilterByValue: onFilterByValue,
      includeIdentityFacts: includeIdentityFacts,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LibraryInspectorFactGrid(facts: presentation.allFacts),
        if (presentation.creators.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryMetadataCreditsList(
            title: 'Creators',
            credits: presentation.creators,
            onValueTap: onFilterByValue,
          ),
        ],
        if (presentation.characters.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorChipWrap(
            label: 'Characters',
            values: presentation.characters,
            onValueTap: onFilterByValue,
          ),
        ],
        if (presentation.storyArcs.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorChipWrap(
            label: 'Story Arcs',
            values: presentation.storyArcs,
            onValueTap: onFilterByValue,
          ),
        ],
        if (presentation.genres.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorChipWrap(
            label: 'Genres',
            values: presentation.genres,
            onValueTap: onFilterByValue,
          ),
        ],
      ],
    );
  }
}
