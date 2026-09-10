import 'package:flutter/widgets.dart';

enum LibraryHierarchyLevel {
  root,
  container,
  group,
  leaf,
}

class LibraryHierarchyAction {
  const LibraryHierarchyAction({
    required this.id,
    required this.label,
    this.icon,
    this.onTap,
  });

  final String id;
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
}

class LibraryHierarchyPresentation {
  const LibraryHierarchyPresentation({
    this.badge,
    this.accentColor,
    this.isExpanded = false,
  });

  final String? badge;
  final Color? accentColor;
  final bool isExpanded;
}

class LibraryHierarchyNode {
  const LibraryHierarchyNode({
    required this.id,
    required this.label,
    this.secondaryLabel,
    this.level = LibraryHierarchyLevel.leaf,
    this.imageUrl,
    this.progress,
    this.totalCount,
    this.children = const <LibraryHierarchyNode>[],
    this.actions = const <LibraryHierarchyAction>[],
    this.presentation = const LibraryHierarchyPresentation(),
    this.extras = const <String, Object?>{},
  });

  final String id;
  final String label;
  final String? secondaryLabel;
  final LibraryHierarchyLevel level;
  final String? imageUrl;
  final double? progress;
  final int? totalCount;
  final List<LibraryHierarchyNode> children;
  final List<LibraryHierarchyAction> actions;
  final LibraryHierarchyPresentation presentation;

  /// Opaque renderer extras supplied by the owning hierarchy contributor.
  ///
  /// The generic hierarchy host never interprets these values.  A kind may
  /// keep transport-only values here while its typed hierarchy UI owns their
  /// meaning.
  final Map<String, Object?> extras;
}
