import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/inspector/sections/personal_status_section.dart';
import 'package:collectarr_app/features/library/kinds/anime/presentation.dart';
import 'package:flutter/material.dart';

Widget buildAnimeWorkInspectorHero(
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

Widget buildAnimeReleaseInspectorHero(
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

Widget buildAnimeCopyInspectorHero(
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

List<Widget> buildAnimeWorkInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return _buildAnimeMetadataSections(context, request);
}

List<Widget> buildAnimeReleaseInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return _buildAnimeMetadataSections(context, request);
}

List<Widget> buildAnimeCopyInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return [
    ..._buildAnimeMetadataSections(context, request),
    if (request.ownedItem != null || request.trackingSummary != null)
      InspectorPersonalStatusSection(
        type: request.type,
        item: request.item,
        ownedItem: request.ownedItem,
        ownedItemDispatch: request.ownedItemDispatch,
        trackingSummary: request.trackingSummary,
        accent: request.accent,
        onFilterByValue: request.onFilterByValue,
      ),
  ];
}

List<Widget> _buildAnimeMetadataSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return animeLibraryMediaBuilder.buildInspectorSections(
    context: context,
    item: request.item,
    accent: request.accent,
    onFilterByValue: request.onFilterByValue,
  );
}
