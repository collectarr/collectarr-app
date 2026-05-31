import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/detail/library_detail_catalog_sections.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:flutter/material.dart';

List<Widget> buildComicInspectorSections(
  BuildContext _,
  LibraryInspectorRequest request,
) {
  final sections = <Widget>[
    LibraryDetailMetadataSection(
      type: request.type,
      entry: request.entry,
      accent: request.accent,
      onFilterByValue: request.onFilterByValue,
    ),
    LibraryDetailContextSection(
      type: request.type,
      entry: request.entry,
      accent: request.accent,
      onFilterByValue: request.onFilterByValue,
    ),
    LibraryDetailCreditsSection(
      type: request.type,
      entry: request.entry,
      accent: request.accent,
      onFilterByValue: request.onFilterByValue,
    ),
  ];
  final ownedItem = request.ownedItem;
  if (ownedItem == null) {
    return sections;
  }
  final ownedIsDigital = resolveOwnedDigitalFlag(
    ownedItem,
    request.entry.editions,
    fallbackLabel: request.entry.variant,
  );
  if (ownedIsDigital == true) {
    return sections;
  }
  final collectorFacts = <LibraryInspectorFactData>[
    if (ownedItem.rawOrSlabbed?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Raw / Slabbed', ownedItem.rawOrSlabbed!),
    if (ownedItem.gradingCompany?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Grading co.', ownedItem.gradingCompany!),
    if (ownedItem.signedBy?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Signed by', ownedItem.signedBy!),
    if (ownedItem.keyComic)
      LibraryInspectorFactData('Key', ownedItem.keyReason ?? 'Yes'),
  ];
  if (collectorFacts.isNotEmpty) {
    sections.add(
      LibraryInspectorSection(
        title: 'Comic details',
        accentColor: request.accent,
        children: [
          LibraryInspectorFactGrid(facts: collectorFacts),
        ],
      ),
    );
  }
  final currentValue = formatMoney(
    ownedItem.marketValueCents,
    ownedItem.currency,
  );
  if (currentValue.isNotEmpty) {
    sections.add(
      LibraryInspectorSection(
        title: 'Value',
        accentColor: request.accent,
        children: [
          LibraryInspectorFactGrid(
            facts: [
              LibraryInspectorFactData('Current value', currentValue),
            ],
          ),
        ],
      ),
    );
  }
  return sections;
}