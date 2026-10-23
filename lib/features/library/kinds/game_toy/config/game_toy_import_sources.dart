import 'package:collectarr_app/features/library/config/library_import_capability.dart';
import 'package:flutter/material.dart';
import '../integrations/import/clz_game_toy_csv_importer.dart';

import '../integrations/import/clz_game_toy_web_importer.dart';

const List<KindMappableField> gameToyMappableFields = [
  KindMappableField(
    key: 'title',
    label: 'Title',
    aliases: ['Title', 'Name'],
    isDefault: true,
  ),
  KindMappableField(
    key: 'sort_title',
    label: 'Sort Title',
    aliases: ['Sort Title'],
  ),
  KindMappableField(
    key: 'toy_type',
    label: 'Type',
    aliases: ['Type', 'Toy Type'],
  ),
  KindMappableField(
    key: 'toy_subtype',
    label: 'Subtype',
    aliases: ['Subtype', 'Toy Subtype'],
  ),
  KindMappableField(
    key: 'release_date',
    label: 'Release Date',
    aliases: ['Release Date', 'Released'],
    isDefault: true,
  ),
  KindMappableField(
    key: 'series',
    label: 'Series',
    aliases: ['Series', 'Franchise'],
  ),
  KindMappableField(
    key: 'barcode',
    label: 'Barcode',
    aliases: ['Barcode', 'UPC', 'EAN'],
  ),
  KindMappableField(
    key: 'description',
    label: 'Description',
    aliases: ['Description', 'Summary'],
  ),
  KindMappableField(
    key: 'completeness',
    label: 'Completeness',
    aliases: ['Completeness'],
  ),
  KindMappableField(
    key: 'box',
    label: 'Box',
    aliases: ['Box', 'Has Box'],
  ),
  KindMappableField(
    key: 'condition',
    label: 'Condition',
    aliases: ['Condition'],
  ),
  KindMappableField(
    key: 'purchase_date',
    label: 'Purchase Date',
    aliases: ['Purchase Date'],
  ),
  KindMappableField(
    key: 'purchase_price',
    label: 'Purchase Price',
    aliases: ['Purchase Price', 'Price Paid'],
  ),
  KindMappableField(
    key: 'purchase_store',
    label: 'Purchase Store',
    aliases: ['Purchase Store', 'Store'],
  ),
  KindMappableField(
    key: 'value',
    label: 'Value',
    aliases: ['Value', 'Current Value'],
  ),
  KindMappableField(
    key: 'added_date',
    label: 'Added Date',
    aliases: ['Added Date'],
  ),
  KindMappableField(
    key: 'modified_date',
    label: 'Modified Date',
    aliases: ['Modified Date'],
  ),
  KindMappableField(
    key: 'collection_status',
    label: 'Collection Status',
    aliases: ['Collection Status', 'Status'],
  ),
  KindMappableField(
    key: 'index',
    label: 'Index',
    aliases: ['Index'],
  ),
  KindMappableField(
    key: 'my_rating',
    label: 'My Rating',
    aliases: ['My Rating', 'Rating'],
  ),
  KindMappableField(
    key: 'notes',
    label: 'Notes',
    aliases: ['Notes'],
  ),
  KindMappableField(
    key: 'owner',
    label: 'Owner',
    aliases: ['Owner'],
  ),
  KindMappableField(
    key: 'quantity',
    label: 'Quantity',
    aliases: ['Quantity'],
  ),
  KindMappableField(
    key: 'tags',
    label: 'Tags',
    aliases: ['Tags', 'Keywords'],
  ),
];

final gameToyKindImport = LibraryKindImportCapability(
    mappableFields: gameToyMappableFields,
    mappedCsvImporter: const GameToyMappedCsvImporter(),
    sources: const [
      LibraryImportSourceDefinition(
          id: 'clz_game_toy_web',
          title: 'CLZ Games Web (Toys)',
          importer: ClzGameToyWebImporter(),
          fileExtensions: ['xml'],
          description: 'Import one Toys collection from CLZ Games Web.',
          instructions: [
            'Open the Toys collection in CLZ Games Web.',
            'Choose Import / Export > Export to XML.',
            'Generate and download the XML file, then upload it here.'
          ],
          filePrompt: 'Upload the CLZ Toys XML export:'),
      LibraryImportSourceDefinition(
          id: 'text',
          title: 'Import a Text or CSV file',
          assetLogoPath: 'assets/import_logos/text.svg',
          fallbackIcon: Icons.description_outlined,
          isSvg: true,
          sourceType: LibraryImportSourceType.csvTxt,
          fileExtensions: ['csv', 'txt']),
    ]);
