import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/entries/library_entries_repository.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_entry_repository.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/music_country_name.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';

abstract final class MusicVocabularyIds {
  static const boxSet = MusicFieldIdentities.boxSetVocabulary;
  static const extra = VocabularyId<String>('music.extra');
  static const spars = VocabularyId<String>('music.spars');
  static const imageType = VocabularyId<String>('music.image_type');
  static const artist = MusicFieldIdentities.artistVocabulary;
  static const contributorName = VocabularyId<String>('music.contributor_name');
  static const instrument = VocabularyId<String>('music.instrument');
  static const signedBy = VocabularyId<String>('music.signed_by');
  static const condition = VocabularyId<String>('music.condition');
  static const grade = VocabularyId<String>('music.grade');
  static const mediaCondition = VocabularyId<String>('music.media_condition');
  static const storageDevice = VocabularyId<String>('music.storage_device');
  static const format = MusicFieldIdentities.formatVocabulary;
  static const packaging = MusicFieldIdentities.packagingVocabulary;
  static const recordLabel = MusicFieldIdentities.publisherVocabulary;
  static const genre = MusicFieldIdentities.genreVocabulary;
  static const creditRole = VocabularyId<String>('music.credit_role');
  static const recordingLocation =
      VocabularyId<String>('music.recording_location');
  static const country = MusicFieldIdentities.countryVocabulary;
  static const soundType = VocabularyId<String>('music.sound_type');
  static const vinylColor = VocabularyId<String>('music.vinyl_color');
}

abstract final class MusicVocabularies {
  /// Include existing local metadata even before a name is saved in a pick list.
  static Future<List<String>> nameOptions(
      LocalDatabase db, String listName) async {
    final semanticName = listName.substring(listName.lastIndexOf('.') + 1);
    final items = await MusicEntryRepository(db).listActive();
    return [
      for (final item in items)
        ..._nameValues(item, semanticName)
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
    ];
  }

  static Iterable<String?> _nameValues(
      MusicLibraryEntry item, String semanticName) sync* {
    if (semanticName == 'signed_by') {
      yield* item.personal.details.signedBy?.split(',') ?? const <String>[];
    } else {
      yield* metadataNames(item.metadata, semanticName);
    }
  }

  static Iterable<String?> metadataNames(
      MusicAlbum item, String semanticName) sync* {
    final Iterable<String?>? metadataValues = switch (semanticName) {
      'format' => item.discs.map((d) => d.format),
      'packaging' => [item.packaging],
      'record_label' => [item.publisher],
      'country' => [item.countryCode],
      'vinyl_color' => item.discs.map((d) => d.color),
      'box_set' => [item.boxSet],
      'extra' => item.extra,
      'spars' => item.discs.map((disc) => disc.sparsCode),
      'genre' => item.genres,
      'sound_type' => item.discs.expand((d) => d.soundTypes),
      'credit_role' => _allCredits(item).map((credit) => credit.role),
      _ => null,
    };
    if (metadataValues != null) {
      yield* metadataValues;
      return;
    }
    if (semanticName == 'artist') {
      if (item.artistCredits.isEmpty) yield item.artist;
      yield* item.artistCredits.map((credit) => credit.creditedName);
    } else if (semanticName == 'recording_location') {
      yield* item.discs.expand((disc) => disc.recordingLocations);
    } else if (semanticName == 'instrument') {
      yield* _allCredits(item).expand((credit) => credit.instruments);
    } else if (semanticName == 'contributor_name') {
      yield* _allCredits(item).map((credit) => credit.name);
    } else {
      yield* _allCredits(item)
          .where((credit) =>
              credit.role.toLowerCase().replaceAll(' ', '_') == semanticName)
          .map((credit) => credit.name);
    }
  }

  static Future<List<String>> entryOptions(
      LocalDatabase db, String semanticName) async {
    return [
      for (final item in await MusicEntryRepository(db).listActive())
        ..._entryValues(item, semanticName)
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
    ];
  }

  static Future<Map<String, int>> entryUsageCounts(
          LocalDatabase db, String semanticName) =>
      countPickListEntryUsages(
          items: MusicEntryRepository(db).listActive(),
          valuesFrom: (item) => _entryValues(item, semanticName));

