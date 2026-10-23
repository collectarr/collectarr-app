import 'package:collectarr_app/features/library/config/library_import_capability.dart';
import 'package:flutter/material.dart';
import '../integrations/import/clz_game_hardware_csv_importer.dart';

import '../integrations/import/clz_game_hardware_web_importer.dart';

const List<KindMappableField> gameHardwareMappableFields = [
  KindMappableField(
    key: 'title',
    label: 'Title',
    aliases: ['Title', 'Name'],
    isDefault: true,
  ),
  KindMappableField(
    key: 'platform',
    label: 'Platform',
    aliases: ['Platform', 'System'],
    isDefault: true,
  ),
  KindMappableField(
    key: 'sort_title',
    label: 'Sort Title',
    aliases: ['Sort Title'],
  ),
  KindMappableField(
    key: 'hardware_type',
    label: 'Hardware Type',
    aliases: ['Hardware Type'],
  ),
  KindMappableField(
    key: 'serial_number',
    label: 'Serial No.',
    aliases: ['Serial No.', 'Serial Number'],
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
    key: 'manual',
    label: 'Manual',
    aliases: ['Manual', 'Has Manual'],
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
  KindMappableField(
    key: 'loaned_to',
    label: 'Loaned To',
    aliases: ['Loaned To', 'Borrower'],
  ),
  KindMappableField(
    key: 'loan_date',
    label: 'Loan Date',
    aliases: ['Loan Date', 'Lent Date'],
  ),
  KindMappableField(
    key: 'loan_due_date',
    label: 'Due Date',
    aliases: ['Due Date'],
  ),
];

final gameHardwareKindImport = LibraryKindImportCapability(
    allowsCustomFieldColumns: true,
    mappableFields: gameHardwareMappableFields,
    mappedCsvImporter: const GameHardwareMappedCsvImporter(),
    sources: const [
      LibraryImportSourceDefinition(
          id: 'clz_game_hardware_web',
          title: 'CLZ Games Web (Hardware)',
          importer: ClzGameHardwareWebImporter(),
          fileExtensions: ['xml'],
          description: 'Import one Hardware collection from CLZ Games Web.',
          instructions: [
            'Open the Hardware collection in CLZ Games Web.',
            'Choose Import / Export > Export to XML.',
            'Generate and download the XML file, then upload it here.'
          ],
          filePrompt: 'Upload the CLZ Hardware XML export:'),
      LibraryImportSourceDefinition(
          id: 'text',
          title: 'Import a Text or CSV file',
          fallbackIcon: Icons.description_outlined,
          sourceType: LibraryImportSourceType.csvTxt,
          fileExtensions: ['csv', 'txt']),
    ]);
