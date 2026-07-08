import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/bundles/bundle_release_contents_section.dart';
import 'package:collectarr_app/features/library/bundles/item_bundle_release_browser_section.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_section_registry.dart';
import 'package:collectarr_app/features/library/detail/activity_timeline_section.dart';
import 'package:collectarr_app/features/library/detail/library_detail_catalog_sections.dart';
import 'package:collectarr_app/features/library/detail/library_detail_collection_sections.dart';
import 'package:collectarr_app/features/library/detail/library_detail_trailers_section.dart';
import 'package:collectarr_app/features/library/detail/metadata_corrections_section.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/details/library_detail_wiring.dart';
import 'package:collectarr_app/features/library/media/video/watch_history_section.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';

List<LibraryDetailSectionSpec> buildLibraryDetailSectionSpecs({
  required BuildContext context,
  required LibraryTypeConfig type,
  required LibraryWorkspaceEntry entry,
  required Color accent,
  required OwnedItem? ownedItem,
  required TrackingEntry? trackingEntry,
  required List<OwnedItem> ownedCopies,
  ValueChanged<String>? onFilterByValue,
}) {
  final activeBundleReleaseId =
      ownedItem?.bundleReleaseId ?? entry.referenceBundleReleaseId;

  final sections = <LibraryDetailSectionSpec>[
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.identity,
      title: 'Identity',
      children: [
        LibraryDetailMetadataSection(
          type: type,
          entry: entry,
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
            entry: entry,
            ownedItem: ownedItem,
            ownedCopies: ownedCopies,
            trackingEntry: trackingEntry,
            accent: accent,
            onFilterByValue: onFilterByValue,
          ),
          ...buildLibraryDetailEditorSections(
            type: type,
            entry: entry,
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
            itemId: entry.titleItemId ?? entry.id,
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
          entry: entry,
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
          entry: entry,
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
          trailerUrls: entry.trailerUrls,
          accent: accent,
        ),
      ],
    ),
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.imagesMedia,
      title: 'Images / media',
      children: [
        LibraryDetailCoverStatusSection(
          entry: entry,
          accent: accent,
        ),
      ],
    ),
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.notesCustomFields,
      title: 'Notes / snapshot',
      children: [
        LibraryDetailLocalSnapshotSection(
          entry: entry,
          ownedItem: ownedItem,
        ),
      ],
    ),
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.sourceCorrections,
      title: 'Source / corrections',
      children: [
        LibraryDetailProvenanceSection(
          type: type,
          entry: entry,
          accent: accent,
        ),
        const SizedBox(height: 8),
        LibraryDetailMetadataHealthSection(
          type: type,
          entry: entry,
          accent: accent,
          onFilterByValue: onFilterByValue,
        ),
        const SizedBox(height: 8),
        MetadataCorrectionsSection(
          itemId: entry.id,
          accent: accent,
        ),
        const SizedBox(height: 8),
        LibraryDetailProviderSection(
          type: type,
          accent: accent,
          onFilterByValue: onFilterByValue,
        ),
      ],
    ),
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.activityHistory,
      title: 'Activity / history',
      children: [
        WatchHistorySection(
          itemId: entry.id,
          accent: accent,
          labels: sessionHistoryLabelsForKind(type.workspace.kind.apiValue),
          defaultTargetRef: CatalogEntityRef(
            kind: type.workspace.kind.apiValue,
            entityType: CatalogEntityType.work,
            id: entry.id,
          ),
        ),
        const SizedBox(height: 8),
        ActivityTimelineSection(
          itemId: entry.id,
          ownedItemIds: ownedCopies.map((c) => c.id).toList(),
          accent: accent,
        ),
      ],
    ),
  ];

  return orderLibraryDetailSections(sections);
}

List<LibraryDetailSectionSpec> orderLibraryDetailSections(
  Iterable<LibraryDetailSectionSpec> sections,
) {
  return LibraryDetailSectionRegistry.instance.orderSections(sections);
}

List<Widget> buildLibraryDetailSectionWidgets(
  Iterable<LibraryDetailSectionSpec> sections, {
  double spacing = 8,
  Color? accentColor,
}) {
  final resolved = <Widget>[];
  for (final section in orderLibraryDetailSections(sections)) {
    if (resolved.isNotEmpty) {
      resolved.add(SizedBox(height: spacing));
    }
    resolved.add(
      LibraryDetailSection.fromSpec(
        section,
        accentColor: accentColor,
      ),
    );
  }
  return resolved;
}
