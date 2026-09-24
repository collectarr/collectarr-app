import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_release.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_values.dart';

MovieCatalogFormValues movieCatalogFormValuesFromMedia(MovieMedia media) {
  final release = media.primaryRelease;
  return MovieCatalogFormValues(
    title: media.title,
    sortTitle: media.sortTitle ?? '',
    workDescription: media.description ?? '',
    genres: _stringList(media.rawPayload['genres']),
    originalLanguage: media.originalLanguage ?? '',
    ageRating: media.ageRating ?? '',
    audienceRating: media.audienceRating ?? '',
    runtimeMinutes: media.runtimeMinutes,
    workReleaseDate: media.releaseDate,
    subtitle: media.subtitle ?? '',
    releaseTitle: release?.title ?? '',
    format: release?.format ?? '',
    region: release?.region ?? '',
    releaseDate: release?.releaseDate,
    distributor: release?.distributor ?? '',
    language: release?.language ?? '',
    releaseDescription: release?.description ?? '',
    coverImageUrl: release?.coverImageUrl ?? '',
    barcode: _rawText(release?.rawPayload['barcode']) ?? '',
    itemNumber: _rawText(release?.rawPayload['item_number']) ?? '',
    variant: _rawText(release?.rawPayload['variant']) ?? '',
    releaseYear: _rawInt(release?.rawPayload['release_year']) ??
        release?.releaseDate?.year,
    directors: media.contributions
        .where((credit) => credit.role.toLowerCase().contains('director'))
        .map((credit) => credit.name)
        .join(', '),
    characters: media.characterAppearances
        .map((appearance) => appearance.characterName)
        .join(', '),
    backCoverImageUrl:
        _rawText(release?.rawPayload['back_cover_image_url']) ?? '',
  );
}

MovieCatalogFormValues movieCatalogFormValuesFromRelease(MovieRelease release) {
  return MovieCatalogFormValues(
    releaseTitle: release.title,
    format: release.format ?? '',
    region: release.region ?? '',
    releaseDate: release.releaseDate,
    distributor: release.distributor ?? '',
    language: release.language ?? '',
    releaseDescription: release.description ?? '',
    coverImageUrl: release.coverImageUrl ?? '',
    barcode: _rawText(release.rawPayload['barcode']) ?? '',
    itemNumber: _rawText(release.rawPayload['item_number']) ?? '',
    variant: _rawText(release.rawPayload['variant']) ?? '',
    releaseYear: _rawInt(release.rawPayload['release_year']) ??
        release.releaseDate?.year,
    backCoverImageUrl:
        _rawText(release.rawPayload['back_cover_image_url']) ?? '',
  );
}

MovieMedia movieMediaFromCatalogFormValues({
  required MovieMedia original,
  required MovieCatalogFormValues values,
}) {
  final unclaimedDirectors = original.contributions
      .where((credit) => credit.role.toLowerCase().contains('director'))
      .toList();
  final directorNames = _splitValues(values.directors);
  final directorCredits = [
    for (var index = 0; index < directorNames.length; index++)
      _reuseOrCreateContributor(
        directorNames[index],
        unclaimedDirectors,
        '${original.id.value}-director-$index',
      ),
  ];
  final unclaimedCharacters = [...original.characterAppearances];
  final characterNames = _splitValues(values.characters);
  final characterCredits = [
    for (var index = 0; index < characterNames.length; index++)
      _reuseOrCreateCharacter(
        characterNames[index],
        unclaimedCharacters,
        '${original.id.value}-character-$index',
      ),
  ];
  final preservedContributions = original.contributions
      .where((credit) => !credit.role.toLowerCase().contains('director'));
  final updatedRelease = original.primaryRelease == null
      ? null
      : movieReleaseFromCatalogFormValues(
          original: original.primaryRelease!,
          values: values,
        );

  return MovieMedia(
    id: original.id,
    title: _emptyToNull(values.title) ?? original.title,
    ageRating: _emptyToNull(values.ageRating),
    audienceRating: _emptyToNull(values.audienceRating),
    characterAppearances: characterCredits,
    contributions: [
      ...preservedContributions,
      ...directorCredits,
    ],
    description: _emptyToNull(values.workDescription),
    externalLinks: original.externalLinks,
    identifiers: original.identifiers,
    originalLanguage: _emptyToNull(values.originalLanguage),
    releaseDate: values.workReleaseDate,
    releases: [
      if (updatedRelease != null) updatedRelease,
      for (final release in original.releases.skip(1)) release,
    ],
    runtimeMinutes: values.runtimeMinutes,
    sortTitle: _emptyToNull(values.sortTitle),
    subtitle: _emptyToNull(values.subtitle),
    trailerUrls: original.trailerUrls,
    rawPayload: {
      ..._withoutKeys(original.rawPayload, _movieOwnedKeys),
      'genres': List<String>.unmodifiable(values.genres),
    },
  );
}

