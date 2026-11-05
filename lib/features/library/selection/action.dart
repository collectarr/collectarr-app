import 'dart:async';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/actions/ui_action.dart';
import 'package:flutter/material.dart';
import 'context.dart';
import 'commands.dart';

enum LibrarySelectionTargetScope { catalog, entry, wishlist }

class LibrarySelectionActionContext {
  const LibrarySelectionActionContext(
      {required this.selection, required this.commands});
  final LibrarySelectionContext selection;
  final LibrarySelectionCommands commands;
}

/// Contribution contract for bulk operations; distinct from single-item actions.
class LibrarySelectionAction
    implements UiAction<LibrarySelectionActionContext> {
  const LibrarySelectionAction(
      {required this.id,
      required this.label,
      required this.icon,
      required this.command,
      this.placement = UiActionPlacement.bulkMenu,
      this.order = 0,
      this.category = 'Items',
      this.homogeneousOnly = false,
      this.scopes = const {
        LibrarySelectionTargetScope.catalog,
        LibrarySelectionTargetScope.entry,
        LibrarySelectionTargetScope.wishlist
      },
      this.unavailableMessage,
      this.enabled});
  @override
  final String id;
  @override
  final String label;
  @override
  final IconData icon;
  @override
  final UiActionPlacement placement;
  final int order;
  final String category;
  final bool homogeneousOnly;
  final Set<LibrarySelectionTargetScope> scopes;
  final String? unavailableMessage;
  final LibrarySelectionCommand? Function(LibrarySelectionCommands) command;
  final bool Function(LibrarySelectionActionContext)? enabled;
  @override
  bool isVisible(LibrarySelectionActionContext context) =>
      !homogeneousOnly || context.selection.homogeneousKind != null;
  @override
  bool isEnabled(LibrarySelectionActionContext context) =>
      isVisible(context) &&
      context.selection
          .every((entry) => scopes.contains(entry.libraryEntryRef != null
              ? LibrarySelectionTargetScope.entry
              : entry.isWishlisted
                  ? LibrarySelectionTargetScope.wishlist
                  : LibrarySelectionTargetScope.catalog)) &&
      (enabled?.call(context) ?? true) &&
      command(context.commands) != null;
  @override
  Future<void> run(LibrarySelectionActionContext context) async {
    if (!isEnabled(context)) {
      throw StateError('$label is unavailable for the current selection.');
    }
    await command(context.commands)!();
  }
}

class ResolvedLibrarySelectionAction {
  const ResolvedLibrarySelectionAction(
      {required this.action, required this.enabled, required this.invoke});
  final LibrarySelectionAction action;
  final bool enabled;
  final FutureOr<void> Function() invoke;
}

/// Intersection by stable action ID: every selected kind must declare support.
List<ResolvedLibrarySelectionAction> resolveLibrarySelectionActions({
  required LibrarySelectionActionContext Function() current,
  required List<LibrarySelectionAction> Function(CatalogMediaKind kind)
      contributions,
}) {
  final snapshot = current();
  if (!snapshot.selection.every((entry) => true)) return const [];
  final kinds =
      snapshot.selection.entries.map((entry) => entry.mediaKind).toSet();
  final declarations = contributions(kinds.first);
  final result = <ResolvedLibrarySelectionAction>[];
  for (final action in declarations) {
    if (!action.isVisible(snapshot) ||
        !kinds.every((kind) => contributions(kind).any((candidate) =>
            candidate.id == action.id && candidate.isVisible(snapshot)))) {
      continue;
    }
    bool applicable(LibrarySelectionActionContext context) => context.selection
        .every((entry) => contributions(entry.mediaKind).any((candidate) =>
            candidate.id == action.id && candidate.isEnabled(context)));
    result.add(ResolvedLibrarySelectionAction(
        action: action,
        enabled: applicable(snapshot),
        invoke: () {
          final latest = current();
          if (!applicable(latest)) {
            throw StateError(
                '${action.label} is unavailable for the current selection.');
          }
          return action.run(latest);
        }));
  }
  result.sort((a, b) => a.action.order.compareTo(b.action.order));
  return result;
}
