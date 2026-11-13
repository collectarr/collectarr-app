import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/formats/clz_csv_values.dart';
import 'package:collectarr_app/features/imports/formats/clz_import_row.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import '../../domain/book_metadata.dart';
import '../../domain/book_personal_data.dart';
import '../../entries/book_entry_details.dart';

final class BookMappedCsvImporter implements LibraryMappedCsvImporter {
  const BookMappedCsvImporter();

  @override
  List<CollectionImportRow> parse(
    List<List<String>> rows, {
    required Map<int, String> mappings,
    required String multiValueDelimiter,
    List<String> headers = const [],
  }) {
    final records = readClzCsvRecords(rows,
        mappings: mappings,
        headers: headers,
        identityFieldKeys: const {'title'});
    final ids = ClzImportIdentities(CatalogMediaKind.book);
    return List.unmodifiable(
        [for (final row in records) _row(row, multiValueDelimiter, ids)]);
  }

  CollectionImportRow _row(
      ClzCsvRecord row, String delimiter, ClzImportIdentities ids) {
    final title = row.text('title');
    if (title == null) {
      throw LibraryImportFormatException(
          'Record ${row.number} is missing a Title.');
    }
    final isbn = row.text('isbn');
    final date = row.date('publication_date', 'Publication Date');
    final metadata = BookCatalogMetadata(
      title: title,
      subtitle: row.text('subtitle'),
      sortTitle: row.text('sort_title'),
      seriesTitle: row.text('series'),
      itemNumber: row.text('series_number'),
      isbn: isbn,
      barcode: row.text('barcode'),
      publisher: row.text('publisher'),
      imprint: row.text('imprint'),
      physicalFormat: row.text('format'),
      pageCount: row.integer('pages', 'Pages'),
      country: row.text('country'),
      language: row.text('language'),
      publicationPlace: row.text('publication_place'),
      releaseDateParts: date,
      releaseDate: date?.asDateTime,
      genres: row.list('genre', delimiter),
      subjects: row.list('subject', delimiter),
      description: row.text('plot'),
      creators: [
        for (final (key, role) in const [
          ('author', 'Author'),
          ('translator', 'Translator'),
          ('editor', 'Editor'),
          ('illustrator', 'Illustrator'),
          ('cover_artist', 'Cover Artist')
        ])
          for (final name in row.list(key, delimiter))
            BookCatalogCredit(name: name, role: role)
      ],
    );
    final personal = BookPersonalData(
      condition: row.text('condition'),
      grade: row.text('grade'),
      indexNumber: row.integer('index', 'Index'),
      ownerLabel: row.text('owner'),
      personalNotes: row.text('notes'),
      tags: row.list('tags', delimiter),
      collectionStatus: row.collectionStatus,
      currency: row.text('currency'),
      pricePaidCents: row.money('purchase_price', 'Purchase Price'),
      purchaseDate: row.date('purchase_date', 'Purchase Date')?.asDateTime,
      purchaseStore: row.text('purchase_store'),
      marketValueCents: row.money('value', 'My Value'),
      sellPriceCents: row.money('price_sold', 'Price Sold'),
      soldAt: row.date('sold_date', 'Sold Date')?.asDateTime,
      details: BookEntryDetails(signedBy: [
        for (final name in (row.text('signed_by') ?? '').split(RegExp(r'[;,]')))
          if (name.trim().isNotEmpty) name.trim(),
      ], retailPriceCents: row.money('retail_price', 'Retail Price')),
    );
    return clzImportRow(
        kind: CatalogMediaKind.book,
        id: ids.next('csv/$title/$isbn/${row.text('author')}'),
        title: title,
        barcode: isbn ?? metadata.barcode,
        catalog: metadata,
        personal: personal,
        createdAt: row.instant('added_date', 'Added Date'),
        updatedAt: row.instant('modified_date', 'Modified Date'),
        customFieldValues: row.customFields,
        loan: row.loan);
  }
}
