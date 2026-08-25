import 'package:flutter/material.dart';

/// Draft containing only universal metadata fields shared across all media kinds.
class CommonMetadataDraft {
  CommonMetadataDraft({
    required this.titleController,
    required this.displayTitleController,
    required this.sortKeyController,
    required this.originalTitleController,
    required this.localizedTitleController,
    required this.searchAliasesController,
    required this.synopsisController,
    required this.coverController,
    required this.thumbnailController,
    required this.releaseDateController,
    required this.releaseDateYearPartController,
    required this.releaseDateMonthPartController,
    required this.releaseDateDayPartController,
    required this.releaseYearController,
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
  final TextEditingController releaseDateController;
  final TextEditingController releaseDateYearPartController;
  final TextEditingController releaseDateMonthPartController;
  final TextEditingController releaseDateDayPartController;
  final TextEditingController releaseYearController;
}
