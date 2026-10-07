import 'package:collectarr_app/features/library/config/library_import_capability.dart';
import 'package:flutter/material.dart';

const List<KindMappableField> musicMappableFields = [
  KindMappableField(
    key: 'artist',
    label: 'Artist',
    aliases: ['Artist', 'Band', 'Performer', 'Artist Name'],
    isDefault: true,
  ),
  KindMappableField(
    key: 'title',
    label: 'Title',
    aliases: ['Title', 'Album', 'Album Title', 'Release', 'Full Title'],
    isDefault: true,
  ),
  KindMappableField(
    key: 'release_year',
    label: 'Release Year',
    aliases: ['Year', 'Release Year', 'Released', 'Date', 'Release Date'],
    isDefault: true,
  ),
  KindMappableField(
    key: 'format',
    label: 'Format',
    aliases: ['Format', 'Media', 'Media Format', 'Physical Format', 'Format / Edition'],
  ),
  KindMappableField(
    key: 'label',
    label: 'Label',
    aliases: ['Label', 'Record Label', 'Publisher', 'Company'],
  ),
  KindMappableField(
    key: 'catalog_no',
    label: 'Catalog Number',
    aliases: ['Catalog no.', 'Catalog Number', 'Cat#', 'Cat No', 'CatNum'],
  ),
  KindMappableField(
    key: 'barcode',
    label: 'Barcode',
    aliases: ['Barcode', 'UPC', 'EAN', 'Barcode / Catalog no.'],
  ),
  KindMappableField(
    key: 'genre',
    label: 'Genre',
    aliases: ['Genre', 'Genres', 'Style', 'Styles'],
  ),
  KindMappableField(
    key: 'country',
    label: 'Country',
    aliases: ['Country', 'Release Country'],
  ),
  KindMappableField(
    key: 'track_count',
    label: 'Track Count',
    aliases: ['Tracks', 'Track Count', 'Total Tracks'],
  ),
  KindMappableField(
    key: 'disc_count',
    label: 'Discs',
    aliases: ['Discs', 'Disc Count', 'Discs Total'],
  ),
  KindMappableField(
    key: 'rating',
    label: 'My Rating',
    aliases: ['Rating', 'My Rating', 'Stars', 'Score'],
  ),
  KindMappableField(
    key: 'condition',
    label: 'Media Condition',
    aliases: ['Condition', 'Media Condition', 'Grade'],
  ),
  KindMappableField(
    key: 'location',
    label: 'Location',
    aliases: ['Location', 'Location ID', 'Shelf', 'Storage'],
  ),
  KindMappableField(
    key: 'purchase_date',
    label: 'Purchase Date',
    aliases: ['Purchase Date', 'Bought Date', 'Acquired'],
  ),
  KindMappableField(
    key: 'price_paid',
    label: 'Purchase Price',
    aliases: ['Purchase Price', 'Price Paid', 'Price', 'Cost'],
  ),
  KindMappableField(
    key: 'notes',
    label: 'Notes',
    aliases: ['Notes', 'Personal Notes', 'Comments', 'Remarks'],
  ),
  KindMappableField(
    key: 'tags',
    label: 'Tags',
    aliases: ['Tags', 'Keywords'],
  ),
];

