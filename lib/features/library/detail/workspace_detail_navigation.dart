import 'location.dart';
import 'package:collectarr_app/features/library/config/item_actions.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/context.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Management and report rows open the same kind-owned detail page as Library.
Future<void> openWorkspaceEntryDetails(
    BuildContext context, LibraryWorkspaceContext source) async {
  final type = libraryKindRegistrationForKind(source.mediaKind);
  await context.push<void>(
      LibraryDetailLocation(source.target).toUri().toString(),
      extra: LibraryDetailPageRequest(
          type: type,
          item: LibraryProjectionItem.fromShelf(source, type),
          libraryEntrySummary: source.libraryEntrySummary,
          libraryEntryDispatch: source.libraryEntryDispatch,
          accent: type.identity.accent));
}