MovieRelease movieReleaseFromCatalogFormValues({
  required MovieRelease original,
  required MovieCatalogFormValues values,
}) {
  return MovieRelease(
    id: original.id,
    title: values.releaseTitle.trim(),
    workId: original.workId,
    coverImageKey: original.coverImageKey,
    coverImageUrl: _emptyToNull(values.coverImageUrl),
    description: _emptyToNull(values.releaseDescription),
    distributor: _emptyToNull(values.distributor),
    externalLinks: original.externalLinks,
    format: _emptyToNull(values.format),
    language: _emptyToNull(values.language),
    media: original.media,
    region: _emptyToNull(values.region),
    releaseDate: _effectiveReleaseDate(values),
    trailerUrls: original.trailerUrls,
    rawPayload: {
      ..._withoutKeys(original.rawPayload, _releaseOwnedKeys),
      if (_emptyToNull(values.barcode) case final value?) 'barcode': value,
      if (_emptyToNull(values.itemNumber) case final value?)
        'item_number': value,
      if (_emptyToNull(values.variant) case final value?) 'variant': value,
      if (_emptyToNull(values.backCoverImageUrl) case final value?)
        'back_cover_image_url': value,
      if (values.releaseYear != null) 'release_year': values.releaseYear,
      if (_emptyToNull(values.distributor) case final value?)
        'publisher': value,
      if (_emptyToNull(values.format) case final value?)
        'physical_format_label': value,
    },
  );
}

MovieMedia movieMediaFromManualCatalogFormValues({
  required MovieCatalogFormValues values,
  required String id,
  required String title,
}) {
  final normalizedTitle = title.trim();
  final normalizedReleaseDate = _effectiveReleaseDate(values);
  final normalizedBarcode = _emptyToNull(values.barcode);
  final directorNames = _splitValues(values.directors);
  final characterNames = _splitValues(values.characters);

  return MovieMedia(
    id: MovieMediaId(id),
    title: normalizedTitle,
    ageRating: _emptyToNull(values.ageRating),
    audienceRating: _emptyToNull(values.audienceRating),
    characterAppearances: [
      for (var index = 0; index < characterNames.length; index++)
        MovieCharacterAppearance(
          id: '$id-character-$index',
          characterId: '$id-character-$index',
          characterName: characterNames[index],
          role: 'cast',
        ),
    ],
    contributions: [
      for (final director in directorNames)
        MovieContributor(name: director, role: 'director'),
    ],
    description: _emptyToNull(values.workDescription),
    identifiers: normalizedBarcode == null
        ? const []
        : [
            MovieIdentifier(
              id: '$id-barcode',
              identifierType: 'barcode',
              value: normalizedBarcode,
              isPrimary: true,
            ),
          ],
    originalLanguage: _emptyToNull(values.originalLanguage),
    releaseDate: values.workReleaseDate,
    releases: [
      MovieRelease(
        id: MovieReleaseId('$id-release'),
        title: _emptyToNull(values.releaseTitle) ?? normalizedTitle,
        coverImageUrl: _emptyToNull(values.coverImageUrl),
        description: _emptyToNull(values.releaseDescription),
        distributor: _emptyToNull(values.distributor),
        format: _emptyToNull(values.format),
        language: _emptyToNull(values.language),
        region: _emptyToNull(values.region),
        releaseDate: normalizedReleaseDate,
        rawPayload: {
          if (normalizedBarcode != null) 'barcode': normalizedBarcode,
          if (_emptyToNull(values.itemNumber) case final value?)
            'item_number': value,
          if (_emptyToNull(values.variant) case final value?) 'variant': value,
          if (_emptyToNull(values.backCoverImageUrl) case final value?)
            'back_cover_image_url': value,
          if (values.releaseYear != null) 'release_year': values.releaseYear,
          if (_emptyToNull(values.distributor) case final value?)
            'publisher': value,
          if (_emptyToNull(values.format) case final value?)
            'physical_format_label': value,
        },
      ),
    ],
    runtimeMinutes: values.runtimeMinutes,
    sortTitle: _emptyToNull(values.sortTitle),
    subtitle: _emptyToNull(values.subtitle),
    rawPayload: {
      'genres': List<String>.unmodifiable(values.genres),
    },
  );
}

