import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_section_registry.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit_presentation_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('detail sections follow the shared registry order', () {
    final registry = LibraryDetailSectionRegistry.instance;
    final sections = registry.orderSections([
      const LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.activityHistory,
        title: 'History',
      ),
      const LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.identity,
        title: 'Identity',
      ),
      const LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.imagesMedia,
        title: 'Images',
      ),
      const LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.people,
        title: 'People',
      ),
    ]);

    expect(
      sections.map((section) => section.slot).toList(),
      [
        LibraryDetailSectionSlot.identity,
        LibraryDetailSectionSlot.people,
        LibraryDetailSectionSlot.imagesMedia,
        LibraryDetailSectionSlot.activityHistory,
      ],
    );
  });

  test('tv edit tabs are ordered by the shared section registry', () {
    final builder = TvLibraryEditPresentationBuilder();
    final tabs = builder.buildTabs(
      context: const LibraryEditPresentationContext(
        isOwned: false,
        isTrackingOnly: false,
        hasTrackingContext: false,
        hasWishlistContext: false,
        isDigitalFormat: false,
        hasPhysicalFormats: true,
        hasEditionAnchors: false,
        hasBundleReleaseAnchors: false,
        hasCustomFields: false,
      ),
    );

    expect(
      tabs.map((tab) => tab.id).toList(),
      [
        'media',
        'personal',
        'episodes',
        'episode_map',
        'cast',
        'crew',
        'cover',
        'photos',
        'links',
        'synopsis',
      ],
    );
  });
}
