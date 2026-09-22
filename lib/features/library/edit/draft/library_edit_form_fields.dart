import 'package:flutter/material.dart';

/// Controllers owned by the edit shell's form chrome.
///
/// These controllers are presentation state only. Canonical values are
/// applied by the selected kind-owned Work/Release edit session.
final class LibraryEditFormFields {
  LibraryEditFormFields({
    required this.titleController,
    required this.displayTitleController,
    required this.sortKeyController,
    required this.originalTitleController,
    required this.localizedTitleController,
    required this.searchAliasesController,
    required this.synopsisController,
    required this.coverController,
    required this.thumbnailController,
  });

  final TextEditingController titleController;
  final TextEditingController displayTitleController;
  final TextEditingController sortKeyController;
  final TextEditingController originalTitleController;
  final TextEditingController localizedTitleController;
  final TextEditingController searchAliasesController;
  final TextEditingController synopsisController;
  final TextEditingController coverController;
  final TextEditingController thumbnailController;
}
