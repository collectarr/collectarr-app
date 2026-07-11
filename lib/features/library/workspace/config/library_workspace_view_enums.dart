import 'package:flutter/material.dart';

enum LibraryViewMode { grid, card, horizontalCards, cardFlow, list, shelves }

enum LibraryWorkspaceBrowserMode { media, releases }

enum LibraryWorkspaceDensityPreset { comfortable, compact, ultraCompact }

extension LibraryViewModeCoverSizeSupport on LibraryViewMode {
  bool get supportsCoverSize {
    return switch (this) {
      LibraryViewMode.grid ||
      LibraryViewMode.card ||
      LibraryViewMode.horizontalCards ||
      LibraryViewMode.shelves =>
        true,
      LibraryViewMode.cardFlow || LibraryViewMode.list => false,
    };
  }
}

enum LibraryDetailsLayout { right, bottom, hidden }

enum LibraryFolderDisplayMode { drilldown, tree }

extension LibraryFolderDisplayModeLabels on LibraryFolderDisplayMode {
  String get label {
    return switch (this) {
      LibraryFolderDisplayMode.drilldown => 'Drilldown',
      LibraryFolderDisplayMode.tree => 'Tree',
    };
  }

  IconData get icon {
    return switch (this) {
      LibraryFolderDisplayMode.drilldown => Icons.segment,
      LibraryFolderDisplayMode.tree => Icons.account_tree_outlined,
    };
  }
}

enum LibraryWorkspacePreset { cover, card, list, details }

extension LibraryWorkspacePresetLabels on LibraryWorkspacePreset {
  String get label {
    return switch (this) {
      LibraryWorkspacePreset.cover => 'Grid',
      LibraryWorkspacePreset.card => 'Cards',
      LibraryWorkspacePreset.list => 'List',
      LibraryWorkspacePreset.details => 'Details panel',
    };
  }

  IconData get icon {
    return switch (this) {
      LibraryWorkspacePreset.cover => Icons.grid_view,
      LibraryWorkspacePreset.card => Icons.view_module,
      LibraryWorkspacePreset.list => Icons.view_list,
      LibraryWorkspacePreset.details => Icons.view_sidebar,
    };
  }
}
