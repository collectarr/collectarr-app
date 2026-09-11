import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/features/library/bundles/bundle_release_contents_section.dart';
import 'package:collectarr_app/features/library/bundles/item_bundle_release_browser_section.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/detail/library_detail_catalog_sections.dart';
import 'package:collectarr_app/features/library/detail/library_detail_collection_sections.dart';
import 'package:collectarr_app/features/library/detail/library_detail_trailers_section.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_wiring.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/config/catalog_reference_helpers.dart';
import 'package:flutter/material.dart';

List<LibraryDetailSectionSpec> buildLibraryDetailSectionSpecs({
  required BuildContext context,
  required LibraryKindModule type,
  required LibraryProjectionView item,
  required Color accent,
  OwnedItemSummary? ownedSummary,
  required TrackingLifecycle? trackingLifecycle,
  required List<OwnedItemSummary> ownedCopies,
  ValueChanged<String>? onFilterByValue,
}) {
  final activeBundleReleaseId =
      catalogRefBundleReleaseId(ownedSummary?.targetRef);

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
    if (ownedSummary != null || trackingLifecycle != null)
      LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.personal,
        title: 'Personal status',
        children: [
          LibraryDetailPersonalSection(
            type: type,
            item: item,
            typedOwnedItem: item.source.typedOwnedItem,
            ownedSummary: ownedSummary,
            ownedCopies: ownedCopies,
            trackingLifecycle: trackingLifecycle,
            accent: accent,
            onFilterByValue: onFilterByValue,
          ),
          ...buildLibraryDetailEditorSections(
            type: type,
            item: item,
            accent: accent,
            trackingLifecycle: trackingLifecycle,
          ),
        ],
      ),
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.progress,
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
      slot: LibraryDetailSectionSlot.metadata,
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
      slot: LibraryDetailSectionSlot.relations,
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
      slot: LibraryDetailSectionSlot.links,
      title: 'Series links',
      children: [
        LibraryDetailTrailersSection(
          trailerUrls: item.source.catalogTransport == null
              ? const []
              : type.presentation.builder.buildLinks(
                  item: item.source.catalogTransport!,
                ),
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
