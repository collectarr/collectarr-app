import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:flutter/material.dart';

typedef LibraryFilterValueBuilder<T> = T? Function(
  LibraryProjectionRuntime item,
);

typedef LibraryFilterMatchBuilder = bool Function(
  LibraryProjectionRuntime item,
  String value,
);

enum LibraryFilterInputKind { dropdown, autocomplete }

class LibraryFilterDefinition<T> {
  static const missingValue = '__missing__';

  const LibraryFilterDefinition({
    required this.id,
    required this.label,
    this.anyLabel = 'Any',
    this.icon,
    this.value,
    this.missingValueLabel,
    this.inputKind = LibraryFilterInputKind.dropdown,
    this.matches,
  });

  final String id;
  final String label;
  final String anyLabel;
  final IconData? icon;
  final LibraryFilterValueBuilder<T>? value;
  final String? missingValueLabel;
  final LibraryFilterInputKind inputKind;
  final LibraryFilterMatchBuilder? matches;

  bool matchesItem(LibraryProjectionRuntime item, String selectedValue) {
    final matcher = matches;
    if (matcher != null) {
      return matcher(item, selectedValue);
    }
    return value?.call(item)?.toString().trim() == selectedValue;
  }
}

class LibraryPresentationLabels {
  const LibraryPresentationLabels({this.values = const {}});

  final Map<String, String> values;

  String labelFor(String id, {String fallback = ''}) {
    return values[id] ?? fallback;
  }
}

typedef LibraryMediaFilterLabels = LibraryPresentationLabels;
typedef LibraryMediaGroupLabels = LibraryPresentationLabels;
typedef LibraryBucketLabelOverrides = LibraryPresentationLabels;
typedef LibraryReferenceLabels = LibraryPresentationLabels;
typedef LibraryStatusLabels = LibraryPresentationLabels;

class LibraryBucketingContext {
  const LibraryBucketingContext({
    required this.source,
    required this.item,
    required this.groupId,
  });

  final ShelfEntry source;
  final LibraryProjectionRuntime item;
  final LibraryGroupIdRuntime groupId;
}

typedef LibraryBucketLabelBuilder = String Function(
  LibraryBucketingContext context,
);
