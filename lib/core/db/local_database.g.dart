// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $CatalogCacheTable extends CatalogCache
    with TableInfo<$CatalogCacheTable, CatalogCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortKeyMeta =
      const VerificationMeta('sortKey');
  @override
  late final GeneratedColumn<String> sortKey = GeneratedColumn<String>(
      'sort_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _itemNumberMeta =
      const VerificationMeta('itemNumber');
  @override
  late final GeneratedColumn<String> itemNumber = GeneratedColumn<String>(
      'item_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _synopsisMeta =
      const VerificationMeta('synopsis');
  @override
  late final GeneratedColumn<String> synopsis = GeneratedColumn<String>(
      'synopsis', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverImageUrlMeta =
      const VerificationMeta('coverImageUrl');
  @override
  late final GeneratedColumn<String> coverImageUrl = GeneratedColumn<String>(
      'cover_image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailImageUrlMeta =
      const VerificationMeta('thumbnailImageUrl');
  @override
  late final GeneratedColumn<String> thumbnailImageUrl =
      GeneratedColumn<String>('thumbnail_image_url', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _editionTitleMeta =
      const VerificationMeta('editionTitle');
  @override
  late final GeneratedColumn<String> editionTitle = GeneratedColumn<String>(
      'edition_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _physicalFormatMeta =
      const VerificationMeta('physicalFormat');
  @override
  late final GeneratedColumn<String> physicalFormat = GeneratedColumn<String>(
      'physical_format', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _physicalFormatLabelMeta =
      const VerificationMeta('physicalFormatLabel');
  @override
  late final GeneratedColumn<String> physicalFormatLabel =
      GeneratedColumn<String>('physical_format_label', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _publisherMeta =
      const VerificationMeta('publisher');
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
      'publisher', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _releaseDateMeta =
      const VerificationMeta('releaseDate');
  @override
  late final GeneratedColumn<DateTime> releaseDate = GeneratedColumn<DateTime>(
      'release_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _releaseYearMeta =
      const VerificationMeta('releaseYear');
  @override
  late final GeneratedColumn<int> releaseYear = GeneratedColumn<int>(
      'release_year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variantMeta =
      const VerificationMeta('variant');
  @override
  late final GeneratedColumn<String> variant = GeneratedColumn<String>(
      'variant', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _seriesIdMeta =
      const VerificationMeta('seriesId');
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
      'series_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _seriesTitleMeta =
      const VerificationMeta('seriesTitle');
  @override
  late final GeneratedColumn<String> seriesTitle = GeneratedColumn<String>(
      'series_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _volumeNameMeta =
      const VerificationMeta('volumeName');
  @override
  late final GeneratedColumn<String> volumeName = GeneratedColumn<String>(
      'volume_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _volumeNumberMeta =
      const VerificationMeta('volumeNumber');
  @override
  late final GeneratedColumn<int> volumeNumber = GeneratedColumn<int>(
      'volume_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _volumeStartYearMeta =
      const VerificationMeta('volumeStartYear');
  @override
  late final GeneratedColumn<int> volumeStartYear = GeneratedColumn<int>(
      'volume_start_year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _seasonNumberMeta =
      const VerificationMeta('seasonNumber');
  @override
  late final GeneratedColumn<int> seasonNumber = GeneratedColumn<int>(
      'season_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _episodeNumberMeta =
      const VerificationMeta('episodeNumber');
  @override
  late final GeneratedColumn<int> episodeNumber = GeneratedColumn<int>(
      'episode_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _runtimeMinutesMeta =
      const VerificationMeta('runtimeMinutes');
  @override
  late final GeneratedColumn<int> runtimeMinutes = GeneratedColumn<int>(
      'runtime_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _trackCountMeta =
      const VerificationMeta('trackCount');
  @override
  late final GeneratedColumn<int> trackCount = GeneratedColumn<int>(
      'track_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _tracksJsonMeta =
      const VerificationMeta('tracksJson');
  @override
  late final GeneratedColumn<String> tracksJson = GeneratedColumn<String>(
      'tracks_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _editionsJsonMeta =
      const VerificationMeta('editionsJson');
  @override
  late final GeneratedColumn<String> editionsJson = GeneratedColumn<String>(
      'editions_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _creatorsJsonMeta =
      const VerificationMeta('creatorsJson');
  @override
  late final GeneratedColumn<String> creatorsJson = GeneratedColumn<String>(
      'creators_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _charactersJsonMeta =
      const VerificationMeta('charactersJson');
  @override
  late final GeneratedColumn<String> charactersJson = GeneratedColumn<String>(
      'characters_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _storyArcsJsonMeta =
      const VerificationMeta('storyArcsJson');
  @override
  late final GeneratedColumn<String> storyArcsJson = GeneratedColumn<String>(
      'story_arcs_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _seriesTagsJsonMeta =
      const VerificationMeta('seriesTagsJson');
  @override
  late final GeneratedColumn<String> seriesTagsJson = GeneratedColumn<String>(
      'series_tags_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _platformsJsonMeta =
      const VerificationMeta('platformsJson');
  @override
  late final GeneratedColumn<String> platformsJson = GeneratedColumn<String>(
      'platforms_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _genresJsonMeta =
      const VerificationMeta('genresJson');
  @override
  late final GeneratedColumn<String> genresJson = GeneratedColumn<String>(
      'genres_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pageCountMeta =
      const VerificationMeta('pageCount');
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
      'page_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _coverPriceCentsMeta =
      const VerificationMeta('coverPriceCents');
  @override
  late final GeneratedColumn<int> coverPriceCents = GeneratedColumn<int>(
      'cover_price_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _catalogCurrencyMeta =
      const VerificationMeta('catalogCurrency');
  @override
  late final GeneratedColumn<String> catalogCurrency = GeneratedColumn<String>(
      'catalog_currency', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _catalogNumberMeta =
      const VerificationMeta('catalogNumber');
  @override
  late final GeneratedColumn<String> catalogNumber = GeneratedColumn<String>(
      'catalog_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _countryMeta =
      const VerificationMeta('country');
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
      'country', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _releaseStatusMeta =
      const VerificationMeta('releaseStatus');
  @override
  late final GeneratedColumn<String> releaseStatus = GeneratedColumn<String>(
      'release_status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ageRatingMeta =
      const VerificationMeta('ageRating');
  @override
  late final GeneratedColumn<String> ageRating = GeneratedColumn<String>(
      'age_rating', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imprintMeta =
      const VerificationMeta('imprint');
  @override
  late final GeneratedColumn<String> imprint = GeneratedColumn<String>(
      'imprint', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subtitleMeta =
      const VerificationMeta('subtitle');
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
      'subtitle', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _seriesGroupMeta =
      const VerificationMeta('seriesGroup');
  @override
  late final GeneratedColumn<String> seriesGroup = GeneratedColumn<String>(
      'series_group', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        kind,
        title,
        sortKey,
        itemNumber,
        synopsis,
        coverImageUrl,
        thumbnailImageUrl,
        editionTitle,
        physicalFormat,
        physicalFormatLabel,
        publisher,
        releaseDate,
        releaseYear,
        barcode,
        variant,
        seriesId,
        seriesTitle,
        volumeName,
        volumeNumber,
        volumeStartYear,
        seasonNumber,
        episodeNumber,
        runtimeMinutes,
        trackCount,
        tracksJson,
        editionsJson,
        creatorsJson,
        charactersJson,
        storyArcsJson,
        seriesTagsJson,
        platformsJson,
        genresJson,
        pageCount,
        coverPriceCents,
        catalogCurrency,
        catalogNumber,
        country,
        releaseStatus,
        language,
        ageRating,
        imprint,
        subtitle,
        seriesGroup,
        cachedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_cache';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('sort_key')) {
      context.handle(_sortKeyMeta,
          sortKey.isAcceptableOrUnknown(data['sort_key']!, _sortKeyMeta));
    }
    if (data.containsKey('item_number')) {
      context.handle(
          _itemNumberMeta,
          itemNumber.isAcceptableOrUnknown(
              data['item_number']!, _itemNumberMeta));
    }
    if (data.containsKey('synopsis')) {
      context.handle(_synopsisMeta,
          synopsis.isAcceptableOrUnknown(data['synopsis']!, _synopsisMeta));
    }
    if (data.containsKey('cover_image_url')) {
      context.handle(
          _coverImageUrlMeta,
          coverImageUrl.isAcceptableOrUnknown(
              data['cover_image_url']!, _coverImageUrlMeta));
    }
    if (data.containsKey('thumbnail_image_url')) {
      context.handle(
          _thumbnailImageUrlMeta,
          thumbnailImageUrl.isAcceptableOrUnknown(
              data['thumbnail_image_url']!, _thumbnailImageUrlMeta));
    }
    if (data.containsKey('edition_title')) {
      context.handle(
          _editionTitleMeta,
          editionTitle.isAcceptableOrUnknown(
              data['edition_title']!, _editionTitleMeta));
    }
    if (data.containsKey('physical_format')) {
      context.handle(
          _physicalFormatMeta,
          physicalFormat.isAcceptableOrUnknown(
              data['physical_format']!, _physicalFormatMeta));
    }
    if (data.containsKey('physical_format_label')) {
      context.handle(
          _physicalFormatLabelMeta,
          physicalFormatLabel.isAcceptableOrUnknown(
              data['physical_format_label']!, _physicalFormatLabelMeta));
    }
    if (data.containsKey('publisher')) {
      context.handle(_publisherMeta,
          publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta));
    }
    if (data.containsKey('release_date')) {
      context.handle(
          _releaseDateMeta,
          releaseDate.isAcceptableOrUnknown(
              data['release_date']!, _releaseDateMeta));
    }
    if (data.containsKey('release_year')) {
      context.handle(
          _releaseYearMeta,
          releaseYear.isAcceptableOrUnknown(
              data['release_year']!, _releaseYearMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    if (data.containsKey('variant')) {
      context.handle(_variantMeta,
          variant.isAcceptableOrUnknown(data['variant']!, _variantMeta));
    }
    if (data.containsKey('series_id')) {
      context.handle(_seriesIdMeta,
          seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta));
    }
    if (data.containsKey('series_title')) {
      context.handle(
          _seriesTitleMeta,
          seriesTitle.isAcceptableOrUnknown(
              data['series_title']!, _seriesTitleMeta));
    }
    if (data.containsKey('volume_name')) {
      context.handle(
          _volumeNameMeta,
          volumeName.isAcceptableOrUnknown(
              data['volume_name']!, _volumeNameMeta));
    }
    if (data.containsKey('volume_number')) {
      context.handle(
          _volumeNumberMeta,
          volumeNumber.isAcceptableOrUnknown(
              data['volume_number']!, _volumeNumberMeta));
    }
    if (data.containsKey('volume_start_year')) {
      context.handle(
          _volumeStartYearMeta,
          volumeStartYear.isAcceptableOrUnknown(
              data['volume_start_year']!, _volumeStartYearMeta));
    }
    if (data.containsKey('season_number')) {
      context.handle(
          _seasonNumberMeta,
          seasonNumber.isAcceptableOrUnknown(
              data['season_number']!, _seasonNumberMeta));
    }
    if (data.containsKey('episode_number')) {
      context.handle(
          _episodeNumberMeta,
          episodeNumber.isAcceptableOrUnknown(
              data['episode_number']!, _episodeNumberMeta));
    }
    if (data.containsKey('runtime_minutes')) {
      context.handle(
          _runtimeMinutesMeta,
          runtimeMinutes.isAcceptableOrUnknown(
              data['runtime_minutes']!, _runtimeMinutesMeta));
    }
    if (data.containsKey('track_count')) {
      context.handle(
          _trackCountMeta,
          trackCount.isAcceptableOrUnknown(
              data['track_count']!, _trackCountMeta));
    }
    if (data.containsKey('tracks_json')) {
      context.handle(
          _tracksJsonMeta,
          tracksJson.isAcceptableOrUnknown(
              data['tracks_json']!, _tracksJsonMeta));
    }
    if (data.containsKey('editions_json')) {
      context.handle(
          _editionsJsonMeta,
          editionsJson.isAcceptableOrUnknown(
              data['editions_json']!, _editionsJsonMeta));
    }
    if (data.containsKey('creators_json')) {
      context.handle(
          _creatorsJsonMeta,
          creatorsJson.isAcceptableOrUnknown(
              data['creators_json']!, _creatorsJsonMeta));
    }
    if (data.containsKey('characters_json')) {
      context.handle(
          _charactersJsonMeta,
          charactersJson.isAcceptableOrUnknown(
              data['characters_json']!, _charactersJsonMeta));
    }
    if (data.containsKey('story_arcs_json')) {
      context.handle(
          _storyArcsJsonMeta,
          storyArcsJson.isAcceptableOrUnknown(
              data['story_arcs_json']!, _storyArcsJsonMeta));
    }
    if (data.containsKey('series_tags_json')) {
      context.handle(
          _seriesTagsJsonMeta,
          seriesTagsJson.isAcceptableOrUnknown(
              data['series_tags_json']!, _seriesTagsJsonMeta));
    }
    if (data.containsKey('platforms_json')) {
      context.handle(
          _platformsJsonMeta,
          platformsJson.isAcceptableOrUnknown(
              data['platforms_json']!, _platformsJsonMeta));
    }
    if (data.containsKey('genres_json')) {
      context.handle(
          _genresJsonMeta,
          genresJson.isAcceptableOrUnknown(
              data['genres_json']!, _genresJsonMeta));
    }
    if (data.containsKey('page_count')) {
      context.handle(_pageCountMeta,
          pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta));
    }
    if (data.containsKey('cover_price_cents')) {
      context.handle(
          _coverPriceCentsMeta,
          coverPriceCents.isAcceptableOrUnknown(
              data['cover_price_cents']!, _coverPriceCentsMeta));
    }
    if (data.containsKey('catalog_currency')) {
      context.handle(
          _catalogCurrencyMeta,
          catalogCurrency.isAcceptableOrUnknown(
              data['catalog_currency']!, _catalogCurrencyMeta));
    }
    if (data.containsKey('catalog_number')) {
      context.handle(
          _catalogNumberMeta,
          catalogNumber.isAcceptableOrUnknown(
              data['catalog_number']!, _catalogNumberMeta));
    }
    if (data.containsKey('country')) {
      context.handle(_countryMeta,
          country.isAcceptableOrUnknown(data['country']!, _countryMeta));
    }
    if (data.containsKey('release_status')) {
      context.handle(
          _releaseStatusMeta,
          releaseStatus.isAcceptableOrUnknown(
              data['release_status']!, _releaseStatusMeta));
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('age_rating')) {
      context.handle(_ageRatingMeta,
          ageRating.isAcceptableOrUnknown(data['age_rating']!, _ageRatingMeta));
    }
    if (data.containsKey('imprint')) {
      context.handle(_imprintMeta,
          imprint.isAcceptableOrUnknown(data['imprint']!, _imprintMeta));
    }
    if (data.containsKey('subtitle')) {
      context.handle(_subtitleMeta,
          subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta));
    }
    if (data.containsKey('series_group')) {
      context.handle(
          _seriesGroupMeta,
          seriesGroup.isAcceptableOrUnknown(
              data['series_group']!, _seriesGroupMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      sortKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sort_key']),
      itemNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_number']),
      synopsis: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}synopsis']),
      coverImageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_image_url']),
      thumbnailImageUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}thumbnail_image_url']),
      editionTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edition_title']),
      physicalFormat: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}physical_format']),
      physicalFormatLabel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}physical_format_label']),
      publisher: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}publisher']),
      releaseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}release_date']),
      releaseYear: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}release_year']),
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode']),
      variant: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant']),
      seriesId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}series_id']),
      seriesTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}series_title']),
      volumeName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}volume_name']),
      volumeNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}volume_number']),
      volumeStartYear: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}volume_start_year']),
      seasonNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}season_number']),
      episodeNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}episode_number']),
      runtimeMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}runtime_minutes']),
      trackCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}track_count']),
      tracksJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tracks_json']),
      editionsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}editions_json']),
      creatorsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}creators_json']),
      charactersJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}characters_json']),
      storyArcsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}story_arcs_json']),
      seriesTagsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}series_tags_json']),
      platformsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}platforms_json']),
      genresJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}genres_json']),
      pageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_count']),
      coverPriceCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cover_price_cents']),
      catalogCurrency: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}catalog_currency']),
      catalogNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}catalog_number']),
      country: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}country']),
      releaseStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}release_status']),
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language']),
      ageRating: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}age_rating']),
      imprint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}imprint']),
      subtitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subtitle']),
      seriesGroup: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}series_group']),
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CatalogCacheTable createAlias(String alias) {
    return $CatalogCacheTable(attachedDatabase, alias);
  }
}

class CatalogCacheData extends DataClass
    implements Insertable<CatalogCacheData> {
  final String id;
  final String kind;
  final String title;
  final String? sortKey;
  final String? itemNumber;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? editionTitle;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? publisher;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? barcode;
  final String? variant;
  final String? seriesId;
  final String? seriesTitle;
  final String? volumeName;
  final int? volumeNumber;
  final int? volumeStartYear;
  final int? seasonNumber;
  final int? episodeNumber;
  final int? runtimeMinutes;
  final int? trackCount;
  final String? tracksJson;
  final String? editionsJson;
  final String? creatorsJson;
  final String? charactersJson;
  final String? storyArcsJson;
  final String? seriesTagsJson;
  final String? platformsJson;
  final String? genresJson;
  final int? pageCount;
  final int? coverPriceCents;
  final String? catalogCurrency;
  final String? catalogNumber;
  final String? country;
  final String? releaseStatus;
  final String? language;
  final String? ageRating;
  final String? imprint;
  final String? subtitle;
  final String? seriesGroup;
  final DateTime cachedAt;
  const CatalogCacheData(
      {required this.id,
      required this.kind,
      required this.title,
      this.sortKey,
      this.itemNumber,
      this.synopsis,
      this.coverImageUrl,
      this.thumbnailImageUrl,
      this.editionTitle,
      this.physicalFormat,
      this.physicalFormatLabel,
      this.publisher,
      this.releaseDate,
      this.releaseYear,
      this.barcode,
      this.variant,
      this.seriesId,
      this.seriesTitle,
      this.volumeName,
      this.volumeNumber,
      this.volumeStartYear,
      this.seasonNumber,
      this.episodeNumber,
      this.runtimeMinutes,
      this.trackCount,
      this.tracksJson,
      this.editionsJson,
      this.creatorsJson,
      this.charactersJson,
      this.storyArcsJson,
      this.seriesTagsJson,
      this.platformsJson,
      this.genresJson,
      this.pageCount,
      this.coverPriceCents,
      this.catalogCurrency,
      this.catalogNumber,
      this.country,
      this.releaseStatus,
      this.language,
      this.ageRating,
      this.imprint,
      this.subtitle,
      this.seriesGroup,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || sortKey != null) {
      map['sort_key'] = Variable<String>(sortKey);
    }
    if (!nullToAbsent || itemNumber != null) {
      map['item_number'] = Variable<String>(itemNumber);
    }
    if (!nullToAbsent || synopsis != null) {
      map['synopsis'] = Variable<String>(synopsis);
    }
    if (!nullToAbsent || coverImageUrl != null) {
      map['cover_image_url'] = Variable<String>(coverImageUrl);
    }
    if (!nullToAbsent || thumbnailImageUrl != null) {
      map['thumbnail_image_url'] = Variable<String>(thumbnailImageUrl);
    }
    if (!nullToAbsent || editionTitle != null) {
      map['edition_title'] = Variable<String>(editionTitle);
    }
    if (!nullToAbsent || physicalFormat != null) {
      map['physical_format'] = Variable<String>(physicalFormat);
    }
    if (!nullToAbsent || physicalFormatLabel != null) {
      map['physical_format_label'] = Variable<String>(physicalFormatLabel);
    }
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(publisher);
    }
    if (!nullToAbsent || releaseDate != null) {
      map['release_date'] = Variable<DateTime>(releaseDate);
    }
    if (!nullToAbsent || releaseYear != null) {
      map['release_year'] = Variable<int>(releaseYear);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || variant != null) {
      map['variant'] = Variable<String>(variant);
    }
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<String>(seriesId);
    }
    if (!nullToAbsent || seriesTitle != null) {
      map['series_title'] = Variable<String>(seriesTitle);
    }
    if (!nullToAbsent || volumeName != null) {
      map['volume_name'] = Variable<String>(volumeName);
    }
    if (!nullToAbsent || volumeNumber != null) {
      map['volume_number'] = Variable<int>(volumeNumber);
    }
    if (!nullToAbsent || volumeStartYear != null) {
      map['volume_start_year'] = Variable<int>(volumeStartYear);
    }
    if (!nullToAbsent || seasonNumber != null) {
      map['season_number'] = Variable<int>(seasonNumber);
    }
    if (!nullToAbsent || episodeNumber != null) {
      map['episode_number'] = Variable<int>(episodeNumber);
    }
    if (!nullToAbsent || runtimeMinutes != null) {
      map['runtime_minutes'] = Variable<int>(runtimeMinutes);
    }
    if (!nullToAbsent || trackCount != null) {
      map['track_count'] = Variable<int>(trackCount);
    }
    if (!nullToAbsent || tracksJson != null) {
      map['tracks_json'] = Variable<String>(tracksJson);
    }
    if (!nullToAbsent || editionsJson != null) {
      map['editions_json'] = Variable<String>(editionsJson);
    }
    if (!nullToAbsent || creatorsJson != null) {
      map['creators_json'] = Variable<String>(creatorsJson);
    }
    if (!nullToAbsent || charactersJson != null) {
      map['characters_json'] = Variable<String>(charactersJson);
    }
    if (!nullToAbsent || storyArcsJson != null) {
      map['story_arcs_json'] = Variable<String>(storyArcsJson);
    }
    if (!nullToAbsent || seriesTagsJson != null) {
      map['series_tags_json'] = Variable<String>(seriesTagsJson);
    }
    if (!nullToAbsent || platformsJson != null) {
      map['platforms_json'] = Variable<String>(platformsJson);
    }
    if (!nullToAbsent || genresJson != null) {
      map['genres_json'] = Variable<String>(genresJson);
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    if (!nullToAbsent || coverPriceCents != null) {
      map['cover_price_cents'] = Variable<int>(coverPriceCents);
    }
    if (!nullToAbsent || catalogCurrency != null) {
      map['catalog_currency'] = Variable<String>(catalogCurrency);
    }
    if (!nullToAbsent || catalogNumber != null) {
      map['catalog_number'] = Variable<String>(catalogNumber);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || releaseStatus != null) {
      map['release_status'] = Variable<String>(releaseStatus);
    }
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    if (!nullToAbsent || ageRating != null) {
      map['age_rating'] = Variable<String>(ageRating);
    }
    if (!nullToAbsent || imprint != null) {
      map['imprint'] = Variable<String>(imprint);
    }
    if (!nullToAbsent || subtitle != null) {
      map['subtitle'] = Variable<String>(subtitle);
    }
    if (!nullToAbsent || seriesGroup != null) {
      map['series_group'] = Variable<String>(seriesGroup);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CatalogCacheCompanion toCompanion(bool nullToAbsent) {
    return CatalogCacheCompanion(
      id: Value(id),
      kind: Value(kind),
      title: Value(title),
      sortKey: sortKey == null && nullToAbsent
          ? const Value.absent()
          : Value(sortKey),
      itemNumber: itemNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(itemNumber),
      synopsis: synopsis == null && nullToAbsent
          ? const Value.absent()
          : Value(synopsis),
      coverImageUrl: coverImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImageUrl),
      thumbnailImageUrl: thumbnailImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailImageUrl),
      editionTitle: editionTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(editionTitle),
      physicalFormat: physicalFormat == null && nullToAbsent
          ? const Value.absent()
          : Value(physicalFormat),
      physicalFormatLabel: physicalFormatLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(physicalFormatLabel),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      releaseDate: releaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseDate),
      releaseYear: releaseYear == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseYear),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      variant: variant == null && nullToAbsent
          ? const Value.absent()
          : Value(variant),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      seriesTitle: seriesTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesTitle),
      volumeName: volumeName == null && nullToAbsent
          ? const Value.absent()
          : Value(volumeName),
      volumeNumber: volumeNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(volumeNumber),
      volumeStartYear: volumeStartYear == null && nullToAbsent
          ? const Value.absent()
          : Value(volumeStartYear),
      seasonNumber: seasonNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonNumber),
      episodeNumber: episodeNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(episodeNumber),
      runtimeMinutes: runtimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(runtimeMinutes),
      trackCount: trackCount == null && nullToAbsent
          ? const Value.absent()
          : Value(trackCount),
      tracksJson: tracksJson == null && nullToAbsent
          ? const Value.absent()
          : Value(tracksJson),
      editionsJson: editionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(editionsJson),
      creatorsJson: creatorsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(creatorsJson),
      charactersJson: charactersJson == null && nullToAbsent
          ? const Value.absent()
          : Value(charactersJson),
      storyArcsJson: storyArcsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(storyArcsJson),
      seriesTagsJson: seriesTagsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesTagsJson),
      platformsJson: platformsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(platformsJson),
      genresJson: genresJson == null && nullToAbsent
          ? const Value.absent()
          : Value(genresJson),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      coverPriceCents: coverPriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPriceCents),
      catalogCurrency: catalogCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogCurrency),
      catalogNumber: catalogNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogNumber),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      releaseStatus: releaseStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseStatus),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      ageRating: ageRating == null && nullToAbsent
          ? const Value.absent()
          : Value(ageRating),
      imprint: imprint == null && nullToAbsent
          ? const Value.absent()
          : Value(imprint),
      subtitle: subtitle == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitle),
      seriesGroup: seriesGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesGroup),
      cachedAt: Value(cachedAt),
    );
  }

  factory CatalogCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogCacheData(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      sortKey: serializer.fromJson<String?>(json['sortKey']),
      itemNumber: serializer.fromJson<String?>(json['itemNumber']),
      synopsis: serializer.fromJson<String?>(json['synopsis']),
      coverImageUrl: serializer.fromJson<String?>(json['coverImageUrl']),
      thumbnailImageUrl:
          serializer.fromJson<String?>(json['thumbnailImageUrl']),
      editionTitle: serializer.fromJson<String?>(json['editionTitle']),
      physicalFormat: serializer.fromJson<String?>(json['physicalFormat']),
      physicalFormatLabel:
          serializer.fromJson<String?>(json['physicalFormatLabel']),
      publisher: serializer.fromJson<String?>(json['publisher']),
      releaseDate: serializer.fromJson<DateTime?>(json['releaseDate']),
      releaseYear: serializer.fromJson<int?>(json['releaseYear']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      variant: serializer.fromJson<String?>(json['variant']),
      seriesId: serializer.fromJson<String?>(json['seriesId']),
      seriesTitle: serializer.fromJson<String?>(json['seriesTitle']),
      volumeName: serializer.fromJson<String?>(json['volumeName']),
      volumeNumber: serializer.fromJson<int?>(json['volumeNumber']),
      volumeStartYear: serializer.fromJson<int?>(json['volumeStartYear']),
      seasonNumber: serializer.fromJson<int?>(json['seasonNumber']),
      episodeNumber: serializer.fromJson<int?>(json['episodeNumber']),
      runtimeMinutes: serializer.fromJson<int?>(json['runtimeMinutes']),
      trackCount: serializer.fromJson<int?>(json['trackCount']),
      tracksJson: serializer.fromJson<String?>(json['tracksJson']),
      editionsJson: serializer.fromJson<String?>(json['editionsJson']),
      creatorsJson: serializer.fromJson<String?>(json['creatorsJson']),
      charactersJson: serializer.fromJson<String?>(json['charactersJson']),
      storyArcsJson: serializer.fromJson<String?>(json['storyArcsJson']),
      seriesTagsJson: serializer.fromJson<String?>(json['seriesTagsJson']),
      platformsJson: serializer.fromJson<String?>(json['platformsJson']),
      genresJson: serializer.fromJson<String?>(json['genresJson']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      coverPriceCents: serializer.fromJson<int?>(json['coverPriceCents']),
      catalogCurrency: serializer.fromJson<String?>(json['catalogCurrency']),
      catalogNumber: serializer.fromJson<String?>(json['catalogNumber']),
      country: serializer.fromJson<String?>(json['country']),
      releaseStatus: serializer.fromJson<String?>(json['releaseStatus']),
      language: serializer.fromJson<String?>(json['language']),
      ageRating: serializer.fromJson<String?>(json['ageRating']),
      imprint: serializer.fromJson<String?>(json['imprint']),
      subtitle: serializer.fromJson<String?>(json['subtitle']),
      seriesGroup: serializer.fromJson<String?>(json['seriesGroup']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'sortKey': serializer.toJson<String?>(sortKey),
      'itemNumber': serializer.toJson<String?>(itemNumber),
      'synopsis': serializer.toJson<String?>(synopsis),
      'coverImageUrl': serializer.toJson<String?>(coverImageUrl),
      'thumbnailImageUrl': serializer.toJson<String?>(thumbnailImageUrl),
      'editionTitle': serializer.toJson<String?>(editionTitle),
      'physicalFormat': serializer.toJson<String?>(physicalFormat),
      'physicalFormatLabel': serializer.toJson<String?>(physicalFormatLabel),
      'publisher': serializer.toJson<String?>(publisher),
      'releaseDate': serializer.toJson<DateTime?>(releaseDate),
      'releaseYear': serializer.toJson<int?>(releaseYear),
      'barcode': serializer.toJson<String?>(barcode),
      'variant': serializer.toJson<String?>(variant),
      'seriesId': serializer.toJson<String?>(seriesId),
      'seriesTitle': serializer.toJson<String?>(seriesTitle),
      'volumeName': serializer.toJson<String?>(volumeName),
      'volumeNumber': serializer.toJson<int?>(volumeNumber),
      'volumeStartYear': serializer.toJson<int?>(volumeStartYear),
      'seasonNumber': serializer.toJson<int?>(seasonNumber),
      'episodeNumber': serializer.toJson<int?>(episodeNumber),
      'runtimeMinutes': serializer.toJson<int?>(runtimeMinutes),
      'trackCount': serializer.toJson<int?>(trackCount),
      'tracksJson': serializer.toJson<String?>(tracksJson),
      'editionsJson': serializer.toJson<String?>(editionsJson),
      'creatorsJson': serializer.toJson<String?>(creatorsJson),
      'charactersJson': serializer.toJson<String?>(charactersJson),
      'storyArcsJson': serializer.toJson<String?>(storyArcsJson),
      'seriesTagsJson': serializer.toJson<String?>(seriesTagsJson),
      'platformsJson': serializer.toJson<String?>(platformsJson),
      'genresJson': serializer.toJson<String?>(genresJson),
      'pageCount': serializer.toJson<int?>(pageCount),
      'coverPriceCents': serializer.toJson<int?>(coverPriceCents),
      'catalogCurrency': serializer.toJson<String?>(catalogCurrency),
      'catalogNumber': serializer.toJson<String?>(catalogNumber),
      'country': serializer.toJson<String?>(country),
      'releaseStatus': serializer.toJson<String?>(releaseStatus),
      'language': serializer.toJson<String?>(language),
      'ageRating': serializer.toJson<String?>(ageRating),
      'imprint': serializer.toJson<String?>(imprint),
      'subtitle': serializer.toJson<String?>(subtitle),
      'seriesGroup': serializer.toJson<String?>(seriesGroup),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CatalogCacheData copyWith(
          {String? id,
          String? kind,
          String? title,
          Value<String?> sortKey = const Value.absent(),
          Value<String?> itemNumber = const Value.absent(),
          Value<String?> synopsis = const Value.absent(),
          Value<String?> coverImageUrl = const Value.absent(),
          Value<String?> thumbnailImageUrl = const Value.absent(),
          Value<String?> editionTitle = const Value.absent(),
          Value<String?> physicalFormat = const Value.absent(),
          Value<String?> physicalFormatLabel = const Value.absent(),
          Value<String?> publisher = const Value.absent(),
          Value<DateTime?> releaseDate = const Value.absent(),
          Value<int?> releaseYear = const Value.absent(),
          Value<String?> barcode = const Value.absent(),
          Value<String?> variant = const Value.absent(),
          Value<String?> seriesId = const Value.absent(),
          Value<String?> seriesTitle = const Value.absent(),
          Value<String?> volumeName = const Value.absent(),
          Value<int?> volumeNumber = const Value.absent(),
          Value<int?> volumeStartYear = const Value.absent(),
          Value<int?> seasonNumber = const Value.absent(),
          Value<int?> episodeNumber = const Value.absent(),
          Value<int?> runtimeMinutes = const Value.absent(),
          Value<int?> trackCount = const Value.absent(),
          Value<String?> tracksJson = const Value.absent(),
          Value<String?> editionsJson = const Value.absent(),
          Value<String?> creatorsJson = const Value.absent(),
          Value<String?> charactersJson = const Value.absent(),
          Value<String?> storyArcsJson = const Value.absent(),
          Value<String?> seriesTagsJson = const Value.absent(),
          Value<String?> platformsJson = const Value.absent(),
          Value<String?> genresJson = const Value.absent(),
          Value<int?> pageCount = const Value.absent(),
          Value<int?> coverPriceCents = const Value.absent(),
          Value<String?> catalogCurrency = const Value.absent(),
          Value<String?> catalogNumber = const Value.absent(),
          Value<String?> country = const Value.absent(),
          Value<String?> releaseStatus = const Value.absent(),
          Value<String?> language = const Value.absent(),
          Value<String?> ageRating = const Value.absent(),
          Value<String?> imprint = const Value.absent(),
          Value<String?> subtitle = const Value.absent(),
          Value<String?> seriesGroup = const Value.absent(),
          DateTime? cachedAt}) =>
      CatalogCacheData(
        id: id ?? this.id,
        kind: kind ?? this.kind,
        title: title ?? this.title,
        sortKey: sortKey.present ? sortKey.value : this.sortKey,
        itemNumber: itemNumber.present ? itemNumber.value : this.itemNumber,
        synopsis: synopsis.present ? synopsis.value : this.synopsis,
        coverImageUrl:
            coverImageUrl.present ? coverImageUrl.value : this.coverImageUrl,
        thumbnailImageUrl: thumbnailImageUrl.present
            ? thumbnailImageUrl.value
            : this.thumbnailImageUrl,
        editionTitle:
            editionTitle.present ? editionTitle.value : this.editionTitle,
        physicalFormat:
            physicalFormat.present ? physicalFormat.value : this.physicalFormat,
        physicalFormatLabel: physicalFormatLabel.present
            ? physicalFormatLabel.value
            : this.physicalFormatLabel,
        publisher: publisher.present ? publisher.value : this.publisher,
        releaseDate: releaseDate.present ? releaseDate.value : this.releaseDate,
        releaseYear: releaseYear.present ? releaseYear.value : this.releaseYear,
        barcode: barcode.present ? barcode.value : this.barcode,
        variant: variant.present ? variant.value : this.variant,
        seriesId: seriesId.present ? seriesId.value : this.seriesId,
        seriesTitle: seriesTitle.present ? seriesTitle.value : this.seriesTitle,
        volumeName: volumeName.present ? volumeName.value : this.volumeName,
        volumeNumber:
            volumeNumber.present ? volumeNumber.value : this.volumeNumber,
        volumeStartYear: volumeStartYear.present
            ? volumeStartYear.value
            : this.volumeStartYear,
        seasonNumber:
            seasonNumber.present ? seasonNumber.value : this.seasonNumber,
        episodeNumber:
            episodeNumber.present ? episodeNumber.value : this.episodeNumber,
        runtimeMinutes:
            runtimeMinutes.present ? runtimeMinutes.value : this.runtimeMinutes,
        trackCount: trackCount.present ? trackCount.value : this.trackCount,
        tracksJson: tracksJson.present ? tracksJson.value : this.tracksJson,
        editionsJson:
            editionsJson.present ? editionsJson.value : this.editionsJson,
        creatorsJson:
            creatorsJson.present ? creatorsJson.value : this.creatorsJson,
        charactersJson:
            charactersJson.present ? charactersJson.value : this.charactersJson,
        storyArcsJson:
            storyArcsJson.present ? storyArcsJson.value : this.storyArcsJson,
        seriesTagsJson:
            seriesTagsJson.present ? seriesTagsJson.value : this.seriesTagsJson,
        platformsJson:
            platformsJson.present ? platformsJson.value : this.platformsJson,
        genresJson: genresJson.present ? genresJson.value : this.genresJson,
        pageCount: pageCount.present ? pageCount.value : this.pageCount,
        coverPriceCents: coverPriceCents.present
            ? coverPriceCents.value
            : this.coverPriceCents,
        catalogCurrency: catalogCurrency.present
            ? catalogCurrency.value
            : this.catalogCurrency,
        catalogNumber:
            catalogNumber.present ? catalogNumber.value : this.catalogNumber,
        country: country.present ? country.value : this.country,
        releaseStatus:
            releaseStatus.present ? releaseStatus.value : this.releaseStatus,
        language: language.present ? language.value : this.language,
        ageRating: ageRating.present ? ageRating.value : this.ageRating,
        imprint: imprint.present ? imprint.value : this.imprint,
        subtitle: subtitle.present ? subtitle.value : this.subtitle,
        seriesGroup: seriesGroup.present ? seriesGroup.value : this.seriesGroup,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CatalogCacheData copyWithCompanion(CatalogCacheCompanion data) {
    return CatalogCacheData(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      sortKey: data.sortKey.present ? data.sortKey.value : this.sortKey,
      itemNumber:
          data.itemNumber.present ? data.itemNumber.value : this.itemNumber,
      synopsis: data.synopsis.present ? data.synopsis.value : this.synopsis,
      coverImageUrl: data.coverImageUrl.present
          ? data.coverImageUrl.value
          : this.coverImageUrl,
      thumbnailImageUrl: data.thumbnailImageUrl.present
          ? data.thumbnailImageUrl.value
          : this.thumbnailImageUrl,
      editionTitle: data.editionTitle.present
          ? data.editionTitle.value
          : this.editionTitle,
      physicalFormat: data.physicalFormat.present
          ? data.physicalFormat.value
          : this.physicalFormat,
      physicalFormatLabel: data.physicalFormatLabel.present
          ? data.physicalFormatLabel.value
          : this.physicalFormatLabel,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      releaseDate:
          data.releaseDate.present ? data.releaseDate.value : this.releaseDate,
      releaseYear:
          data.releaseYear.present ? data.releaseYear.value : this.releaseYear,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      variant: data.variant.present ? data.variant.value : this.variant,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      seriesTitle:
          data.seriesTitle.present ? data.seriesTitle.value : this.seriesTitle,
      volumeName:
          data.volumeName.present ? data.volumeName.value : this.volumeName,
      volumeNumber: data.volumeNumber.present
          ? data.volumeNumber.value
          : this.volumeNumber,
      volumeStartYear: data.volumeStartYear.present
          ? data.volumeStartYear.value
          : this.volumeStartYear,
      seasonNumber: data.seasonNumber.present
          ? data.seasonNumber.value
          : this.seasonNumber,
      episodeNumber: data.episodeNumber.present
          ? data.episodeNumber.value
          : this.episodeNumber,
      runtimeMinutes: data.runtimeMinutes.present
          ? data.runtimeMinutes.value
          : this.runtimeMinutes,
      trackCount:
          data.trackCount.present ? data.trackCount.value : this.trackCount,
      tracksJson:
          data.tracksJson.present ? data.tracksJson.value : this.tracksJson,
      editionsJson: data.editionsJson.present
          ? data.editionsJson.value
          : this.editionsJson,
      creatorsJson: data.creatorsJson.present
          ? data.creatorsJson.value
          : this.creatorsJson,
      charactersJson: data.charactersJson.present
          ? data.charactersJson.value
          : this.charactersJson,
      storyArcsJson: data.storyArcsJson.present
          ? data.storyArcsJson.value
          : this.storyArcsJson,
      seriesTagsJson: data.seriesTagsJson.present
          ? data.seriesTagsJson.value
          : this.seriesTagsJson,
      platformsJson: data.platformsJson.present
          ? data.platformsJson.value
          : this.platformsJson,
      genresJson:
          data.genresJson.present ? data.genresJson.value : this.genresJson,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      coverPriceCents: data.coverPriceCents.present
          ? data.coverPriceCents.value
          : this.coverPriceCents,
      catalogCurrency: data.catalogCurrency.present
          ? data.catalogCurrency.value
          : this.catalogCurrency,
      catalogNumber: data.catalogNumber.present
          ? data.catalogNumber.value
          : this.catalogNumber,
      country: data.country.present ? data.country.value : this.country,
      releaseStatus: data.releaseStatus.present
          ? data.releaseStatus.value
          : this.releaseStatus,
      language: data.language.present ? data.language.value : this.language,
      ageRating: data.ageRating.present ? data.ageRating.value : this.ageRating,
      imprint: data.imprint.present ? data.imprint.value : this.imprint,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      seriesGroup:
          data.seriesGroup.present ? data.seriesGroup.value : this.seriesGroup,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogCacheData(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('sortKey: $sortKey, ')
          ..write('itemNumber: $itemNumber, ')
          ..write('synopsis: $synopsis, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('thumbnailImageUrl: $thumbnailImageUrl, ')
          ..write('editionTitle: $editionTitle, ')
          ..write('physicalFormat: $physicalFormat, ')
          ..write('physicalFormatLabel: $physicalFormatLabel, ')
          ..write('publisher: $publisher, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('barcode: $barcode, ')
          ..write('variant: $variant, ')
          ..write('seriesId: $seriesId, ')
          ..write('seriesTitle: $seriesTitle, ')
          ..write('volumeName: $volumeName, ')
          ..write('volumeNumber: $volumeNumber, ')
          ..write('volumeStartYear: $volumeStartYear, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('runtimeMinutes: $runtimeMinutes, ')
          ..write('trackCount: $trackCount, ')
          ..write('tracksJson: $tracksJson, ')
          ..write('editionsJson: $editionsJson, ')
          ..write('creatorsJson: $creatorsJson, ')
          ..write('charactersJson: $charactersJson, ')
          ..write('storyArcsJson: $storyArcsJson, ')
          ..write('seriesTagsJson: $seriesTagsJson, ')
          ..write('platformsJson: $platformsJson, ')
          ..write('genresJson: $genresJson, ')
          ..write('pageCount: $pageCount, ')
          ..write('coverPriceCents: $coverPriceCents, ')
          ..write('catalogCurrency: $catalogCurrency, ')
          ..write('catalogNumber: $catalogNumber, ')
          ..write('country: $country, ')
          ..write('releaseStatus: $releaseStatus, ')
          ..write('language: $language, ')
          ..write('ageRating: $ageRating, ')
          ..write('imprint: $imprint, ')
          ..write('subtitle: $subtitle, ')
          ..write('seriesGroup: $seriesGroup, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        kind,
        title,
        sortKey,
        itemNumber,
        synopsis,
        coverImageUrl,
        thumbnailImageUrl,
        editionTitle,
        physicalFormat,
        physicalFormatLabel,
        publisher,
        releaseDate,
        releaseYear,
        barcode,
        variant,
        seriesId,
        seriesTitle,
        volumeName,
        volumeNumber,
        volumeStartYear,
        seasonNumber,
        episodeNumber,
        runtimeMinutes,
        trackCount,
        tracksJson,
        editionsJson,
        creatorsJson,
        charactersJson,
        storyArcsJson,
        seriesTagsJson,
        platformsJson,
        genresJson,
        pageCount,
        coverPriceCents,
        catalogCurrency,
        catalogNumber,
        country,
        releaseStatus,
        language,
        ageRating,
        imprint,
        subtitle,
        seriesGroup,
        cachedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogCacheData &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.sortKey == this.sortKey &&
          other.itemNumber == this.itemNumber &&
          other.synopsis == this.synopsis &&
          other.coverImageUrl == this.coverImageUrl &&
          other.thumbnailImageUrl == this.thumbnailImageUrl &&
          other.editionTitle == this.editionTitle &&
          other.physicalFormat == this.physicalFormat &&
          other.physicalFormatLabel == this.physicalFormatLabel &&
          other.publisher == this.publisher &&
          other.releaseDate == this.releaseDate &&
          other.releaseYear == this.releaseYear &&
          other.barcode == this.barcode &&
          other.variant == this.variant &&
          other.seriesId == this.seriesId &&
          other.seriesTitle == this.seriesTitle &&
          other.volumeName == this.volumeName &&
          other.volumeNumber == this.volumeNumber &&
          other.volumeStartYear == this.volumeStartYear &&
          other.seasonNumber == this.seasonNumber &&
          other.episodeNumber == this.episodeNumber &&
          other.runtimeMinutes == this.runtimeMinutes &&
          other.trackCount == this.trackCount &&
          other.tracksJson == this.tracksJson &&
          other.editionsJson == this.editionsJson &&
          other.creatorsJson == this.creatorsJson &&
          other.charactersJson == this.charactersJson &&
          other.storyArcsJson == this.storyArcsJson &&
          other.seriesTagsJson == this.seriesTagsJson &&
          other.platformsJson == this.platformsJson &&
          other.genresJson == this.genresJson &&
          other.pageCount == this.pageCount &&
          other.coverPriceCents == this.coverPriceCents &&
          other.catalogCurrency == this.catalogCurrency &&
          other.catalogNumber == this.catalogNumber &&
          other.country == this.country &&
          other.releaseStatus == this.releaseStatus &&
          other.language == this.language &&
          other.ageRating == this.ageRating &&
          other.imprint == this.imprint &&
          other.subtitle == this.subtitle &&
          other.seriesGroup == this.seriesGroup &&
          other.cachedAt == this.cachedAt);
}

class CatalogCacheCompanion extends UpdateCompanion<CatalogCacheData> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> title;
  final Value<String?> sortKey;
  final Value<String?> itemNumber;
  final Value<String?> synopsis;
  final Value<String?> coverImageUrl;
  final Value<String?> thumbnailImageUrl;
  final Value<String?> editionTitle;
  final Value<String?> physicalFormat;
  final Value<String?> physicalFormatLabel;
  final Value<String?> publisher;
  final Value<DateTime?> releaseDate;
  final Value<int?> releaseYear;
  final Value<String?> barcode;
  final Value<String?> variant;
  final Value<String?> seriesId;
  final Value<String?> seriesTitle;
  final Value<String?> volumeName;
  final Value<int?> volumeNumber;
  final Value<int?> volumeStartYear;
  final Value<int?> seasonNumber;
  final Value<int?> episodeNumber;
  final Value<int?> runtimeMinutes;
  final Value<int?> trackCount;
  final Value<String?> tracksJson;
  final Value<String?> editionsJson;
  final Value<String?> creatorsJson;
  final Value<String?> charactersJson;
  final Value<String?> storyArcsJson;
  final Value<String?> seriesTagsJson;
  final Value<String?> platformsJson;
  final Value<String?> genresJson;
  final Value<int?> pageCount;
  final Value<int?> coverPriceCents;
  final Value<String?> catalogCurrency;
  final Value<String?> catalogNumber;
  final Value<String?> country;
  final Value<String?> releaseStatus;
  final Value<String?> language;
  final Value<String?> ageRating;
  final Value<String?> imprint;
  final Value<String?> subtitle;
  final Value<String?> seriesGroup;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CatalogCacheCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.itemNumber = const Value.absent(),
    this.synopsis = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.thumbnailImageUrl = const Value.absent(),
    this.editionTitle = const Value.absent(),
    this.physicalFormat = const Value.absent(),
    this.physicalFormatLabel = const Value.absent(),
    this.publisher = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.barcode = const Value.absent(),
    this.variant = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.seriesTitle = const Value.absent(),
    this.volumeName = const Value.absent(),
    this.volumeNumber = const Value.absent(),
    this.volumeStartYear = const Value.absent(),
    this.seasonNumber = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.runtimeMinutes = const Value.absent(),
    this.trackCount = const Value.absent(),
    this.tracksJson = const Value.absent(),
    this.editionsJson = const Value.absent(),
    this.creatorsJson = const Value.absent(),
    this.charactersJson = const Value.absent(),
    this.storyArcsJson = const Value.absent(),
    this.seriesTagsJson = const Value.absent(),
    this.platformsJson = const Value.absent(),
    this.genresJson = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.coverPriceCents = const Value.absent(),
    this.catalogCurrency = const Value.absent(),
    this.catalogNumber = const Value.absent(),
    this.country = const Value.absent(),
    this.releaseStatus = const Value.absent(),
    this.language = const Value.absent(),
    this.ageRating = const Value.absent(),
    this.imprint = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.seriesGroup = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogCacheCompanion.insert({
    required String id,
    required String kind,
    required String title,
    this.sortKey = const Value.absent(),
    this.itemNumber = const Value.absent(),
    this.synopsis = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.thumbnailImageUrl = const Value.absent(),
    this.editionTitle = const Value.absent(),
    this.physicalFormat = const Value.absent(),
    this.physicalFormatLabel = const Value.absent(),
    this.publisher = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.barcode = const Value.absent(),
    this.variant = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.seriesTitle = const Value.absent(),
    this.volumeName = const Value.absent(),
    this.volumeNumber = const Value.absent(),
    this.volumeStartYear = const Value.absent(),
    this.seasonNumber = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.runtimeMinutes = const Value.absent(),
    this.trackCount = const Value.absent(),
    this.tracksJson = const Value.absent(),
    this.editionsJson = const Value.absent(),
    this.creatorsJson = const Value.absent(),
    this.charactersJson = const Value.absent(),
    this.storyArcsJson = const Value.absent(),
    this.seriesTagsJson = const Value.absent(),
    this.platformsJson = const Value.absent(),
    this.genresJson = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.coverPriceCents = const Value.absent(),
    this.catalogCurrency = const Value.absent(),
    this.catalogNumber = const Value.absent(),
    this.country = const Value.absent(),
    this.releaseStatus = const Value.absent(),
    this.language = const Value.absent(),
    this.ageRating = const Value.absent(),
    this.imprint = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.seriesGroup = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        kind = Value(kind),
        title = Value(title),
        cachedAt = Value(cachedAt);
  static Insertable<CatalogCacheData> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? sortKey,
    Expression<String>? itemNumber,
    Expression<String>? synopsis,
    Expression<String>? coverImageUrl,
    Expression<String>? thumbnailImageUrl,
    Expression<String>? editionTitle,
    Expression<String>? physicalFormat,
    Expression<String>? physicalFormatLabel,
    Expression<String>? publisher,
    Expression<DateTime>? releaseDate,
    Expression<int>? releaseYear,
    Expression<String>? barcode,
    Expression<String>? variant,
    Expression<String>? seriesId,
    Expression<String>? seriesTitle,
    Expression<String>? volumeName,
    Expression<int>? volumeNumber,
    Expression<int>? volumeStartYear,
    Expression<int>? seasonNumber,
    Expression<int>? episodeNumber,
    Expression<int>? runtimeMinutes,
    Expression<int>? trackCount,
    Expression<String>? tracksJson,
    Expression<String>? editionsJson,
    Expression<String>? creatorsJson,
    Expression<String>? charactersJson,
    Expression<String>? storyArcsJson,
    Expression<String>? seriesTagsJson,
    Expression<String>? platformsJson,
    Expression<String>? genresJson,
    Expression<int>? pageCount,
    Expression<int>? coverPriceCents,
    Expression<String>? catalogCurrency,
    Expression<String>? catalogNumber,
    Expression<String>? country,
    Expression<String>? releaseStatus,
    Expression<String>? language,
    Expression<String>? ageRating,
    Expression<String>? imprint,
    Expression<String>? subtitle,
    Expression<String>? seriesGroup,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (sortKey != null) 'sort_key': sortKey,
      if (itemNumber != null) 'item_number': itemNumber,
      if (synopsis != null) 'synopsis': synopsis,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
      if (editionTitle != null) 'edition_title': editionTitle,
      if (physicalFormat != null) 'physical_format': physicalFormat,
      if (physicalFormatLabel != null)
        'physical_format_label': physicalFormatLabel,
      if (publisher != null) 'publisher': publisher,
      if (releaseDate != null) 'release_date': releaseDate,
      if (releaseYear != null) 'release_year': releaseYear,
      if (barcode != null) 'barcode': barcode,
      if (variant != null) 'variant': variant,
      if (seriesId != null) 'series_id': seriesId,
      if (seriesTitle != null) 'series_title': seriesTitle,
      if (volumeName != null) 'volume_name': volumeName,
      if (volumeNumber != null) 'volume_number': volumeNumber,
      if (volumeStartYear != null) 'volume_start_year': volumeStartYear,
      if (seasonNumber != null) 'season_number': seasonNumber,
      if (episodeNumber != null) 'episode_number': episodeNumber,
      if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
      if (trackCount != null) 'track_count': trackCount,
      if (tracksJson != null) 'tracks_json': tracksJson,
      if (editionsJson != null) 'editions_json': editionsJson,
      if (creatorsJson != null) 'creators_json': creatorsJson,
      if (charactersJson != null) 'characters_json': charactersJson,
      if (storyArcsJson != null) 'story_arcs_json': storyArcsJson,
      if (seriesTagsJson != null) 'series_tags_json': seriesTagsJson,
      if (platformsJson != null) 'platforms_json': platformsJson,
      if (genresJson != null) 'genres_json': genresJson,
      if (pageCount != null) 'page_count': pageCount,
      if (coverPriceCents != null) 'cover_price_cents': coverPriceCents,
      if (catalogCurrency != null) 'catalog_currency': catalogCurrency,
      if (catalogNumber != null) 'catalog_number': catalogNumber,
      if (country != null) 'country': country,
      if (releaseStatus != null) 'release_status': releaseStatus,
      if (language != null) 'language': language,
      if (ageRating != null) 'age_rating': ageRating,
      if (imprint != null) 'imprint': imprint,
      if (subtitle != null) 'subtitle': subtitle,
      if (seriesGroup != null) 'series_group': seriesGroup,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? kind,
      Value<String>? title,
      Value<String?>? sortKey,
      Value<String?>? itemNumber,
      Value<String?>? synopsis,
      Value<String?>? coverImageUrl,
      Value<String?>? thumbnailImageUrl,
      Value<String?>? editionTitle,
      Value<String?>? physicalFormat,
      Value<String?>? physicalFormatLabel,
      Value<String?>? publisher,
      Value<DateTime?>? releaseDate,
      Value<int?>? releaseYear,
      Value<String?>? barcode,
      Value<String?>? variant,
      Value<String?>? seriesId,
      Value<String?>? seriesTitle,
      Value<String?>? volumeName,
      Value<int?>? volumeNumber,
      Value<int?>? volumeStartYear,
      Value<int?>? seasonNumber,
      Value<int?>? episodeNumber,
      Value<int?>? runtimeMinutes,
      Value<int?>? trackCount,
      Value<String?>? tracksJson,
      Value<String?>? editionsJson,
      Value<String?>? creatorsJson,
      Value<String?>? charactersJson,
      Value<String?>? storyArcsJson,
      Value<String?>? seriesTagsJson,
      Value<String?>? platformsJson,
      Value<String?>? genresJson,
      Value<int?>? pageCount,
      Value<int?>? coverPriceCents,
      Value<String?>? catalogCurrency,
      Value<String?>? catalogNumber,
      Value<String?>? country,
      Value<String?>? releaseStatus,
      Value<String?>? language,
      Value<String?>? ageRating,
      Value<String?>? imprint,
      Value<String?>? subtitle,
      Value<String?>? seriesGroup,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return CatalogCacheCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      sortKey: sortKey ?? this.sortKey,
      itemNumber: itemNumber ?? this.itemNumber,
      synopsis: synopsis ?? this.synopsis,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      thumbnailImageUrl: thumbnailImageUrl ?? this.thumbnailImageUrl,
      editionTitle: editionTitle ?? this.editionTitle,
      physicalFormat: physicalFormat ?? this.physicalFormat,
      physicalFormatLabel: physicalFormatLabel ?? this.physicalFormatLabel,
      publisher: publisher ?? this.publisher,
      releaseDate: releaseDate ?? this.releaseDate,
      releaseYear: releaseYear ?? this.releaseYear,
      barcode: barcode ?? this.barcode,
      variant: variant ?? this.variant,
      seriesId: seriesId ?? this.seriesId,
      seriesTitle: seriesTitle ?? this.seriesTitle,
      volumeName: volumeName ?? this.volumeName,
      volumeNumber: volumeNumber ?? this.volumeNumber,
      volumeStartYear: volumeStartYear ?? this.volumeStartYear,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      runtimeMinutes: runtimeMinutes ?? this.runtimeMinutes,
      trackCount: trackCount ?? this.trackCount,
      tracksJson: tracksJson ?? this.tracksJson,
      editionsJson: editionsJson ?? this.editionsJson,
      creatorsJson: creatorsJson ?? this.creatorsJson,
      charactersJson: charactersJson ?? this.charactersJson,
      storyArcsJson: storyArcsJson ?? this.storyArcsJson,
      seriesTagsJson: seriesTagsJson ?? this.seriesTagsJson,
      platformsJson: platformsJson ?? this.platformsJson,
      genresJson: genresJson ?? this.genresJson,
      pageCount: pageCount ?? this.pageCount,
      coverPriceCents: coverPriceCents ?? this.coverPriceCents,
      catalogCurrency: catalogCurrency ?? this.catalogCurrency,
      catalogNumber: catalogNumber ?? this.catalogNumber,
      country: country ?? this.country,
      releaseStatus: releaseStatus ?? this.releaseStatus,
      language: language ?? this.language,
      ageRating: ageRating ?? this.ageRating,
      imprint: imprint ?? this.imprint,
      subtitle: subtitle ?? this.subtitle,
      seriesGroup: seriesGroup ?? this.seriesGroup,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sortKey.present) {
      map['sort_key'] = Variable<String>(sortKey.value);
    }
    if (itemNumber.present) {
      map['item_number'] = Variable<String>(itemNumber.value);
    }
    if (synopsis.present) {
      map['synopsis'] = Variable<String>(synopsis.value);
    }
    if (coverImageUrl.present) {
      map['cover_image_url'] = Variable<String>(coverImageUrl.value);
    }
    if (thumbnailImageUrl.present) {
      map['thumbnail_image_url'] = Variable<String>(thumbnailImageUrl.value);
    }
    if (editionTitle.present) {
      map['edition_title'] = Variable<String>(editionTitle.value);
    }
    if (physicalFormat.present) {
      map['physical_format'] = Variable<String>(physicalFormat.value);
    }
    if (physicalFormatLabel.present) {
      map['physical_format_label'] =
          Variable<String>(physicalFormatLabel.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (releaseDate.present) {
      map['release_date'] = Variable<DateTime>(releaseDate.value);
    }
    if (releaseYear.present) {
      map['release_year'] = Variable<int>(releaseYear.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (variant.present) {
      map['variant'] = Variable<String>(variant.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (seriesTitle.present) {
      map['series_title'] = Variable<String>(seriesTitle.value);
    }
    if (volumeName.present) {
      map['volume_name'] = Variable<String>(volumeName.value);
    }
    if (volumeNumber.present) {
      map['volume_number'] = Variable<int>(volumeNumber.value);
    }
    if (volumeStartYear.present) {
      map['volume_start_year'] = Variable<int>(volumeStartYear.value);
    }
    if (seasonNumber.present) {
      map['season_number'] = Variable<int>(seasonNumber.value);
    }
    if (episodeNumber.present) {
      map['episode_number'] = Variable<int>(episodeNumber.value);
    }
    if (runtimeMinutes.present) {
      map['runtime_minutes'] = Variable<int>(runtimeMinutes.value);
    }
    if (trackCount.present) {
      map['track_count'] = Variable<int>(trackCount.value);
    }
    if (tracksJson.present) {
      map['tracks_json'] = Variable<String>(tracksJson.value);
    }
    if (editionsJson.present) {
      map['editions_json'] = Variable<String>(editionsJson.value);
    }
    if (creatorsJson.present) {
      map['creators_json'] = Variable<String>(creatorsJson.value);
    }
    if (charactersJson.present) {
      map['characters_json'] = Variable<String>(charactersJson.value);
    }
    if (storyArcsJson.present) {
      map['story_arcs_json'] = Variable<String>(storyArcsJson.value);
    }
    if (seriesTagsJson.present) {
      map['series_tags_json'] = Variable<String>(seriesTagsJson.value);
    }
    if (platformsJson.present) {
      map['platforms_json'] = Variable<String>(platformsJson.value);
    }
    if (genresJson.present) {
      map['genres_json'] = Variable<String>(genresJson.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (coverPriceCents.present) {
      map['cover_price_cents'] = Variable<int>(coverPriceCents.value);
    }
    if (catalogCurrency.present) {
      map['catalog_currency'] = Variable<String>(catalogCurrency.value);
    }
    if (catalogNumber.present) {
      map['catalog_number'] = Variable<String>(catalogNumber.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (releaseStatus.present) {
      map['release_status'] = Variable<String>(releaseStatus.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (ageRating.present) {
      map['age_rating'] = Variable<String>(ageRating.value);
    }
    if (imprint.present) {
      map['imprint'] = Variable<String>(imprint.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (seriesGroup.present) {
      map['series_group'] = Variable<String>(seriesGroup.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogCacheCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('sortKey: $sortKey, ')
          ..write('itemNumber: $itemNumber, ')
          ..write('synopsis: $synopsis, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('thumbnailImageUrl: $thumbnailImageUrl, ')
          ..write('editionTitle: $editionTitle, ')
          ..write('physicalFormat: $physicalFormat, ')
          ..write('physicalFormatLabel: $physicalFormatLabel, ')
          ..write('publisher: $publisher, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('barcode: $barcode, ')
          ..write('variant: $variant, ')
          ..write('seriesId: $seriesId, ')
          ..write('seriesTitle: $seriesTitle, ')
          ..write('volumeName: $volumeName, ')
          ..write('volumeNumber: $volumeNumber, ')
          ..write('volumeStartYear: $volumeStartYear, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('runtimeMinutes: $runtimeMinutes, ')
          ..write('trackCount: $trackCount, ')
          ..write('tracksJson: $tracksJson, ')
          ..write('editionsJson: $editionsJson, ')
          ..write('creatorsJson: $creatorsJson, ')
          ..write('charactersJson: $charactersJson, ')
          ..write('storyArcsJson: $storyArcsJson, ')
          ..write('seriesTagsJson: $seriesTagsJson, ')
          ..write('platformsJson: $platformsJson, ')
          ..write('genresJson: $genresJson, ')
          ..write('pageCount: $pageCount, ')
          ..write('coverPriceCents: $coverPriceCents, ')
          ..write('catalogCurrency: $catalogCurrency, ')
          ..write('catalogNumber: $catalogNumber, ')
          ..write('country: $country, ')
          ..write('releaseStatus: $releaseStatus, ')
          ..write('language: $language, ')
          ..write('ageRating: $ageRating, ')
          ..write('imprint: $imprint, ')
          ..write('subtitle: $subtitle, ')
          ..write('seriesGroup: $seriesGroup, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OwnedItemsCacheTable extends OwnedItemsCache
    with TableInfo<$OwnedItemsCacheTable, OwnedItemsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OwnedItemsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _anchorTypeMeta =
      const VerificationMeta('anchorType');
  @override
  late final GeneratedColumn<String> anchorType = GeneratedColumn<String>(
      'anchor_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _editionIdMeta =
      const VerificationMeta('editionId');
  @override
  late final GeneratedColumn<String> editionId = GeneratedColumn<String>(
      'edition_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
      'variant_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bundleReleaseIdMeta =
      const VerificationMeta('bundleReleaseId');
  @override
  late final GeneratedColumn<String> bundleReleaseId = GeneratedColumn<String>(
      'bundle_release_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _conditionMeta =
      const VerificationMeta('condition');
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
      'condition', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
      'grade', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _purchaseDateMeta =
      const VerificationMeta('purchaseDate');
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
      'purchase_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _pricePaidCentsMeta =
      const VerificationMeta('pricePaidCents');
  @override
  late final GeneratedColumn<int> pricePaidCents = GeneratedColumn<int>(
      'price_paid_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _personalNotesMeta =
      const VerificationMeta('personalNotes');
  @override
  late final GeneratedColumn<String> personalNotes = GeneratedColumn<String>(
      'personal_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _storageBoxMeta =
      const VerificationMeta('storageBox');
  @override
  late final GeneratedColumn<String> storageBox = GeneratedColumn<String>(
      'storage_box', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indexNumberMeta =
      const VerificationMeta('indexNumber');
  @override
  late final GeneratedColumn<int> indexNumber = GeneratedColumn<int>(
      'index_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _coverPriceCentsMeta =
      const VerificationMeta('coverPriceCents');
  @override
  late final GeneratedColumn<int> coverPriceCents = GeneratedColumn<int>(
      'cover_price_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _rawOrSlabbedMeta =
      const VerificationMeta('rawOrSlabbed');
  @override
  late final GeneratedColumn<String> rawOrSlabbed = GeneratedColumn<String>(
      'raw_or_slabbed', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _gradingCompanyMeta =
      const VerificationMeta('gradingCompany');
  @override
  late final GeneratedColumn<String> gradingCompany = GeneratedColumn<String>(
      'grading_company', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _graderNotesMeta =
      const VerificationMeta('graderNotes');
  @override
  late final GeneratedColumn<String> graderNotes = GeneratedColumn<String>(
      'grader_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _signedByMeta =
      const VerificationMeta('signedBy');
  @override
  late final GeneratedColumn<String> signedBy = GeneratedColumn<String>(
      'signed_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _keyComicMeta =
      const VerificationMeta('keyComic');
  @override
  late final GeneratedColumn<bool> keyComic = GeneratedColumn<bool>(
      'key_comic', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("key_comic" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _keyReasonMeta =
      const VerificationMeta('keyReason');
  @override
  late final GeneratedColumn<String> keyReason = GeneratedColumn<String>(
      'key_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
      'rating', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _readStatusMeta =
      const VerificationMeta('readStatus');
  @override
  late final GeneratedColumn<String> readStatus = GeneratedColumn<String>(
      'read_status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _finishedAtMeta =
      const VerificationMeta('finishedAt');
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
      'finished_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _soldAtMeta = const VerificationMeta('soldAt');
  @override
  late final GeneratedColumn<DateTime> soldAt = GeneratedColumn<DateTime>(
      'sold_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _sellPriceCentsMeta =
      const VerificationMeta('sellPriceCents');
  @override
  late final GeneratedColumn<int> sellPriceCents = GeneratedColumn<int>(
      'sell_price_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _soldToMeta = const VerificationMeta('soldTo');
  @override
  late final GeneratedColumn<String> soldTo = GeneratedColumn<String>(
      'sold_to', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationIdMeta =
      const VerificationMeta('locationId');
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
      'location_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        itemId,
        anchorType,
        editionId,
        variantId,
        bundleReleaseId,
        condition,
        grade,
        purchaseDate,
        pricePaidCents,
        currency,
        personalNotes,
        quantity,
        storageBox,
        indexNumber,
        coverPriceCents,
        rawOrSlabbed,
        gradingCompany,
        graderNotes,
        signedBy,
        keyComic,
        keyReason,
        rating,
        readStatus,
        startedAt,
        finishedAt,
        tags,
        updatedAt,
        deletedAt,
        soldAt,
        sellPriceCents,
        soldTo,
        locationId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'owned_items_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<OwnedItemsCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('anchor_type')) {
      context.handle(
          _anchorTypeMeta,
          anchorType.isAcceptableOrUnknown(
              data['anchor_type']!, _anchorTypeMeta));
    }
    if (data.containsKey('edition_id')) {
      context.handle(_editionIdMeta,
          editionId.isAcceptableOrUnknown(data['edition_id']!, _editionIdMeta));
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    }
    if (data.containsKey('bundle_release_id')) {
      context.handle(
          _bundleReleaseIdMeta,
          bundleReleaseId.isAcceptableOrUnknown(
              data['bundle_release_id']!, _bundleReleaseIdMeta));
    }
    if (data.containsKey('condition')) {
      context.handle(_conditionMeta,
          condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta));
    }
    if (data.containsKey('grade')) {
      context.handle(
          _gradeMeta, grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta));
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
          _purchaseDateMeta,
          purchaseDate.isAcceptableOrUnknown(
              data['purchase_date']!, _purchaseDateMeta));
    }
    if (data.containsKey('price_paid_cents')) {
      context.handle(
          _pricePaidCentsMeta,
          pricePaidCents.isAcceptableOrUnknown(
              data['price_paid_cents']!, _pricePaidCentsMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('personal_notes')) {
      context.handle(
          _personalNotesMeta,
          personalNotes.isAcceptableOrUnknown(
              data['personal_notes']!, _personalNotesMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('storage_box')) {
      context.handle(
          _storageBoxMeta,
          storageBox.isAcceptableOrUnknown(
              data['storage_box']!, _storageBoxMeta));
    }
    if (data.containsKey('index_number')) {
      context.handle(
          _indexNumberMeta,
          indexNumber.isAcceptableOrUnknown(
              data['index_number']!, _indexNumberMeta));
    }
    if (data.containsKey('cover_price_cents')) {
      context.handle(
          _coverPriceCentsMeta,
          coverPriceCents.isAcceptableOrUnknown(
              data['cover_price_cents']!, _coverPriceCentsMeta));
    }
    if (data.containsKey('raw_or_slabbed')) {
      context.handle(
          _rawOrSlabbedMeta,
          rawOrSlabbed.isAcceptableOrUnknown(
              data['raw_or_slabbed']!, _rawOrSlabbedMeta));
    }
    if (data.containsKey('grading_company')) {
      context.handle(
          _gradingCompanyMeta,
          gradingCompany.isAcceptableOrUnknown(
              data['grading_company']!, _gradingCompanyMeta));
    }
    if (data.containsKey('grader_notes')) {
      context.handle(
          _graderNotesMeta,
          graderNotes.isAcceptableOrUnknown(
              data['grader_notes']!, _graderNotesMeta));
    }
    if (data.containsKey('signed_by')) {
      context.handle(_signedByMeta,
          signedBy.isAcceptableOrUnknown(data['signed_by']!, _signedByMeta));
    }
    if (data.containsKey('key_comic')) {
      context.handle(_keyComicMeta,
          keyComic.isAcceptableOrUnknown(data['key_comic']!, _keyComicMeta));
    }
    if (data.containsKey('key_reason')) {
      context.handle(_keyReasonMeta,
          keyReason.isAcceptableOrUnknown(data['key_reason']!, _keyReasonMeta));
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('read_status')) {
      context.handle(
          _readStatusMeta,
          readStatus.isAcceptableOrUnknown(
              data['read_status']!, _readStatusMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('finished_at')) {
      context.handle(
          _finishedAtMeta,
          finishedAt.isAcceptableOrUnknown(
              data['finished_at']!, _finishedAtMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sold_at')) {
      context.handle(_soldAtMeta,
          soldAt.isAcceptableOrUnknown(data['sold_at']!, _soldAtMeta));
    }
    if (data.containsKey('sell_price_cents')) {
      context.handle(
          _sellPriceCentsMeta,
          sellPriceCents.isAcceptableOrUnknown(
              data['sell_price_cents']!, _sellPriceCentsMeta));
    }
    if (data.containsKey('sold_to')) {
      context.handle(_soldToMeta,
          soldTo.isAcceptableOrUnknown(data['sold_to']!, _soldToMeta));
    }
    if (data.containsKey('location_id')) {
      context.handle(
          _locationIdMeta,
          locationId.isAcceptableOrUnknown(
              data['location_id']!, _locationIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OwnedItemsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OwnedItemsCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      anchorType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}anchor_type']),
      editionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edition_id']),
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id']),
      bundleReleaseId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}bundle_release_id']),
      condition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}condition']),
      grade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}grade']),
      purchaseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}purchase_date']),
      pricePaidCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}price_paid_cents']),
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency']),
      personalNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}personal_notes']),
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      storageBox: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_box']),
      indexNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}index_number']),
      coverPriceCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cover_price_cents']),
      rawOrSlabbed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_or_slabbed']),
      gradingCompany: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}grading_company']),
      graderNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}grader_notes']),
      signedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}signed_by']),
      keyComic: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}key_comic'])!,
      keyReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key_reason']),
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rating']),
      readStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}read_status']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at']),
      finishedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}finished_at']),
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      soldAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sold_at']),
      sellPriceCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sell_price_cents']),
      soldTo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sold_to']),
      locationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_id']),
    );
  }

  @override
  $OwnedItemsCacheTable createAlias(String alias) {
    return $OwnedItemsCacheTable(attachedDatabase, alias);
  }
}

class OwnedItemsCacheData extends DataClass
    implements Insertable<OwnedItemsCacheData> {
  final String id;
  final String itemId;
  final String? anchorType;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final int quantity;
  final String? storageBox;
  final int? indexNumber;
  final int? coverPriceCents;
  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? graderNotes;
  final String? signedBy;
  final bool keyComic;
  final String? keyReason;
  final int? rating;
  final String? readStatus;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? tags;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? soldAt;
  final int? sellPriceCents;
  final String? soldTo;
  final String? locationId;
  const OwnedItemsCacheData(
      {required this.id,
      required this.itemId,
      this.anchorType,
      this.editionId,
      this.variantId,
      this.bundleReleaseId,
      this.condition,
      this.grade,
      this.purchaseDate,
      this.pricePaidCents,
      this.currency,
      this.personalNotes,
      required this.quantity,
      this.storageBox,
      this.indexNumber,
      this.coverPriceCents,
      this.rawOrSlabbed,
      this.gradingCompany,
      this.graderNotes,
      this.signedBy,
      required this.keyComic,
      this.keyReason,
      this.rating,
      this.readStatus,
      this.startedAt,
      this.finishedAt,
      this.tags,
      required this.updatedAt,
      this.deletedAt,
      this.soldAt,
      this.sellPriceCents,
      this.soldTo,
      this.locationId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || anchorType != null) {
      map['anchor_type'] = Variable<String>(anchorType);
    }
    if (!nullToAbsent || editionId != null) {
      map['edition_id'] = Variable<String>(editionId);
    }
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    if (!nullToAbsent || bundleReleaseId != null) {
      map['bundle_release_id'] = Variable<String>(bundleReleaseId);
    }
    if (!nullToAbsent || condition != null) {
      map['condition'] = Variable<String>(condition);
    }
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<String>(grade);
    }
    if (!nullToAbsent || purchaseDate != null) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate);
    }
    if (!nullToAbsent || pricePaidCents != null) {
      map['price_paid_cents'] = Variable<int>(pricePaidCents);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    if (!nullToAbsent || personalNotes != null) {
      map['personal_notes'] = Variable<String>(personalNotes);
    }
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || storageBox != null) {
      map['storage_box'] = Variable<String>(storageBox);
    }
    if (!nullToAbsent || indexNumber != null) {
      map['index_number'] = Variable<int>(indexNumber);
    }
    if (!nullToAbsent || coverPriceCents != null) {
      map['cover_price_cents'] = Variable<int>(coverPriceCents);
    }
    if (!nullToAbsent || rawOrSlabbed != null) {
      map['raw_or_slabbed'] = Variable<String>(rawOrSlabbed);
    }
    if (!nullToAbsent || gradingCompany != null) {
      map['grading_company'] = Variable<String>(gradingCompany);
    }
    if (!nullToAbsent || graderNotes != null) {
      map['grader_notes'] = Variable<String>(graderNotes);
    }
    if (!nullToAbsent || signedBy != null) {
      map['signed_by'] = Variable<String>(signedBy);
    }
    map['key_comic'] = Variable<bool>(keyComic);
    if (!nullToAbsent || keyReason != null) {
      map['key_reason'] = Variable<String>(keyReason);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    if (!nullToAbsent || readStatus != null) {
      map['read_status'] = Variable<String>(readStatus);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || soldAt != null) {
      map['sold_at'] = Variable<DateTime>(soldAt);
    }
    if (!nullToAbsent || sellPriceCents != null) {
      map['sell_price_cents'] = Variable<int>(sellPriceCents);
    }
    if (!nullToAbsent || soldTo != null) {
      map['sold_to'] = Variable<String>(soldTo);
    }
    if (!nullToAbsent || locationId != null) {
      map['location_id'] = Variable<String>(locationId);
    }
    return map;
  }

  OwnedItemsCacheCompanion toCompanion(bool nullToAbsent) {
    return OwnedItemsCacheCompanion(
      id: Value(id),
      itemId: Value(itemId),
      anchorType: anchorType == null && nullToAbsent
          ? const Value.absent()
          : Value(anchorType),
      editionId: editionId == null && nullToAbsent
          ? const Value.absent()
          : Value(editionId),
      variantId: variantId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantId),
      bundleReleaseId: bundleReleaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(bundleReleaseId),
      condition: condition == null && nullToAbsent
          ? const Value.absent()
          : Value(condition),
      grade:
          grade == null && nullToAbsent ? const Value.absent() : Value(grade),
      purchaseDate: purchaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseDate),
      pricePaidCents: pricePaidCents == null && nullToAbsent
          ? const Value.absent()
          : Value(pricePaidCents),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      personalNotes: personalNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(personalNotes),
      quantity: Value(quantity),
      storageBox: storageBox == null && nullToAbsent
          ? const Value.absent()
          : Value(storageBox),
      indexNumber: indexNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(indexNumber),
      coverPriceCents: coverPriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPriceCents),
      rawOrSlabbed: rawOrSlabbed == null && nullToAbsent
          ? const Value.absent()
          : Value(rawOrSlabbed),
      gradingCompany: gradingCompany == null && nullToAbsent
          ? const Value.absent()
          : Value(gradingCompany),
      graderNotes: graderNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(graderNotes),
      signedBy: signedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(signedBy),
      keyComic: Value(keyComic),
      keyReason: keyReason == null && nullToAbsent
          ? const Value.absent()
          : Value(keyReason),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
      readStatus: readStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(readStatus),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      soldAt:
          soldAt == null && nullToAbsent ? const Value.absent() : Value(soldAt),
      sellPriceCents: sellPriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(sellPriceCents),
      soldTo:
          soldTo == null && nullToAbsent ? const Value.absent() : Value(soldTo),
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
    );
  }

  factory OwnedItemsCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OwnedItemsCacheData(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      anchorType: serializer.fromJson<String?>(json['anchorType']),
      editionId: serializer.fromJson<String?>(json['editionId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      bundleReleaseId: serializer.fromJson<String?>(json['bundleReleaseId']),
      condition: serializer.fromJson<String?>(json['condition']),
      grade: serializer.fromJson<String?>(json['grade']),
      purchaseDate: serializer.fromJson<DateTime?>(json['purchaseDate']),
      pricePaidCents: serializer.fromJson<int?>(json['pricePaidCents']),
      currency: serializer.fromJson<String?>(json['currency']),
      personalNotes: serializer.fromJson<String?>(json['personalNotes']),
      quantity: serializer.fromJson<int>(json['quantity']),
      storageBox: serializer.fromJson<String?>(json['storageBox']),
      indexNumber: serializer.fromJson<int?>(json['indexNumber']),
      coverPriceCents: serializer.fromJson<int?>(json['coverPriceCents']),
      rawOrSlabbed: serializer.fromJson<String?>(json['rawOrSlabbed']),
      gradingCompany: serializer.fromJson<String?>(json['gradingCompany']),
      graderNotes: serializer.fromJson<String?>(json['graderNotes']),
      signedBy: serializer.fromJson<String?>(json['signedBy']),
      keyComic: serializer.fromJson<bool>(json['keyComic']),
      keyReason: serializer.fromJson<String?>(json['keyReason']),
      rating: serializer.fromJson<int?>(json['rating']),
      readStatus: serializer.fromJson<String?>(json['readStatus']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      tags: serializer.fromJson<String?>(json['tags']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      soldAt: serializer.fromJson<DateTime?>(json['soldAt']),
      sellPriceCents: serializer.fromJson<int?>(json['sellPriceCents']),
      soldTo: serializer.fromJson<String?>(json['soldTo']),
      locationId: serializer.fromJson<String?>(json['locationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'anchorType': serializer.toJson<String?>(anchorType),
      'editionId': serializer.toJson<String?>(editionId),
      'variantId': serializer.toJson<String?>(variantId),
      'bundleReleaseId': serializer.toJson<String?>(bundleReleaseId),
      'condition': serializer.toJson<String?>(condition),
      'grade': serializer.toJson<String?>(grade),
      'purchaseDate': serializer.toJson<DateTime?>(purchaseDate),
      'pricePaidCents': serializer.toJson<int?>(pricePaidCents),
      'currency': serializer.toJson<String?>(currency),
      'personalNotes': serializer.toJson<String?>(personalNotes),
      'quantity': serializer.toJson<int>(quantity),
      'storageBox': serializer.toJson<String?>(storageBox),
      'indexNumber': serializer.toJson<int?>(indexNumber),
      'coverPriceCents': serializer.toJson<int?>(coverPriceCents),
      'rawOrSlabbed': serializer.toJson<String?>(rawOrSlabbed),
      'gradingCompany': serializer.toJson<String?>(gradingCompany),
      'graderNotes': serializer.toJson<String?>(graderNotes),
      'signedBy': serializer.toJson<String?>(signedBy),
      'keyComic': serializer.toJson<bool>(keyComic),
      'keyReason': serializer.toJson<String?>(keyReason),
      'rating': serializer.toJson<int?>(rating),
      'readStatus': serializer.toJson<String?>(readStatus),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'tags': serializer.toJson<String?>(tags),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'soldAt': serializer.toJson<DateTime?>(soldAt),
      'sellPriceCents': serializer.toJson<int?>(sellPriceCents),
      'soldTo': serializer.toJson<String?>(soldTo),
      'locationId': serializer.toJson<String?>(locationId),
    };
  }

  OwnedItemsCacheData copyWith(
          {String? id,
          String? itemId,
          Value<String?> anchorType = const Value.absent(),
          Value<String?> editionId = const Value.absent(),
          Value<String?> variantId = const Value.absent(),
          Value<String?> bundleReleaseId = const Value.absent(),
          Value<String?> condition = const Value.absent(),
          Value<String?> grade = const Value.absent(),
          Value<DateTime?> purchaseDate = const Value.absent(),
          Value<int?> pricePaidCents = const Value.absent(),
          Value<String?> currency = const Value.absent(),
          Value<String?> personalNotes = const Value.absent(),
          int? quantity,
          Value<String?> storageBox = const Value.absent(),
          Value<int?> indexNumber = const Value.absent(),
          Value<int?> coverPriceCents = const Value.absent(),
          Value<String?> rawOrSlabbed = const Value.absent(),
          Value<String?> gradingCompany = const Value.absent(),
          Value<String?> graderNotes = const Value.absent(),
          Value<String?> signedBy = const Value.absent(),
          bool? keyComic,
          Value<String?> keyReason = const Value.absent(),
          Value<int?> rating = const Value.absent(),
          Value<String?> readStatus = const Value.absent(),
          Value<DateTime?> startedAt = const Value.absent(),
          Value<DateTime?> finishedAt = const Value.absent(),
          Value<String?> tags = const Value.absent(),
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<DateTime?> soldAt = const Value.absent(),
          Value<int?> sellPriceCents = const Value.absent(),
          Value<String?> soldTo = const Value.absent(),
          Value<String?> locationId = const Value.absent()}) =>
      OwnedItemsCacheData(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        anchorType: anchorType.present ? anchorType.value : this.anchorType,
        editionId: editionId.present ? editionId.value : this.editionId,
        variantId: variantId.present ? variantId.value : this.variantId,
        bundleReleaseId: bundleReleaseId.present
            ? bundleReleaseId.value
            : this.bundleReleaseId,
        condition: condition.present ? condition.value : this.condition,
        grade: grade.present ? grade.value : this.grade,
        purchaseDate:
            purchaseDate.present ? purchaseDate.value : this.purchaseDate,
        pricePaidCents:
            pricePaidCents.present ? pricePaidCents.value : this.pricePaidCents,
        currency: currency.present ? currency.value : this.currency,
        personalNotes:
            personalNotes.present ? personalNotes.value : this.personalNotes,
        quantity: quantity ?? this.quantity,
        storageBox: storageBox.present ? storageBox.value : this.storageBox,
        indexNumber: indexNumber.present ? indexNumber.value : this.indexNumber,
        coverPriceCents: coverPriceCents.present
            ? coverPriceCents.value
            : this.coverPriceCents,
        rawOrSlabbed:
            rawOrSlabbed.present ? rawOrSlabbed.value : this.rawOrSlabbed,
        gradingCompany:
            gradingCompany.present ? gradingCompany.value : this.gradingCompany,
        graderNotes: graderNotes.present ? graderNotes.value : this.graderNotes,
        signedBy: signedBy.present ? signedBy.value : this.signedBy,
        keyComic: keyComic ?? this.keyComic,
        keyReason: keyReason.present ? keyReason.value : this.keyReason,
        rating: rating.present ? rating.value : this.rating,
        readStatus: readStatus.present ? readStatus.value : this.readStatus,
        startedAt: startedAt.present ? startedAt.value : this.startedAt,
        finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
        tags: tags.present ? tags.value : this.tags,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        soldAt: soldAt.present ? soldAt.value : this.soldAt,
        sellPriceCents:
            sellPriceCents.present ? sellPriceCents.value : this.sellPriceCents,
        soldTo: soldTo.present ? soldTo.value : this.soldTo,
        locationId: locationId.present ? locationId.value : this.locationId,
      );
  OwnedItemsCacheData copyWithCompanion(OwnedItemsCacheCompanion data) {
    return OwnedItemsCacheData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      anchorType:
          data.anchorType.present ? data.anchorType.value : this.anchorType,
      editionId: data.editionId.present ? data.editionId.value : this.editionId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      bundleReleaseId: data.bundleReleaseId.present
          ? data.bundleReleaseId.value
          : this.bundleReleaseId,
      condition: data.condition.present ? data.condition.value : this.condition,
      grade: data.grade.present ? data.grade.value : this.grade,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      pricePaidCents: data.pricePaidCents.present
          ? data.pricePaidCents.value
          : this.pricePaidCents,
      currency: data.currency.present ? data.currency.value : this.currency,
      personalNotes: data.personalNotes.present
          ? data.personalNotes.value
          : this.personalNotes,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      storageBox:
          data.storageBox.present ? data.storageBox.value : this.storageBox,
      indexNumber:
          data.indexNumber.present ? data.indexNumber.value : this.indexNumber,
      coverPriceCents: data.coverPriceCents.present
          ? data.coverPriceCents.value
          : this.coverPriceCents,
      rawOrSlabbed: data.rawOrSlabbed.present
          ? data.rawOrSlabbed.value
          : this.rawOrSlabbed,
      gradingCompany: data.gradingCompany.present
          ? data.gradingCompany.value
          : this.gradingCompany,
      graderNotes:
          data.graderNotes.present ? data.graderNotes.value : this.graderNotes,
      signedBy: data.signedBy.present ? data.signedBy.value : this.signedBy,
      keyComic: data.keyComic.present ? data.keyComic.value : this.keyComic,
      keyReason: data.keyReason.present ? data.keyReason.value : this.keyReason,
      rating: data.rating.present ? data.rating.value : this.rating,
      readStatus:
          data.readStatus.present ? data.readStatus.value : this.readStatus,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt:
          data.finishedAt.present ? data.finishedAt.value : this.finishedAt,
      tags: data.tags.present ? data.tags.value : this.tags,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      soldAt: data.soldAt.present ? data.soldAt.value : this.soldAt,
      sellPriceCents: data.sellPriceCents.present
          ? data.sellPriceCents.value
          : this.sellPriceCents,
      soldTo: data.soldTo.present ? data.soldTo.value : this.soldTo,
      locationId:
          data.locationId.present ? data.locationId.value : this.locationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OwnedItemsCacheData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('anchorType: $anchorType, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('bundleReleaseId: $bundleReleaseId, ')
          ..write('condition: $condition, ')
          ..write('grade: $grade, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('pricePaidCents: $pricePaidCents, ')
          ..write('currency: $currency, ')
          ..write('personalNotes: $personalNotes, ')
          ..write('quantity: $quantity, ')
          ..write('storageBox: $storageBox, ')
          ..write('indexNumber: $indexNumber, ')
          ..write('coverPriceCents: $coverPriceCents, ')
          ..write('rawOrSlabbed: $rawOrSlabbed, ')
          ..write('gradingCompany: $gradingCompany, ')
          ..write('graderNotes: $graderNotes, ')
          ..write('signedBy: $signedBy, ')
          ..write('keyComic: $keyComic, ')
          ..write('keyReason: $keyReason, ')
          ..write('rating: $rating, ')
          ..write('readStatus: $readStatus, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('tags: $tags, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('soldAt: $soldAt, ')
          ..write('sellPriceCents: $sellPriceCents, ')
          ..write('soldTo: $soldTo, ')
          ..write('locationId: $locationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        itemId,
        anchorType,
        editionId,
        variantId,
        bundleReleaseId,
        condition,
        grade,
        purchaseDate,
        pricePaidCents,
        currency,
        personalNotes,
        quantity,
        storageBox,
        indexNumber,
        coverPriceCents,
        rawOrSlabbed,
        gradingCompany,
        graderNotes,
        signedBy,
        keyComic,
        keyReason,
        rating,
        readStatus,
        startedAt,
        finishedAt,
        tags,
        updatedAt,
        deletedAt,
        soldAt,
        sellPriceCents,
        soldTo,
        locationId
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OwnedItemsCacheData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.anchorType == this.anchorType &&
          other.editionId == this.editionId &&
          other.variantId == this.variantId &&
          other.bundleReleaseId == this.bundleReleaseId &&
          other.condition == this.condition &&
          other.grade == this.grade &&
          other.purchaseDate == this.purchaseDate &&
          other.pricePaidCents == this.pricePaidCents &&
          other.currency == this.currency &&
          other.personalNotes == this.personalNotes &&
          other.quantity == this.quantity &&
          other.storageBox == this.storageBox &&
          other.indexNumber == this.indexNumber &&
          other.coverPriceCents == this.coverPriceCents &&
          other.rawOrSlabbed == this.rawOrSlabbed &&
          other.gradingCompany == this.gradingCompany &&
          other.graderNotes == this.graderNotes &&
          other.signedBy == this.signedBy &&
          other.keyComic == this.keyComic &&
          other.keyReason == this.keyReason &&
          other.rating == this.rating &&
          other.readStatus == this.readStatus &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.tags == this.tags &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.soldAt == this.soldAt &&
          other.sellPriceCents == this.sellPriceCents &&
          other.soldTo == this.soldTo &&
          other.locationId == this.locationId);
}

class OwnedItemsCacheCompanion extends UpdateCompanion<OwnedItemsCacheData> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String?> anchorType;
  final Value<String?> editionId;
  final Value<String?> variantId;
  final Value<String?> bundleReleaseId;
  final Value<String?> condition;
  final Value<String?> grade;
  final Value<DateTime?> purchaseDate;
  final Value<int?> pricePaidCents;
  final Value<String?> currency;
  final Value<String?> personalNotes;
  final Value<int> quantity;
  final Value<String?> storageBox;
  final Value<int?> indexNumber;
  final Value<int?> coverPriceCents;
  final Value<String?> rawOrSlabbed;
  final Value<String?> gradingCompany;
  final Value<String?> graderNotes;
  final Value<String?> signedBy;
  final Value<bool> keyComic;
  final Value<String?> keyReason;
  final Value<int?> rating;
  final Value<String?> readStatus;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<String?> tags;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> soldAt;
  final Value<int?> sellPriceCents;
  final Value<String?> soldTo;
  final Value<String?> locationId;
  final Value<int> rowid;
  const OwnedItemsCacheCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.anchorType = const Value.absent(),
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.bundleReleaseId = const Value.absent(),
    this.condition = const Value.absent(),
    this.grade = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.pricePaidCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.personalNotes = const Value.absent(),
    this.quantity = const Value.absent(),
    this.storageBox = const Value.absent(),
    this.indexNumber = const Value.absent(),
    this.coverPriceCents = const Value.absent(),
    this.rawOrSlabbed = const Value.absent(),
    this.gradingCompany = const Value.absent(),
    this.graderNotes = const Value.absent(),
    this.signedBy = const Value.absent(),
    this.keyComic = const Value.absent(),
    this.keyReason = const Value.absent(),
    this.rating = const Value.absent(),
    this.readStatus = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.tags = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.soldAt = const Value.absent(),
    this.sellPriceCents = const Value.absent(),
    this.soldTo = const Value.absent(),
    this.locationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OwnedItemsCacheCompanion.insert({
    required String id,
    required String itemId,
    this.anchorType = const Value.absent(),
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.bundleReleaseId = const Value.absent(),
    this.condition = const Value.absent(),
    this.grade = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.pricePaidCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.personalNotes = const Value.absent(),
    this.quantity = const Value.absent(),
    this.storageBox = const Value.absent(),
    this.indexNumber = const Value.absent(),
    this.coverPriceCents = const Value.absent(),
    this.rawOrSlabbed = const Value.absent(),
    this.gradingCompany = const Value.absent(),
    this.graderNotes = const Value.absent(),
    this.signedBy = const Value.absent(),
    this.keyComic = const Value.absent(),
    this.keyReason = const Value.absent(),
    this.rating = const Value.absent(),
    this.readStatus = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.tags = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.soldAt = const Value.absent(),
    this.sellPriceCents = const Value.absent(),
    this.soldTo = const Value.absent(),
    this.locationId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        updatedAt = Value(updatedAt);
  static Insertable<OwnedItemsCacheData> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? anchorType,
    Expression<String>? editionId,
    Expression<String>? variantId,
    Expression<String>? bundleReleaseId,
    Expression<String>? condition,
    Expression<String>? grade,
    Expression<DateTime>? purchaseDate,
    Expression<int>? pricePaidCents,
    Expression<String>? currency,
    Expression<String>? personalNotes,
    Expression<int>? quantity,
    Expression<String>? storageBox,
    Expression<int>? indexNumber,
    Expression<int>? coverPriceCents,
    Expression<String>? rawOrSlabbed,
    Expression<String>? gradingCompany,
    Expression<String>? graderNotes,
    Expression<String>? signedBy,
    Expression<bool>? keyComic,
    Expression<String>? keyReason,
    Expression<int>? rating,
    Expression<String>? readStatus,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<String>? tags,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? soldAt,
    Expression<int>? sellPriceCents,
    Expression<String>? soldTo,
    Expression<String>? locationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (anchorType != null) 'anchor_type': anchorType,
      if (editionId != null) 'edition_id': editionId,
      if (variantId != null) 'variant_id': variantId,
      if (bundleReleaseId != null) 'bundle_release_id': bundleReleaseId,
      if (condition != null) 'condition': condition,
      if (grade != null) 'grade': grade,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (pricePaidCents != null) 'price_paid_cents': pricePaidCents,
      if (currency != null) 'currency': currency,
      if (personalNotes != null) 'personal_notes': personalNotes,
      if (quantity != null) 'quantity': quantity,
      if (storageBox != null) 'storage_box': storageBox,
      if (indexNumber != null) 'index_number': indexNumber,
      if (coverPriceCents != null) 'cover_price_cents': coverPriceCents,
      if (rawOrSlabbed != null) 'raw_or_slabbed': rawOrSlabbed,
      if (gradingCompany != null) 'grading_company': gradingCompany,
      if (graderNotes != null) 'grader_notes': graderNotes,
      if (signedBy != null) 'signed_by': signedBy,
      if (keyComic != null) 'key_comic': keyComic,
      if (keyReason != null) 'key_reason': keyReason,
      if (rating != null) 'rating': rating,
      if (readStatus != null) 'read_status': readStatus,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (tags != null) 'tags': tags,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (soldAt != null) 'sold_at': soldAt,
      if (sellPriceCents != null) 'sell_price_cents': sellPriceCents,
      if (soldTo != null) 'sold_to': soldTo,
      if (locationId != null) 'location_id': locationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OwnedItemsCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<String?>? anchorType,
      Value<String?>? editionId,
      Value<String?>? variantId,
      Value<String?>? bundleReleaseId,
      Value<String?>? condition,
      Value<String?>? grade,
      Value<DateTime?>? purchaseDate,
      Value<int?>? pricePaidCents,
      Value<String?>? currency,
      Value<String?>? personalNotes,
      Value<int>? quantity,
      Value<String?>? storageBox,
      Value<int?>? indexNumber,
      Value<int?>? coverPriceCents,
      Value<String?>? rawOrSlabbed,
      Value<String?>? gradingCompany,
      Value<String?>? graderNotes,
      Value<String?>? signedBy,
      Value<bool>? keyComic,
      Value<String?>? keyReason,
      Value<int?>? rating,
      Value<String?>? readStatus,
      Value<DateTime?>? startedAt,
      Value<DateTime?>? finishedAt,
      Value<String?>? tags,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<DateTime?>? soldAt,
      Value<int?>? sellPriceCents,
      Value<String?>? soldTo,
      Value<String?>? locationId,
      Value<int>? rowid}) {
    return OwnedItemsCacheCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      anchorType: anchorType ?? this.anchorType,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
      condition: condition ?? this.condition,
      grade: grade ?? this.grade,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      pricePaidCents: pricePaidCents ?? this.pricePaidCents,
      currency: currency ?? this.currency,
      personalNotes: personalNotes ?? this.personalNotes,
      quantity: quantity ?? this.quantity,
      storageBox: storageBox ?? this.storageBox,
      indexNumber: indexNumber ?? this.indexNumber,
      coverPriceCents: coverPriceCents ?? this.coverPriceCents,
      rawOrSlabbed: rawOrSlabbed ?? this.rawOrSlabbed,
      gradingCompany: gradingCompany ?? this.gradingCompany,
      graderNotes: graderNotes ?? this.graderNotes,
      signedBy: signedBy ?? this.signedBy,
      keyComic: keyComic ?? this.keyComic,
      keyReason: keyReason ?? this.keyReason,
      rating: rating ?? this.rating,
      readStatus: readStatus ?? this.readStatus,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      tags: tags ?? this.tags,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      soldAt: soldAt ?? this.soldAt,
      sellPriceCents: sellPriceCents ?? this.sellPriceCents,
      soldTo: soldTo ?? this.soldTo,
      locationId: locationId ?? this.locationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (anchorType.present) {
      map['anchor_type'] = Variable<String>(anchorType.value);
    }
    if (editionId.present) {
      map['edition_id'] = Variable<String>(editionId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (bundleReleaseId.present) {
      map['bundle_release_id'] = Variable<String>(bundleReleaseId.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (pricePaidCents.present) {
      map['price_paid_cents'] = Variable<int>(pricePaidCents.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (personalNotes.present) {
      map['personal_notes'] = Variable<String>(personalNotes.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (storageBox.present) {
      map['storage_box'] = Variable<String>(storageBox.value);
    }
    if (indexNumber.present) {
      map['index_number'] = Variable<int>(indexNumber.value);
    }
    if (coverPriceCents.present) {
      map['cover_price_cents'] = Variable<int>(coverPriceCents.value);
    }
    if (rawOrSlabbed.present) {
      map['raw_or_slabbed'] = Variable<String>(rawOrSlabbed.value);
    }
    if (gradingCompany.present) {
      map['grading_company'] = Variable<String>(gradingCompany.value);
    }
    if (graderNotes.present) {
      map['grader_notes'] = Variable<String>(graderNotes.value);
    }
    if (signedBy.present) {
      map['signed_by'] = Variable<String>(signedBy.value);
    }
    if (keyComic.present) {
      map['key_comic'] = Variable<bool>(keyComic.value);
    }
    if (keyReason.present) {
      map['key_reason'] = Variable<String>(keyReason.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (readStatus.present) {
      map['read_status'] = Variable<String>(readStatus.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (soldAt.present) {
      map['sold_at'] = Variable<DateTime>(soldAt.value);
    }
    if (sellPriceCents.present) {
      map['sell_price_cents'] = Variable<int>(sellPriceCents.value);
    }
    if (soldTo.present) {
      map['sold_to'] = Variable<String>(soldTo.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OwnedItemsCacheCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('anchorType: $anchorType, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('bundleReleaseId: $bundleReleaseId, ')
          ..write('condition: $condition, ')
          ..write('grade: $grade, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('pricePaidCents: $pricePaidCents, ')
          ..write('currency: $currency, ')
          ..write('personalNotes: $personalNotes, ')
          ..write('quantity: $quantity, ')
          ..write('storageBox: $storageBox, ')
          ..write('indexNumber: $indexNumber, ')
          ..write('coverPriceCents: $coverPriceCents, ')
          ..write('rawOrSlabbed: $rawOrSlabbed, ')
          ..write('gradingCompany: $gradingCompany, ')
          ..write('graderNotes: $graderNotes, ')
          ..write('signedBy: $signedBy, ')
          ..write('keyComic: $keyComic, ')
          ..write('keyReason: $keyReason, ')
          ..write('rating: $rating, ')
          ..write('readStatus: $readStatus, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('tags: $tags, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('soldAt: $soldAt, ')
          ..write('sellPriceCents: $sellPriceCents, ')
          ..write('soldTo: $soldTo, ')
          ..write('locationId: $locationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WishlistItemsCacheTable extends WishlistItemsCache
    with TableInfo<$WishlistItemsCacheTable, WishlistItemsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WishlistItemsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _anchorTypeMeta =
      const VerificationMeta('anchorType');
  @override
  late final GeneratedColumn<String> anchorType = GeneratedColumn<String>(
      'anchor_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _editionIdMeta =
      const VerificationMeta('editionId');
  @override
  late final GeneratedColumn<String> editionId = GeneratedColumn<String>(
      'edition_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
      'variant_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bundleReleaseIdMeta =
      const VerificationMeta('bundleReleaseId');
  @override
  late final GeneratedColumn<String> bundleReleaseId = GeneratedColumn<String>(
      'bundle_release_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _targetPriceCentsMeta =
      const VerificationMeta('targetPriceCents');
  @override
  late final GeneratedColumn<int> targetPriceCents = GeneratedColumn<int>(
      'target_price_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        itemId,
        anchorType,
        editionId,
        variantId,
        bundleReleaseId,
        targetPriceCents,
        currency,
        notes,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wishlist_items_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<WishlistItemsCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('anchor_type')) {
      context.handle(
          _anchorTypeMeta,
          anchorType.isAcceptableOrUnknown(
              data['anchor_type']!, _anchorTypeMeta));
    }
    if (data.containsKey('edition_id')) {
      context.handle(_editionIdMeta,
          editionId.isAcceptableOrUnknown(data['edition_id']!, _editionIdMeta));
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    }
    if (data.containsKey('bundle_release_id')) {
      context.handle(
          _bundleReleaseIdMeta,
          bundleReleaseId.isAcceptableOrUnknown(
              data['bundle_release_id']!, _bundleReleaseIdMeta));
    }
    if (data.containsKey('target_price_cents')) {
      context.handle(
          _targetPriceCentsMeta,
          targetPriceCents.isAcceptableOrUnknown(
              data['target_price_cents']!, _targetPriceCentsMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WishlistItemsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WishlistItemsCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      anchorType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}anchor_type']),
      editionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edition_id']),
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id']),
      bundleReleaseId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}bundle_release_id']),
      targetPriceCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_price_cents']),
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $WishlistItemsCacheTable createAlias(String alias) {
    return $WishlistItemsCacheTable(attachedDatabase, alias);
  }
}

class WishlistItemsCacheData extends DataClass
    implements Insertable<WishlistItemsCacheData> {
  final String id;
  final String itemId;
  final String? anchorType;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
  final int? targetPriceCents;
  final String? currency;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const WishlistItemsCacheData(
      {required this.id,
      required this.itemId,
      this.anchorType,
      this.editionId,
      this.variantId,
      this.bundleReleaseId,
      this.targetPriceCents,
      this.currency,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || anchorType != null) {
      map['anchor_type'] = Variable<String>(anchorType);
    }
    if (!nullToAbsent || editionId != null) {
      map['edition_id'] = Variable<String>(editionId);
    }
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    if (!nullToAbsent || bundleReleaseId != null) {
      map['bundle_release_id'] = Variable<String>(bundleReleaseId);
    }
    if (!nullToAbsent || targetPriceCents != null) {
      map['target_price_cents'] = Variable<int>(targetPriceCents);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  WishlistItemsCacheCompanion toCompanion(bool nullToAbsent) {
    return WishlistItemsCacheCompanion(
      id: Value(id),
      itemId: Value(itemId),
      anchorType: anchorType == null && nullToAbsent
          ? const Value.absent()
          : Value(anchorType),
      editionId: editionId == null && nullToAbsent
          ? const Value.absent()
          : Value(editionId),
      variantId: variantId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantId),
      bundleReleaseId: bundleReleaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(bundleReleaseId),
      targetPriceCents: targetPriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(targetPriceCents),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory WishlistItemsCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WishlistItemsCacheData(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      anchorType: serializer.fromJson<String?>(json['anchorType']),
      editionId: serializer.fromJson<String?>(json['editionId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      bundleReleaseId: serializer.fromJson<String?>(json['bundleReleaseId']),
      targetPriceCents: serializer.fromJson<int?>(json['targetPriceCents']),
      currency: serializer.fromJson<String?>(json['currency']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'anchorType': serializer.toJson<String?>(anchorType),
      'editionId': serializer.toJson<String?>(editionId),
      'variantId': serializer.toJson<String?>(variantId),
      'bundleReleaseId': serializer.toJson<String?>(bundleReleaseId),
      'targetPriceCents': serializer.toJson<int?>(targetPriceCents),
      'currency': serializer.toJson<String?>(currency),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  WishlistItemsCacheData copyWith(
          {String? id,
          String? itemId,
          Value<String?> anchorType = const Value.absent(),
          Value<String?> editionId = const Value.absent(),
          Value<String?> variantId = const Value.absent(),
          Value<String?> bundleReleaseId = const Value.absent(),
          Value<int?> targetPriceCents = const Value.absent(),
          Value<String?> currency = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      WishlistItemsCacheData(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        anchorType: anchorType.present ? anchorType.value : this.anchorType,
        editionId: editionId.present ? editionId.value : this.editionId,
        variantId: variantId.present ? variantId.value : this.variantId,
        bundleReleaseId: bundleReleaseId.present
            ? bundleReleaseId.value
            : this.bundleReleaseId,
        targetPriceCents: targetPriceCents.present
            ? targetPriceCents.value
            : this.targetPriceCents,
        currency: currency.present ? currency.value : this.currency,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  WishlistItemsCacheData copyWithCompanion(WishlistItemsCacheCompanion data) {
    return WishlistItemsCacheData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      anchorType:
          data.anchorType.present ? data.anchorType.value : this.anchorType,
      editionId: data.editionId.present ? data.editionId.value : this.editionId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      bundleReleaseId: data.bundleReleaseId.present
          ? data.bundleReleaseId.value
          : this.bundleReleaseId,
      targetPriceCents: data.targetPriceCents.present
          ? data.targetPriceCents.value
          : this.targetPriceCents,
      currency: data.currency.present ? data.currency.value : this.currency,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WishlistItemsCacheData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('anchorType: $anchorType, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('bundleReleaseId: $bundleReleaseId, ')
          ..write('targetPriceCents: $targetPriceCents, ')
          ..write('currency: $currency, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      itemId,
      anchorType,
      editionId,
      variantId,
      bundleReleaseId,
      targetPriceCents,
      currency,
      notes,
      createdAt,
      updatedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WishlistItemsCacheData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.anchorType == this.anchorType &&
          other.editionId == this.editionId &&
          other.variantId == this.variantId &&
          other.bundleReleaseId == this.bundleReleaseId &&
          other.targetPriceCents == this.targetPriceCents &&
          other.currency == this.currency &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class WishlistItemsCacheCompanion
    extends UpdateCompanion<WishlistItemsCacheData> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String?> anchorType;
  final Value<String?> editionId;
  final Value<String?> variantId;
  final Value<String?> bundleReleaseId;
  final Value<int?> targetPriceCents;
  final Value<String?> currency;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const WishlistItemsCacheCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.anchorType = const Value.absent(),
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.bundleReleaseId = const Value.absent(),
    this.targetPriceCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WishlistItemsCacheCompanion.insert({
    required String id,
    required String itemId,
    this.anchorType = const Value.absent(),
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.bundleReleaseId = const Value.absent(),
    this.targetPriceCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<WishlistItemsCacheData> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? anchorType,
    Expression<String>? editionId,
    Expression<String>? variantId,
    Expression<String>? bundleReleaseId,
    Expression<int>? targetPriceCents,
    Expression<String>? currency,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (anchorType != null) 'anchor_type': anchorType,
      if (editionId != null) 'edition_id': editionId,
      if (variantId != null) 'variant_id': variantId,
      if (bundleReleaseId != null) 'bundle_release_id': bundleReleaseId,
      if (targetPriceCents != null) 'target_price_cents': targetPriceCents,
      if (currency != null) 'currency': currency,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WishlistItemsCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<String?>? anchorType,
      Value<String?>? editionId,
      Value<String?>? variantId,
      Value<String?>? bundleReleaseId,
      Value<int?>? targetPriceCents,
      Value<String?>? currency,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return WishlistItemsCacheCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      anchorType: anchorType ?? this.anchorType,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
      targetPriceCents: targetPriceCents ?? this.targetPriceCents,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (anchorType.present) {
      map['anchor_type'] = Variable<String>(anchorType.value);
    }
    if (editionId.present) {
      map['edition_id'] = Variable<String>(editionId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (bundleReleaseId.present) {
      map['bundle_release_id'] = Variable<String>(bundleReleaseId.value);
    }
    if (targetPriceCents.present) {
      map['target_price_cents'] = Variable<int>(targetPriceCents.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WishlistItemsCacheCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('anchorType: $anchorType, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('bundleReleaseId: $bundleReleaseId, ')
          ..write('targetPriceCents: $targetPriceCents, ')
          ..write('currency: $currency, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackingEntriesCacheTable extends TrackingEntriesCache
    with TableInfo<$TrackingEntriesCacheTable, TrackingEntriesCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackingEntriesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownedItemIdMeta =
      const VerificationMeta('ownedItemId');
  @override
  late final GeneratedColumn<String> ownedItemId = GeneratedColumn<String>(
      'owned_item_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _editionIdMeta =
      const VerificationMeta('editionId');
  @override
  late final GeneratedColumn<String> editionId = GeneratedColumn<String>(
      'edition_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
      'variant_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
      'rating', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _finishedAtMeta =
      const VerificationMeta('finishedAt');
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
      'finished_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _progressCurrentMeta =
      const VerificationMeta('progressCurrent');
  @override
  late final GeneratedColumn<int> progressCurrent = GeneratedColumn<int>(
      'progress_current', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _progressTotalMeta =
      const VerificationMeta('progressTotal');
  @override
  late final GeneratedColumn<int> progressTotal = GeneratedColumn<int>(
      'progress_total', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _timesCompletedMeta =
      const VerificationMeta('timesCompleted');
  @override
  late final GeneratedColumn<int> timesCompleted = GeneratedColumn<int>(
      'times_completed', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _seasonNumberMeta =
      const VerificationMeta('seasonNumber');
  @override
  late final GeneratedColumn<int> seasonNumber = GeneratedColumn<int>(
      'season_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _episodeNumberMeta =
      const VerificationMeta('episodeNumber');
  @override
  late final GeneratedColumn<int> episodeNumber = GeneratedColumn<int>(
      'episode_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        itemId,
        ownedItemId,
        editionId,
        variantId,
        sourceType,
        status,
        rating,
        startedAt,
        finishedAt,
        progressCurrent,
        progressTotal,
        timesCompleted,
        notes,
        seasonNumber,
        episodeNumber,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracking_entries_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<TrackingEntriesCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('owned_item_id')) {
      context.handle(
          _ownedItemIdMeta,
          ownedItemId.isAcceptableOrUnknown(
              data['owned_item_id']!, _ownedItemIdMeta));
    }
    if (data.containsKey('edition_id')) {
      context.handle(_editionIdMeta,
          editionId.isAcceptableOrUnknown(data['edition_id']!, _editionIdMeta));
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('finished_at')) {
      context.handle(
          _finishedAtMeta,
          finishedAt.isAcceptableOrUnknown(
              data['finished_at']!, _finishedAtMeta));
    }
    if (data.containsKey('progress_current')) {
      context.handle(
          _progressCurrentMeta,
          progressCurrent.isAcceptableOrUnknown(
              data['progress_current']!, _progressCurrentMeta));
    }
    if (data.containsKey('progress_total')) {
      context.handle(
          _progressTotalMeta,
          progressTotal.isAcceptableOrUnknown(
              data['progress_total']!, _progressTotalMeta));
    }
    if (data.containsKey('times_completed')) {
      context.handle(
          _timesCompletedMeta,
          timesCompleted.isAcceptableOrUnknown(
              data['times_completed']!, _timesCompletedMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('season_number')) {
      context.handle(
          _seasonNumberMeta,
          seasonNumber.isAcceptableOrUnknown(
              data['season_number']!, _seasonNumberMeta));
    }
    if (data.containsKey('episode_number')) {
      context.handle(
          _episodeNumberMeta,
          episodeNumber.isAcceptableOrUnknown(
              data['episode_number']!, _episodeNumberMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackingEntriesCacheData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackingEntriesCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      ownedItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owned_item_id']),
      editionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edition_id']),
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant_id']),
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status']),
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rating']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at']),
      finishedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}finished_at']),
      progressCurrent: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}progress_current']),
      progressTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}progress_total']),
      timesCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}times_completed']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      seasonNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}season_number']),
      episodeNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}episode_number']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $TrackingEntriesCacheTable createAlias(String alias) {
    return $TrackingEntriesCacheTable(attachedDatabase, alias);
  }
}

class TrackingEntriesCacheData extends DataClass
    implements Insertable<TrackingEntriesCacheData> {
  final String id;
  final String itemId;
  final String? ownedItemId;
  final String? editionId;
  final String? variantId;
  final String? sourceType;
  final String? status;
  final int? rating;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int? progressCurrent;
  final int? progressTotal;
  final int? timesCompleted;
  final String? notes;
  final int? seasonNumber;
  final int? episodeNumber;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TrackingEntriesCacheData(
      {required this.id,
      required this.itemId,
      this.ownedItemId,
      this.editionId,
      this.variantId,
      this.sourceType,
      this.status,
      this.rating,
      this.startedAt,
      this.finishedAt,
      this.progressCurrent,
      this.progressTotal,
      this.timesCompleted,
      this.notes,
      this.seasonNumber,
      this.episodeNumber,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || ownedItemId != null) {
      map['owned_item_id'] = Variable<String>(ownedItemId);
    }
    if (!nullToAbsent || editionId != null) {
      map['edition_id'] = Variable<String>(editionId);
    }
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    if (!nullToAbsent || sourceType != null) {
      map['source_type'] = Variable<String>(sourceType);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    if (!nullToAbsent || progressCurrent != null) {
      map['progress_current'] = Variable<int>(progressCurrent);
    }
    if (!nullToAbsent || progressTotal != null) {
      map['progress_total'] = Variable<int>(progressTotal);
    }
    if (!nullToAbsent || timesCompleted != null) {
      map['times_completed'] = Variable<int>(timesCompleted);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || seasonNumber != null) {
      map['season_number'] = Variable<int>(seasonNumber);
    }
    if (!nullToAbsent || episodeNumber != null) {
      map['episode_number'] = Variable<int>(episodeNumber);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TrackingEntriesCacheCompanion toCompanion(bool nullToAbsent) {
    return TrackingEntriesCacheCompanion(
      id: Value(id),
      itemId: Value(itemId),
      ownedItemId: ownedItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownedItemId),
      editionId: editionId == null && nullToAbsent
          ? const Value.absent()
          : Value(editionId),
      variantId: variantId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantId),
      sourceType: sourceType == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceType),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      progressCurrent: progressCurrent == null && nullToAbsent
          ? const Value.absent()
          : Value(progressCurrent),
      progressTotal: progressTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(progressTotal),
      timesCompleted: timesCompleted == null && nullToAbsent
          ? const Value.absent()
          : Value(timesCompleted),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      seasonNumber: seasonNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonNumber),
      episodeNumber: episodeNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(episodeNumber),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TrackingEntriesCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackingEntriesCacheData(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      ownedItemId: serializer.fromJson<String?>(json['ownedItemId']),
      editionId: serializer.fromJson<String?>(json['editionId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      sourceType: serializer.fromJson<String?>(json['sourceType']),
      status: serializer.fromJson<String?>(json['status']),
      rating: serializer.fromJson<int?>(json['rating']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      progressCurrent: serializer.fromJson<int?>(json['progressCurrent']),
      progressTotal: serializer.fromJson<int?>(json['progressTotal']),
      timesCompleted: serializer.fromJson<int?>(json['timesCompleted']),
      notes: serializer.fromJson<String?>(json['notes']),
      seasonNumber: serializer.fromJson<int?>(json['seasonNumber']),
      episodeNumber: serializer.fromJson<int?>(json['episodeNumber']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'ownedItemId': serializer.toJson<String?>(ownedItemId),
      'editionId': serializer.toJson<String?>(editionId),
      'variantId': serializer.toJson<String?>(variantId),
      'sourceType': serializer.toJson<String?>(sourceType),
      'status': serializer.toJson<String?>(status),
      'rating': serializer.toJson<int?>(rating),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'progressCurrent': serializer.toJson<int?>(progressCurrent),
      'progressTotal': serializer.toJson<int?>(progressTotal),
      'timesCompleted': serializer.toJson<int?>(timesCompleted),
      'notes': serializer.toJson<String?>(notes),
      'seasonNumber': serializer.toJson<int?>(seasonNumber),
      'episodeNumber': serializer.toJson<int?>(episodeNumber),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TrackingEntriesCacheData copyWith(
          {String? id,
          String? itemId,
          Value<String?> ownedItemId = const Value.absent(),
          Value<String?> editionId = const Value.absent(),
          Value<String?> variantId = const Value.absent(),
          Value<String?> sourceType = const Value.absent(),
          Value<String?> status = const Value.absent(),
          Value<int?> rating = const Value.absent(),
          Value<DateTime?> startedAt = const Value.absent(),
          Value<DateTime?> finishedAt = const Value.absent(),
          Value<int?> progressCurrent = const Value.absent(),
          Value<int?> progressTotal = const Value.absent(),
          Value<int?> timesCompleted = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<int?> seasonNumber = const Value.absent(),
          Value<int?> episodeNumber = const Value.absent(),
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      TrackingEntriesCacheData(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        ownedItemId: ownedItemId.present ? ownedItemId.value : this.ownedItemId,
        editionId: editionId.present ? editionId.value : this.editionId,
        variantId: variantId.present ? variantId.value : this.variantId,
        sourceType: sourceType.present ? sourceType.value : this.sourceType,
        status: status.present ? status.value : this.status,
        rating: rating.present ? rating.value : this.rating,
        startedAt: startedAt.present ? startedAt.value : this.startedAt,
        finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
        progressCurrent: progressCurrent.present
            ? progressCurrent.value
            : this.progressCurrent,
        progressTotal:
            progressTotal.present ? progressTotal.value : this.progressTotal,
        timesCompleted:
            timesCompleted.present ? timesCompleted.value : this.timesCompleted,
        notes: notes.present ? notes.value : this.notes,
        seasonNumber:
            seasonNumber.present ? seasonNumber.value : this.seasonNumber,
        episodeNumber:
            episodeNumber.present ? episodeNumber.value : this.episodeNumber,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  TrackingEntriesCacheData copyWithCompanion(
      TrackingEntriesCacheCompanion data) {
    return TrackingEntriesCacheData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      ownedItemId:
          data.ownedItemId.present ? data.ownedItemId.value : this.ownedItemId,
      editionId: data.editionId.present ? data.editionId.value : this.editionId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      status: data.status.present ? data.status.value : this.status,
      rating: data.rating.present ? data.rating.value : this.rating,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt:
          data.finishedAt.present ? data.finishedAt.value : this.finishedAt,
      progressCurrent: data.progressCurrent.present
          ? data.progressCurrent.value
          : this.progressCurrent,
      progressTotal: data.progressTotal.present
          ? data.progressTotal.value
          : this.progressTotal,
      timesCompleted: data.timesCompleted.present
          ? data.timesCompleted.value
          : this.timesCompleted,
      notes: data.notes.present ? data.notes.value : this.notes,
      seasonNumber: data.seasonNumber.present
          ? data.seasonNumber.value
          : this.seasonNumber,
      episodeNumber: data.episodeNumber.present
          ? data.episodeNumber.value
          : this.episodeNumber,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackingEntriesCacheData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('sourceType: $sourceType, ')
          ..write('status: $status, ')
          ..write('rating: $rating, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('progressCurrent: $progressCurrent, ')
          ..write('progressTotal: $progressTotal, ')
          ..write('timesCompleted: $timesCompleted, ')
          ..write('notes: $notes, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      itemId,
      ownedItemId,
      editionId,
      variantId,
      sourceType,
      status,
      rating,
      startedAt,
      finishedAt,
      progressCurrent,
      progressTotal,
      timesCompleted,
      notes,
      seasonNumber,
      episodeNumber,
      updatedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackingEntriesCacheData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.ownedItemId == this.ownedItemId &&
          other.editionId == this.editionId &&
          other.variantId == this.variantId &&
          other.sourceType == this.sourceType &&
          other.status == this.status &&
          other.rating == this.rating &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.progressCurrent == this.progressCurrent &&
          other.progressTotal == this.progressTotal &&
          other.timesCompleted == this.timesCompleted &&
          other.notes == this.notes &&
          other.seasonNumber == this.seasonNumber &&
          other.episodeNumber == this.episodeNumber &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TrackingEntriesCacheCompanion
    extends UpdateCompanion<TrackingEntriesCacheData> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String?> ownedItemId;
  final Value<String?> editionId;
  final Value<String?> variantId;
  final Value<String?> sourceType;
  final Value<String?> status;
  final Value<int?> rating;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<int?> progressCurrent;
  final Value<int?> progressTotal;
  final Value<int?> timesCompleted;
  final Value<String?> notes;
  final Value<int?> seasonNumber;
  final Value<int?> episodeNumber;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TrackingEntriesCacheCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.ownedItemId = const Value.absent(),
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.status = const Value.absent(),
    this.rating = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.progressCurrent = const Value.absent(),
    this.progressTotal = const Value.absent(),
    this.timesCompleted = const Value.absent(),
    this.notes = const Value.absent(),
    this.seasonNumber = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackingEntriesCacheCompanion.insert({
    required String id,
    required String itemId,
    this.ownedItemId = const Value.absent(),
    this.editionId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.status = const Value.absent(),
    this.rating = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.progressCurrent = const Value.absent(),
    this.progressTotal = const Value.absent(),
    this.timesCompleted = const Value.absent(),
    this.notes = const Value.absent(),
    this.seasonNumber = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        updatedAt = Value(updatedAt);
  static Insertable<TrackingEntriesCacheData> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? ownedItemId,
    Expression<String>? editionId,
    Expression<String>? variantId,
    Expression<String>? sourceType,
    Expression<String>? status,
    Expression<int>? rating,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? progressCurrent,
    Expression<int>? progressTotal,
    Expression<int>? timesCompleted,
    Expression<String>? notes,
    Expression<int>? seasonNumber,
    Expression<int>? episodeNumber,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (ownedItemId != null) 'owned_item_id': ownedItemId,
      if (editionId != null) 'edition_id': editionId,
      if (variantId != null) 'variant_id': variantId,
      if (sourceType != null) 'source_type': sourceType,
      if (status != null) 'status': status,
      if (rating != null) 'rating': rating,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (progressCurrent != null) 'progress_current': progressCurrent,
      if (progressTotal != null) 'progress_total': progressTotal,
      if (timesCompleted != null) 'times_completed': timesCompleted,
      if (notes != null) 'notes': notes,
      if (seasonNumber != null) 'season_number': seasonNumber,
      if (episodeNumber != null) 'episode_number': episodeNumber,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackingEntriesCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<String?>? ownedItemId,
      Value<String?>? editionId,
      Value<String?>? variantId,
      Value<String?>? sourceType,
      Value<String?>? status,
      Value<int?>? rating,
      Value<DateTime?>? startedAt,
      Value<DateTime?>? finishedAt,
      Value<int?>? progressCurrent,
      Value<int?>? progressTotal,
      Value<int?>? timesCompleted,
      Value<String?>? notes,
      Value<int?>? seasonNumber,
      Value<int?>? episodeNumber,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return TrackingEntriesCacheCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      sourceType: sourceType ?? this.sourceType,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      progressCurrent: progressCurrent ?? this.progressCurrent,
      progressTotal: progressTotal ?? this.progressTotal,
      timesCompleted: timesCompleted ?? this.timesCompleted,
      notes: notes ?? this.notes,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (ownedItemId.present) {
      map['owned_item_id'] = Variable<String>(ownedItemId.value);
    }
    if (editionId.present) {
      map['edition_id'] = Variable<String>(editionId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (progressCurrent.present) {
      map['progress_current'] = Variable<int>(progressCurrent.value);
    }
    if (progressTotal.present) {
      map['progress_total'] = Variable<int>(progressTotal.value);
    }
    if (timesCompleted.present) {
      map['times_completed'] = Variable<int>(timesCompleted.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (seasonNumber.present) {
      map['season_number'] = Variable<int>(seasonNumber.value);
    }
    if (episodeNumber.present) {
      map['episode_number'] = Variable<int>(episodeNumber.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackingEntriesCacheCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('editionId: $editionId, ')
          ..write('variantId: $variantId, ')
          ..write('sourceType: $sourceType, ')
          ..write('status: $status, ')
          ..write('rating: $rating, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('progressCurrent: $progressCurrent, ')
          ..write('progressTotal: $progressTotal, ')
          ..write('timesCompleted: $timesCompleted, ')
          ..write('notes: $notes, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientChangedAtMeta =
      const VerificationMeta('clientChangedAt');
  @override
  late final GeneratedColumn<DateTime> clientChangedAt =
      GeneratedColumn<DateTime>('client_changed_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, entityType, entityId, action, payloadJson, clientChangedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('client_changed_at')) {
      context.handle(
          _clientChangedAtMeta,
          clientChangedAt.isAcceptableOrUnknown(
              data['client_changed_at']!, _clientChangedAtMeta));
    } else if (isInserting) {
      context.missing(_clientChangedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType, entityId};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      clientChangedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}client_changed_at'])!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final String id;
  final String entityType;
  final String entityId;
  final String action;
  final String payloadJson;
  final DateTime clientChangedAt;
  const SyncQueueData(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.action,
      required this.payloadJson,
      required this.clientChangedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    map['payload_json'] = Variable<String>(payloadJson);
    map['client_changed_at'] = Variable<DateTime>(clientChangedAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      payloadJson: Value(payloadJson),
      clientChangedAt: Value(clientChangedAt),
    );
  }

  factory SyncQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      clientChangedAt: serializer.fromJson<DateTime>(json['clientChangedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'clientChangedAt': serializer.toJson<DateTime>(clientChangedAt),
    };
  }

  SyncQueueData copyWith(
          {String? id,
          String? entityType,
          String? entityId,
          String? action,
          String? payloadJson,
          DateTime? clientChangedAt}) =>
      SyncQueueData(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        action: action ?? this.action,
        payloadJson: payloadJson ?? this.payloadJson,
        clientChangedAt: clientChangedAt ?? this.clientChangedAt,
      );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      clientChangedAt: data.clientChangedAt.present
          ? data.clientChangedAt.value
          : this.clientChangedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('clientChangedAt: $clientChangedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, entityType, entityId, action, payloadJson, clientChangedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.payloadJson == this.payloadJson &&
          other.clientChangedAt == this.clientChangedAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String> payloadJson;
  final Value<DateTime> clientChangedAt;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.clientChangedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String action,
    required String payloadJson,
    required DateTime clientChangedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
        entityId = Value(entityId),
        action = Value(action),
        payloadJson = Value(payloadJson),
        clientChangedAt = Value(clientChangedAt);
  static Insertable<SyncQueueData> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? payloadJson,
    Expression<DateTime>? clientChangedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (clientChangedAt != null) 'client_changed_at': clientChangedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? action,
      Value<String>? payloadJson,
      Value<DateTime>? clientChangedAt,
      Value<int>? rowid}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      payloadJson: payloadJson ?? this.payloadJson,
      clientChangedAt: clientChangedAt ?? this.clientChangedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (clientChangedAt.present) {
      map['client_changed_at'] = Variable<DateTime>(clientChangedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('clientChangedAt: $clientChangedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomFieldDefinitionsCacheTable extends CustomFieldDefinitionsCache
    with
        TableInfo<$CustomFieldDefinitionsCacheTable,
            CustomFieldDefinitionsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomFieldDefinitionsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fieldTypeMeta =
      const VerificationMeta('fieldType');
  @override
  late final GeneratedColumn<String> fieldType = GeneratedColumn<String>(
      'field_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mediaKindMeta =
      const VerificationMeta('mediaKind');
  @override
  late final GeneratedColumn<String> mediaKind = GeneratedColumn<String>(
      'media_kind', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _optionsMeta =
      const VerificationMeta('options');
  @override
  late final GeneratedColumn<String> options = GeneratedColumn<String>(
      'options', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, fieldType, mediaKind, sortOrder, options, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_field_definitions_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<CustomFieldDefinitionsCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('field_type')) {
      context.handle(_fieldTypeMeta,
          fieldType.isAcceptableOrUnknown(data['field_type']!, _fieldTypeMeta));
    } else if (isInserting) {
      context.missing(_fieldTypeMeta);
    }
    if (data.containsKey('media_kind')) {
      context.handle(_mediaKindMeta,
          mediaKind.isAcceptableOrUnknown(data['media_kind']!, _mediaKindMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('options')) {
      context.handle(_optionsMeta,
          options.isAcceptableOrUnknown(data['options']!, _optionsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomFieldDefinitionsCacheData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomFieldDefinitionsCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      fieldType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}field_type'])!,
      mediaKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_kind']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      options: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}options']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CustomFieldDefinitionsCacheTable createAlias(String alias) {
    return $CustomFieldDefinitionsCacheTable(attachedDatabase, alias);
  }
}

class CustomFieldDefinitionsCacheData extends DataClass
    implements Insertable<CustomFieldDefinitionsCacheData> {
  final String id;
  final String name;
  final String fieldType;
  final String? mediaKind;
  final int sortOrder;
  final String? options;
  final DateTime createdAt;
  const CustomFieldDefinitionsCacheData(
      {required this.id,
      required this.name,
      required this.fieldType,
      this.mediaKind,
      required this.sortOrder,
      this.options,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['field_type'] = Variable<String>(fieldType);
    if (!nullToAbsent || mediaKind != null) {
      map['media_kind'] = Variable<String>(mediaKind);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || options != null) {
      map['options'] = Variable<String>(options);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomFieldDefinitionsCacheCompanion toCompanion(bool nullToAbsent) {
    return CustomFieldDefinitionsCacheCompanion(
      id: Value(id),
      name: Value(name),
      fieldType: Value(fieldType),
      mediaKind: mediaKind == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaKind),
      sortOrder: Value(sortOrder),
      options: options == null && nullToAbsent
          ? const Value.absent()
          : Value(options),
      createdAt: Value(createdAt),
    );
  }

  factory CustomFieldDefinitionsCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomFieldDefinitionsCacheData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      fieldType: serializer.fromJson<String>(json['fieldType']),
      mediaKind: serializer.fromJson<String?>(json['mediaKind']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      options: serializer.fromJson<String?>(json['options']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'fieldType': serializer.toJson<String>(fieldType),
      'mediaKind': serializer.toJson<String?>(mediaKind),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'options': serializer.toJson<String?>(options),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomFieldDefinitionsCacheData copyWith(
          {String? id,
          String? name,
          String? fieldType,
          Value<String?> mediaKind = const Value.absent(),
          int? sortOrder,
          Value<String?> options = const Value.absent(),
          DateTime? createdAt}) =>
      CustomFieldDefinitionsCacheData(
        id: id ?? this.id,
        name: name ?? this.name,
        fieldType: fieldType ?? this.fieldType,
        mediaKind: mediaKind.present ? mediaKind.value : this.mediaKind,
        sortOrder: sortOrder ?? this.sortOrder,
        options: options.present ? options.value : this.options,
        createdAt: createdAt ?? this.createdAt,
      );
  CustomFieldDefinitionsCacheData copyWithCompanion(
      CustomFieldDefinitionsCacheCompanion data) {
    return CustomFieldDefinitionsCacheData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      fieldType: data.fieldType.present ? data.fieldType.value : this.fieldType,
      mediaKind: data.mediaKind.present ? data.mediaKind.value : this.mediaKind,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      options: data.options.present ? data.options.value : this.options,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomFieldDefinitionsCacheData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fieldType: $fieldType, ')
          ..write('mediaKind: $mediaKind, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('options: $options, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, fieldType, mediaKind, sortOrder, options, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomFieldDefinitionsCacheData &&
          other.id == this.id &&
          other.name == this.name &&
          other.fieldType == this.fieldType &&
          other.mediaKind == this.mediaKind &&
          other.sortOrder == this.sortOrder &&
          other.options == this.options &&
          other.createdAt == this.createdAt);
}

class CustomFieldDefinitionsCacheCompanion
    extends UpdateCompanion<CustomFieldDefinitionsCacheData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> fieldType;
  final Value<String?> mediaKind;
  final Value<int> sortOrder;
  final Value<String?> options;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CustomFieldDefinitionsCacheCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.fieldType = const Value.absent(),
    this.mediaKind = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.options = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomFieldDefinitionsCacheCompanion.insert({
    required String id,
    required String name,
    required String fieldType,
    this.mediaKind = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.options = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        fieldType = Value(fieldType),
        createdAt = Value(createdAt);
  static Insertable<CustomFieldDefinitionsCacheData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? fieldType,
    Expression<String>? mediaKind,
    Expression<int>? sortOrder,
    Expression<String>? options,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (fieldType != null) 'field_type': fieldType,
      if (mediaKind != null) 'media_kind': mediaKind,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (options != null) 'options': options,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomFieldDefinitionsCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? fieldType,
      Value<String?>? mediaKind,
      Value<int>? sortOrder,
      Value<String?>? options,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CustomFieldDefinitionsCacheCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      fieldType: fieldType ?? this.fieldType,
      mediaKind: mediaKind ?? this.mediaKind,
      sortOrder: sortOrder ?? this.sortOrder,
      options: options ?? this.options,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fieldType.present) {
      map['field_type'] = Variable<String>(fieldType.value);
    }
    if (mediaKind.present) {
      map['media_kind'] = Variable<String>(mediaKind.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (options.present) {
      map['options'] = Variable<String>(options.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomFieldDefinitionsCacheCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fieldType: $fieldType, ')
          ..write('mediaKind: $mediaKind, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('options: $options, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomFieldValuesCacheTable extends CustomFieldValuesCache
    with TableInfo<$CustomFieldValuesCacheTable, CustomFieldValuesCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomFieldValuesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownedItemIdMeta =
      const VerificationMeta('ownedItemId');
  @override
  late final GeneratedColumn<String> ownedItemId = GeneratedColumn<String>(
      'owned_item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fieldDefinitionIdMeta =
      const VerificationMeta('fieldDefinitionId');
  @override
  late final GeneratedColumn<String> fieldDefinitionId =
      GeneratedColumn<String>('field_definition_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, ownedItemId, fieldDefinitionId, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_field_values_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<CustomFieldValuesCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owned_item_id')) {
      context.handle(
          _ownedItemIdMeta,
          ownedItemId.isAcceptableOrUnknown(
              data['owned_item_id']!, _ownedItemIdMeta));
    } else if (isInserting) {
      context.missing(_ownedItemIdMeta);
    }
    if (data.containsKey('field_definition_id')) {
      context.handle(
          _fieldDefinitionIdMeta,
          fieldDefinitionId.isAcceptableOrUnknown(
              data['field_definition_id']!, _fieldDefinitionIdMeta));
    } else if (isInserting) {
      context.missing(_fieldDefinitionIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomFieldValuesCacheData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomFieldValuesCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ownedItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owned_item_id'])!,
      fieldDefinitionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}field_definition_id'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CustomFieldValuesCacheTable createAlias(String alias) {
    return $CustomFieldValuesCacheTable(attachedDatabase, alias);
  }
}

class CustomFieldValuesCacheData extends DataClass
    implements Insertable<CustomFieldValuesCacheData> {
  final String id;
  final String ownedItemId;
  final String fieldDefinitionId;
  final String? value;
  final DateTime updatedAt;
  const CustomFieldValuesCacheData(
      {required this.id,
      required this.ownedItemId,
      required this.fieldDefinitionId,
      this.value,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owned_item_id'] = Variable<String>(ownedItemId);
    map['field_definition_id'] = Variable<String>(fieldDefinitionId);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CustomFieldValuesCacheCompanion toCompanion(bool nullToAbsent) {
    return CustomFieldValuesCacheCompanion(
      id: Value(id),
      ownedItemId: Value(ownedItemId),
      fieldDefinitionId: Value(fieldDefinitionId),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory CustomFieldValuesCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomFieldValuesCacheData(
      id: serializer.fromJson<String>(json['id']),
      ownedItemId: serializer.fromJson<String>(json['ownedItemId']),
      fieldDefinitionId: serializer.fromJson<String>(json['fieldDefinitionId']),
      value: serializer.fromJson<String?>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownedItemId': serializer.toJson<String>(ownedItemId),
      'fieldDefinitionId': serializer.toJson<String>(fieldDefinitionId),
      'value': serializer.toJson<String?>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CustomFieldValuesCacheData copyWith(
          {String? id,
          String? ownedItemId,
          String? fieldDefinitionId,
          Value<String?> value = const Value.absent(),
          DateTime? updatedAt}) =>
      CustomFieldValuesCacheData(
        id: id ?? this.id,
        ownedItemId: ownedItemId ?? this.ownedItemId,
        fieldDefinitionId: fieldDefinitionId ?? this.fieldDefinitionId,
        value: value.present ? value.value : this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CustomFieldValuesCacheData copyWithCompanion(
      CustomFieldValuesCacheCompanion data) {
    return CustomFieldValuesCacheData(
      id: data.id.present ? data.id.value : this.id,
      ownedItemId:
          data.ownedItemId.present ? data.ownedItemId.value : this.ownedItemId,
      fieldDefinitionId: data.fieldDefinitionId.present
          ? data.fieldDefinitionId.value
          : this.fieldDefinitionId,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomFieldValuesCacheData(')
          ..write('id: $id, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('fieldDefinitionId: $fieldDefinitionId, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ownedItemId, fieldDefinitionId, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomFieldValuesCacheData &&
          other.id == this.id &&
          other.ownedItemId == this.ownedItemId &&
          other.fieldDefinitionId == this.fieldDefinitionId &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class CustomFieldValuesCacheCompanion
    extends UpdateCompanion<CustomFieldValuesCacheData> {
  final Value<String> id;
  final Value<String> ownedItemId;
  final Value<String> fieldDefinitionId;
  final Value<String?> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CustomFieldValuesCacheCompanion({
    this.id = const Value.absent(),
    this.ownedItemId = const Value.absent(),
    this.fieldDefinitionId = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomFieldValuesCacheCompanion.insert({
    required String id,
    required String ownedItemId,
    required String fieldDefinitionId,
    this.value = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        ownedItemId = Value(ownedItemId),
        fieldDefinitionId = Value(fieldDefinitionId),
        updatedAt = Value(updatedAt);
  static Insertable<CustomFieldValuesCacheData> custom({
    Expression<String>? id,
    Expression<String>? ownedItemId,
    Expression<String>? fieldDefinitionId,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownedItemId != null) 'owned_item_id': ownedItemId,
      if (fieldDefinitionId != null) 'field_definition_id': fieldDefinitionId,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomFieldValuesCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? ownedItemId,
      Value<String>? fieldDefinitionId,
      Value<String?>? value,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CustomFieldValuesCacheCompanion(
      id: id ?? this.id,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      fieldDefinitionId: fieldDefinitionId ?? this.fieldDefinitionId,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownedItemId.present) {
      map['owned_item_id'] = Variable<String>(ownedItemId.value);
    }
    if (fieldDefinitionId.present) {
      map['field_definition_id'] = Variable<String>(fieldDefinitionId.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomFieldValuesCacheCompanion(')
          ..write('id: $id, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('fieldDefinitionId: $fieldDefinitionId, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemImagesCacheTable extends ItemImagesCache
    with TableInfo<$ItemImagesCacheTable, ItemImagesCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemImagesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownedItemIdMeta =
      const VerificationMeta('ownedItemId');
  @override
  late final GeneratedColumn<String> ownedItemId = GeneratedColumn<String>(
      'owned_item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageTypeMeta =
      const VerificationMeta('imageType');
  @override
  late final GeneratedColumn<String> imageType = GeneratedColumn<String>(
      'image_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('front_cover'));
  static const VerificationMeta _imageDataMeta =
      const VerificationMeta('imageData');
  @override
  late final GeneratedColumn<String> imageData = GeneratedColumn<String>(
      'image_data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _captionMeta =
      const VerificationMeta('caption');
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
      'caption', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, ownedItemId, imageType, imageData, caption, sortOrder, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_images_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<ItemImagesCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owned_item_id')) {
      context.handle(
          _ownedItemIdMeta,
          ownedItemId.isAcceptableOrUnknown(
              data['owned_item_id']!, _ownedItemIdMeta));
    } else if (isInserting) {
      context.missing(_ownedItemIdMeta);
    }
    if (data.containsKey('image_type')) {
      context.handle(_imageTypeMeta,
          imageType.isAcceptableOrUnknown(data['image_type']!, _imageTypeMeta));
    }
    if (data.containsKey('image_data')) {
      context.handle(_imageDataMeta,
          imageData.isAcceptableOrUnknown(data['image_data']!, _imageDataMeta));
    } else if (isInserting) {
      context.missing(_imageDataMeta);
    }
    if (data.containsKey('caption')) {
      context.handle(_captionMeta,
          caption.isAcceptableOrUnknown(data['caption']!, _captionMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemImagesCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemImagesCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ownedItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owned_item_id'])!,
      imageType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_type'])!,
      imageData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_data'])!,
      caption: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}caption']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ItemImagesCacheTable createAlias(String alias) {
    return $ItemImagesCacheTable(attachedDatabase, alias);
  }
}

class ItemImagesCacheData extends DataClass
    implements Insertable<ItemImagesCacheData> {
  final String id;
  final String ownedItemId;
  final String imageType;
  final String imageData;
  final String? caption;
  final int sortOrder;
  final DateTime createdAt;
  const ItemImagesCacheData(
      {required this.id,
      required this.ownedItemId,
      required this.imageType,
      required this.imageData,
      this.caption,
      required this.sortOrder,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owned_item_id'] = Variable<String>(ownedItemId);
    map['image_type'] = Variable<String>(imageType);
    map['image_data'] = Variable<String>(imageData);
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ItemImagesCacheCompanion toCompanion(bool nullToAbsent) {
    return ItemImagesCacheCompanion(
      id: Value(id),
      ownedItemId: Value(ownedItemId),
      imageType: Value(imageType),
      imageData: Value(imageData),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory ItemImagesCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemImagesCacheData(
      id: serializer.fromJson<String>(json['id']),
      ownedItemId: serializer.fromJson<String>(json['ownedItemId']),
      imageType: serializer.fromJson<String>(json['imageType']),
      imageData: serializer.fromJson<String>(json['imageData']),
      caption: serializer.fromJson<String?>(json['caption']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownedItemId': serializer.toJson<String>(ownedItemId),
      'imageType': serializer.toJson<String>(imageType),
      'imageData': serializer.toJson<String>(imageData),
      'caption': serializer.toJson<String?>(caption),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ItemImagesCacheData copyWith(
          {String? id,
          String? ownedItemId,
          String? imageType,
          String? imageData,
          Value<String?> caption = const Value.absent(),
          int? sortOrder,
          DateTime? createdAt}) =>
      ItemImagesCacheData(
        id: id ?? this.id,
        ownedItemId: ownedItemId ?? this.ownedItemId,
        imageType: imageType ?? this.imageType,
        imageData: imageData ?? this.imageData,
        caption: caption.present ? caption.value : this.caption,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
      );
  ItemImagesCacheData copyWithCompanion(ItemImagesCacheCompanion data) {
    return ItemImagesCacheData(
      id: data.id.present ? data.id.value : this.id,
      ownedItemId:
          data.ownedItemId.present ? data.ownedItemId.value : this.ownedItemId,
      imageType: data.imageType.present ? data.imageType.value : this.imageType,
      imageData: data.imageData.present ? data.imageData.value : this.imageData,
      caption: data.caption.present ? data.caption.value : this.caption,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemImagesCacheData(')
          ..write('id: $id, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('imageType: $imageType, ')
          ..write('imageData: $imageData, ')
          ..write('caption: $caption, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, ownedItemId, imageType, imageData, caption, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemImagesCacheData &&
          other.id == this.id &&
          other.ownedItemId == this.ownedItemId &&
          other.imageType == this.imageType &&
          other.imageData == this.imageData &&
          other.caption == this.caption &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class ItemImagesCacheCompanion extends UpdateCompanion<ItemImagesCacheData> {
  final Value<String> id;
  final Value<String> ownedItemId;
  final Value<String> imageType;
  final Value<String> imageData;
  final Value<String?> caption;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ItemImagesCacheCompanion({
    this.id = const Value.absent(),
    this.ownedItemId = const Value.absent(),
    this.imageType = const Value.absent(),
    this.imageData = const Value.absent(),
    this.caption = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemImagesCacheCompanion.insert({
    required String id,
    required String ownedItemId,
    this.imageType = const Value.absent(),
    required String imageData,
    this.caption = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        ownedItemId = Value(ownedItemId),
        imageData = Value(imageData),
        createdAt = Value(createdAt);
  static Insertable<ItemImagesCacheData> custom({
    Expression<String>? id,
    Expression<String>? ownedItemId,
    Expression<String>? imageType,
    Expression<String>? imageData,
    Expression<String>? caption,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownedItemId != null) 'owned_item_id': ownedItemId,
      if (imageType != null) 'image_type': imageType,
      if (imageData != null) 'image_data': imageData,
      if (caption != null) 'caption': caption,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemImagesCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? ownedItemId,
      Value<String>? imageType,
      Value<String>? imageData,
      Value<String?>? caption,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ItemImagesCacheCompanion(
      id: id ?? this.id,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      imageType: imageType ?? this.imageType,
      imageData: imageData ?? this.imageData,
      caption: caption ?? this.caption,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownedItemId.present) {
      map['owned_item_id'] = Variable<String>(ownedItemId.value);
    }
    if (imageType.present) {
      map['image_type'] = Variable<String>(imageType.value);
    }
    if (imageData.present) {
      map['image_data'] = Variable<String>(imageData.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemImagesCacheCompanion(')
          ..write('id: $id, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('imageType: $imageType, ')
          ..write('imageData: $imageData, ')
          ..write('caption: $caption, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoansCacheTable extends LoansCache
    with TableInfo<$LoansCacheTable, LoansCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoansCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownedItemIdMeta =
      const VerificationMeta('ownedItemId');
  @override
  late final GeneratedColumn<String> ownedItemId = GeneratedColumn<String>(
      'owned_item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _borrowerNameMeta =
      const VerificationMeta('borrowerName');
  @override
  late final GeneratedColumn<String> borrowerName = GeneratedColumn<String>(
      'borrower_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lentDateMeta =
      const VerificationMeta('lentDate');
  @override
  late final GeneratedColumn<DateTime> lentDate = GeneratedColumn<DateTime>(
      'lent_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _returnedDateMeta =
      const VerificationMeta('returnedDate');
  @override
  late final GeneratedColumn<DateTime> returnedDate = GeneratedColumn<DateTime>(
      'returned_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, ownedItemId, borrowerName, lentDate, dueDate, returnedDate, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loans_cache';
  @override
  VerificationContext validateIntegrity(Insertable<LoansCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owned_item_id')) {
      context.handle(
          _ownedItemIdMeta,
          ownedItemId.isAcceptableOrUnknown(
              data['owned_item_id']!, _ownedItemIdMeta));
    } else if (isInserting) {
      context.missing(_ownedItemIdMeta);
    }
    if (data.containsKey('borrower_name')) {
      context.handle(
          _borrowerNameMeta,
          borrowerName.isAcceptableOrUnknown(
              data['borrower_name']!, _borrowerNameMeta));
    } else if (isInserting) {
      context.missing(_borrowerNameMeta);
    }
    if (data.containsKey('lent_date')) {
      context.handle(_lentDateMeta,
          lentDate.isAcceptableOrUnknown(data['lent_date']!, _lentDateMeta));
    } else if (isInserting) {
      context.missing(_lentDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('returned_date')) {
      context.handle(
          _returnedDateMeta,
          returnedDate.isAcceptableOrUnknown(
              data['returned_date']!, _returnedDateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoansCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoansCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ownedItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owned_item_id'])!,
      borrowerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}borrower_name'])!,
      lentDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}lent_date'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      returnedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}returned_date']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $LoansCacheTable createAlias(String alias) {
    return $LoansCacheTable(attachedDatabase, alias);
  }
}

class LoansCacheData extends DataClass implements Insertable<LoansCacheData> {
  final String id;
  final String ownedItemId;
  final String borrowerName;
  final DateTime lentDate;
  final DateTime? dueDate;
  final DateTime? returnedDate;
  final String? notes;
  const LoansCacheData(
      {required this.id,
      required this.ownedItemId,
      required this.borrowerName,
      required this.lentDate,
      this.dueDate,
      this.returnedDate,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owned_item_id'] = Variable<String>(ownedItemId);
    map['borrower_name'] = Variable<String>(borrowerName);
    map['lent_date'] = Variable<DateTime>(lentDate);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || returnedDate != null) {
      map['returned_date'] = Variable<DateTime>(returnedDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  LoansCacheCompanion toCompanion(bool nullToAbsent) {
    return LoansCacheCompanion(
      id: Value(id),
      ownedItemId: Value(ownedItemId),
      borrowerName: Value(borrowerName),
      lentDate: Value(lentDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      returnedDate: returnedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(returnedDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory LoansCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoansCacheData(
      id: serializer.fromJson<String>(json['id']),
      ownedItemId: serializer.fromJson<String>(json['ownedItemId']),
      borrowerName: serializer.fromJson<String>(json['borrowerName']),
      lentDate: serializer.fromJson<DateTime>(json['lentDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      returnedDate: serializer.fromJson<DateTime?>(json['returnedDate']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownedItemId': serializer.toJson<String>(ownedItemId),
      'borrowerName': serializer.toJson<String>(borrowerName),
      'lentDate': serializer.toJson<DateTime>(lentDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'returnedDate': serializer.toJson<DateTime?>(returnedDate),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  LoansCacheData copyWith(
          {String? id,
          String? ownedItemId,
          String? borrowerName,
          DateTime? lentDate,
          Value<DateTime?> dueDate = const Value.absent(),
          Value<DateTime?> returnedDate = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      LoansCacheData(
        id: id ?? this.id,
        ownedItemId: ownedItemId ?? this.ownedItemId,
        borrowerName: borrowerName ?? this.borrowerName,
        lentDate: lentDate ?? this.lentDate,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        returnedDate:
            returnedDate.present ? returnedDate.value : this.returnedDate,
        notes: notes.present ? notes.value : this.notes,
      );
  LoansCacheData copyWithCompanion(LoansCacheCompanion data) {
    return LoansCacheData(
      id: data.id.present ? data.id.value : this.id,
      ownedItemId:
          data.ownedItemId.present ? data.ownedItemId.value : this.ownedItemId,
      borrowerName: data.borrowerName.present
          ? data.borrowerName.value
          : this.borrowerName,
      lentDate: data.lentDate.present ? data.lentDate.value : this.lentDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      returnedDate: data.returnedDate.present
          ? data.returnedDate.value
          : this.returnedDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoansCacheData(')
          ..write('id: $id, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('borrowerName: $borrowerName, ')
          ..write('lentDate: $lentDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('returnedDate: $returnedDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, ownedItemId, borrowerName, lentDate, dueDate, returnedDate, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoansCacheData &&
          other.id == this.id &&
          other.ownedItemId == this.ownedItemId &&
          other.borrowerName == this.borrowerName &&
          other.lentDate == this.lentDate &&
          other.dueDate == this.dueDate &&
          other.returnedDate == this.returnedDate &&
          other.notes == this.notes);
}

class LoansCacheCompanion extends UpdateCompanion<LoansCacheData> {
  final Value<String> id;
  final Value<String> ownedItemId;
  final Value<String> borrowerName;
  final Value<DateTime> lentDate;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> returnedDate;
  final Value<String?> notes;
  final Value<int> rowid;
  const LoansCacheCompanion({
    this.id = const Value.absent(),
    this.ownedItemId = const Value.absent(),
    this.borrowerName = const Value.absent(),
    this.lentDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.returnedDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoansCacheCompanion.insert({
    required String id,
    required String ownedItemId,
    required String borrowerName,
    required DateTime lentDate,
    this.dueDate = const Value.absent(),
    this.returnedDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        ownedItemId = Value(ownedItemId),
        borrowerName = Value(borrowerName),
        lentDate = Value(lentDate);
  static Insertable<LoansCacheData> custom({
    Expression<String>? id,
    Expression<String>? ownedItemId,
    Expression<String>? borrowerName,
    Expression<DateTime>? lentDate,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? returnedDate,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownedItemId != null) 'owned_item_id': ownedItemId,
      if (borrowerName != null) 'borrower_name': borrowerName,
      if (lentDate != null) 'lent_date': lentDate,
      if (dueDate != null) 'due_date': dueDate,
      if (returnedDate != null) 'returned_date': returnedDate,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoansCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? ownedItemId,
      Value<String>? borrowerName,
      Value<DateTime>? lentDate,
      Value<DateTime?>? dueDate,
      Value<DateTime?>? returnedDate,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return LoansCacheCompanion(
      id: id ?? this.id,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      borrowerName: borrowerName ?? this.borrowerName,
      lentDate: lentDate ?? this.lentDate,
      dueDate: dueDate ?? this.dueDate,
      returnedDate: returnedDate ?? this.returnedDate,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownedItemId.present) {
      map['owned_item_id'] = Variable<String>(ownedItemId.value);
    }
    if (borrowerName.present) {
      map['borrower_name'] = Variable<String>(borrowerName.value);
    }
    if (lentDate.present) {
      map['lent_date'] = Variable<DateTime>(lentDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (returnedDate.present) {
      map['returned_date'] = Variable<DateTime>(returnedDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoansCacheCompanion(')
          ..write('id: $id, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('borrowerName: $borrowerName, ')
          ..write('lentDate: $lentDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('returnedDate: $returnedDate, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationsCacheTable extends LocationsCache
    with TableInfo<$LocationsCacheTable, LocationsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, parentId, description, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'locations_cache';
  @override
  VerificationContext validateIntegrity(Insertable<LocationsCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationsCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $LocationsCacheTable createAlias(String alias) {
    return $LocationsCacheTable(attachedDatabase, alias);
  }
}

class LocationsCacheData extends DataClass
    implements Insertable<LocationsCacheData> {
  final String id;
  final String name;
  final String? parentId;
  final String? description;
  final int sortOrder;
  const LocationsCacheData(
      {required this.id,
      required this.name,
      this.parentId,
      this.description,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LocationsCacheCompanion toCompanion(bool nullToAbsent) {
    return LocationsCacheCompanion(
      id: Value(id),
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      sortOrder: Value(sortOrder),
    );
  }

  factory LocationsCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationsCacheData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      description: serializer.fromJson<String?>(json['description']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<String?>(parentId),
      'description': serializer.toJson<String?>(description),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LocationsCacheData copyWith(
          {String? id,
          String? name,
          Value<String?> parentId = const Value.absent(),
          Value<String?> description = const Value.absent(),
          int? sortOrder}) =>
      LocationsCacheData(
        id: id ?? this.id,
        name: name ?? this.name,
        parentId: parentId.present ? parentId.value : this.parentId,
        description: description.present ? description.value : this.description,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  LocationsCacheData copyWithCompanion(LocationsCacheCompanion data) {
    return LocationsCacheData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      description:
          data.description.present ? data.description.value : this.description,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationsCacheData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, parentId, description, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationsCacheData &&
          other.id == this.id &&
          other.name == this.name &&
          other.parentId == this.parentId &&
          other.description == this.description &&
          other.sortOrder == this.sortOrder);
}

class LocationsCacheCompanion extends UpdateCompanion<LocationsCacheData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> parentId;
  final Value<String?> description;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LocationsCacheCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationsCacheCompanion.insert({
    required String id,
    required String name,
    this.parentId = const Value.absent(),
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<LocationsCacheData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? parentId,
    Expression<String>? description,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (description != null) 'description': description,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationsCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? parentId,
      Value<String?>? description,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return LocationsCacheCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationsCacheCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SmartListsCacheTable extends SmartListsCache
    with TableInfo<$SmartListsCacheTable, SmartListsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SmartListsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mediaKindMeta =
      const VerificationMeta('mediaKind');
  @override
  late final GeneratedColumn<String> mediaKind = GeneratedColumn<String>(
      'media_kind', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _criteriaJsonMeta =
      const VerificationMeta('criteriaJson');
  @override
  late final GeneratedColumn<String> criteriaJson = GeneratedColumn<String>(
      'criteria_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, mediaKind, criteriaJson, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'smart_lists_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<SmartListsCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('media_kind')) {
      context.handle(_mediaKindMeta,
          mediaKind.isAcceptableOrUnknown(data['media_kind']!, _mediaKindMeta));
    }
    if (data.containsKey('criteria_json')) {
      context.handle(
          _criteriaJsonMeta,
          criteriaJson.isAcceptableOrUnknown(
              data['criteria_json']!, _criteriaJsonMeta));
    } else if (isInserting) {
      context.missing(_criteriaJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SmartListsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SmartListsCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      mediaKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_kind']),
      criteriaJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}criteria_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SmartListsCacheTable createAlias(String alias) {
    return $SmartListsCacheTable(attachedDatabase, alias);
  }
}

class SmartListsCacheData extends DataClass
    implements Insertable<SmartListsCacheData> {
  final String id;
  final String name;
  final String? mediaKind;
  final String criteriaJson;
  final DateTime createdAt;
  const SmartListsCacheData(
      {required this.id,
      required this.name,
      this.mediaKind,
      required this.criteriaJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || mediaKind != null) {
      map['media_kind'] = Variable<String>(mediaKind);
    }
    map['criteria_json'] = Variable<String>(criteriaJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SmartListsCacheCompanion toCompanion(bool nullToAbsent) {
    return SmartListsCacheCompanion(
      id: Value(id),
      name: Value(name),
      mediaKind: mediaKind == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaKind),
      criteriaJson: Value(criteriaJson),
      createdAt: Value(createdAt),
    );
  }

  factory SmartListsCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SmartListsCacheData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      mediaKind: serializer.fromJson<String?>(json['mediaKind']),
      criteriaJson: serializer.fromJson<String>(json['criteriaJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'mediaKind': serializer.toJson<String?>(mediaKind),
      'criteriaJson': serializer.toJson<String>(criteriaJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SmartListsCacheData copyWith(
          {String? id,
          String? name,
          Value<String?> mediaKind = const Value.absent(),
          String? criteriaJson,
          DateTime? createdAt}) =>
      SmartListsCacheData(
        id: id ?? this.id,
        name: name ?? this.name,
        mediaKind: mediaKind.present ? mediaKind.value : this.mediaKind,
        criteriaJson: criteriaJson ?? this.criteriaJson,
        createdAt: createdAt ?? this.createdAt,
      );
  SmartListsCacheData copyWithCompanion(SmartListsCacheCompanion data) {
    return SmartListsCacheData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      mediaKind: data.mediaKind.present ? data.mediaKind.value : this.mediaKind,
      criteriaJson: data.criteriaJson.present
          ? data.criteriaJson.value
          : this.criteriaJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmartListsCacheData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mediaKind: $mediaKind, ')
          ..write('criteriaJson: $criteriaJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, mediaKind, criteriaJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmartListsCacheData &&
          other.id == this.id &&
          other.name == this.name &&
          other.mediaKind == this.mediaKind &&
          other.criteriaJson == this.criteriaJson &&
          other.createdAt == this.createdAt);
}

class SmartListsCacheCompanion extends UpdateCompanion<SmartListsCacheData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> mediaKind;
  final Value<String> criteriaJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SmartListsCacheCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.mediaKind = const Value.absent(),
    this.criteriaJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SmartListsCacheCompanion.insert({
    required String id,
    required String name,
    this.mediaKind = const Value.absent(),
    required String criteriaJson,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        criteriaJson = Value(criteriaJson),
        createdAt = Value(createdAt);
  static Insertable<SmartListsCacheData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? mediaKind,
    Expression<String>? criteriaJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (mediaKind != null) 'media_kind': mediaKind,
      if (criteriaJson != null) 'criteria_json': criteriaJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SmartListsCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? mediaKind,
      Value<String>? criteriaJson,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SmartListsCacheCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      mediaKind: mediaKind ?? this.mediaKind,
      criteriaJson: criteriaJson ?? this.criteriaJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (mediaKind.present) {
      map['media_kind'] = Variable<String>(mediaKind.value);
    }
    if (criteriaJson.present) {
      map['criteria_json'] = Variable<String>(criteriaJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmartListsCacheCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mediaKind: $mediaKind, ')
          ..write('criteriaJson: $criteriaJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserFoldersCacheTable extends UserFoldersCache
    with TableInfo<$UserFoldersCacheTable, UserFoldersCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserFoldersCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconNameMeta =
      const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
      'icon_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, parentId, iconName, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_folders_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<UserFoldersCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('icon_name')) {
      context.handle(_iconNameMeta,
          iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserFoldersCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserFoldersCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      iconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_name']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $UserFoldersCacheTable createAlias(String alias) {
    return $UserFoldersCacheTable(attachedDatabase, alias);
  }
}

class UserFoldersCacheData extends DataClass
    implements Insertable<UserFoldersCacheData> {
  final String id;
  final String name;
  final String? description;
  final String? parentId;
  final String? iconName;
  final int sortOrder;
  const UserFoldersCacheData(
      {required this.id,
      required this.name,
      this.description,
      this.parentId,
      this.iconName,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  UserFoldersCacheCompanion toCompanion(bool nullToAbsent) {
    return UserFoldersCacheCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      sortOrder: Value(sortOrder),
    );
  }

  factory UserFoldersCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserFoldersCacheData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'parentId': serializer.toJson<String?>(parentId),
      'iconName': serializer.toJson<String?>(iconName),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  UserFoldersCacheData copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> parentId = const Value.absent(),
          Value<String?> iconName = const Value.absent(),
          int? sortOrder}) =>
      UserFoldersCacheData(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        parentId: parentId.present ? parentId.value : this.parentId,
        iconName: iconName.present ? iconName.value : this.iconName,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  UserFoldersCacheData copyWithCompanion(UserFoldersCacheCompanion data) {
    return UserFoldersCacheData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserFoldersCacheData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('parentId: $parentId, ')
          ..write('iconName: $iconName, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, parentId, iconName, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserFoldersCacheData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.parentId == this.parentId &&
          other.iconName == this.iconName &&
          other.sortOrder == this.sortOrder);
}

class UserFoldersCacheCompanion extends UpdateCompanion<UserFoldersCacheData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> parentId;
  final Value<String?> iconName;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const UserFoldersCacheCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.parentId = const Value.absent(),
    this.iconName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserFoldersCacheCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.parentId = const Value.absent(),
    this.iconName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<UserFoldersCacheData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? parentId,
    Expression<String>? iconName,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (parentId != null) 'parent_id': parentId,
      if (iconName != null) 'icon_name': iconName,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserFoldersCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? parentId,
      Value<String?>? iconName,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return UserFoldersCacheCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      iconName: iconName ?? this.iconName,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserFoldersCacheCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('parentId: $parentId, ')
          ..write('iconName: $iconName, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserFolderItemsCacheTable extends UserFolderItemsCache
    with TableInfo<$UserFolderItemsCacheTable, UserFolderItemsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserFolderItemsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _folderIdMeta =
      const VerificationMeta('folderId');
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
      'folder_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownedItemIdMeta =
      const VerificationMeta('ownedItemId');
  @override
  late final GeneratedColumn<String> ownedItemId = GeneratedColumn<String>(
      'owned_item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [folderId, ownedItemId, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_folder_items_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<UserFolderItemsCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('folder_id')) {
      context.handle(_folderIdMeta,
          folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta));
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('owned_item_id')) {
      context.handle(
          _ownedItemIdMeta,
          ownedItemId.isAcceptableOrUnknown(
              data['owned_item_id']!, _ownedItemIdMeta));
    } else if (isInserting) {
      context.missing(_ownedItemIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {folderId, ownedItemId};
  @override
  UserFolderItemsCacheData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserFolderItemsCacheData(
      folderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}folder_id'])!,
      ownedItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owned_item_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $UserFolderItemsCacheTable createAlias(String alias) {
    return $UserFolderItemsCacheTable(attachedDatabase, alias);
  }
}

class UserFolderItemsCacheData extends DataClass
    implements Insertable<UserFolderItemsCacheData> {
  final String folderId;
  final String ownedItemId;
  final int sortOrder;
  const UserFolderItemsCacheData(
      {required this.folderId,
      required this.ownedItemId,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['folder_id'] = Variable<String>(folderId);
    map['owned_item_id'] = Variable<String>(ownedItemId);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  UserFolderItemsCacheCompanion toCompanion(bool nullToAbsent) {
    return UserFolderItemsCacheCompanion(
      folderId: Value(folderId),
      ownedItemId: Value(ownedItemId),
      sortOrder: Value(sortOrder),
    );
  }

  factory UserFolderItemsCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserFolderItemsCacheData(
      folderId: serializer.fromJson<String>(json['folderId']),
      ownedItemId: serializer.fromJson<String>(json['ownedItemId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'folderId': serializer.toJson<String>(folderId),
      'ownedItemId': serializer.toJson<String>(ownedItemId),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  UserFolderItemsCacheData copyWith(
          {String? folderId, String? ownedItemId, int? sortOrder}) =>
      UserFolderItemsCacheData(
        folderId: folderId ?? this.folderId,
        ownedItemId: ownedItemId ?? this.ownedItemId,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  UserFolderItemsCacheData copyWithCompanion(
      UserFolderItemsCacheCompanion data) {
    return UserFolderItemsCacheData(
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      ownedItemId:
          data.ownedItemId.present ? data.ownedItemId.value : this.ownedItemId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserFolderItemsCacheData(')
          ..write('folderId: $folderId, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(folderId, ownedItemId, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserFolderItemsCacheData &&
          other.folderId == this.folderId &&
          other.ownedItemId == this.ownedItemId &&
          other.sortOrder == this.sortOrder);
}

class UserFolderItemsCacheCompanion
    extends UpdateCompanion<UserFolderItemsCacheData> {
  final Value<String> folderId;
  final Value<String> ownedItemId;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const UserFolderItemsCacheCompanion({
    this.folderId = const Value.absent(),
    this.ownedItemId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserFolderItemsCacheCompanion.insert({
    required String folderId,
    required String ownedItemId,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : folderId = Value(folderId),
        ownedItemId = Value(ownedItemId);
  static Insertable<UserFolderItemsCacheData> custom({
    Expression<String>? folderId,
    Expression<String>? ownedItemId,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (folderId != null) 'folder_id': folderId,
      if (ownedItemId != null) 'owned_item_id': ownedItemId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserFolderItemsCacheCompanion copyWith(
      {Value<String>? folderId,
      Value<String>? ownedItemId,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return UserFolderItemsCacheCompanion(
      folderId: folderId ?? this.folderId,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (ownedItemId.present) {
      map['owned_item_id'] = Variable<String>(ownedItemId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserFolderItemsCacheCompanion(')
          ..write('folderId: $folderId, ')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingQueueCacheTable extends ReadingQueueCache
    with TableInfo<$ReadingQueueCacheTable, ReadingQueueCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingQueueCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownedItemIdMeta =
      const VerificationMeta('ownedItemId');
  @override
  late final GeneratedColumn<String> ownedItemId = GeneratedColumn<String>(
      'owned_item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [ownedItemId, position, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_queue_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReadingQueueCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owned_item_id')) {
      context.handle(
          _ownedItemIdMeta,
          ownedItemId.isAcceptableOrUnknown(
              data['owned_item_id']!, _ownedItemIdMeta));
    } else if (isInserting) {
      context.missing(_ownedItemIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownedItemId};
  @override
  ReadingQueueCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingQueueCacheData(
      ownedItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owned_item_id'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
    );
  }

  @override
  $ReadingQueueCacheTable createAlias(String alias) {
    return $ReadingQueueCacheTable(attachedDatabase, alias);
  }
}

class ReadingQueueCacheData extends DataClass
    implements Insertable<ReadingQueueCacheData> {
  final String ownedItemId;
  final int position;
  final DateTime addedAt;
  const ReadingQueueCacheData(
      {required this.ownedItemId,
      required this.position,
      required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owned_item_id'] = Variable<String>(ownedItemId);
    map['position'] = Variable<int>(position);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  ReadingQueueCacheCompanion toCompanion(bool nullToAbsent) {
    return ReadingQueueCacheCompanion(
      ownedItemId: Value(ownedItemId),
      position: Value(position),
      addedAt: Value(addedAt),
    );
  }

  factory ReadingQueueCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingQueueCacheData(
      ownedItemId: serializer.fromJson<String>(json['ownedItemId']),
      position: serializer.fromJson<int>(json['position']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownedItemId': serializer.toJson<String>(ownedItemId),
      'position': serializer.toJson<int>(position),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  ReadingQueueCacheData copyWith(
          {String? ownedItemId, int? position, DateTime? addedAt}) =>
      ReadingQueueCacheData(
        ownedItemId: ownedItemId ?? this.ownedItemId,
        position: position ?? this.position,
        addedAt: addedAt ?? this.addedAt,
      );
  ReadingQueueCacheData copyWithCompanion(ReadingQueueCacheCompanion data) {
    return ReadingQueueCacheData(
      ownedItemId:
          data.ownedItemId.present ? data.ownedItemId.value : this.ownedItemId,
      position: data.position.present ? data.position.value : this.position,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingQueueCacheData(')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ownedItemId, position, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingQueueCacheData &&
          other.ownedItemId == this.ownedItemId &&
          other.position == this.position &&
          other.addedAt == this.addedAt);
}

class ReadingQueueCacheCompanion
    extends UpdateCompanion<ReadingQueueCacheData> {
  final Value<String> ownedItemId;
  final Value<int> position;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const ReadingQueueCacheCompanion({
    this.ownedItemId = const Value.absent(),
    this.position = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingQueueCacheCompanion.insert({
    required String ownedItemId,
    required int position,
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  })  : ownedItemId = Value(ownedItemId),
        position = Value(position),
        addedAt = Value(addedAt);
  static Insertable<ReadingQueueCacheData> custom({
    Expression<String>? ownedItemId,
    Expression<int>? position,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownedItemId != null) 'owned_item_id': ownedItemId,
      if (position != null) 'position': position,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingQueueCacheCompanion copyWith(
      {Value<String>? ownedItemId,
      Value<int>? position,
      Value<DateTime>? addedAt,
      Value<int>? rowid}) {
    return ReadingQueueCacheCompanion(
      ownedItemId: ownedItemId ?? this.ownedItemId,
      position: position ?? this.position,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownedItemId.present) {
      map['owned_item_id'] = Variable<String>(ownedItemId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingQueueCacheCompanion(')
          ..write('ownedItemId: $ownedItemId, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PickListValuesCacheTable extends PickListValuesCache
    with TableInfo<$PickListValuesCacheTable, PickListValuesCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PickListValuesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _listNameMeta =
      const VerificationMeta('listName');
  @override
  late final GeneratedColumn<String> listName = GeneratedColumn<String>(
      'list_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mediaKindMeta =
      const VerificationMeta('mediaKind');
  @override
  late final GeneratedColumn<String> mediaKind = GeneratedColumn<String>(
      'media_kind', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, listName, mediaKind, value, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pick_list_values_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<PickListValuesCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('list_name')) {
      context.handle(_listNameMeta,
          listName.isAcceptableOrUnknown(data['list_name']!, _listNameMeta));
    } else if (isInserting) {
      context.missing(_listNameMeta);
    }
    if (data.containsKey('media_kind')) {
      context.handle(_mediaKindMeta,
          mediaKind.isAcceptableOrUnknown(data['media_kind']!, _mediaKindMeta));
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PickListValuesCacheData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PickListValuesCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      listName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}list_name'])!,
      mediaKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_kind']),
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $PickListValuesCacheTable createAlias(String alias) {
    return $PickListValuesCacheTable(attachedDatabase, alias);
  }
}

class PickListValuesCacheData extends DataClass
    implements Insertable<PickListValuesCacheData> {
  final String id;
  final String listName;
  final String? mediaKind;
  final String value;
  final int sortOrder;
  const PickListValuesCacheData(
      {required this.id,
      required this.listName,
      this.mediaKind,
      required this.value,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['list_name'] = Variable<String>(listName);
    if (!nullToAbsent || mediaKind != null) {
      map['media_kind'] = Variable<String>(mediaKind);
    }
    map['value'] = Variable<String>(value);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PickListValuesCacheCompanion toCompanion(bool nullToAbsent) {
    return PickListValuesCacheCompanion(
      id: Value(id),
      listName: Value(listName),
      mediaKind: mediaKind == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaKind),
      value: Value(value),
      sortOrder: Value(sortOrder),
    );
  }

  factory PickListValuesCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PickListValuesCacheData(
      id: serializer.fromJson<String>(json['id']),
      listName: serializer.fromJson<String>(json['listName']),
      mediaKind: serializer.fromJson<String?>(json['mediaKind']),
      value: serializer.fromJson<String>(json['value']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'listName': serializer.toJson<String>(listName),
      'mediaKind': serializer.toJson<String?>(mediaKind),
      'value': serializer.toJson<String>(value),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  PickListValuesCacheData copyWith(
          {String? id,
          String? listName,
          Value<String?> mediaKind = const Value.absent(),
          String? value,
          int? sortOrder}) =>
      PickListValuesCacheData(
        id: id ?? this.id,
        listName: listName ?? this.listName,
        mediaKind: mediaKind.present ? mediaKind.value : this.mediaKind,
        value: value ?? this.value,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  PickListValuesCacheData copyWithCompanion(PickListValuesCacheCompanion data) {
    return PickListValuesCacheData(
      id: data.id.present ? data.id.value : this.id,
      listName: data.listName.present ? data.listName.value : this.listName,
      mediaKind: data.mediaKind.present ? data.mediaKind.value : this.mediaKind,
      value: data.value.present ? data.value.value : this.value,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PickListValuesCacheData(')
          ..write('id: $id, ')
          ..write('listName: $listName, ')
          ..write('mediaKind: $mediaKind, ')
          ..write('value: $value, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, listName, mediaKind, value, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PickListValuesCacheData &&
          other.id == this.id &&
          other.listName == this.listName &&
          other.mediaKind == this.mediaKind &&
          other.value == this.value &&
          other.sortOrder == this.sortOrder);
}

class PickListValuesCacheCompanion
    extends UpdateCompanion<PickListValuesCacheData> {
  final Value<String> id;
  final Value<String> listName;
  final Value<String?> mediaKind;
  final Value<String> value;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const PickListValuesCacheCompanion({
    this.id = const Value.absent(),
    this.listName = const Value.absent(),
    this.mediaKind = const Value.absent(),
    this.value = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PickListValuesCacheCompanion.insert({
    required String id,
    required String listName,
    this.mediaKind = const Value.absent(),
    required String value,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        listName = Value(listName),
        value = Value(value);
  static Insertable<PickListValuesCacheData> custom({
    Expression<String>? id,
    Expression<String>? listName,
    Expression<String>? mediaKind,
    Expression<String>? value,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listName != null) 'list_name': listName,
      if (mediaKind != null) 'media_kind': mediaKind,
      if (value != null) 'value': value,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PickListValuesCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? listName,
      Value<String?>? mediaKind,
      Value<String>? value,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return PickListValuesCacheCompanion(
      id: id ?? this.id,
      listName: listName ?? this.listName,
      mediaKind: mediaKind ?? this.mediaKind,
      value: value ?? this.value,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (listName.present) {
      map['list_name'] = Variable<String>(listName.value);
    }
    if (mediaKind.present) {
      map['media_kind'] = Variable<String>(mediaKind.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PickListValuesCacheCompanion(')
          ..write('id: $id, ')
          ..write('listName: $listName, ')
          ..write('mediaKind: $mediaKind, ')
          ..write('value: $value, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $CatalogCacheTable catalogCache = $CatalogCacheTable(this);
  late final $OwnedItemsCacheTable ownedItemsCache =
      $OwnedItemsCacheTable(this);
  late final $WishlistItemsCacheTable wishlistItemsCache =
      $WishlistItemsCacheTable(this);
  late final $TrackingEntriesCacheTable trackingEntriesCache =
      $TrackingEntriesCacheTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $CustomFieldDefinitionsCacheTable customFieldDefinitionsCache =
      $CustomFieldDefinitionsCacheTable(this);
  late final $CustomFieldValuesCacheTable customFieldValuesCache =
      $CustomFieldValuesCacheTable(this);
  late final $ItemImagesCacheTable itemImagesCache =
      $ItemImagesCacheTable(this);
  late final $LoansCacheTable loansCache = $LoansCacheTable(this);
  late final $LocationsCacheTable locationsCache = $LocationsCacheTable(this);
  late final $SmartListsCacheTable smartListsCache =
      $SmartListsCacheTable(this);
  late final $UserFoldersCacheTable userFoldersCache =
      $UserFoldersCacheTable(this);
  late final $UserFolderItemsCacheTable userFolderItemsCache =
      $UserFolderItemsCacheTable(this);
  late final $ReadingQueueCacheTable readingQueueCache =
      $ReadingQueueCacheTable(this);
  late final $PickListValuesCacheTable pickListValuesCache =
      $PickListValuesCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        catalogCache,
        ownedItemsCache,
        wishlistItemsCache,
        trackingEntriesCache,
        syncQueue,
        customFieldDefinitionsCache,
        customFieldValuesCache,
        itemImagesCache,
        loansCache,
        locationsCache,
        smartListsCache,
        userFoldersCache,
        userFolderItemsCache,
        readingQueueCache,
        pickListValuesCache
      ];
}

typedef $$CatalogCacheTableCreateCompanionBuilder = CatalogCacheCompanion
    Function({
  required String id,
  required String kind,
  required String title,
  Value<String?> sortKey,
  Value<String?> itemNumber,
  Value<String?> synopsis,
  Value<String?> coverImageUrl,
  Value<String?> thumbnailImageUrl,
  Value<String?> editionTitle,
  Value<String?> physicalFormat,
  Value<String?> physicalFormatLabel,
  Value<String?> publisher,
  Value<DateTime?> releaseDate,
  Value<int?> releaseYear,
  Value<String?> barcode,
  Value<String?> variant,
  Value<String?> seriesId,
  Value<String?> seriesTitle,
  Value<String?> volumeName,
  Value<int?> volumeNumber,
  Value<int?> volumeStartYear,
  Value<int?> seasonNumber,
  Value<int?> episodeNumber,
  Value<int?> runtimeMinutes,
  Value<int?> trackCount,
  Value<String?> tracksJson,
  Value<String?> editionsJson,
  Value<String?> creatorsJson,
  Value<String?> charactersJson,
  Value<String?> storyArcsJson,
  Value<String?> seriesTagsJson,
  Value<String?> platformsJson,
  Value<String?> genresJson,
  Value<int?> pageCount,
  Value<int?> coverPriceCents,
  Value<String?> catalogCurrency,
  Value<String?> catalogNumber,
  Value<String?> country,
  Value<String?> releaseStatus,
  Value<String?> language,
  Value<String?> ageRating,
  Value<String?> imprint,
  Value<String?> subtitle,
  Value<String?> seriesGroup,
  required DateTime cachedAt,
  Value<int> rowid,
});
typedef $$CatalogCacheTableUpdateCompanionBuilder = CatalogCacheCompanion
    Function({
  Value<String> id,
  Value<String> kind,
  Value<String> title,
  Value<String?> sortKey,
  Value<String?> itemNumber,
  Value<String?> synopsis,
  Value<String?> coverImageUrl,
  Value<String?> thumbnailImageUrl,
  Value<String?> editionTitle,
  Value<String?> physicalFormat,
  Value<String?> physicalFormatLabel,
  Value<String?> publisher,
  Value<DateTime?> releaseDate,
  Value<int?> releaseYear,
  Value<String?> barcode,
  Value<String?> variant,
  Value<String?> seriesId,
  Value<String?> seriesTitle,
  Value<String?> volumeName,
  Value<int?> volumeNumber,
  Value<int?> volumeStartYear,
  Value<int?> seasonNumber,
  Value<int?> episodeNumber,
  Value<int?> runtimeMinutes,
  Value<int?> trackCount,
  Value<String?> tracksJson,
  Value<String?> editionsJson,
  Value<String?> creatorsJson,
  Value<String?> charactersJson,
  Value<String?> storyArcsJson,
  Value<String?> seriesTagsJson,
  Value<String?> platformsJson,
  Value<String?> genresJson,
  Value<int?> pageCount,
  Value<int?> coverPriceCents,
  Value<String?> catalogCurrency,
  Value<String?> catalogNumber,
  Value<String?> country,
  Value<String?> releaseStatus,
  Value<String?> language,
  Value<String?> ageRating,
  Value<String?> imprint,
  Value<String?> subtitle,
  Value<String?> seriesGroup,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

class $$CatalogCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $CatalogCacheTable> {
  $$CatalogCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sortKey => $composableBuilder(
      column: $table.sortKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemNumber => $composableBuilder(
      column: $table.itemNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get synopsis => $composableBuilder(
      column: $table.synopsis, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailImageUrl => $composableBuilder(
      column: $table.thumbnailImageUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editionTitle => $composableBuilder(
      column: $table.editionTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get physicalFormat => $composableBuilder(
      column: $table.physicalFormat,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get physicalFormatLabel => $composableBuilder(
      column: $table.physicalFormatLabel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get publisher => $composableBuilder(
      column: $table.publisher, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get releaseDate => $composableBuilder(
      column: $table.releaseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get releaseYear => $composableBuilder(
      column: $table.releaseYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variant => $composableBuilder(
      column: $table.variant, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seriesId => $composableBuilder(
      column: $table.seriesId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seriesTitle => $composableBuilder(
      column: $table.seriesTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get volumeName => $composableBuilder(
      column: $table.volumeName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get volumeNumber => $composableBuilder(
      column: $table.volumeNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get volumeStartYear => $composableBuilder(
      column: $table.volumeStartYear,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get runtimeMinutes => $composableBuilder(
      column: $table.runtimeMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get trackCount => $composableBuilder(
      column: $table.trackCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tracksJson => $composableBuilder(
      column: $table.tracksJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editionsJson => $composableBuilder(
      column: $table.editionsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get creatorsJson => $composableBuilder(
      column: $table.creatorsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get charactersJson => $composableBuilder(
      column: $table.charactersJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storyArcsJson => $composableBuilder(
      column: $table.storyArcsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seriesTagsJson => $composableBuilder(
      column: $table.seriesTagsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get platformsJson => $composableBuilder(
      column: $table.platformsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get genresJson => $composableBuilder(
      column: $table.genresJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageCount => $composableBuilder(
      column: $table.pageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get coverPriceCents => $composableBuilder(
      column: $table.coverPriceCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get catalogCurrency => $composableBuilder(
      column: $table.catalogCurrency,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get catalogNumber => $composableBuilder(
      column: $table.catalogNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get country => $composableBuilder(
      column: $table.country, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get releaseStatus => $composableBuilder(
      column: $table.releaseStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ageRating => $composableBuilder(
      column: $table.ageRating, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imprint => $composableBuilder(
      column: $table.imprint, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subtitle => $composableBuilder(
      column: $table.subtitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seriesGroup => $composableBuilder(
      column: $table.seriesGroup, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CatalogCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $CatalogCacheTable> {
  $$CatalogCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sortKey => $composableBuilder(
      column: $table.sortKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemNumber => $composableBuilder(
      column: $table.itemNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get synopsis => $composableBuilder(
      column: $table.synopsis, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailImageUrl => $composableBuilder(
      column: $table.thumbnailImageUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editionTitle => $composableBuilder(
      column: $table.editionTitle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get physicalFormat => $composableBuilder(
      column: $table.physicalFormat,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get physicalFormatLabel => $composableBuilder(
      column: $table.physicalFormatLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get publisher => $composableBuilder(
      column: $table.publisher, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get releaseDate => $composableBuilder(
      column: $table.releaseDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get releaseYear => $composableBuilder(
      column: $table.releaseYear, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variant => $composableBuilder(
      column: $table.variant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seriesId => $composableBuilder(
      column: $table.seriesId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seriesTitle => $composableBuilder(
      column: $table.seriesTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get volumeName => $composableBuilder(
      column: $table.volumeName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get volumeNumber => $composableBuilder(
      column: $table.volumeNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get volumeStartYear => $composableBuilder(
      column: $table.volumeStartYear,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get runtimeMinutes => $composableBuilder(
      column: $table.runtimeMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get trackCount => $composableBuilder(
      column: $table.trackCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tracksJson => $composableBuilder(
      column: $table.tracksJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editionsJson => $composableBuilder(
      column: $table.editionsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get creatorsJson => $composableBuilder(
      column: $table.creatorsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get charactersJson => $composableBuilder(
      column: $table.charactersJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storyArcsJson => $composableBuilder(
      column: $table.storyArcsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seriesTagsJson => $composableBuilder(
      column: $table.seriesTagsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get platformsJson => $composableBuilder(
      column: $table.platformsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get genresJson => $composableBuilder(
      column: $table.genresJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageCount => $composableBuilder(
      column: $table.pageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get coverPriceCents => $composableBuilder(
      column: $table.coverPriceCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get catalogCurrency => $composableBuilder(
      column: $table.catalogCurrency,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get catalogNumber => $composableBuilder(
      column: $table.catalogNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get country => $composableBuilder(
      column: $table.country, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get releaseStatus => $composableBuilder(
      column: $table.releaseStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ageRating => $composableBuilder(
      column: $table.ageRating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imprint => $composableBuilder(
      column: $table.imprint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subtitle => $composableBuilder(
      column: $table.subtitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seriesGroup => $composableBuilder(
      column: $table.seriesGroup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CatalogCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $CatalogCacheTable> {
  $$CatalogCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => column);

  GeneratedColumn<String> get itemNumber => $composableBuilder(
      column: $table.itemNumber, builder: (column) => column);

  GeneratedColumn<String> get synopsis =>
      $composableBuilder(column: $table.synopsis, builder: (column) => column);

  GeneratedColumn<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbnailImageUrl => $composableBuilder(
      column: $table.thumbnailImageUrl, builder: (column) => column);

  GeneratedColumn<String> get editionTitle => $composableBuilder(
      column: $table.editionTitle, builder: (column) => column);

  GeneratedColumn<String> get physicalFormat => $composableBuilder(
      column: $table.physicalFormat, builder: (column) => column);

  GeneratedColumn<String> get physicalFormatLabel => $composableBuilder(
      column: $table.physicalFormatLabel, builder: (column) => column);

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<DateTime> get releaseDate => $composableBuilder(
      column: $table.releaseDate, builder: (column) => column);

  GeneratedColumn<int> get releaseYear => $composableBuilder(
      column: $table.releaseYear, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get variant =>
      $composableBuilder(column: $table.variant, builder: (column) => column);

  GeneratedColumn<String> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<String> get seriesTitle => $composableBuilder(
      column: $table.seriesTitle, builder: (column) => column);

  GeneratedColumn<String> get volumeName => $composableBuilder(
      column: $table.volumeName, builder: (column) => column);

  GeneratedColumn<int> get volumeNumber => $composableBuilder(
      column: $table.volumeNumber, builder: (column) => column);

  GeneratedColumn<int> get volumeStartYear => $composableBuilder(
      column: $table.volumeStartYear, builder: (column) => column);

  GeneratedColumn<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber, builder: (column) => column);

  GeneratedColumn<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber, builder: (column) => column);

  GeneratedColumn<int> get runtimeMinutes => $composableBuilder(
      column: $table.runtimeMinutes, builder: (column) => column);

  GeneratedColumn<int> get trackCount => $composableBuilder(
      column: $table.trackCount, builder: (column) => column);

  GeneratedColumn<String> get tracksJson => $composableBuilder(
      column: $table.tracksJson, builder: (column) => column);

  GeneratedColumn<String> get editionsJson => $composableBuilder(
      column: $table.editionsJson, builder: (column) => column);

  GeneratedColumn<String> get creatorsJson => $composableBuilder(
      column: $table.creatorsJson, builder: (column) => column);

  GeneratedColumn<String> get charactersJson => $composableBuilder(
      column: $table.charactersJson, builder: (column) => column);

  GeneratedColumn<String> get storyArcsJson => $composableBuilder(
      column: $table.storyArcsJson, builder: (column) => column);

  GeneratedColumn<String> get seriesTagsJson => $composableBuilder(
      column: $table.seriesTagsJson, builder: (column) => column);

  GeneratedColumn<String> get platformsJson => $composableBuilder(
      column: $table.platformsJson, builder: (column) => column);

  GeneratedColumn<String> get genresJson => $composableBuilder(
      column: $table.genresJson, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<int> get coverPriceCents => $composableBuilder(
      column: $table.coverPriceCents, builder: (column) => column);

  GeneratedColumn<String> get catalogCurrency => $composableBuilder(
      column: $table.catalogCurrency, builder: (column) => column);

  GeneratedColumn<String> get catalogNumber => $composableBuilder(
      column: $table.catalogNumber, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get releaseStatus => $composableBuilder(
      column: $table.releaseStatus, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get ageRating =>
      $composableBuilder(column: $table.ageRating, builder: (column) => column);

  GeneratedColumn<String> get imprint =>
      $composableBuilder(column: $table.imprint, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get seriesGroup => $composableBuilder(
      column: $table.seriesGroup, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CatalogCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $CatalogCacheTable,
    CatalogCacheData,
    $$CatalogCacheTableFilterComposer,
    $$CatalogCacheTableOrderingComposer,
    $$CatalogCacheTableAnnotationComposer,
    $$CatalogCacheTableCreateCompanionBuilder,
    $$CatalogCacheTableUpdateCompanionBuilder,
    (
      CatalogCacheData,
      BaseReferences<_$LocalDatabase, $CatalogCacheTable, CatalogCacheData>
    ),
    CatalogCacheData,
    PrefetchHooks Function()> {
  $$CatalogCacheTableTableManager(_$LocalDatabase db, $CatalogCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> sortKey = const Value.absent(),
            Value<String?> itemNumber = const Value.absent(),
            Value<String?> synopsis = const Value.absent(),
            Value<String?> coverImageUrl = const Value.absent(),
            Value<String?> thumbnailImageUrl = const Value.absent(),
            Value<String?> editionTitle = const Value.absent(),
            Value<String?> physicalFormat = const Value.absent(),
            Value<String?> physicalFormatLabel = const Value.absent(),
            Value<String?> publisher = const Value.absent(),
            Value<DateTime?> releaseDate = const Value.absent(),
            Value<int?> releaseYear = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<String?> variant = const Value.absent(),
            Value<String?> seriesId = const Value.absent(),
            Value<String?> seriesTitle = const Value.absent(),
            Value<String?> volumeName = const Value.absent(),
            Value<int?> volumeNumber = const Value.absent(),
            Value<int?> volumeStartYear = const Value.absent(),
            Value<int?> seasonNumber = const Value.absent(),
            Value<int?> episodeNumber = const Value.absent(),
            Value<int?> runtimeMinutes = const Value.absent(),
            Value<int?> trackCount = const Value.absent(),
            Value<String?> tracksJson = const Value.absent(),
            Value<String?> editionsJson = const Value.absent(),
            Value<String?> creatorsJson = const Value.absent(),
            Value<String?> charactersJson = const Value.absent(),
            Value<String?> storyArcsJson = const Value.absent(),
            Value<String?> seriesTagsJson = const Value.absent(),
            Value<String?> platformsJson = const Value.absent(),
            Value<String?> genresJson = const Value.absent(),
            Value<int?> pageCount = const Value.absent(),
            Value<int?> coverPriceCents = const Value.absent(),
            Value<String?> catalogCurrency = const Value.absent(),
            Value<String?> catalogNumber = const Value.absent(),
            Value<String?> country = const Value.absent(),
            Value<String?> releaseStatus = const Value.absent(),
            Value<String?> language = const Value.absent(),
            Value<String?> ageRating = const Value.absent(),
            Value<String?> imprint = const Value.absent(),
            Value<String?> subtitle = const Value.absent(),
            Value<String?> seriesGroup = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogCacheCompanion(
            id: id,
            kind: kind,
            title: title,
            sortKey: sortKey,
            itemNumber: itemNumber,
            synopsis: synopsis,
            coverImageUrl: coverImageUrl,
            thumbnailImageUrl: thumbnailImageUrl,
            editionTitle: editionTitle,
            physicalFormat: physicalFormat,
            physicalFormatLabel: physicalFormatLabel,
            publisher: publisher,
            releaseDate: releaseDate,
            releaseYear: releaseYear,
            barcode: barcode,
            variant: variant,
            seriesId: seriesId,
            seriesTitle: seriesTitle,
            volumeName: volumeName,
            volumeNumber: volumeNumber,
            volumeStartYear: volumeStartYear,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            runtimeMinutes: runtimeMinutes,
            trackCount: trackCount,
            tracksJson: tracksJson,
            editionsJson: editionsJson,
            creatorsJson: creatorsJson,
            charactersJson: charactersJson,
            storyArcsJson: storyArcsJson,
            seriesTagsJson: seriesTagsJson,
            platformsJson: platformsJson,
            genresJson: genresJson,
            pageCount: pageCount,
            coverPriceCents: coverPriceCents,
            catalogCurrency: catalogCurrency,
            catalogNumber: catalogNumber,
            country: country,
            releaseStatus: releaseStatus,
            language: language,
            ageRating: ageRating,
            imprint: imprint,
            subtitle: subtitle,
            seriesGroup: seriesGroup,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String kind,
            required String title,
            Value<String?> sortKey = const Value.absent(),
            Value<String?> itemNumber = const Value.absent(),
            Value<String?> synopsis = const Value.absent(),
            Value<String?> coverImageUrl = const Value.absent(),
            Value<String?> thumbnailImageUrl = const Value.absent(),
            Value<String?> editionTitle = const Value.absent(),
            Value<String?> physicalFormat = const Value.absent(),
            Value<String?> physicalFormatLabel = const Value.absent(),
            Value<String?> publisher = const Value.absent(),
            Value<DateTime?> releaseDate = const Value.absent(),
            Value<int?> releaseYear = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<String?> variant = const Value.absent(),
            Value<String?> seriesId = const Value.absent(),
            Value<String?> seriesTitle = const Value.absent(),
            Value<String?> volumeName = const Value.absent(),
            Value<int?> volumeNumber = const Value.absent(),
            Value<int?> volumeStartYear = const Value.absent(),
            Value<int?> seasonNumber = const Value.absent(),
            Value<int?> episodeNumber = const Value.absent(),
            Value<int?> runtimeMinutes = const Value.absent(),
            Value<int?> trackCount = const Value.absent(),
            Value<String?> tracksJson = const Value.absent(),
            Value<String?> editionsJson = const Value.absent(),
            Value<String?> creatorsJson = const Value.absent(),
            Value<String?> charactersJson = const Value.absent(),
            Value<String?> storyArcsJson = const Value.absent(),
            Value<String?> seriesTagsJson = const Value.absent(),
            Value<String?> platformsJson = const Value.absent(),
            Value<String?> genresJson = const Value.absent(),
            Value<int?> pageCount = const Value.absent(),
            Value<int?> coverPriceCents = const Value.absent(),
            Value<String?> catalogCurrency = const Value.absent(),
            Value<String?> catalogNumber = const Value.absent(),
            Value<String?> country = const Value.absent(),
            Value<String?> releaseStatus = const Value.absent(),
            Value<String?> language = const Value.absent(),
            Value<String?> ageRating = const Value.absent(),
            Value<String?> imprint = const Value.absent(),
            Value<String?> subtitle = const Value.absent(),
            Value<String?> seriesGroup = const Value.absent(),
            required DateTime cachedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogCacheCompanion.insert(
            id: id,
            kind: kind,
            title: title,
            sortKey: sortKey,
            itemNumber: itemNumber,
            synopsis: synopsis,
            coverImageUrl: coverImageUrl,
            thumbnailImageUrl: thumbnailImageUrl,
            editionTitle: editionTitle,
            physicalFormat: physicalFormat,
            physicalFormatLabel: physicalFormatLabel,
            publisher: publisher,
            releaseDate: releaseDate,
            releaseYear: releaseYear,
            barcode: barcode,
            variant: variant,
            seriesId: seriesId,
            seriesTitle: seriesTitle,
            volumeName: volumeName,
            volumeNumber: volumeNumber,
            volumeStartYear: volumeStartYear,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            runtimeMinutes: runtimeMinutes,
            trackCount: trackCount,
            tracksJson: tracksJson,
            editionsJson: editionsJson,
            creatorsJson: creatorsJson,
            charactersJson: charactersJson,
            storyArcsJson: storyArcsJson,
            seriesTagsJson: seriesTagsJson,
            platformsJson: platformsJson,
            genresJson: genresJson,
            pageCount: pageCount,
            coverPriceCents: coverPriceCents,
            catalogCurrency: catalogCurrency,
            catalogNumber: catalogNumber,
            country: country,
            releaseStatus: releaseStatus,
            language: language,
            ageRating: ageRating,
            imprint: imprint,
            subtitle: subtitle,
            seriesGroup: seriesGroup,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CatalogCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $CatalogCacheTable,
    CatalogCacheData,
    $$CatalogCacheTableFilterComposer,
    $$CatalogCacheTableOrderingComposer,
    $$CatalogCacheTableAnnotationComposer,
    $$CatalogCacheTableCreateCompanionBuilder,
    $$CatalogCacheTableUpdateCompanionBuilder,
    (
      CatalogCacheData,
      BaseReferences<_$LocalDatabase, $CatalogCacheTable, CatalogCacheData>
    ),
    CatalogCacheData,
    PrefetchHooks Function()>;
typedef $$OwnedItemsCacheTableCreateCompanionBuilder = OwnedItemsCacheCompanion
    Function({
  required String id,
  required String itemId,
  Value<String?> anchorType,
  Value<String?> editionId,
  Value<String?> variantId,
  Value<String?> bundleReleaseId,
  Value<String?> condition,
  Value<String?> grade,
  Value<DateTime?> purchaseDate,
  Value<int?> pricePaidCents,
  Value<String?> currency,
  Value<String?> personalNotes,
  Value<int> quantity,
  Value<String?> storageBox,
  Value<int?> indexNumber,
  Value<int?> coverPriceCents,
  Value<String?> rawOrSlabbed,
  Value<String?> gradingCompany,
  Value<String?> graderNotes,
  Value<String?> signedBy,
  Value<bool> keyComic,
  Value<String?> keyReason,
  Value<int?> rating,
  Value<String?> readStatus,
  Value<DateTime?> startedAt,
  Value<DateTime?> finishedAt,
  Value<String?> tags,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> soldAt,
  Value<int?> sellPriceCents,
  Value<String?> soldTo,
  Value<String?> locationId,
  Value<int> rowid,
});
typedef $$OwnedItemsCacheTableUpdateCompanionBuilder = OwnedItemsCacheCompanion
    Function({
  Value<String> id,
  Value<String> itemId,
  Value<String?> anchorType,
  Value<String?> editionId,
  Value<String?> variantId,
  Value<String?> bundleReleaseId,
  Value<String?> condition,
  Value<String?> grade,
  Value<DateTime?> purchaseDate,
  Value<int?> pricePaidCents,
  Value<String?> currency,
  Value<String?> personalNotes,
  Value<int> quantity,
  Value<String?> storageBox,
  Value<int?> indexNumber,
  Value<int?> coverPriceCents,
  Value<String?> rawOrSlabbed,
  Value<String?> gradingCompany,
  Value<String?> graderNotes,
  Value<String?> signedBy,
  Value<bool> keyComic,
  Value<String?> keyReason,
  Value<int?> rating,
  Value<String?> readStatus,
  Value<DateTime?> startedAt,
  Value<DateTime?> finishedAt,
  Value<String?> tags,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> soldAt,
  Value<int?> sellPriceCents,
  Value<String?> soldTo,
  Value<String?> locationId,
  Value<int> rowid,
});

class $$OwnedItemsCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $OwnedItemsCacheTable> {
  $$OwnedItemsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get anchorType => $composableBuilder(
      column: $table.anchorType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bundleReleaseId => $composableBuilder(
      column: $table.bundleReleaseId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pricePaidCents => $composableBuilder(
      column: $table.pricePaidCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get personalNotes => $composableBuilder(
      column: $table.personalNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storageBox => $composableBuilder(
      column: $table.storageBox, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get indexNumber => $composableBuilder(
      column: $table.indexNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get coverPriceCents => $composableBuilder(
      column: $table.coverPriceCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawOrSlabbed => $composableBuilder(
      column: $table.rawOrSlabbed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gradingCompany => $composableBuilder(
      column: $table.gradingCompany,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get graderNotes => $composableBuilder(
      column: $table.graderNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get signedBy => $composableBuilder(
      column: $table.signedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get keyComic => $composableBuilder(
      column: $table.keyComic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get keyReason => $composableBuilder(
      column: $table.keyReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get readStatus => $composableBuilder(
      column: $table.readStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get soldAt => $composableBuilder(
      column: $table.soldAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sellPriceCents => $composableBuilder(
      column: $table.sellPriceCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get soldTo => $composableBuilder(
      column: $table.soldTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnFilters(column));
}

class $$OwnedItemsCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $OwnedItemsCacheTable> {
  $$OwnedItemsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get anchorType => $composableBuilder(
      column: $table.anchorType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bundleReleaseId => $composableBuilder(
      column: $table.bundleReleaseId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pricePaidCents => $composableBuilder(
      column: $table.pricePaidCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personalNotes => $composableBuilder(
      column: $table.personalNotes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storageBox => $composableBuilder(
      column: $table.storageBox, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get indexNumber => $composableBuilder(
      column: $table.indexNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get coverPriceCents => $composableBuilder(
      column: $table.coverPriceCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawOrSlabbed => $composableBuilder(
      column: $table.rawOrSlabbed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gradingCompany => $composableBuilder(
      column: $table.gradingCompany,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get graderNotes => $composableBuilder(
      column: $table.graderNotes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get signedBy => $composableBuilder(
      column: $table.signedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get keyComic => $composableBuilder(
      column: $table.keyComic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get keyReason => $composableBuilder(
      column: $table.keyReason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get readStatus => $composableBuilder(
      column: $table.readStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get soldAt => $composableBuilder(
      column: $table.soldAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sellPriceCents => $composableBuilder(
      column: $table.sellPriceCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get soldTo => $composableBuilder(
      column: $table.soldTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnOrderings(column));
}

class $$OwnedItemsCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $OwnedItemsCacheTable> {
  $$OwnedItemsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get anchorType => $composableBuilder(
      column: $table.anchorType, builder: (column) => column);

  GeneratedColumn<String> get editionId =>
      $composableBuilder(column: $table.editionId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get bundleReleaseId => $composableBuilder(
      column: $table.bundleReleaseId, builder: (column) => column);

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate, builder: (column) => column);

  GeneratedColumn<int> get pricePaidCents => $composableBuilder(
      column: $table.pricePaidCents, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get personalNotes => $composableBuilder(
      column: $table.personalNotes, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get storageBox => $composableBuilder(
      column: $table.storageBox, builder: (column) => column);

  GeneratedColumn<int> get indexNumber => $composableBuilder(
      column: $table.indexNumber, builder: (column) => column);

  GeneratedColumn<int> get coverPriceCents => $composableBuilder(
      column: $table.coverPriceCents, builder: (column) => column);

  GeneratedColumn<String> get rawOrSlabbed => $composableBuilder(
      column: $table.rawOrSlabbed, builder: (column) => column);

  GeneratedColumn<String> get gradingCompany => $composableBuilder(
      column: $table.gradingCompany, builder: (column) => column);

  GeneratedColumn<String> get graderNotes => $composableBuilder(
      column: $table.graderNotes, builder: (column) => column);

  GeneratedColumn<String> get signedBy =>
      $composableBuilder(column: $table.signedBy, builder: (column) => column);

  GeneratedColumn<bool> get keyComic =>
      $composableBuilder(column: $table.keyComic, builder: (column) => column);

  GeneratedColumn<String> get keyReason =>
      $composableBuilder(column: $table.keyReason, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get readStatus => $composableBuilder(
      column: $table.readStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get soldAt =>
      $composableBuilder(column: $table.soldAt, builder: (column) => column);

  GeneratedColumn<int> get sellPriceCents => $composableBuilder(
      column: $table.sellPriceCents, builder: (column) => column);

  GeneratedColumn<String> get soldTo =>
      $composableBuilder(column: $table.soldTo, builder: (column) => column);

  GeneratedColumn<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => column);
}

class $$OwnedItemsCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $OwnedItemsCacheTable,
    OwnedItemsCacheData,
    $$OwnedItemsCacheTableFilterComposer,
    $$OwnedItemsCacheTableOrderingComposer,
    $$OwnedItemsCacheTableAnnotationComposer,
    $$OwnedItemsCacheTableCreateCompanionBuilder,
    $$OwnedItemsCacheTableUpdateCompanionBuilder,
    (
      OwnedItemsCacheData,
      BaseReferences<_$LocalDatabase, $OwnedItemsCacheTable,
          OwnedItemsCacheData>
    ),
    OwnedItemsCacheData,
    PrefetchHooks Function()> {
  $$OwnedItemsCacheTableTableManager(
      _$LocalDatabase db, $OwnedItemsCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OwnedItemsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OwnedItemsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OwnedItemsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String?> anchorType = const Value.absent(),
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> bundleReleaseId = const Value.absent(),
            Value<String?> condition = const Value.absent(),
            Value<String?> grade = const Value.absent(),
            Value<DateTime?> purchaseDate = const Value.absent(),
            Value<int?> pricePaidCents = const Value.absent(),
            Value<String?> currency = const Value.absent(),
            Value<String?> personalNotes = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String?> storageBox = const Value.absent(),
            Value<int?> indexNumber = const Value.absent(),
            Value<int?> coverPriceCents = const Value.absent(),
            Value<String?> rawOrSlabbed = const Value.absent(),
            Value<String?> gradingCompany = const Value.absent(),
            Value<String?> graderNotes = const Value.absent(),
            Value<String?> signedBy = const Value.absent(),
            Value<bool> keyComic = const Value.absent(),
            Value<String?> keyReason = const Value.absent(),
            Value<int?> rating = const Value.absent(),
            Value<String?> readStatus = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> finishedAt = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTime?> soldAt = const Value.absent(),
            Value<int?> sellPriceCents = const Value.absent(),
            Value<String?> soldTo = const Value.absent(),
            Value<String?> locationId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OwnedItemsCacheCompanion(
            id: id,
            itemId: itemId,
            anchorType: anchorType,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
            condition: condition,
            grade: grade,
            purchaseDate: purchaseDate,
            pricePaidCents: pricePaidCents,
            currency: currency,
            personalNotes: personalNotes,
            quantity: quantity,
            storageBox: storageBox,
            indexNumber: indexNumber,
            coverPriceCents: coverPriceCents,
            rawOrSlabbed: rawOrSlabbed,
            gradingCompany: gradingCompany,
            graderNotes: graderNotes,
            signedBy: signedBy,
            keyComic: keyComic,
            keyReason: keyReason,
            rating: rating,
            readStatus: readStatus,
            startedAt: startedAt,
            finishedAt: finishedAt,
            tags: tags,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            soldAt: soldAt,
            sellPriceCents: sellPriceCents,
            soldTo: soldTo,
            locationId: locationId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            Value<String?> anchorType = const Value.absent(),
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> bundleReleaseId = const Value.absent(),
            Value<String?> condition = const Value.absent(),
            Value<String?> grade = const Value.absent(),
            Value<DateTime?> purchaseDate = const Value.absent(),
            Value<int?> pricePaidCents = const Value.absent(),
            Value<String?> currency = const Value.absent(),
            Value<String?> personalNotes = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String?> storageBox = const Value.absent(),
            Value<int?> indexNumber = const Value.absent(),
            Value<int?> coverPriceCents = const Value.absent(),
            Value<String?> rawOrSlabbed = const Value.absent(),
            Value<String?> gradingCompany = const Value.absent(),
            Value<String?> graderNotes = const Value.absent(),
            Value<String?> signedBy = const Value.absent(),
            Value<bool> keyComic = const Value.absent(),
            Value<String?> keyReason = const Value.absent(),
            Value<int?> rating = const Value.absent(),
            Value<String?> readStatus = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> finishedAt = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTime?> soldAt = const Value.absent(),
            Value<int?> sellPriceCents = const Value.absent(),
            Value<String?> soldTo = const Value.absent(),
            Value<String?> locationId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OwnedItemsCacheCompanion.insert(
            id: id,
            itemId: itemId,
            anchorType: anchorType,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
            condition: condition,
            grade: grade,
            purchaseDate: purchaseDate,
            pricePaidCents: pricePaidCents,
            currency: currency,
            personalNotes: personalNotes,
            quantity: quantity,
            storageBox: storageBox,
            indexNumber: indexNumber,
            coverPriceCents: coverPriceCents,
            rawOrSlabbed: rawOrSlabbed,
            gradingCompany: gradingCompany,
            graderNotes: graderNotes,
            signedBy: signedBy,
            keyComic: keyComic,
            keyReason: keyReason,
            rating: rating,
            readStatus: readStatus,
            startedAt: startedAt,
            finishedAt: finishedAt,
            tags: tags,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            soldAt: soldAt,
            sellPriceCents: sellPriceCents,
            soldTo: soldTo,
            locationId: locationId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OwnedItemsCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $OwnedItemsCacheTable,
    OwnedItemsCacheData,
    $$OwnedItemsCacheTableFilterComposer,
    $$OwnedItemsCacheTableOrderingComposer,
    $$OwnedItemsCacheTableAnnotationComposer,
    $$OwnedItemsCacheTableCreateCompanionBuilder,
    $$OwnedItemsCacheTableUpdateCompanionBuilder,
    (
      OwnedItemsCacheData,
      BaseReferences<_$LocalDatabase, $OwnedItemsCacheTable,
          OwnedItemsCacheData>
    ),
    OwnedItemsCacheData,
    PrefetchHooks Function()>;
typedef $$WishlistItemsCacheTableCreateCompanionBuilder
    = WishlistItemsCacheCompanion Function({
  required String id,
  required String itemId,
  Value<String?> anchorType,
  Value<String?> editionId,
  Value<String?> variantId,
  Value<String?> bundleReleaseId,
  Value<int?> targetPriceCents,
  Value<String?> currency,
  Value<String?> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$WishlistItemsCacheTableUpdateCompanionBuilder
    = WishlistItemsCacheCompanion Function({
  Value<String> id,
  Value<String> itemId,
  Value<String?> anchorType,
  Value<String?> editionId,
  Value<String?> variantId,
  Value<String?> bundleReleaseId,
  Value<int?> targetPriceCents,
  Value<String?> currency,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$WishlistItemsCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $WishlistItemsCacheTable> {
  $$WishlistItemsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get anchorType => $composableBuilder(
      column: $table.anchorType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bundleReleaseId => $composableBuilder(
      column: $table.bundleReleaseId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetPriceCents => $composableBuilder(
      column: $table.targetPriceCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$WishlistItemsCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $WishlistItemsCacheTable> {
  $$WishlistItemsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get anchorType => $composableBuilder(
      column: $table.anchorType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bundleReleaseId => $composableBuilder(
      column: $table.bundleReleaseId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetPriceCents => $composableBuilder(
      column: $table.targetPriceCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$WishlistItemsCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $WishlistItemsCacheTable> {
  $$WishlistItemsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get anchorType => $composableBuilder(
      column: $table.anchorType, builder: (column) => column);

  GeneratedColumn<String> get editionId =>
      $composableBuilder(column: $table.editionId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get bundleReleaseId => $composableBuilder(
      column: $table.bundleReleaseId, builder: (column) => column);

  GeneratedColumn<int> get targetPriceCents => $composableBuilder(
      column: $table.targetPriceCents, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$WishlistItemsCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $WishlistItemsCacheTable,
    WishlistItemsCacheData,
    $$WishlistItemsCacheTableFilterComposer,
    $$WishlistItemsCacheTableOrderingComposer,
    $$WishlistItemsCacheTableAnnotationComposer,
    $$WishlistItemsCacheTableCreateCompanionBuilder,
    $$WishlistItemsCacheTableUpdateCompanionBuilder,
    (
      WishlistItemsCacheData,
      BaseReferences<_$LocalDatabase, $WishlistItemsCacheTable,
          WishlistItemsCacheData>
    ),
    WishlistItemsCacheData,
    PrefetchHooks Function()> {
  $$WishlistItemsCacheTableTableManager(
      _$LocalDatabase db, $WishlistItemsCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WishlistItemsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WishlistItemsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WishlistItemsCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String?> anchorType = const Value.absent(),
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> bundleReleaseId = const Value.absent(),
            Value<int?> targetPriceCents = const Value.absent(),
            Value<String?> currency = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WishlistItemsCacheCompanion(
            id: id,
            itemId: itemId,
            anchorType: anchorType,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
            targetPriceCents: targetPriceCents,
            currency: currency,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            Value<String?> anchorType = const Value.absent(),
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> bundleReleaseId = const Value.absent(),
            Value<int?> targetPriceCents = const Value.absent(),
            Value<String?> currency = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WishlistItemsCacheCompanion.insert(
            id: id,
            itemId: itemId,
            anchorType: anchorType,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
            targetPriceCents: targetPriceCents,
            currency: currency,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WishlistItemsCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $WishlistItemsCacheTable,
    WishlistItemsCacheData,
    $$WishlistItemsCacheTableFilterComposer,
    $$WishlistItemsCacheTableOrderingComposer,
    $$WishlistItemsCacheTableAnnotationComposer,
    $$WishlistItemsCacheTableCreateCompanionBuilder,
    $$WishlistItemsCacheTableUpdateCompanionBuilder,
    (
      WishlistItemsCacheData,
      BaseReferences<_$LocalDatabase, $WishlistItemsCacheTable,
          WishlistItemsCacheData>
    ),
    WishlistItemsCacheData,
    PrefetchHooks Function()>;
typedef $$TrackingEntriesCacheTableCreateCompanionBuilder
    = TrackingEntriesCacheCompanion Function({
  required String id,
  required String itemId,
  Value<String?> ownedItemId,
  Value<String?> editionId,
  Value<String?> variantId,
  Value<String?> sourceType,
  Value<String?> status,
  Value<int?> rating,
  Value<DateTime?> startedAt,
  Value<DateTime?> finishedAt,
  Value<int?> progressCurrent,
  Value<int?> progressTotal,
  Value<int?> timesCompleted,
  Value<String?> notes,
  Value<int?> seasonNumber,
  Value<int?> episodeNumber,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$TrackingEntriesCacheTableUpdateCompanionBuilder
    = TrackingEntriesCacheCompanion Function({
  Value<String> id,
  Value<String> itemId,
  Value<String?> ownedItemId,
  Value<String?> editionId,
  Value<String?> variantId,
  Value<String?> sourceType,
  Value<String?> status,
  Value<int?> rating,
  Value<DateTime?> startedAt,
  Value<DateTime?> finishedAt,
  Value<int?> progressCurrent,
  Value<int?> progressTotal,
  Value<int?> timesCompleted,
  Value<String?> notes,
  Value<int?> seasonNumber,
  Value<int?> episodeNumber,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$TrackingEntriesCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $TrackingEntriesCacheTable> {
  $$TrackingEntriesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get progressCurrent => $composableBuilder(
      column: $table.progressCurrent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get progressTotal => $composableBuilder(
      column: $table.progressTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timesCompleted => $composableBuilder(
      column: $table.timesCompleted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$TrackingEntriesCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $TrackingEntriesCacheTable> {
  $$TrackingEntriesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editionId => $composableBuilder(
      column: $table.editionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantId => $composableBuilder(
      column: $table.variantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get progressCurrent => $composableBuilder(
      column: $table.progressCurrent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get progressTotal => $composableBuilder(
      column: $table.progressTotal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timesCompleted => $composableBuilder(
      column: $table.timesCompleted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$TrackingEntriesCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $TrackingEntriesCacheTable> {
  $$TrackingEntriesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => column);

  GeneratedColumn<String> get editionId =>
      $composableBuilder(column: $table.editionId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => column);

  GeneratedColumn<int> get progressCurrent => $composableBuilder(
      column: $table.progressCurrent, builder: (column) => column);

  GeneratedColumn<int> get progressTotal => $composableBuilder(
      column: $table.progressTotal, builder: (column) => column);

  GeneratedColumn<int> get timesCompleted => $composableBuilder(
      column: $table.timesCompleted, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get seasonNumber => $composableBuilder(
      column: $table.seasonNumber, builder: (column) => column);

  GeneratedColumn<int> get episodeNumber => $composableBuilder(
      column: $table.episodeNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TrackingEntriesCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $TrackingEntriesCacheTable,
    TrackingEntriesCacheData,
    $$TrackingEntriesCacheTableFilterComposer,
    $$TrackingEntriesCacheTableOrderingComposer,
    $$TrackingEntriesCacheTableAnnotationComposer,
    $$TrackingEntriesCacheTableCreateCompanionBuilder,
    $$TrackingEntriesCacheTableUpdateCompanionBuilder,
    (
      TrackingEntriesCacheData,
      BaseReferences<_$LocalDatabase, $TrackingEntriesCacheTable,
          TrackingEntriesCacheData>
    ),
    TrackingEntriesCacheData,
    PrefetchHooks Function()> {
  $$TrackingEntriesCacheTableTableManager(
      _$LocalDatabase db, $TrackingEntriesCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackingEntriesCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackingEntriesCacheTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackingEntriesCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String?> ownedItemId = const Value.absent(),
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> sourceType = const Value.absent(),
            Value<String?> status = const Value.absent(),
            Value<int?> rating = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> finishedAt = const Value.absent(),
            Value<int?> progressCurrent = const Value.absent(),
            Value<int?> progressTotal = const Value.absent(),
            Value<int?> timesCompleted = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> seasonNumber = const Value.absent(),
            Value<int?> episodeNumber = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackingEntriesCacheCompanion(
            id: id,
            itemId: itemId,
            ownedItemId: ownedItemId,
            editionId: editionId,
            variantId: variantId,
            sourceType: sourceType,
            status: status,
            rating: rating,
            startedAt: startedAt,
            finishedAt: finishedAt,
            progressCurrent: progressCurrent,
            progressTotal: progressTotal,
            timesCompleted: timesCompleted,
            notes: notes,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            Value<String?> ownedItemId = const Value.absent(),
            Value<String?> editionId = const Value.absent(),
            Value<String?> variantId = const Value.absent(),
            Value<String?> sourceType = const Value.absent(),
            Value<String?> status = const Value.absent(),
            Value<int?> rating = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> finishedAt = const Value.absent(),
            Value<int?> progressCurrent = const Value.absent(),
            Value<int?> progressTotal = const Value.absent(),
            Value<int?> timesCompleted = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> seasonNumber = const Value.absent(),
            Value<int?> episodeNumber = const Value.absent(),
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackingEntriesCacheCompanion.insert(
            id: id,
            itemId: itemId,
            ownedItemId: ownedItemId,
            editionId: editionId,
            variantId: variantId,
            sourceType: sourceType,
            status: status,
            rating: rating,
            startedAt: startedAt,
            finishedAt: finishedAt,
            progressCurrent: progressCurrent,
            progressTotal: progressTotal,
            timesCompleted: timesCompleted,
            notes: notes,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TrackingEntriesCacheTableProcessedTableManager
    = ProcessedTableManager<
        _$LocalDatabase,
        $TrackingEntriesCacheTable,
        TrackingEntriesCacheData,
        $$TrackingEntriesCacheTableFilterComposer,
        $$TrackingEntriesCacheTableOrderingComposer,
        $$TrackingEntriesCacheTableAnnotationComposer,
        $$TrackingEntriesCacheTableCreateCompanionBuilder,
        $$TrackingEntriesCacheTableUpdateCompanionBuilder,
        (
          TrackingEntriesCacheData,
          BaseReferences<_$LocalDatabase, $TrackingEntriesCacheTable,
              TrackingEntriesCacheData>
        ),
        TrackingEntriesCacheData,
        PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  required String id,
  required String entityType,
  required String entityId,
  required String action,
  required String payloadJson,
  required DateTime clientChangedAt,
  Value<int> rowid,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<String> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> action,
  Value<String> payloadJson,
  Value<DateTime> clientChangedAt,
  Value<int> rowid,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$LocalDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get clientChangedAt => $composableBuilder(
      column: $table.clientChangedAt,
      builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$LocalDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get clientChangedAt => $composableBuilder(
      column: $table.clientChangedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$LocalDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get clientChangedAt => $composableBuilder(
      column: $table.clientChangedAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$LocalDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$LocalDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> clientChangedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            action: action,
            payloadJson: payloadJson,
            clientChangedAt: clientChangedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityType,
            required String entityId,
            required String action,
            required String payloadJson,
            required DateTime clientChangedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            action: action,
            payloadJson: payloadJson,
            clientChangedAt: clientChangedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$LocalDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()>;
typedef $$CustomFieldDefinitionsCacheTableCreateCompanionBuilder
    = CustomFieldDefinitionsCacheCompanion Function({
  required String id,
  required String name,
  required String fieldType,
  Value<String?> mediaKind,
  Value<int> sortOrder,
  Value<String?> options,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CustomFieldDefinitionsCacheTableUpdateCompanionBuilder
    = CustomFieldDefinitionsCacheCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> fieldType,
  Value<String?> mediaKind,
  Value<int> sortOrder,
  Value<String?> options,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CustomFieldDefinitionsCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $CustomFieldDefinitionsCacheTable> {
  $$CustomFieldDefinitionsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fieldType => $composableBuilder(
      column: $table.fieldType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaKind => $composableBuilder(
      column: $table.mediaKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get options => $composableBuilder(
      column: $table.options, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CustomFieldDefinitionsCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $CustomFieldDefinitionsCacheTable> {
  $$CustomFieldDefinitionsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fieldType => $composableBuilder(
      column: $table.fieldType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaKind => $composableBuilder(
      column: $table.mediaKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get options => $composableBuilder(
      column: $table.options, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CustomFieldDefinitionsCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $CustomFieldDefinitionsCacheTable> {
  $$CustomFieldDefinitionsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get fieldType =>
      $composableBuilder(column: $table.fieldType, builder: (column) => column);

  GeneratedColumn<String> get mediaKind =>
      $composableBuilder(column: $table.mediaKind, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get options =>
      $composableBuilder(column: $table.options, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomFieldDefinitionsCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $CustomFieldDefinitionsCacheTable,
    CustomFieldDefinitionsCacheData,
    $$CustomFieldDefinitionsCacheTableFilterComposer,
    $$CustomFieldDefinitionsCacheTableOrderingComposer,
    $$CustomFieldDefinitionsCacheTableAnnotationComposer,
    $$CustomFieldDefinitionsCacheTableCreateCompanionBuilder,
    $$CustomFieldDefinitionsCacheTableUpdateCompanionBuilder,
    (
      CustomFieldDefinitionsCacheData,
      BaseReferences<_$LocalDatabase, $CustomFieldDefinitionsCacheTable,
          CustomFieldDefinitionsCacheData>
    ),
    CustomFieldDefinitionsCacheData,
    PrefetchHooks Function()> {
  $$CustomFieldDefinitionsCacheTableTableManager(
      _$LocalDatabase db, $CustomFieldDefinitionsCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomFieldDefinitionsCacheTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomFieldDefinitionsCacheTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomFieldDefinitionsCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> fieldType = const Value.absent(),
            Value<String?> mediaKind = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String?> options = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomFieldDefinitionsCacheCompanion(
            id: id,
            name: name,
            fieldType: fieldType,
            mediaKind: mediaKind,
            sortOrder: sortOrder,
            options: options,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String fieldType,
            Value<String?> mediaKind = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String?> options = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomFieldDefinitionsCacheCompanion.insert(
            id: id,
            name: name,
            fieldType: fieldType,
            mediaKind: mediaKind,
            sortOrder: sortOrder,
            options: options,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CustomFieldDefinitionsCacheTableProcessedTableManager
    = ProcessedTableManager<
        _$LocalDatabase,
        $CustomFieldDefinitionsCacheTable,
        CustomFieldDefinitionsCacheData,
        $$CustomFieldDefinitionsCacheTableFilterComposer,
        $$CustomFieldDefinitionsCacheTableOrderingComposer,
        $$CustomFieldDefinitionsCacheTableAnnotationComposer,
        $$CustomFieldDefinitionsCacheTableCreateCompanionBuilder,
        $$CustomFieldDefinitionsCacheTableUpdateCompanionBuilder,
        (
          CustomFieldDefinitionsCacheData,
          BaseReferences<_$LocalDatabase, $CustomFieldDefinitionsCacheTable,
              CustomFieldDefinitionsCacheData>
        ),
        CustomFieldDefinitionsCacheData,
        PrefetchHooks Function()>;
typedef $$CustomFieldValuesCacheTableCreateCompanionBuilder
    = CustomFieldValuesCacheCompanion Function({
  required String id,
  required String ownedItemId,
  required String fieldDefinitionId,
  Value<String?> value,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CustomFieldValuesCacheTableUpdateCompanionBuilder
    = CustomFieldValuesCacheCompanion Function({
  Value<String> id,
  Value<String> ownedItemId,
  Value<String> fieldDefinitionId,
  Value<String?> value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CustomFieldValuesCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $CustomFieldValuesCacheTable> {
  $$CustomFieldValuesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fieldDefinitionId => $composableBuilder(
      column: $table.fieldDefinitionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CustomFieldValuesCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $CustomFieldValuesCacheTable> {
  $$CustomFieldValuesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fieldDefinitionId => $composableBuilder(
      column: $table.fieldDefinitionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CustomFieldValuesCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $CustomFieldValuesCacheTable> {
  $$CustomFieldValuesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => column);

  GeneratedColumn<String> get fieldDefinitionId => $composableBuilder(
      column: $table.fieldDefinitionId, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CustomFieldValuesCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $CustomFieldValuesCacheTable,
    CustomFieldValuesCacheData,
    $$CustomFieldValuesCacheTableFilterComposer,
    $$CustomFieldValuesCacheTableOrderingComposer,
    $$CustomFieldValuesCacheTableAnnotationComposer,
    $$CustomFieldValuesCacheTableCreateCompanionBuilder,
    $$CustomFieldValuesCacheTableUpdateCompanionBuilder,
    (
      CustomFieldValuesCacheData,
      BaseReferences<_$LocalDatabase, $CustomFieldValuesCacheTable,
          CustomFieldValuesCacheData>
    ),
    CustomFieldValuesCacheData,
    PrefetchHooks Function()> {
  $$CustomFieldValuesCacheTableTableManager(
      _$LocalDatabase db, $CustomFieldValuesCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomFieldValuesCacheTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomFieldValuesCacheTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomFieldValuesCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> ownedItemId = const Value.absent(),
            Value<String> fieldDefinitionId = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomFieldValuesCacheCompanion(
            id: id,
            ownedItemId: ownedItemId,
            fieldDefinitionId: fieldDefinitionId,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String ownedItemId,
            required String fieldDefinitionId,
            Value<String?> value = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomFieldValuesCacheCompanion.insert(
            id: id,
            ownedItemId: ownedItemId,
            fieldDefinitionId: fieldDefinitionId,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CustomFieldValuesCacheTableProcessedTableManager
    = ProcessedTableManager<
        _$LocalDatabase,
        $CustomFieldValuesCacheTable,
        CustomFieldValuesCacheData,
        $$CustomFieldValuesCacheTableFilterComposer,
        $$CustomFieldValuesCacheTableOrderingComposer,
        $$CustomFieldValuesCacheTableAnnotationComposer,
        $$CustomFieldValuesCacheTableCreateCompanionBuilder,
        $$CustomFieldValuesCacheTableUpdateCompanionBuilder,
        (
          CustomFieldValuesCacheData,
          BaseReferences<_$LocalDatabase, $CustomFieldValuesCacheTable,
              CustomFieldValuesCacheData>
        ),
        CustomFieldValuesCacheData,
        PrefetchHooks Function()>;
typedef $$ItemImagesCacheTableCreateCompanionBuilder = ItemImagesCacheCompanion
    Function({
  required String id,
  required String ownedItemId,
  Value<String> imageType,
  required String imageData,
  Value<String?> caption,
  Value<int> sortOrder,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ItemImagesCacheTableUpdateCompanionBuilder = ItemImagesCacheCompanion
    Function({
  Value<String> id,
  Value<String> ownedItemId,
  Value<String> imageType,
  Value<String> imageData,
  Value<String?> caption,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ItemImagesCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $ItemImagesCacheTable> {
  $$ItemImagesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageType => $composableBuilder(
      column: $table.imageType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageData => $composableBuilder(
      column: $table.imageData, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ItemImagesCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $ItemImagesCacheTable> {
  $$ItemImagesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageType => $composableBuilder(
      column: $table.imageType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageData => $composableBuilder(
      column: $table.imageData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ItemImagesCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $ItemImagesCacheTable> {
  $$ItemImagesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => column);

  GeneratedColumn<String> get imageType =>
      $composableBuilder(column: $table.imageType, builder: (column) => column);

  GeneratedColumn<String> get imageData =>
      $composableBuilder(column: $table.imageData, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ItemImagesCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $ItemImagesCacheTable,
    ItemImagesCacheData,
    $$ItemImagesCacheTableFilterComposer,
    $$ItemImagesCacheTableOrderingComposer,
    $$ItemImagesCacheTableAnnotationComposer,
    $$ItemImagesCacheTableCreateCompanionBuilder,
    $$ItemImagesCacheTableUpdateCompanionBuilder,
    (
      ItemImagesCacheData,
      BaseReferences<_$LocalDatabase, $ItemImagesCacheTable,
          ItemImagesCacheData>
    ),
    ItemImagesCacheData,
    PrefetchHooks Function()> {
  $$ItemImagesCacheTableTableManager(
      _$LocalDatabase db, $ItemImagesCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemImagesCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemImagesCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemImagesCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> ownedItemId = const Value.absent(),
            Value<String> imageType = const Value.absent(),
            Value<String> imageData = const Value.absent(),
            Value<String?> caption = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemImagesCacheCompanion(
            id: id,
            ownedItemId: ownedItemId,
            imageType: imageType,
            imageData: imageData,
            caption: caption,
            sortOrder: sortOrder,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String ownedItemId,
            Value<String> imageType = const Value.absent(),
            required String imageData,
            Value<String?> caption = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemImagesCacheCompanion.insert(
            id: id,
            ownedItemId: ownedItemId,
            imageType: imageType,
            imageData: imageData,
            caption: caption,
            sortOrder: sortOrder,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItemImagesCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $ItemImagesCacheTable,
    ItemImagesCacheData,
    $$ItemImagesCacheTableFilterComposer,
    $$ItemImagesCacheTableOrderingComposer,
    $$ItemImagesCacheTableAnnotationComposer,
    $$ItemImagesCacheTableCreateCompanionBuilder,
    $$ItemImagesCacheTableUpdateCompanionBuilder,
    (
      ItemImagesCacheData,
      BaseReferences<_$LocalDatabase, $ItemImagesCacheTable,
          ItemImagesCacheData>
    ),
    ItemImagesCacheData,
    PrefetchHooks Function()>;
typedef $$LoansCacheTableCreateCompanionBuilder = LoansCacheCompanion Function({
  required String id,
  required String ownedItemId,
  required String borrowerName,
  required DateTime lentDate,
  Value<DateTime?> dueDate,
  Value<DateTime?> returnedDate,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$LoansCacheTableUpdateCompanionBuilder = LoansCacheCompanion Function({
  Value<String> id,
  Value<String> ownedItemId,
  Value<String> borrowerName,
  Value<DateTime> lentDate,
  Value<DateTime?> dueDate,
  Value<DateTime?> returnedDate,
  Value<String?> notes,
  Value<int> rowid,
});

class $$LoansCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $LoansCacheTable> {
  $$LoansCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get borrowerName => $composableBuilder(
      column: $table.borrowerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lentDate => $composableBuilder(
      column: $table.lentDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get returnedDate => $composableBuilder(
      column: $table.returnedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$LoansCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $LoansCacheTable> {
  $$LoansCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get borrowerName => $composableBuilder(
      column: $table.borrowerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lentDate => $composableBuilder(
      column: $table.lentDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get returnedDate => $composableBuilder(
      column: $table.returnedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$LoansCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LoansCacheTable> {
  $$LoansCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => column);

  GeneratedColumn<String> get borrowerName => $composableBuilder(
      column: $table.borrowerName, builder: (column) => column);

  GeneratedColumn<DateTime> get lentDate =>
      $composableBuilder(column: $table.lentDate, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get returnedDate => $composableBuilder(
      column: $table.returnedDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$LoansCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LoansCacheTable,
    LoansCacheData,
    $$LoansCacheTableFilterComposer,
    $$LoansCacheTableOrderingComposer,
    $$LoansCacheTableAnnotationComposer,
    $$LoansCacheTableCreateCompanionBuilder,
    $$LoansCacheTableUpdateCompanionBuilder,
    (
      LoansCacheData,
      BaseReferences<_$LocalDatabase, $LoansCacheTable, LoansCacheData>
    ),
    LoansCacheData,
    PrefetchHooks Function()> {
  $$LoansCacheTableTableManager(_$LocalDatabase db, $LoansCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoansCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoansCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoansCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> ownedItemId = const Value.absent(),
            Value<String> borrowerName = const Value.absent(),
            Value<DateTime> lentDate = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> returnedDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LoansCacheCompanion(
            id: id,
            ownedItemId: ownedItemId,
            borrowerName: borrowerName,
            lentDate: lentDate,
            dueDate: dueDate,
            returnedDate: returnedDate,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String ownedItemId,
            required String borrowerName,
            required DateTime lentDate,
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> returnedDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LoansCacheCompanion.insert(
            id: id,
            ownedItemId: ownedItemId,
            borrowerName: borrowerName,
            lentDate: lentDate,
            dueDate: dueDate,
            returnedDate: returnedDate,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LoansCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LoansCacheTable,
    LoansCacheData,
    $$LoansCacheTableFilterComposer,
    $$LoansCacheTableOrderingComposer,
    $$LoansCacheTableAnnotationComposer,
    $$LoansCacheTableCreateCompanionBuilder,
    $$LoansCacheTableUpdateCompanionBuilder,
    (
      LoansCacheData,
      BaseReferences<_$LocalDatabase, $LoansCacheTable, LoansCacheData>
    ),
    LoansCacheData,
    PrefetchHooks Function()>;
typedef $$LocationsCacheTableCreateCompanionBuilder = LocationsCacheCompanion
    Function({
  required String id,
  required String name,
  Value<String?> parentId,
  Value<String?> description,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$LocationsCacheTableUpdateCompanionBuilder = LocationsCacheCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> parentId,
  Value<String?> description,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$LocationsCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $LocationsCacheTable> {
  $$LocationsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$LocationsCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocationsCacheTable> {
  $$LocationsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$LocationsCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocationsCacheTable> {
  $$LocationsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$LocationsCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocationsCacheTable,
    LocationsCacheData,
    $$LocationsCacheTableFilterComposer,
    $$LocationsCacheTableOrderingComposer,
    $$LocationsCacheTableAnnotationComposer,
    $$LocationsCacheTableCreateCompanionBuilder,
    $$LocationsCacheTableUpdateCompanionBuilder,
    (
      LocationsCacheData,
      BaseReferences<_$LocalDatabase, $LocationsCacheTable, LocationsCacheData>
    ),
    LocationsCacheData,
    PrefetchHooks Function()> {
  $$LocationsCacheTableTableManager(
      _$LocalDatabase db, $LocationsCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocationsCacheCompanion(
            id: id,
            name: name,
            parentId: parentId,
            description: description,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> parentId = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocationsCacheCompanion.insert(
            id: id,
            name: name,
            parentId: parentId,
            description: description,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocationsCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocationsCacheTable,
    LocationsCacheData,
    $$LocationsCacheTableFilterComposer,
    $$LocationsCacheTableOrderingComposer,
    $$LocationsCacheTableAnnotationComposer,
    $$LocationsCacheTableCreateCompanionBuilder,
    $$LocationsCacheTableUpdateCompanionBuilder,
    (
      LocationsCacheData,
      BaseReferences<_$LocalDatabase, $LocationsCacheTable, LocationsCacheData>
    ),
    LocationsCacheData,
    PrefetchHooks Function()>;
typedef $$SmartListsCacheTableCreateCompanionBuilder = SmartListsCacheCompanion
    Function({
  required String id,
  required String name,
  Value<String?> mediaKind,
  required String criteriaJson,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SmartListsCacheTableUpdateCompanionBuilder = SmartListsCacheCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> mediaKind,
  Value<String> criteriaJson,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SmartListsCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $SmartListsCacheTable> {
  $$SmartListsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaKind => $composableBuilder(
      column: $table.mediaKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get criteriaJson => $composableBuilder(
      column: $table.criteriaJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SmartListsCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $SmartListsCacheTable> {
  $$SmartListsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaKind => $composableBuilder(
      column: $table.mediaKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get criteriaJson => $composableBuilder(
      column: $table.criteriaJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SmartListsCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $SmartListsCacheTable> {
  $$SmartListsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get mediaKind =>
      $composableBuilder(column: $table.mediaKind, builder: (column) => column);

  GeneratedColumn<String> get criteriaJson => $composableBuilder(
      column: $table.criteriaJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SmartListsCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $SmartListsCacheTable,
    SmartListsCacheData,
    $$SmartListsCacheTableFilterComposer,
    $$SmartListsCacheTableOrderingComposer,
    $$SmartListsCacheTableAnnotationComposer,
    $$SmartListsCacheTableCreateCompanionBuilder,
    $$SmartListsCacheTableUpdateCompanionBuilder,
    (
      SmartListsCacheData,
      BaseReferences<_$LocalDatabase, $SmartListsCacheTable,
          SmartListsCacheData>
    ),
    SmartListsCacheData,
    PrefetchHooks Function()> {
  $$SmartListsCacheTableTableManager(
      _$LocalDatabase db, $SmartListsCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SmartListsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SmartListsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SmartListsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> mediaKind = const Value.absent(),
            Value<String> criteriaJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SmartListsCacheCompanion(
            id: id,
            name: name,
            mediaKind: mediaKind,
            criteriaJson: criteriaJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> mediaKind = const Value.absent(),
            required String criteriaJson,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SmartListsCacheCompanion.insert(
            id: id,
            name: name,
            mediaKind: mediaKind,
            criteriaJson: criteriaJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SmartListsCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $SmartListsCacheTable,
    SmartListsCacheData,
    $$SmartListsCacheTableFilterComposer,
    $$SmartListsCacheTableOrderingComposer,
    $$SmartListsCacheTableAnnotationComposer,
    $$SmartListsCacheTableCreateCompanionBuilder,
    $$SmartListsCacheTableUpdateCompanionBuilder,
    (
      SmartListsCacheData,
      BaseReferences<_$LocalDatabase, $SmartListsCacheTable,
          SmartListsCacheData>
    ),
    SmartListsCacheData,
    PrefetchHooks Function()>;
typedef $$UserFoldersCacheTableCreateCompanionBuilder
    = UserFoldersCacheCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  Value<String?> parentId,
  Value<String?> iconName,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$UserFoldersCacheTableUpdateCompanionBuilder
    = UserFoldersCacheCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String?> parentId,
  Value<String?> iconName,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$UserFoldersCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $UserFoldersCacheTable> {
  $$UserFoldersCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$UserFoldersCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $UserFoldersCacheTable> {
  $$UserFoldersCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$UserFoldersCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $UserFoldersCacheTable> {
  $$UserFoldersCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$UserFoldersCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $UserFoldersCacheTable,
    UserFoldersCacheData,
    $$UserFoldersCacheTableFilterComposer,
    $$UserFoldersCacheTableOrderingComposer,
    $$UserFoldersCacheTableAnnotationComposer,
    $$UserFoldersCacheTableCreateCompanionBuilder,
    $$UserFoldersCacheTableUpdateCompanionBuilder,
    (
      UserFoldersCacheData,
      BaseReferences<_$LocalDatabase, $UserFoldersCacheTable,
          UserFoldersCacheData>
    ),
    UserFoldersCacheData,
    PrefetchHooks Function()> {
  $$UserFoldersCacheTableTableManager(
      _$LocalDatabase db, $UserFoldersCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserFoldersCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserFoldersCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserFoldersCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<String?> iconName = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserFoldersCacheCompanion(
            id: id,
            name: name,
            description: description,
            parentId: parentId,
            iconName: iconName,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<String?> iconName = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserFoldersCacheCompanion.insert(
            id: id,
            name: name,
            description: description,
            parentId: parentId,
            iconName: iconName,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserFoldersCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $UserFoldersCacheTable,
    UserFoldersCacheData,
    $$UserFoldersCacheTableFilterComposer,
    $$UserFoldersCacheTableOrderingComposer,
    $$UserFoldersCacheTableAnnotationComposer,
    $$UserFoldersCacheTableCreateCompanionBuilder,
    $$UserFoldersCacheTableUpdateCompanionBuilder,
    (
      UserFoldersCacheData,
      BaseReferences<_$LocalDatabase, $UserFoldersCacheTable,
          UserFoldersCacheData>
    ),
    UserFoldersCacheData,
    PrefetchHooks Function()>;
typedef $$UserFolderItemsCacheTableCreateCompanionBuilder
    = UserFolderItemsCacheCompanion Function({
  required String folderId,
  required String ownedItemId,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$UserFolderItemsCacheTableUpdateCompanionBuilder
    = UserFolderItemsCacheCompanion Function({
  Value<String> folderId,
  Value<String> ownedItemId,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$UserFolderItemsCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $UserFolderItemsCacheTable> {
  $$UserFolderItemsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get folderId => $composableBuilder(
      column: $table.folderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$UserFolderItemsCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $UserFolderItemsCacheTable> {
  $$UserFolderItemsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get folderId => $composableBuilder(
      column: $table.folderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$UserFolderItemsCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $UserFolderItemsCacheTable> {
  $$UserFolderItemsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$UserFolderItemsCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $UserFolderItemsCacheTable,
    UserFolderItemsCacheData,
    $$UserFolderItemsCacheTableFilterComposer,
    $$UserFolderItemsCacheTableOrderingComposer,
    $$UserFolderItemsCacheTableAnnotationComposer,
    $$UserFolderItemsCacheTableCreateCompanionBuilder,
    $$UserFolderItemsCacheTableUpdateCompanionBuilder,
    (
      UserFolderItemsCacheData,
      BaseReferences<_$LocalDatabase, $UserFolderItemsCacheTable,
          UserFolderItemsCacheData>
    ),
    UserFolderItemsCacheData,
    PrefetchHooks Function()> {
  $$UserFolderItemsCacheTableTableManager(
      _$LocalDatabase db, $UserFolderItemsCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserFolderItemsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserFolderItemsCacheTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserFolderItemsCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> folderId = const Value.absent(),
            Value<String> ownedItemId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserFolderItemsCacheCompanion(
            folderId: folderId,
            ownedItemId: ownedItemId,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String folderId,
            required String ownedItemId,
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserFolderItemsCacheCompanion.insert(
            folderId: folderId,
            ownedItemId: ownedItemId,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserFolderItemsCacheTableProcessedTableManager
    = ProcessedTableManager<
        _$LocalDatabase,
        $UserFolderItemsCacheTable,
        UserFolderItemsCacheData,
        $$UserFolderItemsCacheTableFilterComposer,
        $$UserFolderItemsCacheTableOrderingComposer,
        $$UserFolderItemsCacheTableAnnotationComposer,
        $$UserFolderItemsCacheTableCreateCompanionBuilder,
        $$UserFolderItemsCacheTableUpdateCompanionBuilder,
        (
          UserFolderItemsCacheData,
          BaseReferences<_$LocalDatabase, $UserFolderItemsCacheTable,
              UserFolderItemsCacheData>
        ),
        UserFolderItemsCacheData,
        PrefetchHooks Function()>;
typedef $$ReadingQueueCacheTableCreateCompanionBuilder
    = ReadingQueueCacheCompanion Function({
  required String ownedItemId,
  required int position,
  required DateTime addedAt,
  Value<int> rowid,
});
typedef $$ReadingQueueCacheTableUpdateCompanionBuilder
    = ReadingQueueCacheCompanion Function({
  Value<String> ownedItemId,
  Value<int> position,
  Value<DateTime> addedAt,
  Value<int> rowid,
});

class $$ReadingQueueCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $ReadingQueueCacheTable> {
  $$ReadingQueueCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));
}

class $$ReadingQueueCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $ReadingQueueCacheTable> {
  $$ReadingQueueCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));
}

class $$ReadingQueueCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $ReadingQueueCacheTable> {
  $$ReadingQueueCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownedItemId => $composableBuilder(
      column: $table.ownedItemId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$ReadingQueueCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $ReadingQueueCacheTable,
    ReadingQueueCacheData,
    $$ReadingQueueCacheTableFilterComposer,
    $$ReadingQueueCacheTableOrderingComposer,
    $$ReadingQueueCacheTableAnnotationComposer,
    $$ReadingQueueCacheTableCreateCompanionBuilder,
    $$ReadingQueueCacheTableUpdateCompanionBuilder,
    (
      ReadingQueueCacheData,
      BaseReferences<_$LocalDatabase, $ReadingQueueCacheTable,
          ReadingQueueCacheData>
    ),
    ReadingQueueCacheData,
    PrefetchHooks Function()> {
  $$ReadingQueueCacheTableTableManager(
      _$LocalDatabase db, $ReadingQueueCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingQueueCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingQueueCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingQueueCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> ownedItemId = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingQueueCacheCompanion(
            ownedItemId: ownedItemId,
            position: position,
            addedAt: addedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String ownedItemId,
            required int position,
            required DateTime addedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingQueueCacheCompanion.insert(
            ownedItemId: ownedItemId,
            position: position,
            addedAt: addedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReadingQueueCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $ReadingQueueCacheTable,
    ReadingQueueCacheData,
    $$ReadingQueueCacheTableFilterComposer,
    $$ReadingQueueCacheTableOrderingComposer,
    $$ReadingQueueCacheTableAnnotationComposer,
    $$ReadingQueueCacheTableCreateCompanionBuilder,
    $$ReadingQueueCacheTableUpdateCompanionBuilder,
    (
      ReadingQueueCacheData,
      BaseReferences<_$LocalDatabase, $ReadingQueueCacheTable,
          ReadingQueueCacheData>
    ),
    ReadingQueueCacheData,
    PrefetchHooks Function()>;
typedef $$PickListValuesCacheTableCreateCompanionBuilder
    = PickListValuesCacheCompanion Function({
  required String id,
  required String listName,
  Value<String?> mediaKind,
  required String value,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$PickListValuesCacheTableUpdateCompanionBuilder
    = PickListValuesCacheCompanion Function({
  Value<String> id,
  Value<String> listName,
  Value<String?> mediaKind,
  Value<String> value,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$PickListValuesCacheTableFilterComposer
    extends Composer<_$LocalDatabase, $PickListValuesCacheTable> {
  $$PickListValuesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get listName => $composableBuilder(
      column: $table.listName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaKind => $composableBuilder(
      column: $table.mediaKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$PickListValuesCacheTableOrderingComposer
    extends Composer<_$LocalDatabase, $PickListValuesCacheTable> {
  $$PickListValuesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get listName => $composableBuilder(
      column: $table.listName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaKind => $composableBuilder(
      column: $table.mediaKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$PickListValuesCacheTableAnnotationComposer
    extends Composer<_$LocalDatabase, $PickListValuesCacheTable> {
  $$PickListValuesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get listName =>
      $composableBuilder(column: $table.listName, builder: (column) => column);

  GeneratedColumn<String> get mediaKind =>
      $composableBuilder(column: $table.mediaKind, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$PickListValuesCacheTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $PickListValuesCacheTable,
    PickListValuesCacheData,
    $$PickListValuesCacheTableFilterComposer,
    $$PickListValuesCacheTableOrderingComposer,
    $$PickListValuesCacheTableAnnotationComposer,
    $$PickListValuesCacheTableCreateCompanionBuilder,
    $$PickListValuesCacheTableUpdateCompanionBuilder,
    (
      PickListValuesCacheData,
      BaseReferences<_$LocalDatabase, $PickListValuesCacheTable,
          PickListValuesCacheData>
    ),
    PickListValuesCacheData,
    PrefetchHooks Function()> {
  $$PickListValuesCacheTableTableManager(
      _$LocalDatabase db, $PickListValuesCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PickListValuesCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PickListValuesCacheTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PickListValuesCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> listName = const Value.absent(),
            Value<String?> mediaKind = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PickListValuesCacheCompanion(
            id: id,
            listName: listName,
            mediaKind: mediaKind,
            value: value,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String listName,
            Value<String?> mediaKind = const Value.absent(),
            required String value,
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PickListValuesCacheCompanion.insert(
            id: id,
            listName: listName,
            mediaKind: mediaKind,
            value: value,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PickListValuesCacheTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $PickListValuesCacheTable,
    PickListValuesCacheData,
    $$PickListValuesCacheTableFilterComposer,
    $$PickListValuesCacheTableOrderingComposer,
    $$PickListValuesCacheTableAnnotationComposer,
    $$PickListValuesCacheTableCreateCompanionBuilder,
    $$PickListValuesCacheTableUpdateCompanionBuilder,
    (
      PickListValuesCacheData,
      BaseReferences<_$LocalDatabase, $PickListValuesCacheTable,
          PickListValuesCacheData>
    ),
    PickListValuesCacheData,
    PrefetchHooks Function()>;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$CatalogCacheTableTableManager get catalogCache =>
      $$CatalogCacheTableTableManager(_db, _db.catalogCache);
  $$OwnedItemsCacheTableTableManager get ownedItemsCache =>
      $$OwnedItemsCacheTableTableManager(_db, _db.ownedItemsCache);
  $$WishlistItemsCacheTableTableManager get wishlistItemsCache =>
      $$WishlistItemsCacheTableTableManager(_db, _db.wishlistItemsCache);
  $$TrackingEntriesCacheTableTableManager get trackingEntriesCache =>
      $$TrackingEntriesCacheTableTableManager(_db, _db.trackingEntriesCache);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$CustomFieldDefinitionsCacheTableTableManager
      get customFieldDefinitionsCache =>
          $$CustomFieldDefinitionsCacheTableTableManager(
              _db, _db.customFieldDefinitionsCache);
  $$CustomFieldValuesCacheTableTableManager get customFieldValuesCache =>
      $$CustomFieldValuesCacheTableTableManager(
          _db, _db.customFieldValuesCache);
  $$ItemImagesCacheTableTableManager get itemImagesCache =>
      $$ItemImagesCacheTableTableManager(_db, _db.itemImagesCache);
  $$LoansCacheTableTableManager get loansCache =>
      $$LoansCacheTableTableManager(_db, _db.loansCache);
  $$LocationsCacheTableTableManager get locationsCache =>
      $$LocationsCacheTableTableManager(_db, _db.locationsCache);
  $$SmartListsCacheTableTableManager get smartListsCache =>
      $$SmartListsCacheTableTableManager(_db, _db.smartListsCache);
  $$UserFoldersCacheTableTableManager get userFoldersCache =>
      $$UserFoldersCacheTableTableManager(_db, _db.userFoldersCache);
  $$UserFolderItemsCacheTableTableManager get userFolderItemsCache =>
      $$UserFolderItemsCacheTableTableManager(_db, _db.userFolderItemsCache);
  $$ReadingQueueCacheTableTableManager get readingQueueCache =>
      $$ReadingQueueCacheTableTableManager(_db, _db.readingQueueCache);
  $$PickListValuesCacheTableTableManager get pickListValuesCache =>
      $$PickListValuesCacheTableTableManager(_db, _db.pickListValuesCache);
}
