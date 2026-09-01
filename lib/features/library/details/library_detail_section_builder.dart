import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/bundles/bundle_release_contents_section.dart';
import 'package:collectarr_app/features/library/bundles/item_bundle_release_browser_section.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/detail/library_detail_catalog_sections.dart';
import 'package:collectarr_app/features/library/detail/library_detail_collection_sections.dart';
import 'package:collectarr_app/features/library/detail/library_detail_trailers_section.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_wiring.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

List<LibraryDetailSectionSpec> buildLibraryDetailSectionSpecs({
  required BuildContext context,
  required LibraryKindRuntime type,
  required LibraryProjectionRuntime item,
  required Color accent,
  required OwnedItem? ownedItem,
  required TrackingEntry? trackingEntry,
  required List<OwnedItem> ownedCopies,
  ValueChanged<String>? onFilterByValue,
}) {
  final activeBundleReleaseId = ownedItem?.bundleReleaseId;

  final sections = <LibraryDetailSectionSpec>[
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.identity,
      title: 'Identity',
      children: [
        LibraryDetailMetadataSection(
          type: type,
          item: item,
          accent: accent,
          onFilterByValue: onFilterByValue,
        ),
      ],
    ),
    if (ownedItem != null || trackingEntry != null)
      LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.personalStatus,
        title: 'Personal status',
        children: [
          LibraryDetailPersonalSection(
            item: item,
            ownedItem: ownedItem,
            ownedCopies: ownedCopies,
            trackingEntry: trackingEntry,
            accent: accent,
            onFilterByValue: onFilterByValue,
          ),
          ...buildLibraryDetailEditorSections(
            type: type,
            item: item,
            accent: accent,
            ownedItem: ownedItem,
            trackingEntry: trackingEntry,
          ),
        ],
      ),
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.progressOwnership,
      title: 'Ownership / release',
      children: [
        if (activeBundleReleaseId != null)
          BundleReleaseContentsSection(
            bundleReleaseId: activeBundleReleaseId,
            accent: accent,
          )
        else
          ItemBundleReleaseBrowserSection(
            itemId: item.node.titleItemId,
            accent: accent,
          ),
      ],
    ),
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.formatEditionRelease,
      title: 'Release details',
      children: [
        LibraryDetailContextSection(
          type: type,
          item: item,
          accent: accent,
          onFilterByValue: onFilterByValue,
        ),
      ],
    ),
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.people,
      title: 'People',
      children: [
        LibraryDetailCreditsSection(
          type: type,
          item: item,
          accent: accent,
          onFilterByValue: onFilterByValue,
        ),
      ],
    ),
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.seriesLinks,
      title: 'Series links',
      children: [
        LibraryDetailTrailersSection(
          trailerUrls: item.source.catalogItem?.trailerUrls ?? const [],
          accent: accent,
        ),
      ],
    ),
    for (final widget in buildLibraryDetailCatalogSections(
      context: context,
      type: type,
      item: item,
      accent: accent,
      onFilterByValue: onFilterByValue,
    ))
      LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.identity,
        title: '',
        children: [widget],
      ),
  ];

  return orderLibraryDetailSections(sections);
}

List<LibraryDetailSectionSpec> orderLibraryDetailSections(
  List<LibraryDetailSectionSpec> sections,
) {
  final copy = List<LibraryDetailSectionSpec>.from(sections);
  copy.sort((a, b) {
    final indexA = libraryDetailSectionOrder.indexOf(a.slot);
    final indexB = libraryDetailSectionOrder.indexOf(b.slot);
    final rankA = indexA == -1 ? 999 : indexA;
    final rankB = indexB == -1 ? 999 : indexB;
    return rankA.compareTo(rankB);
  });
  return copy;
}
