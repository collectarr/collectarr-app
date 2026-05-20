import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/library/generic/generic_library_empty_state.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:flutter/material.dart';

class ComicsEmptyState extends StatelessWidget {
  const ComicsEmptyState({
    super.key,
    required this.onAddComic,
    this.hasActiveFilter = false,
    this.onClearFilter,
  });

  final VoidCallback onAddComic;
  final bool hasActiveFilter;
  final VoidCallback? onClearFilter;

  @override
  Widget build(BuildContext context) {
    return GenericLibraryEmptyState(
      type: comicsLibraryConfig,
      icon: comicsWorkspaceConfig.icon,
      accent: libraryAccentForKind('comic'),
      hasActiveFilter: hasActiveFilter,
      onAdd: onAddComic,
      onClearFilter: onClearFilter ?? () {},
    );
  }
}
