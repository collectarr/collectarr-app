import 'package:collectarr_app/features/library/details/library_detail_models.dart';

List<LibraryDetailSectionSpec> orderLibraryDetailSections(
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