  static Future<void> updateSortName(LocalDatabase db, String semanticName,
      String value, String? sortName) async {
    if (semanticName != 'artist' && semanticName != 'contributor_name') {
      return;
    }
    final normalized = normalizePickListValue(value);
    for (final item in await MusicEntryRepository(db).listActive()) {
      if (!_entryValues(item, semanticName)
          .whereType<String>()
          .any((value) => normalizePickListValue(value) == normalized)) {
        continue;
      }
      final data = item.metadata.toJson();
      if (semanticName == 'artist') {
        data['artist_credits'] = [
          for (final credit in item.metadata.artistCredits)
            {
              ...credit.toJson(),
              if (normalizePickListValue(credit.creditedName) == normalized)
                'sort_name': sortName
            }
        ];
      } else {
        bool matches(MusicCredit credit) =>
            normalizePickListValue(credit.name) == normalized;
        data['credits'] = [
          for (final credit in item.metadata.credits)
            {...credit.toJson(), if (matches(credit)) 'sort_name': sortName},
        ];
        data['discs'] = [
          for (final disc in item.metadata.discs)
            {
              ...disc.toJson(),
              'credits': [
                for (final credit in disc.credits)
                  {
                    ...credit.toJson(),
                    if (matches(credit)) 'sort_name': sortName
                  },
              ],
            },
        ];
      }
      await MusicEntryRepository(db).upsert(item.copyWith(
          metadata: MusicAlbum.fromJson(data),
          updatedAt: DateTime.now().toUtc()));
      await enqueueLibraryEntrySnapshot(
          db,
          LibraryEntryRef(
              kind: CatalogMediaKind.music, id: LibraryEntryId(item.id.value)));
    }
  }

