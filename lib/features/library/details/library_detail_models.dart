import 'package:flutter/material.dart';

enum LibraryDetailSectionSlot {
  identity,
  personal,
  progress,
  metadata,
  relations,
  links,
  media,
  notes,
  source,
  activity,
}

const List<LibraryDetailSectionSlot> libraryDetailSectionOrder = [
  LibraryDetailSectionSlot.identity,
  LibraryDetailSectionSlot.personal,
  LibraryDetailSectionSlot.progress,
  LibraryDetailSectionSlot.metadata,
  LibraryDetailSectionSlot.relations,
  LibraryDetailSectionSlot.links,
  LibraryDetailSectionSlot.media,
  LibraryDetailSectionSlot.notes,
  LibraryDetailSectionSlot.source,
  LibraryDetailSectionSlot.activity,
];

class LibraryDetailField {
  const LibraryDetailField({
    required this.label,
    required this.value,
    this.onTap,
    this.tooltip,
    this.priority = 0,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final String? tooltip;
  final int priority;
}

class LibraryDetailChipGroup {
  const LibraryDetailChipGroup({
    required this.values,
    this.label,
    this.onValueTap,
    this.priority = 0,
  });

  final String? label;
  final List<String> values;
  final ValueChanged<String>? onValueTap;
  final int priority;
}

class LibraryDetailSectionSpec {
  const LibraryDetailSectionSpec({
    required this.slot,
    required this.title,
    this.subtitle,
    this.fields = const [],
    this.chips = const [],
    this.children = const [],
    this.headerActions = const [],
    this.initiallyExpanded = true,
  });

  final LibraryDetailSectionSlot slot;
  final String title;
  final String? subtitle;
  final List<LibraryDetailField> fields;
  final List<LibraryDetailChipGroup> chips;
  final List<Widget> children;
  final List<Widget> headerActions;
  final bool initiallyExpanded;
}
