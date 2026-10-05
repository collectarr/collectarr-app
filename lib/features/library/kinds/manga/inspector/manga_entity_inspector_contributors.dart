import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/inspector/sections/personal_status_section.dart';
import 'package:collectarr_app/features/library/kinds/manga/presentation_builder.dart';
import 'package:flutter/material.dart';

Widget buildMangaCatalogItemInspectorHero(
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

Widget buildMangaLibraryEntryInspectorHero(
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

List<Widget> buildMangaCatalogItemInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return _buildMangaMetadataSections(context, request, showSummary: true);
}

List<Widget> buildMangaLibraryEntryInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return [
    ..._buildMangaMetadataSections(context, request, showSummary: false),
    if (request.libraryEntry != null || request.trackingSummary != null)
      InspectorPersonalStatusSection(
        type: request.type,
        item: request.item,
        libraryEntry: request.libraryEntry,
        libraryEntryDispatch: request.libraryEntryDispatch,
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