final musicImportSources = <LibraryImportSourceDefinition>[
  const LibraryImportSourceDefinition(
    id: 'text',
    title: 'Import a Text or CSV file',
    assetLogoPath: 'assets/import_logos/text.svg',
    fallbackIcon: Icons.description_outlined,
    isSvg: true,
    sourceType: LibraryImportSourceType.csvTxt,
    fileExtensions: ['csv', 'txt'],
  ),
  const LibraryImportSourceDefinition(
    id: 'discogs',
    title: 'Discogs',
    assetLogoPath: 'assets/import_logos/discogs.svg',
    fallbackIcon: Icons.album_outlined,
    isSvg: true,
    sourceType: LibraryImportSourceType.guidedFile,
    fileExtensions: ['csv'],
    description:
        'To import your list of albums from Discogs, you need to export a CSV file of your albums out of your Discogs account. Here\'s what to do:',
    instructions: [
      'Log in to your Discogs account.',
      'Open your Dashboard and click "Export".',
      'Under "Choose export options" click "Collection", then click "Request Data Export"',
      'Download the created CSV file and upload it below:',
    ],
    filePrompt: 'Upload your Discogs CSV file:',
  ),
  const LibraryImportSourceDefinition(
    id: 'musiclabel',
    title: 'Music Label',
    assetLogoPath: 'assets/import_logos/musiclabel.png',
    fallbackIcon: Icons.album,
    isSvg: false,
    sourceType: LibraryImportSourceType.guidedFile,
    fileExtensions: ['xml'],
    description:
        'To import your list of albums from Music Label, you need to export a ZIP file of your albums out of your Music Label program. Here\'s what to do:',
    instructions: [
      'Start Music Label on your computer.',
      'Click Albums on the left side.',
      'Click the Data tab at the top.',
      'Click Export Data.',
      'Click Netwalk Musica [Legacy].',
      'Save the ZIP file on your computer and extract it.',
      'Inside you will find a file called export.xml, upload that file below:',
    ],
    filePrompt: 'Upload your Music Label XML file:',
  ),
  const LibraryImportSourceDefinition(
    id: 'catraxx',
    title: 'CATraxx',
    assetLogoPath: 'assets/import_logos/catraxx.svg',
    fallbackIcon: Icons.music_note,
    isSvg: true,
    sourceType: LibraryImportSourceType.guidedFile,
    fileExtensions: ['xml'],
    description:
        'To import your list of albums from CATraxx, you need to export an XML file of your albums out of CATraxx. Here\'s what to do:',
    instructions: [
      'Start CATraxx on your computer.',
      'Click menu File > Export > XML',
      'Click "Albums" in the left hand panel and set it to include "All" albums.',
      'Click "Export" and save the XML file on your computer.',
      'Upload the "CATraxx_Albums.xml" file below:',
    ],
    filePrompt: 'Upload your CATraxx XML file:',
  ),
  const LibraryImportSourceDefinition(
    id: 'delicious',
    title: 'Delicious Library',
    assetLogoPath: 'assets/import_logos/delicious.png',
    fallbackIcon: Icons.folder_special,
    isSvg: false,
    sourceType: LibraryImportSourceType.guidedFile,
    fileExtensions: ['txt'],
    description:
        'To import your list of albums from Delicious, you need to export a TXT file of your Delicious collection. Here\'s what to do:',
    instructions: [
      'Start Delicious Library on your computer.',
      'Click menu File > Export To > Another Application.',
      'Select Delimited Text and check every box in the Export Fields box.',
      'For Export, select Entire Library.',
      'For Seperate multiple values with:, select Comma.',
      'For Delimiter, select Comma-seperated.',
      'Check the Export as Unicode box.',
      'Press the Export button.',
      'Upload the saved "Library Export xxxx-xx-xx.txt" file below:',
    ],
    filePrompt: 'Upload your Delicious TXT file:',
  ),
  const LibraryImportSourceDefinition(
    id: 'orangecd',
    title: 'OrangeCD',
    assetLogoPath: 'assets/import_logos/orangecd.png',
    fallbackIcon: Icons.album_outlined,
    isSvg: false,
    sourceType: LibraryImportSourceType.guidedFile,
    fileExtensions: ['oxl', 'xml'],
    description:
        'To import your list of albums from OrangeCD, you need to export an OXL file of your albums out of OrangeCD. Here\'s what to do:',
    instructions: [
      'Start OrangeCD on your computer.',
      'Click menu Database > Import and export',
      'Select the Export to OrangeCD XML option',
      'Press "next" and save the file somewhere you will be able to find it',
      'Upload your OrangeCD OXL file below:',
    ],
    filePrompt: 'Upload your OrangeCD OXL file:',
  ),
  const LibraryImportSourceDefinition(
    id: 'cdpedia',
    title: 'CDpedia',
    assetLogoPath: 'assets/import_logos/cdpedia.png',
    fallbackIcon: Icons.library_music,
    isSvg: false,
    sourceType: LibraryImportSourceType.guidedFile,
    fileExtensions: ['xml'],
    description:
        'To import your list of albums from CDpedia, you need to export an XML file of your albums out of CDpedia. Here\'s what to do:',
    instructions: [
      'Start CDpedia on your computer.',
      'Click menu File > Export',
      'at the top select the ".cdpedia" tab',
      'Click the Export button',
      'Locate the exported folder and find the info.xml file inside it',
      'Upload the "info.xml" file below:',
    ],
    filePrompt: 'Upload your CDpedia XML file:',
  ),
  const LibraryImportSourceDefinition(
    id: 'musiccollector',
    title: 'Music Collector',
    assetLogoPath: 'assets/import_logos/logo-desktop.png',
    fallbackIcon: Icons.desktop_windows,
    isSvg: false,
    sourceType: LibraryImportSourceType.guidedFile,
    fileExtensions: ['xml'],
    description:
        'To import your list of albums from Music Collector, you need to export an XML file of your albums out of Music Collector. Here\'s what to do:',
    instructions: [
      'Start Music Collector on your computer.',
      'Click menu File > Export to > XML.',
      'Select "All Albums" and export to an XML file.',
      'Upload the saved XML file below:',
    ],
    filePrompt: 'Upload your Music Collector XML file:',
  ),
  const LibraryImportSourceDefinition(
    id: 'clzweb',
    title: 'CLZ Music Web',
    assetLogoPath: 'assets/import_logos/clz-music-icon.svg',
    fallbackIcon: Icons.cloud_download_outlined,
    isSvg: true,
    sourceType: LibraryImportSourceType.guidedFile,
    fileExtensions: ['xml'],
    description:
        'To import your list of albums from CLZ Music Web, you need to export an XML file of your albums out of CLZ Music Web. Here\'s what to do:',
    instructions: [
      'Login to CLZ Music Web.',
      'Click the menu on the left and navigate to "Export to XML".',
      'Click OK to save the exported XML file.',
      'Download the XML file.',
      'Upload the saved XML file below:',
    ],
    filePrompt: 'Upload your CLZ Music Web XML file:',
  ),
];