  static Future<PickListEntryMergeResult> previewEntryMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
  ) {
    return previewPickListEntryMerge(
      items: MusicEntryRepository(db).listActive(),
      idFrom: (item) => item.id.value,
      valuesFrom: (item) => _entryValues(item, semanticName),
      normalizedSourceValues: normalizedSourceValues,
    );
  }

  static Future<void> applyEntryMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
    String targetValue,
  ) {
    return applyPickListEntryMerge(
      items: MusicEntryRepository(db).listActive(),
      valuesFrom: (item) => _entryValues(item, semanticName),
      replaceValue: (item, sources, target) =>
          _replaceEntryValue(item, semanticName, sources, target),
      save: MusicEntryRepository(db).upsert,
      normalizedSourceValues: normalizedSourceValues,
      targetValue: targetValue,
    );
  }

  static MusicLibraryEntry _replaceEntryValue(
    MusicLibraryEntry item,
    String semanticName,
    Set<String> normalizedSourceValues,
    String targetValue,
  ) {
    switch (semanticName) {
      case 'owners':
        return item.copyWith(
            personal: item.personal.copyWith(
                ownerLabel: targetValue.isEmpty ? null : targetValue));
      case 'condition':
        return item.copyWith(
          personal: item.personal.copyWith(condition: targetValue),
        );
      case 'storage_device':
        return item.copyWith(
            personal: item.personal.copyWith(
                details: item.personal.details.copyWith(
          media: [
            for (final row in item.personal.details.media)
              MusicEntryDiscDetails(
                  discId: row.discId,
                  storageSlot: row.storageSlot,
                  storageDevice: normalizedSourceValues.contains(
                          normalizePickListValue(row.storageDevice ?? ''))
                      ? targetValue
                      : row.storageDevice)
          ],
        )));
      case 'media_condition':
        return item.copyWith(
            personal: item.personal.copyWith(mediaCondition: targetValue));
      case 'grade':
        return item.copyWith(
            personal: item.personal.copyWith(grade: targetValue));
      case 'purchase_store':
        return item.copyWith(
          personal: item.personal.copyWith(purchaseStore: targetValue),
        );
      case 'sold_to':
        return item.copyWith(
            personal: item.personal.copyWith(soldTo: targetValue));
      case 'collection_status':
        return item.copyWith(
          personal: item.personal.copyWith(collectionStatus: targetValue),
        );
      case 'tags':
        return item.copyWith(
          personal: item.personal.copyWith(
            tags: replacePickListDelimitedValue(
              item.personal.tags,
              normalizedSourceValues,
              targetValue,
            ),
          ),
        );
      case 'signed_by':
        return item.copyWith(
          personal: item.personal.copyWith(
            details: item.personal.details.copyWith(
                signedBy: replacePickListDelimitedValue(
                    item.personal.details.signedBy,
                    normalizedSourceValues,
                    targetValue)),
          ),
        );
    }
    if (semanticName == 'extra') {
      final seen = <String>{};
      final values = item.metadata.extra
          .map((value) =>
              normalizedSourceValues.contains(normalizePickListValue(value))
                  ? targetValue
                  : value)
          .where((value) =>
              value.trim().isNotEmpty &&
              seen.add(normalizePickListValue(value)))
          .toList();
      final data = item.metadata.toJson()..['extra'] = values;
      return item.copyWith(metadata: MusicAlbum.fromJson(data));
    }
    String? replace(String? value) => value != null &&
            normalizedSourceValues.contains(normalizePickListValue(value))
        ? targetValue
        : value;
    List<String> replaceValues(Iterable<String> values) {
      final seen = <String>{};
      return [
        for (final value in values)
          if (replace(value) case final next?)
            if (next.trim().isNotEmpty &&
                seen.add(normalizePickListValue(next)))
              next,
      ];
    }

    final data = item.metadata.toJson();
    switch (semanticName) {
      case 'packaging':
        data['packaging'] = targetValue.isEmpty ? null : targetValue;
      case 'record_label':
        data['publisher'] = targetValue.isEmpty ? null : targetValue;
      case 'country':
        data['country_code'] = targetValue.isEmpty ? null : targetValue;
      case 'box_set':
        data['box_set'] = targetValue.isEmpty ? null : targetValue;
      case 'genre':
        data['genres'] = replaceValues(item.metadata.genres);
      case 'format':
      case 'spars':
      case 'vinyl_color':
        final key = switch (semanticName) {
          'format' => 'format',
          'spars' => 'spars_code',
          _ => 'color',
        };
        data['discs'] = [
          for (final disc in item.metadata.discs)
            {
              ...disc.toJson(),
              key: replace(switch (semanticName) {
                'format' => disc.format,
                'spars' => disc.sparsCode,
                _ => disc.color,
              }),
            },
        ];
      case 'sound_type':
      case 'recording_location':
        final key = semanticName == 'sound_type'
            ? 'sound_types'
            : 'recording_locations';
        data['discs'] = [
          for (final disc in item.metadata.discs)
            {
              ...disc.toJson(),
              key: replaceValues(semanticName == 'sound_type'
                  ? disc.soundTypes
                  : disc.recordingLocations),
            },
        ];
      case 'artist':
        final artistCredits = [
          for (final credit in item.metadata.artistCredits)
            if (targetValue.isNotEmpty ||
                !normalizedSourceValues
                    .contains(normalizePickListValue(credit.creditedName)))
              {
                ...credit.toJson(),
                'credited_name': replace(credit.creditedName),
              },
        ];
        data['artist_credits'] = artistCredits;
        data['artist'] = item.metadata.artistCredits.isEmpty
            ? replace(item.metadata.artist)
            : artistCredits.isEmpty
                ? null
                : artistCredits
                    .map((credit) => credit['credited_name'])
                    .join(' / ');
      case 'contributor_name':
      case 'credit_role':
      case 'instrument':
        List<Map<String, dynamic>> updateCredits(List<MusicCredit> credits) => [
              for (final credit in credits)
                if (targetValue.isNotEmpty ||
                    !(semanticName == 'credit_role' &&
                            normalizedSourceValues.contains(
                                normalizePickListValue(credit.role))) &&
                        !(semanticName == 'contributor_name' &&
                            normalizedSourceValues
                                .contains(normalizePickListValue(credit.name))))
                  {
                    ...credit.toJson(),
                    if (semanticName == 'contributor_name')
                      'name': replace(credit.name),
                    if (semanticName == 'credit_role')
                      'role': replace(credit.role),
                    if (semanticName == 'instrument')
                      'instruments': replaceValues(credit.instruments),
                  },
            ];
        data['credits'] = updateCredits(item.metadata.credits);
        data['discs'] = [
          for (final disc in item.metadata.discs)
            {
              ...disc.toJson(),
              'credits': updateCredits(disc.credits),
            },
        ];
      default:
        return item;
    }
    return item.copyWith(metadata: MusicAlbum.fromJson(data));
  }

  static Iterable<String?> _entryValues(
    MusicLibraryEntry item,
    String semanticName,
  ) sync* {
    final standard = switch (semanticName) {
      'owners' => item.personal.ownerLabel,
      'condition' => item.personal.condition,
      'media_condition' => item.personal.mediaCondition,
      'grade' => item.personal.grade,
      'purchase_store' => item.personal.purchaseStore,
      'sold_to' => item.personal.soldTo,
      'collection_status' => item.personal.collectionStatus,
      _ => null,
    };
    if (standard != null) {
      yield standard;
      return;
    }
    if (semanticName == 'storage_device') {
      yield* item.personal.details.media.map((row) => row.storageDevice);
      return;
    }
    if (semanticName == 'tags') {
      yield* item.personal.tags?.split(',') ?? const <String>[];
      return;
    }
    if (semanticName == 'signed_by') {
      yield* item.personal.details.signedBy?.split(',') ?? const <String>[];
      return;
    }
    yield* metadataNames(item.metadata, semanticName);
  }

  static const condition = VocabularyDefinition<String>(
    id: MusicVocabularyIds.condition,
    label: 'Package/Sleeve Condition',
    builtIns: [
      'Mint',
      'Near Mint',
      'Excellent',
      'Very Good',
      'Good',
      'Fair',
      'Poor',
    ],
  );

  static const mediaCondition = VocabularyDefinition<String>(
    id: MusicVocabularyIds.mediaCondition,
    label: 'Media Condition',
    builtIns: [
      'Mint',
      'Near Mint',
      'Excellent',
      'Very Good',
      'Good',
      'Fair',
      'Poor'
    ],
  );
  static const storageDevice = VocabularyDefinition<String>(
    id: MusicVocabularyIds.storageDevice,
    label: 'Storage Device',
    builtIns: [],
  );
  static const grade = VocabularyDefinition<String>(
    id: MusicVocabularyIds.grade,
    label: 'Grade',
    builtIns: ['Ungraded'],
  );

  static const format = VocabularyDefinition<String>(
    id: MusicVocabularyIds.format,
    label: 'Format',
    valuesFrom: TypedVocabularyProjector<MusicAlbum>(_formatCatalogValues),
    builtIns: [
      'Vinyl (12" LP)',
      'Vinyl (7" Single)',
      'Vinyl (10" EP)',
      'CD',
      'Cassette',
      'SACD',
      'FLAC / Hi-Res Digital',
      'Digital Download',
    ],
  );

  static const packaging = VocabularyDefinition<String>(
    id: MusicVocabularyIds.packaging,
    label: 'Packaging',
    valuesFrom: TypedVocabularyProjector<MusicAlbum>(
      _packagingCatalogValues,
    ),
    builtIns: [
      'Standard Jewel Case',
      'Digipak',
      'Gatefold Sleeve',
      'Box Set',
      'Deluxe Cardboard Sleeve',
      'Cardboard Slipcase',
    ],
  );

  static const recordLabel = VocabularyDefinition<String>(
    id: MusicVocabularyIds.recordLabel,
    label: 'Label',
    valuesFrom: TypedVocabularyProjector<MusicAlbum>(
      _recordLabelCatalogValues,
    ),
    builtIns: [
      'Columbia Records',
      'Atlantic Records',
      'Warner Records',
      'Interscope Records',
      'Def Jam Recordings',
      'Epic Records',
      'Sub Pop',
      '4AD',
      'Blue Note Records',
      'Deutsche Grammophon',
    ],
  );

  static const genre = VocabularyDefinition<String>(
    id: MusicVocabularyIds.genre,
    label: 'Genre',
    multiValue: true,
    valuesFrom: TypedVocabularyProjector<MusicAlbum>(_genreValues),
    builtIns: [
      'Rock',
      'Pop',
      'Jazz',
      'Classical',
      'Electronic',
      'Hip-Hop',
      'Metal',
      'Blues',
      'Folk',
      'Soundtrack',
    ],
  );

  static const creditRole = VocabularyDefinition<String>(
    id: MusicVocabularyIds.creditRole,
    label: 'Credit Role',
    valuesFrom: TypedVocabularyProjector<MusicAlbum>(_creditRoleValues),
    builtIns: [
      'Artist',
      'Performer',
      'Musician',
      'Composer',
      'Conductor',
      'Producer',
      'Engineer',
      'Remixer',
      'Arranger',
      'Orchestra',
      'Chorus',
      'Band',
    ],
  );

  static const contributorName = VocabularyDefinition<String>(
    id: MusicVocabularyIds.contributorName,
    label: 'Contributor',
    multiValue: true,
    valuesFrom: const _MusicNameProjector('contributor_name'),
  );

  static const instrument = VocabularyDefinition<String>(
    id: MusicVocabularyIds.instrument,
    label: 'Instrument',
    multiValue: true,
    valuesFrom: const _MusicNameProjector('instrument'),
  );

  static const country = VocabularyDefinition<String>(
    id: MusicVocabularyIds.country,
    label: 'Country',
    optionLabel: _countryLabel,
    valuesFrom: TypedVocabularyProjector<MusicAlbum>(_countryValues),
    builtIns: musicCountryCodes,
  );

  static const vinylColor = VocabularyDefinition<String>(
    id: MusicVocabularyIds.vinylColor,
    label: 'Vinyl Color',
    valuesFrom: TypedVocabularyProjector<MusicAlbum>(
      _vinylColorValues,
    ),
  );

  static const recordingLocation = VocabularyDefinition<String>(
    id: MusicVocabularyIds.recordingLocation,
    label: 'Recording Location',
    multiValue: true,
    valuesFrom: TypedVocabularyProjector<MusicAlbum>(_recordingLocationValues),
  );

  static const soundType = VocabularyDefinition<String>(
    id: MusicVocabularyIds.soundType,
    label: 'Sound',
    multiValue: true,
    valuesFrom: TypedVocabularyProjector<MusicAlbum>(_soundTypeValues),
    builtIns: ['Mono', 'Stereo', 'Quadraphonic', 'Dolby Atmos'],
  );

  static const orderedNames = <VocabularyDefinition<String>>[
    VocabularyDefinition<String>(
      id: VocabularyId<String>('music.artist'),
      label: 'Artist',
      multiValue: true,
      valuesFrom: _MusicNameProjector('artist'),
    ),
    contributorName,
    instrument,
    VocabularyDefinition<String>(
      id: VocabularyId<String>('music.signed_by'),
      label: 'Signee',
      multiValue: true,
    ),
  ];

  static const boxSet = VocabularyDefinition<String>(
      id: MusicVocabularyIds.boxSet,
      label: 'Box Set',
      valuesFrom: _MusicNameProjector('box_set'));
  static const extra = VocabularyDefinition<String>(
      id: MusicVocabularyIds.extra,
      label: 'Extra',
      multiValue: true,
      valuesFrom: _MusicNameProjector('extra'));
  static const spars = VocabularyDefinition<String>(
      id: MusicVocabularyIds.spars,
      label: 'SPARS',
      builtIns: ['AAD', 'ADD', 'DAD', 'DDD'],
      valuesFrom: TypedVocabularyProjector<MusicAlbum>(_sparsValues));
  static const imageType = VocabularyDefinition<String>(
      id: MusicVocabularyIds.imageType,
      label: 'Image Type',
      optionLabel: _imageTypeLabel,
      builtIns: ['booklet', 'signature', 'label', 'disc', 'other']);

  static const all = <VocabularyDefinition<dynamic>>[
    ...orderedNames,
    boxSet,
    extra,
    spars,
    imageType,
    condition,
    mediaCondition,
    storageDevice,
    grade,
    format,
    packaging,
    recordLabel,
    genre,
    creditRole,
    country,
    recordingLocation,
    soundType,
    vinylColor,
  ];
}

