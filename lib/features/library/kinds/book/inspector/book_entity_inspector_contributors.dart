import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/book/detail/book_author_spotlight.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation_builder.dart';
import 'package:flutter/material.dart';

Widget buildBookWorkInspectorHero(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return LibraryDetailHero(
    type: request.type,
    item: request.item,
    libraryEntry: request.libraryEntry,
    accent: request.accent,
    kindEntryContent: buildBookAuthorSpotlight(
      item: request.item,
      accent: request.accent,
    ),
  );
}

Widget buildBookCopyInspectorHero(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return LibraryDetailHero(
    type: request.type,
    item: request.item,
    libraryEntry: request.libraryEntry,
    accent: request.accent,
    kindEntryContent: buildBookAuthorSpotlight(
      item: request.item,
      accent: request.accent,
    ),
  );
}

List<Widget> buildBookWorkInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return const BookLibraryMediaPresentationBuilder(
    showSummary: true,
    showVolumeHierarchy: true,
    showPersonalDetails: false,
  ).buildInspectorSections(
    context: context,
    item: request.item,
    accent: request.accent,
    onFilterByValue: request.onFilterByValue,
  );
}

List<Widget> buildBookCopyInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  final sections = const BookLibraryMediaPresentationBuilder(
    showPersonalDetails: false,
  ).buildInspectorSections(
    context: context,
    item: request.item,
    accent: request.accent,
    onFilterByValue: request.onFilterByValue,
  );
  final entry =
      BookLibraryEntryProjection.fromDispatch(request.libraryEntryDispatch);
  if (entry == null) return sections;
  final details = entry.personal.details;
  final facts = <LibraryDetailField>[
    if (details.signedBy?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Signed by', value: details.signedBy!.trim()),
    if (details.dustJacketPresent)
      LibraryDetailField(
        label: 'Dust jacket',
        value: details.dustJacketCondition?.trim().isNotEmpty == true
            ? details.dustJacketCondition!.trim()
            : 'Present',
      ),
  ];
  if (facts.isEmpty) return sections;
  return [
    ...sections,
    LibraryDetailSection(
      title: 'Collection item details',
      accentColor: request.accent,
      children: [LibraryDetailFieldTable(fields: facts)],
    ),
  ];
}
