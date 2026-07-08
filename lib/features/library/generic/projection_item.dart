import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/media/video/video_release_source.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_node.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

class LibraryProjectionItem {
const LibraryProjectionItem({
  required this.source,
  required this.entry,
  required this.node,
  this.customFieldBadges = const <String>[],
});

factory LibraryProjectionItem.fromShelf(
  ShelfEntry source,
  LibraryTypeConfig type, {
  List<String> customFieldBadges = const <String>[],
}) {
  final item = source.catalogItem!;
  final entry = type.presentation.workspaceEntryBuilder(source);
  return LibraryProjectionItem(
    source: source,
    entry: entry,
    customFieldBadges: customFieldBadges,
    node: LibraryBrowserNode(
      id: item.id,
      scope: LibraryBrowserScope.title,
      entry: entry,
      titleItemId: item.id,
      catalogItem: item,
      source: source,
    ),
  );
}

final ShelfEntry source;
final LibraryWorkspaceEntry entry;
final LibraryBrowserNode node;
final List<String> customFieldBadges;
}

List<LibraryProjectionItem> libraryItemsForShelf(
ShelfState shelf,
LibraryTypeConfig type, {
List<CustomFieldDefinition> customFieldDefinitions = const [],
Map<String, Map<String, String>> customFieldValuesByDefinitionByItem = const {},
Map<String, List<String>> customFieldValuesByItem = const {},
LibraryWorkspaceBrowserMode browserMode = LibraryWorkspaceBrowserMode.media,
String? releaseFolderTitleItemId,
}) {
final kind = type.workspace.kind;
if (browserMode == LibraryWorkspaceBrowserMode.releases) {
  return _libraryReleaseItemsForShelf(
    shelf,
    type,
    customFieldDefinitions: customFieldDefinitions,
    customFieldValuesByDefinitionByItem:
        customFieldValuesByDefinitionByItem,
    customFieldValuesByItem: customFieldValuesByItem,
    releaseFolderTitleItemId: releaseFolderTitleItemId,
  );
}
return [
  for (final source in shelf.entries)
    if (source.catalogItem != null && source.catalogItem!.kind == kind.apiValue)
      LibraryProjectionItem.fromShelf(
        source,
        type,
        customFieldBadges: _customFieldBadgesForEntry(
          source,
          customFieldDefinitions: customFieldDefinitions,
          customFieldValuesByDefinitionByItem:
              customFieldValuesByDefinitionByItem,
          customFieldValuesByItem: customFieldValuesByItem,
        ),
      ),
];
}

List<LibraryProjectionItem> _libraryReleaseItemsForShelf(
ShelfState shelf,
LibraryTypeConfig type, {
List<CustomFieldDefinition> customFieldDefinitions = const [],
Map<String, Map<String, String>> customFieldValuesByDefinitionByItem = const {},
Map<String, List<String>> customFieldValuesByItem = const {},
String? releaseFolderTitleItemId,
}) {
final kind = type.workspace.kind;
final requestedTitleId = releaseFolderTitleItemId?.trim();
final items = <LibraryProjectionItem>[];

for (final source in shelf.entries) {
  final catalogItem = source.catalogItem;
  if (catalogItem == null || catalogItem.kind != kind.apiValue) {
    continue;
  }
  if (requestedTitleId != null && catalogItem.id != requestedTitleId) {
    continue;
  }

  final titleEntry = type.presentation.workspaceEntryBuilder(source);
  final resolvedEditions = resolveVideoCatalogEditionsForCatalogItem(
    catalogItem,
    ownedItems:
        source.ownedItem == null ? const [] : [source.ownedItem!],
    wishlistItems:
        source.wishlistItem == null ? const [] : [source.wishlistItem!],
  );
  if (resolvedEditions.isEmpty) {
    // Hide media that have no release-level data in release mode.
    continue;
  }

  for (final edition in resolvedEditions) {
    final ownedMatches = source.ownedItem == null
        ? false
        : matchesVideoReleaseAnchor(
            edition,
            editionId: source.ownedItem!.editionId,
            variantId: source.ownedItem!.variantId,
            bundleReleaseId: source.ownedItem!.bundleReleaseId,
          );
    final wishlistMatches = source.wishlistItem == null
        ? false
        : matchesVideoReleaseAnchor(
            edition,
            editionId: source.wishlistItem!.editionId,
            variantId: source.wishlistItem!.variantId,
            bundleReleaseId: source.wishlistItem!.bundleReleaseId,
          );

    final entry = type.presentation.releaseEntryBuilder(
      LibraryReleaseEntryRequest(
        titleEntry: titleEntry,
        edition: edition,
        isOwned: ownedMatches,
        isWishlisted: wishlistMatches,
        isTracked: source.isTracked,
        referenceEditionId: edition.id,
        referenceVariantId: preferredVideoEditionVariantId(edition),
        editions: resolvedEditions,
        updatedAt: source.updatedAt,
      ),
    );
    items.add(
      LibraryProjectionItem(
        source: source,
        entry: entry,
        customFieldBadges: _customFieldBadgesForReleaseEntry(
          source,
          entry,
          customFieldDefinitions: customFieldDefinitions,
          customFieldValuesByDefinitionByItem:
              customFieldValuesByDefinitionByItem,
          customFieldValuesByItem: customFieldValuesByItem,
        ),
        node: LibraryBrowserNode(
          id: entry.id,
          scope: entry.browseScope,
          entry: entry,
          titleItemId: titleEntry.id,
          releaseId: edition.id,
          edition: edition,
          source: source,
        ),
      ),
    );
  }
}
return items;
}

