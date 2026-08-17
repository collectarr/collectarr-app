import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
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
    this.defaultDensityPreset = LibraryWorkspaceDensityPreset.comfortable,
    this.availableDensityPresets = LibraryWorkspaceDensityPreset.values,
  });

  factory LibraryKindIdentity.fromWorkspaceConfig({
    required LibraryWorkspaceConfig workspace,
    required String singularLabel,
    required String pluralLabel,
  }) {
    return LibraryKindIdentity(
      kind: workspace.kind,
      singularLabel: singularLabel,
      pluralLabel: pluralLabel,
      title: workspace.title,
      icon: workspace.icon,
      accent: workspace.accent,
      preferencePrefix: workspace.preferencePrefix,
      defaultDensityPreset: workspace.defaultDensityPreset,
      availableDensityPresets: workspace.availableDensityPresets,
    );
  }

  final CatalogMediaKind kind;
  final String singularLabel;
  final String pluralLabel;
  final String title;
  final IconData icon;
  final Color accent;
  final String preferencePrefix;
  final LibraryWorkspaceDensityPreset defaultDensityPreset;
  final List<LibraryWorkspaceDensityPreset> availableDensityPresets;

  String countLabel(int count) => count == 1 ? singularLabel : pluralLabel;
  String preferenceKey(String suffix) => '$preferencePrefix.$suffix';

  LibraryWorkspaceConfig toWorkspaceConfig() => LibraryWorkspaceConfig(
        kind: kind,
        title: title,
        icon: icon,
        accent: accent,
        preferencePrefix: preferencePrefix,
        defaultDensityPreset: defaultDensityPreset,
        availableDensityPresets: availableDensityPresets,
      );
}
