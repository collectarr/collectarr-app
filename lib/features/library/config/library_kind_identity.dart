import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_view_enums.dart';
import 'package:flutter/material.dart';

/// Defines core identity and workspace representation for a media kind.
class LibraryKindIdentity {
  const LibraryKindIdentity({
    required this.kind,
    required this.singularLabel,
    required this.pluralLabel,
    required this.title,
    required this.icon,
    required this.accent,
    required this.preferencePrefix,
    this.defaultDensityPreset = LibraryWorkspaceDensityPreset.compact,
    this.availableDensityPresets = const [
      LibraryWorkspaceDensityPreset.comfortable,
      LibraryWorkspaceDensityPreset.compact,
      LibraryWorkspaceDensityPreset.ultraCompact,
    ],
    this.toolbarActions = kDefaultLibraryToolbarActions,
  });

  final CatalogMediaKind kind;
  final String singularLabel;
  final String pluralLabel;
  final String title;
  final IconData icon;
  final Color accent;
  final String preferencePrefix;
  final LibraryWorkspaceDensityPreset defaultDensityPreset;
  final List<LibraryWorkspaceDensityPreset> availableDensityPresets;
  final List<LibraryToolbarActionId> toolbarActions;

  String countLabel(int count) => count == 1 ? singularLabel : pluralLabel;
  String preferenceKey(String suffix) => '$preferencePrefix.$suffix';
}
