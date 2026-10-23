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
    this.collectionIconSvgAsset,
    required this.coverPlaceholderIcon,
    required this.accent,
    required this.preferencePrefix,
    this.routeSegments = const [],
    required this.mediaFamily,
    this.isTopLevel = true,
    this.normalizeCatalogLabels = false,
    this.defaultDensityPreset = LibraryWorkspaceDensityPreset.compact,
    this.availableDensityPresets = const [
      LibraryWorkspaceDensityPreset.comfortable,
      LibraryWorkspaceDensityPreset.compact,
      LibraryWorkspaceDensityPreset.ultraCompact,
    ],
    this.toolbarActions = kDefaultLibraryToolbarActions,
    this.collectionFamily,
    this.defaultCollectionName = 'Main Collection',
    this.hasTrailers = false,
  });

  final CatalogMediaKind kind;
  final String singularLabel;
  final String pluralLabel;
  final String title;
  final IconData icon;

  /// Optional original vector artwork for collection tabs and their menu.
  final String? collectionIconSvgAsset;

  /// Shown on the dark tile that stands in for a missing cover.
  final IconData coverPlaceholderIcon;
  final Color accent;
  final String preferencePrefix;
  final List<String> routeSegments;
  final String mediaFamily;
  final bool isTopLevel;
  final bool normalizeCatalogLabels;
  final LibraryWorkspaceDensityPreset defaultDensityPreset;
  final List<LibraryWorkspaceDensityPreset> availableDensityPresets;
  final List<LibraryToolbarActionId> toolbarActions;

  /// Inventories with independent domain models can share one library's tabs.
  final String? collectionFamily;
  final String defaultCollectionName;

  /// Items carry trailer links shown in the details panel, which Settings
  /// can hide.
  final bool hasTrailers;

  String countLabel(int count) => count == 1 ? singularLabel : pluralLabel;
  String preferenceKey(String suffix) => '$preferencePrefix.$suffix';
}
