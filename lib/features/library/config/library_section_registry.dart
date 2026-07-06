import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';

enum LibrarySectionCategory {
  identity,
  collectionStatus,
  progressTracking,
  seriesHierarchy,
  releaseEditionFormat,
  episodesVolumesTracks,
  people,
  imagesMedia,
  linksTrailersProviders,
  notesCustomFields,
  sourceCorrections,
  activityHistory,
}

class LibraryFieldSpec {
  const LibraryFieldSpec({
    required this.id,
    required this.label,
    required this.category,
    this.priority = 0,
    this.readOnly = false,
  });

  final String id;
  final String label;
  final LibrarySectionCategory category;
  final int priority;
  final bool readOnly;
}

class LibrarySectionSpec {
  const LibrarySectionSpec({
    required this.id,
    required this.title,
    required this.category,
    this.fields = const <LibraryFieldSpec>[],
  });

  final String id;
  final String title;
  final LibrarySectionCategory category;
  final List<LibraryFieldSpec> fields;
}

class LibraryDetailSectionRegistry {
  const LibraryDetailSectionRegistry();

  static const LibraryDetailSectionRegistry instance =
      LibraryDetailSectionRegistry();

  static const List<LibrarySectionCategory> categoryOrder = [
    LibrarySectionCategory.identity,
    LibrarySectionCategory.collectionStatus,
    LibrarySectionCategory.progressTracking,
    LibrarySectionCategory.seriesHierarchy,
    LibrarySectionCategory.releaseEditionFormat,
    LibrarySectionCategory.episodesVolumesTracks,
    LibrarySectionCategory.people,
    LibrarySectionCategory.imagesMedia,
    LibrarySectionCategory.linksTrailersProviders,
    LibrarySectionCategory.notesCustomFields,
    LibrarySectionCategory.sourceCorrections,
    LibrarySectionCategory.activityHistory,
  ];

  static const Map<LibraryDetailSectionSlot, LibrarySectionCategory>
      categoryBySlot = {
    LibraryDetailSectionSlot.identity: LibrarySectionCategory.identity,
    LibraryDetailSectionSlot.personalStatus:
        LibrarySectionCategory.collectionStatus,
    LibraryDetailSectionSlot.progressOwnership:
        LibrarySectionCategory.progressTracking,
    LibraryDetailSectionSlot.formatEditionRelease:
        LibrarySectionCategory.releaseEditionFormat,
    LibraryDetailSectionSlot.people: LibrarySectionCategory.people,
    LibraryDetailSectionSlot.seriesLinks:
        LibrarySectionCategory.linksTrailersProviders,
    LibraryDetailSectionSlot.imagesMedia: LibrarySectionCategory.imagesMedia,
    LibraryDetailSectionSlot.notesCustomFields:
        LibrarySectionCategory.notesCustomFields,
    LibraryDetailSectionSlot.sourceCorrections:
        LibrarySectionCategory.sourceCorrections,
    LibraryDetailSectionSlot.activityHistory:
        LibrarySectionCategory.activityHistory,
  };

  int orderOfCategory(LibrarySectionCategory category) {
    return categoryOrder.indexOf(category);
  }

  int orderOfSlot(LibraryDetailSectionSlot slot) {
    final category = categoryBySlot[slot];
    if (category == null) {
      return categoryOrder.length;
    }
    return orderOfCategory(category);
  }

  List<LibraryDetailSectionSpec> orderSections(
    Iterable<LibraryDetailSectionSpec> sections,
  ) {
    final bySlot = <LibraryDetailSectionSlot, LibraryDetailSectionSpec>{};
    for (final section in sections) {
      bySlot[section.slot] = section;
    }
    return [
      for (final slot in libraryDetailSectionOrder)
        if (bySlot.containsKey(slot)) bySlot[slot]!,
    ];
  }
}

class LibraryInspectorSectionRegistry {
  const LibraryInspectorSectionRegistry();

  static const LibraryInspectorSectionRegistry instance =
      LibraryInspectorSectionRegistry();
}

class LibraryEditSectionRegistry {
  const LibraryEditSectionRegistry();

  static const LibraryEditSectionRegistry instance =
      LibraryEditSectionRegistry();

