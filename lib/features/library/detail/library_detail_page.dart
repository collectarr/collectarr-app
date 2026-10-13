import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Standalone details use the same inspector, actions and kind contributions.
class LibraryDetailPage extends ConsumerWidget {
  const LibraryDetailPage(
      {super.key,
      required this.type,
      required this.item,
      required this.libraryEntrySummary,
      this.libraryEntryDispatch,
      this.projection,
      required this.accent,
      required this.onAddEntry,
      required this.onRemoveEntry,
      required this.onAddWishlist,
      required this.onRemoveWishlist,
      required this.onEdit,
      this.onFilterByValue,
      this.onDetailsLayoutChanged,
      this.searchQuery,
      this.searchTarget = LibrarySearchTarget.all});
  final LibraryKindRegistration type;
  final LibraryProjectionView item;
  final LibraryEntrySummary? libraryEntrySummary;
  final LibraryEntryDispatch? libraryEntryDispatch;
  final LibraryProjection? projection;
  final Color accent;
  final VoidCallback? onAddEntry;
  final VoidCallback? onRemoveEntry;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final void Function(LibraryEntrySummary? libraryEntry)? onEdit;
  final ValueChanged<String>? onFilterByValue;
  final ValueChanged<LibraryDetailsLayout>? onDetailsLayoutChanged;
  final String? searchQuery;
  final LibrarySearchTarget searchTarget;

  @override
  Widget build(BuildContext context, WidgetRef ref) => LibraryInspector(
        type: type,
        projection: projection ?? LibraryProjection.forItem(item),
        item: item,
        libraryEntry: libraryEntrySummary,
        libraryEntryDispatch: libraryEntryDispatch,
        accent: accent,
        db: ref.watch(localDatabaseProvider),
        fullscreen: true,
        onAddEntry: onAddEntry,
        onRemoveEntry: onRemoveEntry,
        onAddWishlist: onAddWishlist,
        onRemoveWishlist: onRemoveWishlist,
        onEdit: onEdit,
        searchQuery: searchQuery,
        searchTarget: searchTarget,
        onFilterByValue: onFilterByValue == null
            ? null
            : (value) {
                onFilterByValue!(value);
                Navigator.of(context).maybePop();
              },
        onDetailsLayoutChanged: onDetailsLayoutChanged == null
            ? null
            : (layout) {
                onDetailsLayoutChanged!(layout);
                if (layout != LibraryDetailsLayout.hidden) {
                  Navigator.of(context).maybePop();
                }
              },
      );
}
