import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/formats/clz_csv_values.dart';
import 'package:collectarr_app/features/imports/formats/clz_import_row.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import '../../domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_story_arc.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_creator.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_character.dart';
import '../../domain/comic_personal_data.dart';
import '../../domain/comic_reading_state.dart';
import '../../entries/comic_entry_details.dart';

final class ComicMappedCsvImporter implements LibraryMappedCsvImporter {
  const ComicMappedCsvImporter();

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
        identityFieldKeys: const {'title', 'series'});
    final ids = ClzImportIdentities(CatalogMediaKind.comic);
    return List.unmodifiable([
      for (final record in records) _row(record, multiValueDelimiter, ids),
    ]);
  }

  CollectionImportRow _row(
      ClzCsvRecord row, String delimiter, ClzImportIdentities ids) {
    final series = row.text('series');
    final title = row.text('title') ?? '';
    // The review row reads like the reference list: "Series #2A", then the
    // issue title when there is one.
    final issue = '${row.text('issue') ?? ''}${row.text('variant') ?? ''}';
    final headline = [
      if (series != null) series,
      if (issue.isNotEmpty) '#$issue',
    ].join(' ');
    final id = ids.next(
        'csv/$series/${row.text('issue')}/${row.text('variant')}/${row.text('barcode')}');
    final coverDate = row.date('cover_date', 'Cover Date');
    final releaseDate = row.date('release_date', 'Release Date');
    final metadata = ComicCatalogItem(
      title: title,
      seriesTitle: series,
      subtitle: row.text('subtitle'),
      issueNumber: row.text('issue'),
      variant: row.text('variant'),
      variantDescription: row.text('variant_description'),
      barcode: row.text('barcode'),
      publisher: row.text('publisher'),
      imprint: row.text('imprint'),
      seriesGroup: row.text('series_group'),
      physicalFormat: row.text('format'),
      publicationAge: row.text('age'),
      ageRating: row.text('age_rating'),
      country: row.text('country') ?? '',
      language: row.text('language') ?? '',
      pageCount: row.integer('pages', 'No. of Pages'),
      genres: row.list('genre', delimiter),
      coverDateParts: coverDate,
      coverDate: coverDate?.asDateTime,
      releaseDateParts: releaseDate,
      releaseDate: releaseDate?.asDateTime,
      crossover: row.text('crossover'),
      storyArcs: [
        for (final name in row.list('story_arc', delimiter))
          ComicStoryArc(name: name)
      ],
      description: row.text('plot'),
      creators: [
        for (final (key, role) in const [
          ('writer', 'Writer'),
          ('artist', 'Artist'),
          ('cover_artist', 'Cover Artist'),
          ('colorist', 'Colorist'),
          ('letterer', 'Letterer')
        ])
          for (final name in row.list(key, delimiter))
            ComicCreator.fromValue({'name': name, 'role': role}),
      ],
      characters: [
        for (final name in row.list('characters', delimiter))
          ComicCharacter.fromValue(name)
      ],
    );
    final severity = _key(row.text('key'));
    final read = row.boolean('read', 'Read');
    final personal = ComicPersonalData(
      quantity: row.integer('quantity', 'Quantity', min: 1) ?? 1,
      ownerLabel: row.text('owner'),
      personalNotes: row.text('notes'),
      tags: row.list('tags', delimiter),
      condition: row.text('condition'),
      grade: row.text('grade'),
      indexNumber: row.integer('index', 'Index'),
      collectionStatus: row.collectionStatus,
      currency: row.text('currency'),
      pricePaidCents: row.money('purchase_price', 'Purchase Price'),
      purchaseDate: row.date('purchase_date', 'Purchase Date')?.asDateTime,
      purchaseStore: row.text('purchase_store'),
      marketValueCents: row.money('value', 'My Value'),
      sellPriceCents: row.money('price_sold', 'Price Sold'),
      soldAt: row.date('sold_date', 'Sold Date')?.asDateTime,
      details: ComicEntryDetails(
        rawOrSlabbed: row.text('raw_or_slabbed'),
        gradingCompany: row.text('grading_company'),
        certificationNumber: row.text('certification_number'),
        graderNotes: row.text('grader_notes'),
        signedBy: row.text('signed_by'),
        labelType: row.text('label_type'),
        customLabel: row.text('custom_label'),
        pageQuality: row.text('page_quality'),
        keyComic: severity != null,
        keySeverity: severity,
        keyReason: row.text('key_reason'),
        keyCategory: row.text('key_category'),
        coverPriceCents: row.money('cover_price', 'Cover Price'),
        lastBagBoardDate:
            row.date('bag_board_date', 'Bag/Board Date')?.asDateTime,
      ),
      reading: ComicReadingState(
        status: read == null
            ? null
            : read
                ? 'Read'
                : 'Unread',
        finishedAt: row.date('read_date', 'Read Date')?.asDateTime,
        rating: row.integer('my_rating', 'My Rating', max: 10),
      ),
    );
    return clzImportRow(
        kind: CatalogMediaKind.comic,
        id: id,
        title: series == null ? title : headline,
        subtitle: series == null || title.isEmpty ? null : title,
        barcode: metadata.barcode,
        catalog: metadata,
        personal: personal,
        createdAt: row.instant('added_date', 'Added Date'),
        updatedAt: row.instant('modified_date', 'Modified Date'),
        customFieldValues: row.customFields,
        loan: row.loan);
  }
}

String? _key(String? value) => switch (value?.trim().toLowerCase()) {
      null || '' || 'no' || 'false' || '0' => null,
      'major' => 'Major',
      'minor' => 'Minor',
      'trivia' => 'Trivia',
      _ => throw LibraryImportFormatException(
          'Invalid Key "$value". Use Major, Minor, Trivia or No.'),
    };
