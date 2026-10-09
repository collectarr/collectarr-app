import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section_builder.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit_presentation_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('detail sections follow the shared detail order', () {
    final sections = orderLibraryDetailSections([
      const LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.activity,
        title: 'History',
      ),
      const LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.identity,
        title: 'Identity',
      ),
      const LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.media,
        title: 'Images',
      ),
      const LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.relations,
        title: 'People',
      ),
    ]);

    expect(
      sections.map((section) => section.slot).toList(),
      [
        LibraryDetailSectionSlot.identity,
        LibraryDetailSectionSlot.relations,
        LibraryDetailSectionSlot.media,
        LibraryDetailSectionSlot.activity,
      ],
    );
  });

  test('tv edit tabs are ordered by the technical tab order helper', () {
    final tabs = tvLibraryEditPresentation.buildTabs(
      context: const LibraryEditPresentationContext(
        isEntry: false,
        isTrackingOnly: false,
        hasTrackingContext: false,
        hasWishlistContext: false,
        isDigitalFormat: false,
        hasPhysicalFormats: true,
        hasCustomFields: false,
      ),
      isEntry: false,
    );

    expect(
      tabs.map((tab) => tab.id).toList(),
      [
        'media',
        'edition',
        'personal',
        'episodes',
        'episode_media_map',
        'cast',
        'crew',
        'specs',
        'cover',
        'photos',
        'links',
        'synopsis',
      ],
    );
  });
}