final musicOtherImportSources = <LibraryImportSourceDefinition>[
  const LibraryImportSourceDefinition(
    id: 'musiccollector_udf',
    title: 'Import User Defined Fields from Music Collector',
    assetLogoPath: 'assets/import_logos/logo-desktop.png',
    fallbackIcon: Icons.desktop_windows,
    isSvg: false,
    sourceType: LibraryImportSourceType.guidedFile,
    fileExtensions: ['xml'],
    isOtherSection: true,
    description:
        'If you have user defined fields in the legacy Music Collector Windows program, you can import them to CLZ Music Web. This is a one-time import meant for users who are making the switch from Music Collector to CLZ Music Web (and stop using Music Collector Windows).',
    subDescription:
        'To import your user defined fields from Music Collector Windows to CLZ Music Web, follow these steps exactly and not make any other alterations to your database during the process:',
    instructions: [
      'Click menu CLZ Cloud > Synchronize and click "Synchronize".',
      'Now go to File > Export to > XML and export "All Albums" to an XML file (use the Browse button to select a location).',
      'Upload the XML file below:',
    ],
    filePrompt: 'Upload your Music Collector XML file:',
    extraNoteTitle: 'Do you also use the CLZ Mobile app?',
    extraNoteContent:
        'First we\'re going to make sure you are \'in sync\' and have a fresh copy of data in your Cloud. Here\'s what to do:',
    extraNoteBullets: [
      'Tap the menu top left and tap Maintenance, then use Clear Database,',
      'Then choose Sync with CLZ Cloud to download a fresh copy of your data from the CLZ Cloud.',
    ],
  ),
];

final musicKindImport = LibraryKindImportCapability(
  sources: musicImportSources,
  otherSources: musicOtherImportSources,
  mappableFields: musicMappableFields,
);
