import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/inspector/sections/personal_status_section.dart';
import 'package:collectarr_app/features/library/kinds/anime/presentation.dart';
import 'package:flutter/material.dart';

Widget buildAnimeCatalogItemInspectorHero(
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

Widget buildAnimeLibraryEntryInspectorHero(
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

List<Widget> buildAnimeCatalogItemInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return _buildAnimeMetadataSections(context, request);
}

List<Widget> buildAnimeLibraryEntryInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return [
    ..._buildAnimeMetadataSections(context, request),
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
