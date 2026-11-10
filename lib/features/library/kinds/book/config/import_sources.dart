import 'package:collectarr_app/features/library/config/import_capability.dart';
import 'package:flutter/material.dart';
import '../integrations/import/mapped_csv_importer.dart';

const _fields = <(String, String)>[
  ('title', 'Title'),
  ('sort_title', 'Sort Title'),
  ('subtitle', 'Subtitle'),
  ('author', 'Author'),
  ('series', 'Series'),
  ('series_number', 'Series Number'),
  ('isbn', 'ISBN'),
  ('barcode', 'Barcode'),
  ('publisher', 'Publisher'),
  ('imprint', 'Imprint'),
  ('format', 'Format'),
  ('pages', 'Pages'),
  ('country', 'Country'),
  ('language', 'Language'),
  ('publication_date', 'Publication Date'),
  ('publication_place', 'Publication Place'),
  ('genre', 'Genre'),
  ('subject', 'Subject'),
  ('plot', 'Plot'),
  ('translator', 'Translator'),
  ('editor', 'Editor'),
  ('illustrator', 'Illustrator'),
  ('cover_artist', 'Cover Artist'),
  ('condition', 'Condition'),
  ('grade', 'Grade'),
  ('index', 'Index'),
  ('owner', 'Owner'),
  ('notes', 'Notes'),
  ('tags', 'Tags'),
  ('collection_status', 'Collection Status'),
  ('currency', 'Currency'),
  ('purchase_price', 'Purchase Price'),
  ('purchase_date', 'Purchase Date'),
  ('purchase_store', 'Purchase Store'),
  ('retail_price', 'Retail Price'),
  ('value', 'My Value'),
  ('price_sold', 'Price Sold'),
  ('sold_date', 'Sold Date'),
  ('signed_by', 'Signed By'),
  ('added_date', 'Added Date'),
  ('modified_date', 'Modified Date'),
  ('loaned_to', 'Loaned To'),
  ('loan_date', 'Loan Date'),
  ('loan_due_date', 'Due Date'),
];

final bookKindImport = LibraryKindImportCapability(
  allowsCustomFieldColumns: true,
  mappedCsvImporter: const BookMappedCsvImporter(),
  mappableFields: [
    for (final (key, label) in _fields)
      KindMappableField(
          key: key, label: label, aliases: [label], isDefault: key == 'title')
  ],
  sources: const [
    LibraryImportSourceDefinition(
        id: 'text',
        title: 'Import a Text or CSV file',
        fallbackIcon: Icons.description_outlined,
        sourceType: LibraryImportSourceType.csvTxt,
        fileExtensions: ['csv', 'txt'])
  ],
);
