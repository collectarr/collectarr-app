import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_import_capability.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_import_sources.dart';
import 'package:flutter/material.dart';

LibraryKindImportCapability _buildGenericKindImport(
  CatalogMediaKind kind, {
  List<LibraryImportSourceDefinition> additionalSources = const [],
}) {
  return LibraryKindImportCapability(
    sources: [
      const LibraryImportSourceDefinition(
        id: 'text',
        title: 'Import a Text or CSV file',
        assetLogoPath: 'assets/import_logos/text.svg',
        fallbackIcon: Icons.description_outlined,
        isSvg: true,
        sourceType: LibraryImportSourceType.csvTxt,
        fileExtensions: ['csv', 'txt'],
      ),
      ...additionalSources,
    ],
    mappableFields: const [
      KindMappableField(key: 'title', label: 'Title', aliases: ['Title', 'Name'], isDefault: true),
      KindMappableField(key: 'creator', label: 'Creator / Author', aliases: ['Creator', 'Author', 'Artist']),
      KindMappableField(key: 'year', label: 'Release Year', aliases: ['Year', 'Date']),
      KindMappableField(key: 'barcode', label: 'Barcode', aliases: ['Barcode', 'UPC', 'ISBN', 'EAN']),
      KindMappableField(key: 'notes', label: 'Notes', aliases: ['Notes', 'Comments']),
    ],
  );
}

final Map<CatalogMediaKind, LibraryKindImportCapability> collectarrKindImports =
    Map.unmodifiable(<CatalogMediaKind, LibraryKindImportCapability>{
  CatalogMediaKind.music: musicKindImport,
  CatalogMediaKind.comic: _buildGenericKindImport(
    CatalogMediaKind.comic,
    additionalSources: const [
      LibraryImportSourceDefinition(
        id: 'comicrack',
        title: 'ComicRack',
        fallbackIcon: Icons.menu_book,
        sourceType: LibraryImportSourceType.guidedFile,
        fileExtensions: ['xml', 'crb'],
        description: 'To import your list of comics from ComicRack, export an XML/CRB file from ComicRack.',
        instructions: [
          'Start ComicRack on your computer.',
          'Select your collection and click File > Export.',
          'Choose XML format and save the file.',
          'Upload the file below:',
        ],
        filePrompt: 'Upload your ComicRack XML file:',
      ),
      LibraryImportSourceDefinition(
        id: 'clzcomicweb',
        title: 'CLZ Comics Web',
        assetLogoPath: 'assets/import_logos/clz-music-icon.svg',
        fallbackIcon: Icons.cloud_download_outlined,
        isSvg: true,
        sourceType: LibraryImportSourceType.guidedFile,
        fileExtensions: ['xml'],
        description: 'To import your list of comics from CLZ Comics Web, export an XML file of your comics out of CLZ Comics Web.',
        instructions: [
          'Login to CLZ Comics Web.',
          'Click the menu on the left and navigate to "Export to XML".',
          'Download the XML file.',
          'Upload the XML file below:',
        ],
        filePrompt: 'Upload your CLZ Comics Web XML file:',
      ),
    ],
  ),
  CatalogMediaKind.book: _buildGenericKindImport(
    CatalogMediaKind.book,
    additionalSources: const [
      LibraryImportSourceDefinition(
        id: 'goodreads',
        title: 'Goodreads',
        fallbackIcon: Icons.auto_stories,
        sourceType: LibraryImportSourceType.guidedFile,
        fileExtensions: ['csv'],
        description: 'To import your library from Goodreads, export your library to CSV from Goodreads account settings.',
        instructions: [
          'Log in to Goodreads and go to My Books.',
          'Click "Import and export" on the left sidebar.',
          'Click "Export Library" and download the CSV.',
          'Upload the CSV file below:',
        ],
        filePrompt: 'Upload your Goodreads CSV file:',
      ),
      LibraryImportSourceDefinition(
        id: 'calibre',
        title: 'Calibre',
        fallbackIcon: Icons.import_contacts,
        sourceType: LibraryImportSourceType.guidedFile,
        fileExtensions: ['csv', 'xml'],
        description: 'To import your books from Calibre, export your catalog to CSV or XML.',
        instructions: [
          'Start Calibre on your computer.',
          'Click Convert books > Create a catalog of books in your Calibre library.',
          'Select CSV or XML and save the file.',
          'Upload the file below:',
        ],
        filePrompt: 'Upload your Calibre file:',
      ),
    ],
  ),
  CatalogMediaKind.movie: _buildGenericKindImport(
    CatalogMediaKind.movie,
    additionalSources: const [
      LibraryImportSourceDefinition(
        id: 'dvdprofiler',
        title: 'DVD Profiler',
        fallbackIcon: Icons.movie_outlined,
        sourceType: LibraryImportSourceType.guidedFile,
        fileExtensions: ['xml'],
        description: 'To import your movies from DVD Profiler, export an XML file from DVD Profiler.',
        instructions: [
          'Start DVD Profiler on your computer.',
          'Click File > Export > XML.',
          'Save the XML file on your computer.',
          'Upload the file below:',
        ],
        filePrompt: 'Upload your DVD Profiler XML file:',
      ),
    ],
  ),
  CatalogMediaKind.game: _buildGenericKindImport(CatalogMediaKind.game),
  CatalogMediaKind.anime: _buildGenericKindImport(CatalogMediaKind.anime),
  CatalogMediaKind.manga: _buildGenericKindImport(CatalogMediaKind.manga),
  CatalogMediaKind.tv: _buildGenericKindImport(CatalogMediaKind.tv),
  CatalogMediaKind.boardgame: _buildGenericKindImport(CatalogMediaKind.boardgame),
});