Iterable<String?> _formatCatalogValues(MusicAlbum item) sync* {
  yield* vocabularyValues(item.discs.map((d) => d.format));
}

Iterable<String?> _packagingCatalogValues(MusicAlbum item) {
  return vocabularyValues([item.packaging]);
}

Iterable<String?> _recordLabelCatalogValues(MusicAlbum item) {
  return vocabularyValues([item.publisher]);
}

Iterable<String?> _recordingLocationValues(MusicAlbum item) =>
    vocabularyValues(item.discs.expand((disc) => disc.recordingLocations));

Iterable<String?> _soundTypeValues(MusicAlbum item) => vocabularyValues([
      for (final disc in item.discs) ...disc.soundTypes,
    ]);

Iterable<String?> _genreValues(MusicAlbum item) {
  return vocabularyValues([item.genres]);
}

Iterable<String?> _creditRoleValues(MusicAlbum item) {
  return vocabularyValues([
    for (final credit in _allCredits(item)) credit.role,
  ]);
}

Iterable<String?> _sparsValues(MusicAlbum item) =>
    vocabularyValues(item.discs.map((disc) => disc.sparsCode));

Iterable<MusicCredit> _allCredits(MusicAlbum item) sync* {
  yield* item.credits;
  for (final disc in item.discs) {
    yield* disc.credits;
  }
}

Iterable<String?> _countryValues(MusicAlbum item) {
  return vocabularyValues([item.countryCode]);
}

Iterable<String?> _vinylColorValues(MusicAlbum item) sync* {
  yield* vocabularyValues(item.discs.map((d) => d.color));
}

/// One projector for all ordered name vocabularies; field semantics stay in Music.
final class _MusicNameProjector implements VocabularyCatalogValueProjector {
  const _MusicNameProjector(this.semanticName);
  final String semanticName;
  @override
  Iterable<String?> call(Object? metadata) => metadata is MusicAlbum
      ? MusicVocabularies.metadataNames(metadata, semanticName)
      : const [];
}

String _countryLabel(String value) => musicCountryName(value) ?? value;

String _imageTypeLabel(String value) => switch (value) {
      'booklet' => 'Booklet',
      'signature' => 'Signature',
      'label' => 'Label',
      'disc' => 'Disc',
      'other' => 'Other',
      _ => value,
    };
