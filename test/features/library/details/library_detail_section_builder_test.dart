import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section_builder.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('detail sections are ordered canonically', () {
    final ordered = orderLibraryDetailSections([
      LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.activityHistory,
        title: 'Activity',
        children: const [SizedBox.shrink()],
      ),
      LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.identity,
        title: 'Identity',
        children: const [SizedBox.shrink()],
      ),
      LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.imagesMedia,
        title: 'Images',
        children: const [SizedBox.shrink()],
      ),
    ]);

    expect(
      ordered.map((section) => section.slot),
      equals([
        LibraryDetailSectionSlot.identity,
        LibraryDetailSectionSlot.imagesMedia,
        LibraryDetailSectionSlot.activityHistory,
      ]),
    );
  });
}
