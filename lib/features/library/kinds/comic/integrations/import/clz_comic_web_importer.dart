import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'package:collectarr_app/features/imports/formats/clz_web_xml.dart';
import 'package:collectarr_app/features/imports/formats/clz_import_row.dart';
import '../../domain/comic_catalog_item.dart';
import '../../domain/comic_character.dart';
import '../../domain/comic_creator.dart';
import '../../domain/comic_personal_data.dart';
import '../../domain/comic_reading_state.dart';
import '../../domain/comic_story_arc.dart';
import '../../entries/comic_entry_details.dart';
import 'comic_import_values.dart';
import 'package:xml/xml.dart';

final class ClzComicWebImporter implements LibraryGuidedImporter {
  const ClzComicWebImporter();
  @override
  List<CollectionImportRow> parse(String source) {
    final records = readClzWebRecords(source,
        section: 'comicinfo', list: 'comiclist', record: 'comic');
    final ids = ClzImportIdentities(CatalogMediaKind.comic);
    return List.unmodifiable([for (final raw in records) _parse(raw, ids)]);
  }

  CollectionImportRow _parse(ClzXmlRecord raw, ClzImportIdentities ids) {
    final series = raw.text('mainsection/series');
    final title = raw.text('mainsection/title') ?? '';
    final issue = raw.text('issuenr');
    final variant = raw.text('issueext');
    final externalId = raw.text('hash') ?? '$series/$issue$variant';
    final id = ids.next('${raw.text('collection/hash') ?? ''}/$externalId');
    final coverDate = raw.date('coverdate');
    final releaseDate = raw.date('releasedate');
    final metadata = ComicCatalogItem(
      title: title,
      seriesTitle: series,
      subtitle: raw.text('mainsection/subtitle'),
      issueNumber: issue,
      variant: variant,
      variantDescription: raw.text('edition'),
      barcode: raw.text('barcode'),
      publisher: raw.text('publisher'),
      imprint: raw.text('imprint'),
      seriesGroup: raw.text('seriesgroup'),
      physicalFormat: raw.text('format'),
      publicationAge: raw.text('age'),
      country: raw.text('country') ?? '',
      language: raw.text('language') ?? '',
      pageCount: raw.integer('mainsection/pagecount'),
      genres: raw.values('genres', 'genre'),
      coverDateParts: coverDate,
      coverDate: coverDate?.asDateTime,
      releaseDateParts: releaseDate,
      releaseDate: releaseDate?.asDateTime,
      crossover: raw.text('crossover'),
      storyArcs: [
        if (raw.text('storyarc') case final name?) ComicStoryArc(name: name)
      ],
      description: raw.text('mainsection/plot'),
      coverImageUrl: raw.text('coverfrontdefault'),
      // The export lists credits and characters only when the user edited
      // them; otherwise the reference shows its own Core data.
      creators: [
        for (final credit in raw.node('credits')?.findElements('credit') ??
            const <XmlElement>[])
          if (ClzXmlRecord(credit) case final value
              when value.text('person') != null)
            ComicCreator(
                name: value.text('person'),
                sortName: value.text('person/sortname'),
                role: _role(value.text('roleid') ?? value.text('role')),
                sequence: value.integer('sequence')),
      ],
      characters: [
        for (final character
            in raw.node('characters')?.findElements('character') ??
                const <XmlElement>[])
          if (ClzXmlRecord(character).text('name') case final name?)
            ComicCharacter(name: name),
      ],
    );
    final severity = comicKeySeverity(raw.text('iskeycomic'));
    final read = raw.boolean('readit');
    final purchase = raw.date('purchasedate');
    final keyCategories = raw.values('keycategories', 'keycategory');
    final signees = raw.values('signees', 'signee');
    final personal = ComicPersonalData(
      quantity: raw.integer('quantity', min: 1) ?? 1,
      ownerLabel: raw.text('owner'),
      personalNotes: raw.text('mainsection/notes'),
      tags: raw.values('tags', 'tag'),
      // An ungraded copy carries only an id and a 0.0 rating.
      grade: raw.text('grade/displayname'),
      indexNumber: raw.integer('index'),
      collectionStatus: raw.collectionStatus,
      pricePaidCents: raw.money('purchaseprice'),
      purchaseDate: purchase?.asDateTime,
      purchaseStore: raw.text('store'),
      // The reference writes 0 for a value nobody entered.
      marketValueCents: _nonZero(raw.money('currentprice')),
      sellPriceCents: _nonZero(raw.money('soldprice')),
      soldAt: raw.date('solddate')?.asDateTime,
      details: ComicEntryDetails(
        rawOrSlabbed: raw.text('isslabbed'),
        gradingCompany: raw.text('gradingcompany'),
        certificationNumber: raw.text('slabcertnumber'),
        signedBy: signees.isEmpty ? null : signees.join(', '),
        labelType: raw.text('slablabel'),
        customLabel: raw.text('customlabel'),
        pageQuality: raw.text('pagequality'),
        keyComic: severity != null,
        keySeverity: severity,
        keyReason: raw.text('keycomicreason'),
        keyCategory: keyCategories.isEmpty ? null : keyCategories.join(', '),
        coverPriceCents: _nonZero(raw.money('coverprice')),
        lastBagBoardDate: raw.date('baggeddate')?.asDateTime,
      ),
      reading: ComicReadingState(
        status: read == null
            ? null
            : read
                ? 'Read'
                : 'Unread',
        finishedAt: raw.date('readingdate')?.asDateTime,
        rating: _nonZero(raw.integer('mainsection/myrating', max: 10)),
      ),
    );
    return clzImportRow(
        kind: CatalogMediaKind.comic,
        id: id,
        title: series == null
            ? title
            : comicImportHeadline(series, issue, variant),
        barcode: metadata.barcode,
        catalog: metadata,
        personal: personal,
        createdAt: raw.instant('addeddate'),
        updatedAt: raw.instant('modifieddate'));
  }
}

int? _nonZero(int? value) => value == 0 ? null : value;

/// The reference role ids name the role in camel case after a "df" prefix:
/// dfCoverArtist is Cover Artist, dfEditorInChief is Editor in Chief.
String? _role(String? id) {
  if (id == null) return null;
  final words = id
      .replaceFirst(RegExp('^df'), '')
      .replaceAllMapped(RegExp('(?<=[a-z])(?=[A-Z])'), (_) => ' ')
      .split(' ');
  return [
    for (var i = 0; i < words.length; i++)
      i > 0 && words[i] == 'In' ? 'in' : words[i]
  ].join(' ');
}
