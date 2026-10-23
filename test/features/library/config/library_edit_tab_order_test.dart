import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section_builder.dart';
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
}
