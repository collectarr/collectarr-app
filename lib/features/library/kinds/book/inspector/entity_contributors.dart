import 'package:collectarr_app/features/library/config/item_actions.dart';
import '../detail/hero.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation_builder.dart';
import 'package:flutter/material.dart';

Widget buildBookCatalogItemInspectorHero(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return BookDetailHero(request: request);
}

Widget buildBookLibraryEntryInspectorHero(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return BookDetailHero(request: request);
}

List<Widget> buildBookCatalogItemInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return const BookLibraryMediaPresentationBuilder(
    showPersonalDetails: false,
  ).buildInspectorSections(
    context: context,
    item: request.item,
    accent: request.accent,
    onFilterByValue: request.onFilterByValue,
  );
}

List<Widget> buildBookLibraryEntryInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return const BookLibraryMediaPresentationBuilder().buildInspectorSections(
    context: context,
    item: request.item,
    accent: request.accent,
    onFilterByValue: request.onFilterByValue,
  );
}
