import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/music/inspector/music_inspector_view_model.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation.dart';
import 'package:flutter/material.dart';

Widget buildMusicWorkInspectorHero(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return LibraryDetailHero(
    type: request.type,
    item: request.item,
    libraryEntry: request.libraryEntry,
    accent: request.accent,
  );
}

Widget buildMusicAlbumInspectorHero(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return LibraryDetailHero(
    type: request.type,
    item: request.item,
    libraryEntry: request.libraryEntry,
    accent: request.accent,
  );
}

Widget buildMusicCopyInspectorHero(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return LibraryDetailHero(
    type: request.type,
    item: request.item,
    libraryEntry: request.libraryEntry,
    accent: request.accent,
  );
}

List<Widget> buildMusicWorkInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return _buildMusicInspectorSections(context, request);
}

List<Widget> buildMusicAlbumInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return _buildMusicInspectorSections(context, request);
}

List<Widget> buildMusicCopyInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  final sections = _buildMusicInspectorSections(context, request);
  final entryDetails =
      MusicInspectorViewModel.from(request.item).entry?.details;
  if (entryDetails == null) return sections;

  final facts = <LibraryDetailField>[
    if (entryDetails.signedBy?.trim().isNotEmpty == true)
      LibraryDetailField(
          label: 'Signed by', value: entryDetails.signedBy!.trim()),
    if (entryDetails.lastCleanedDate != null)
      LibraryDetailField(
        label: 'Last cleaned',
        value: formatNullableDate(entryDetails.lastCleanedDate) ?? '-',
      ),
  ];
  final model = MusicInspectorViewModel.from(request.item);
  for (final medium in model.mediums) {
    final storage = model.storageForMedium(medium.mediumNumber);
    if (storage.label != '-') {
      facts.add(
        LibraryDetailField(
          label: 'Disc ${medium.mediumNumber} storage',
          value: storage.label,
        ),
      );
    }
  }
  if (facts.isEmpty) return sections;
  return [
    ...sections,
    LibraryDetailSection(
      title: 'Entry media',
      accentColor: request.accent,
      children: [LibraryDetailFieldTable(fields: facts)],
    ),
  ];
}

List<Widget> _buildMusicInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return [
    InspectorMetadataSection(
      type: request.type,
      item: request.item,
      accent: request.accent,
      onFilterByValue: request.onFilterByValue,
    ),
    ...musicLibraryMediaBuilder.buildInspectorSections(
      context: context,
      item: request.item,
      accent: request.accent,
      onFilterByValue: request.onFilterByValue,
    ),
  ];
}
