import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
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
    ownedItem: request.ownedItem,
    ownedCopies: request.ownedCopies,
    accent: request.accent,
  );
}

Widget buildMusicReleaseInspectorHero(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return LibraryDetailHero(
    type: request.type,
    item: request.item,
    ownedItem: request.ownedItem,
    ownedCopies: request.ownedCopies,
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
    ownedItem: request.ownedItem,
    ownedCopies: [
      if (request.ownedItem != null) request.ownedItem!,
    ],
    accent: request.accent,
  );
}

List<Widget> buildMusicWorkInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return _buildMusicInspectorSections(context, request);
}

List<Widget> buildMusicReleaseInspectorSections(
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
  final ownedDetails =
      MusicInspectorViewModel.from(request.item).owned?.details;
  if (ownedDetails == null) return sections;

  final facts = <LibraryDetailField>[
    if (ownedDetails.signedBy?.trim().isNotEmpty == true)
      LibraryDetailField(
          label: 'Signed by', value: ownedDetails.signedBy!.trim()),
    if (ownedDetails.lastCleanedDate != null)
      LibraryDetailField(
        label: 'Last cleaned',
        value: formatNullableDate(ownedDetails.lastCleanedDate) ?? '-',
      ),
  ];
  final model = MusicInspectorViewModel.from(request.item);
  for (final medium in model.mediums) {
    final storage = model.storageForMedium(medium.mediumNumber);
    final runouts = model.matrixForMedium(medium.mediumNumber);
    if (storage.label != '-') {
      facts.add(
        LibraryDetailField(
          label: 'Disc ${medium.mediumNumber} storage',
          value: storage.label,
        ),
      );
    }
    if (runouts.isNotEmpty) {
      facts.add(
        LibraryDetailField(
          label: 'Disc ${medium.mediumNumber} matrix',
          value: runouts
              .map((runout) => '${runout.side}: ${runout.text}')
              .join(' / '),
        ),
      );
    }
  }
  if (facts.isEmpty) return sections;
  return [
    ...sections,
    LibraryDetailSection(
      title: 'Owned media',
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