DateTime? _effectiveReleaseDate(MovieCatalogFormValues values) {
  final selectedYear = values.releaseYear;
  if (selectedYear == null || selectedYear < 1) return values.releaseDate;
  final selectedDate = values.releaseDate;
  if (selectedDate == null) return DateTime.utc(selectedYear);
  if (selectedDate.year == selectedYear) return selectedDate;
  return DateTime.utc(selectedYear, selectedDate.month, selectedDate.day);
}

MovieContributor _reuseOrCreateContributor(
  String name,
  List<MovieContributor> unclaimed,
  String generatedId,
) {
  final index = unclaimed.indexWhere(
    (credit) => _normalized(credit.name) == _normalized(name),
  );
  if (index >= 0) return unclaimed.removeAt(index);
  return MovieContributor(id: generatedId, name: name, role: 'director');
}

MovieCharacterAppearance _reuseOrCreateCharacter(
  String name,
  List<MovieCharacterAppearance> unclaimed,
  String generatedId,
) {
  final index = unclaimed.indexWhere(
    (appearance) => _normalized(appearance.characterName) == _normalized(name),
  );
  if (index >= 0) return unclaimed.removeAt(index);
  return MovieCharacterAppearance(
    id: generatedId,
    characterId: generatedId,
    characterName: name,
    role: 'cast',
  );
}

String _normalized(String value) => value.trim().toLowerCase();

String? _emptyToNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

String? _rawText(Object? value) {
  final normalized = value?.toString().trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

int? _rawInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

List<String> _stringList(Object? value) {
  if (value is! Iterable) return const [];
  return value
      .map((entry) => entry.toString().trim())
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
}

List<String> _splitValues(String value) => value
    .split(RegExp(r'[,;\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);

const _movieOwnedKeys = {
  'id',
  'kind',
  'title',
  'age_rating',
  'audience_rating',
  'character_appearances',
  'contributions',
  'description',
  'external_links',
  'identifiers',
  'original_language',
  'release_date',
  'releases',
  'runtime_minutes',
  'sort_title',
  'subtitle',
  'trailer_urls',
  'genres',
};

const _releaseOwnedKeys = {
  'id',
  'kind',
  'work_id',
  'release_title',
  'title',
  'cover_image_key',
  'cover_image_url',
  'description',
  'distributor',
  'external_links',
  'format',
  'language',
  'media',
  'region',
  'release_date',
  'trailer_urls',
  'barcode',
  'item_number',
  'variant',
  'back_cover_image_url',
  'release_year',
  'publisher',
  'physical_format_label',
};

Map<String, dynamic> _withoutKeys(
  Map<String, dynamic> payload,
  Set<String> keys,
) =>
    {
      for (final entry in payload.entries)
        if (!keys.contains(entry.key)) entry.key: entry.value,
    };