List<String> _customFieldBadgesForEntry(
ShelfEntry source, {
required List<CustomFieldDefinition> customFieldDefinitions,
required Map<String, Map<String, String>> customFieldValuesByDefinitionByItem,
required Map<String, List<String>> customFieldValuesByItem,
}) {
final candidateIds = <String>{
  source.ownedItem?.id ?? '',
  source.catalogItem?.id ?? '',
}..removeWhere((value) => value.isEmpty);
return _customFieldBadgesFromIds(
  candidateIds,
  customFieldDefinitions: customFieldDefinitions,
  customFieldValuesByDefinitionByItem:
      customFieldValuesByDefinitionByItem,
  customFieldValuesByItem: customFieldValuesByItem,
);
}

List<String> _customFieldBadgesForReleaseEntry(
ShelfEntry source,
LibraryWorkspaceEntry entry, {
required List<CustomFieldDefinition> customFieldDefinitions,
required Map<String, Map<String, String>> customFieldValuesByDefinitionByItem,
required Map<String, List<String>> customFieldValuesByItem,
}) {
final candidateIds = <String>{
  source.ownedItem?.id ?? '',
  source.catalogItem?.id ?? '',
  entry.titleItemId ?? '',
  entry.releaseId ?? '',
  entry.ownedItemId ?? '',
  entry.copyId ?? '',
}..removeWhere((value) => value.isEmpty);
return _customFieldBadgesFromIds(
  candidateIds,
  customFieldDefinitions: customFieldDefinitions,
  customFieldValuesByDefinitionByItem:
      customFieldValuesByDefinitionByItem,
  customFieldValuesByItem: customFieldValuesByItem,
);
}

List<String> _customFieldBadgesFromIds(
Iterable<String> targetIds, {
required List<CustomFieldDefinition> customFieldDefinitions,
required Map<String, Map<String, String>> customFieldValuesByDefinitionByItem,
required Map<String, List<String>> customFieldValuesByItem,
}) {
if (customFieldDefinitions.isEmpty) {
  return const [];
}
final seen = <String>{};
final badges = <String>[];
for (final targetId in targetIds) {
  final byDefinition = customFieldValuesByDefinitionByItem[targetId];
  if (byDefinition == null || byDefinition.isEmpty) {
    continue;
  }
  for (final definition in customFieldDefinitions) {
    final value = byDefinition[definition.id]?.trim();
    if (value == null || value.isEmpty) {
      continue;
    }
    final name = definition.name.trim();
    final label = name.isEmpty ? value : '$name: $value';
    if (seen.add(label)) {
      badges.add(label);
    }
    if (badges.length >= 3) {
      return badges;
    }
  }
}
if (badges.isNotEmpty) {
  return badges;
}
for (final targetId in targetIds) {
  final values = customFieldValuesByItem[targetId];
  if (values == null || values.isEmpty) {
    continue;
  }
  for (final value in values) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      continue;
    }
    if (seen.add(normalized)) {
      badges.add(normalized);
    }
    if (badges.length >= 3) {
      return badges;
    }
  }
}
return badges;
}
