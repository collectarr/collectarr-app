import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'package:flutter/material.dart';

enum LibraryImportSourceType {
  csvTxt,
  guidedFile,
}

class KindMappableField {
  const KindMappableField({
    required this.key,
    required this.label,
    this.aliases = const [],
    this.isDefault = false,
  });

  final String key;
  final String label;
  final List<String> aliases;
  final bool isDefault;
}

class LibraryImportSourceDefinition {
  const LibraryImportSourceDefinition({
    required this.id,
    required this.title,
    this.subtitle,
    this.assetLogoPath,
    this.fallbackIcon = Icons.insert_drive_file_outlined,
    this.isSvg = false,
    this.sourceType = LibraryImportSourceType.guidedFile,
    this.fileExtensions = const ['xml'],
    this.description = '',
    this.instructions = const [],
    this.filePrompt = 'Upload your file below:',
    this.importer,
  }) : assert((sourceType == LibraryImportSourceType.guidedFile) ==
            (importer != null));

  final LibraryGuidedImporter? importer;
  final String id;
  final String title;
  final String? subtitle;
  final String? assetLogoPath;
  final IconData fallbackIcon;
  final bool isSvg;
  final LibraryImportSourceType sourceType;
  final List<String> fileExtensions;
  final String description;
  final List<String> instructions;
  final String filePrompt;
}

/// Mapping value for a column imported as a custom field named after its
/// header.
const importCustomFieldMappingKey = 'custom_field';

class LibraryKindImportCapability {
  const LibraryKindImportCapability({
    this.sources = const [],
    this.mappableFields = const [],
    this.mappedCsvImporter,
    this.allowsCustomFieldColumns = false,
  });

  /// Whether unrecognized columns may be imported as custom fields.
  final bool allowsCustomFieldColumns;

  final List<LibraryImportSourceDefinition> sources;
  final List<KindMappableField> mappableFields;
  final LibraryMappedCsvImporter? mappedCsvImporter;

  LibraryImportSourceDefinition? findSourceById(String id) {
    for (final s in sources) {
      if (s.id == id) return s;
    }
    return null;
  }
}