  static const List<LibrarySectionCategory> categoryOrder = [
    LibrarySectionCategory.identity,
    LibrarySectionCategory.collectionStatus,
    LibrarySectionCategory.progressTracking,
    LibrarySectionCategory.seriesHierarchy,
    LibrarySectionCategory.releaseEditionFormat,
    LibrarySectionCategory.episodesVolumesTracks,
    LibrarySectionCategory.people,
    LibrarySectionCategory.imagesMedia,
    LibrarySectionCategory.linksTrailersProviders,
    LibrarySectionCategory.notesCustomFields,
    LibrarySectionCategory.sourceCorrections,
    LibrarySectionCategory.activityHistory,
  ];

  static const Map<String, LibrarySectionCategory> sectionCategoryById = {
    'catalog_snapshot': LibrarySectionCategory.identity,
    'details': LibrarySectionCategory.identity,
    'main': LibrarySectionCategory.identity,
    'tracking_context': LibrarySectionCategory.progressTracking,
    'tracking_personal': LibrarySectionCategory.collectionStatus,
    'ownership_reference': LibrarySectionCategory.releaseEditionFormat,
    'ownership_fields': LibrarySectionCategory.collectionStatus,
    'purchase_fields': LibrarySectionCategory.collectionStatus,
    'sold_fields': LibrarySectionCategory.activityHistory,
    'wishlist_reference': LibrarySectionCategory.collectionStatus,
    'owned_notes': LibrarySectionCategory.notesCustomFields,
    'collection_fields_info': LibrarySectionCategory.collectionStatus,
    'owned_grading': LibrarySectionCategory.collectionStatus,
    'sold_status': LibrarySectionCategory.activityHistory,
    'profit_loss': LibrarySectionCategory.activityHistory,
    'value_summary': LibrarySectionCategory.collectionStatus,
    'release_details': LibrarySectionCategory.releaseEditionFormat,
    'video_specs': LibrarySectionCategory.releaseEditionFormat,
    'hdr': LibrarySectionCategory.releaseEditionFormat,
    'audio_subtitles': LibrarySectionCategory.releaseEditionFormat,
    'features': LibrarySectionCategory.releaseEditionFormat,
    'box_set': LibrarySectionCategory.releaseEditionFormat,
    'tv_episodes': LibrarySectionCategory.episodesVolumesTracks,
    'tv_episode_disc_map': LibrarySectionCategory.episodesVolumesTracks,
    'cast_list': LibrarySectionCategory.people,
    'crew_list': LibrarySectionCategory.people,
    'external_links': LibrarySectionCategory.linksTrailersProviders,
    'cover_images': LibrarySectionCategory.imagesMedia,
    'photos': LibrarySectionCategory.imagesMedia,
    'synopsis': LibrarySectionCategory.notesCustomFields,
    'custom_fields': LibrarySectionCategory.notesCustomFields,
    'read_history': LibrarySectionCategory.activityHistory,
  };

  int orderOfCategory(LibrarySectionCategory category) {
    return categoryOrder.indexOf(category);
  }

  int orderOfTab(
    LibraryEditTabSpec tab, [
    LibraryEditPresentationContext? context,
  ]) {
    final sectionIds = context == null || tab.sectionIdsForContext == null
        ? tab.sectionIds
        : tab.sectionIdsForContext!(context);
    if (sectionIds.isEmpty) {
      return categoryOrder.length;
    }
    var best = categoryOrder.length;
    for (final sectionId in sectionIds) {
      final category = sectionCategoryById[sectionId];
      if (category == null) continue;
      final order = orderOfCategory(category);
      if (order >= 0 && order < best) {
        best = order;
      }
    }
    return best;
  }

  List<LibraryEditTabSpec> orderTabs(
    Iterable<LibraryEditTabSpec> tabs, [
    LibraryEditPresentationContext? context,
  ]) {
    final indexedTabs = <_IndexedEditTab>[];
    var index = 0;
    for (final tab in tabs) {
      indexedTabs.add(_IndexedEditTab(index: index, tab: tab));
      index++;
    }
    indexedTabs.sort((left, right) {
      final leftOrder = orderOfTab(left.tab, context);
      final rightOrder = orderOfTab(right.tab, context);
      if (leftOrder != rightOrder) {
        return leftOrder.compareTo(rightOrder);
      }
      return left.index.compareTo(right.index);
    });
    return [for (final entry in indexedTabs) entry.tab];
  }
}

class _IndexedEditTab {
  const _IndexedEditTab({
    required this.index,
    required this.tab,
  });

  final int index;
  final LibraryEditTabSpec tab;
}
