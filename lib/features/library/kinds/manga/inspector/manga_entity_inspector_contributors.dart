import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/inspector/sections/personal_status_section.dart';
import 'package:collectarr_app/features/library/kinds/manga/presentation_builder.dart';
import 'package:flutter/material.dart';

Widget buildMangaWorkInspectorHero(
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

Widget buildMangaReleaseInspectorHero(
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

Widget buildMangaCopyInspectorHero(
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

List<Widget> buildMangaWorkInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return _buildMangaMetadataSections(context, request, showSummary: true);
}

List<Widget> buildMangaReleaseInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return _buildMangaMetadataSections(context, request, showSummary: false);
}

List<Widget> buildMangaCopyInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return [
    ..._buildMangaMetadataSections(context, request, showSummary: false),
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

List<Widget> _buildMangaMetadataSections(
  BuildContext context,
  LibraryInspectorRequest request, {
  required bool showSummary,
}) {
  return MangaLibraryMediaPresentationBuilder(showSummary: showSummary)
      .buildInspectorSections(
    context: context,
    item: request.item,
    accent: request.accent,
    onFilterByValue: request.onFilterByValue,
  );
}
