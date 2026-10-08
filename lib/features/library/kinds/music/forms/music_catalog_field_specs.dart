import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_ordered_pick_list_field.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_title_formatting.dart';
import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_ordered_names_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'dart:async';

import 'package:collectarr_app/features/library/kinds/music/forms/music_album_form_values.dart';
import 'package:collectarr_app/features/library/kinds/music/music_country_name.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';

typedef MusicAlbumValuesReader<TDraft> = MusicAlbumFormValues Function(
    TDraft draft);

const musicTitleActions = [
  LibraryTextFieldAction(
    label: 'Autocap',
    iconText: 'Aa',
    transform: autocapMusicTitle,
  ),
];

List<LibraryFieldSpec<TDraft>> musicAlbumFields<TDraft>({
  required MusicAlbumValuesReader<TDraft> values,
  Set<String>? include,
  String? Function(TDraft draft)? formatSummary,
  Iterable<String>? formatOptions,
  Iterable<String>? genreOptions,
  Iterable<String>? countryOptions,
  Iterable<String>? recordLabelOptions,
  Iterable<String>? packagingOptions,
  Iterable<String>? studioOptions,
  Iterable<String>? soundTypeOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageCountry,
  FutureOr<void> Function()? onManageRecordLabel,
  FutureOr<void> Function()? onManagePackaging,
}) =>
    _included<TDraft>([
      _text<TDraft>(
        id: 'title',
        label: 'Title',
        read: (draft) => values(draft).title,
        write: (draft, value) => values(draft).title = value,
        actions: musicTitleActions,
      ),
      _text<TDraft>(
        id: 'sort_title',
        label: 'Sort Title',
        read: (draft) => values(draft).sortTitle,
        write: (draft, value) => values(draft).sortTitle = value,
      ),
      _text<TDraft>(
        id: 'subtitle',
        label: 'Subtitle',
        read: (draft) => values(draft).subtitle,
        write: (draft, value) => values(draft).subtitle = value,
      ),
      LibraryCustomFieldSpec<TDraft>(
        id: 'artist',
        label: 'Artist',
        builder: (context, draft) =>
            StatefulBuilder(builder: (context, refresh) {
          final form = values(draft);
          final credits = form.artistCredits.isNotEmpty
              ? form.artistCredits
              : [
                  if (form.artist.trim().isNotEmpty)
                    MusicArtistCredit(
                      id: 'artist-main',
                      creditedName: form.artist,
                      sequence: 1,
                    ),
                ];
          return LibraryOrderedPickListField(
            label: 'Artist',
            listName: MusicVocabularyIds.artist.value,
            mediaKind: 'music',
            loadOptions: (db) => MusicVocabularies.nameOptions(
                db, MusicVocabularyIds.artist.value),
            values: [
              for (final credit in credits)
                LibraryNamedValue(
                    id: credit.id,
                    name: credit.creditedName,
                    sortName: credit.sortName)
            ],
            onChanged: (names) => refresh(() {
              form.artistCredits = [
                for (var index = 0; index < names.length; index++)
                  MusicArtistCredit(
                    id: names[index].id,
                    creditedName: names[index].name,
                    sortName: names[index].sortName,
                    artistId: credits
                        .where((c) => c.id == names[index].id)
                        .firstOrNull
                        ?.artistId,
                    joinPhrase: credits
                        .where((c) => c.id == names[index].id)
                        .firstOrNull
                        ?.joinPhrase,
                    sequence: index + 1,
                  )
              ];
              form.artist = names
                  .map((value) => value.name.trim())
                  .where((name) => name.isNotEmpty)
                  .join(' / ');
            }),
          );
        }),
      ),
      LibraryPartialDateFieldSpec<TDraft>(
        id: 'original_release_date',
        label: 'Original Release Date',
        value: (draft) => values(draft).originalReleaseDateParts,
        setValue: (draft, value) =>
            values(draft).originalReleaseDateParts = value,
      ),
      LibraryPartialDateFieldSpec<TDraft>(
        id: 'recording_date',
        label: 'Recording Date',
        value: (draft) => values(draft).recordingDateParts,
        setValue: (draft, value) => values(draft).recordingDateParts = value,
      ),
      LibraryCustomFieldSpec<TDraft>(
        id: 'studios',
        label: 'Studio',
        builder: (context, draft) => StatefulBuilder(
            builder: (context, refresh) => LibraryOrderedPickListField(
                  label: 'Studio',
                  listName: MusicVocabularyIds.studio.value,
                  mediaKind: 'music',
                  options: [...?studioOptions],
                  loadOptions: (db) => MusicVocabularies.nameOptions(
                      db, MusicVocabularyIds.studio.value),
                  values: [
                    for (final studio in values(draft).studios)
                      LibraryNamedValue(id: studio, name: studio)
                  ],
                  onChanged: (names) => refresh(() => values(draft).studios =
                      names.map((value) => value.name).toList()),
                )),
      ),
      LibraryCustomFieldSpec<TDraft>(
        id: 'is_live',
        label: 'Is Live',
        builder: (context, draft) => StatefulBuilder(
            builder: (context, refresh) => LibraryFormField(
                  label: 'Is Live',
                  child: LibrarySegmentedField<bool>(
                      value: values(draft).isLive ?? false,
                      options: const {false: 'No', true: 'Yes'},
                      onChanged: (value) =>
                          refresh(() => values(draft).isLive = value)),
                )),
      ),
      LibraryMultiVocabularyFieldSpec<TDraft, String>(
        id: 'genres',
        label: 'Genre',
        pickListKey: MusicVocabularyIds.genre.value,
        pluralLabel: 'Genres',
        values: (draft) => values(draft).genres.toSet(),
        setValues: (draft, next) =>
            values(draft).genres = next.toList(growable: false),
        options: _options(genreOptions ?? MusicVocabularies.genre.builtIns),
      ),
      LibraryCustomFieldSpec<TDraft>(
        id: 'format',
        label: 'Format',
        builder: (context, draft) {
          final fmt = (formatSummary?.call(draft) ??
                  (draft is MusicAlbumEditDraft
                      ? (draft as MusicAlbumEditDraft).formatSummary
                      : null) ??
                  '')
              .trim();
          final display = fmt.isNotEmpty ? fmt : 'Not specified';
          return LibraryFormField(
            label: 'Format',
            child: Container(
              height: kLibraryFormControlHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: appPalette(context).field,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: appPalette(context).divider,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      display,
                      style: TextStyle(
                        color: fmt.isNotEmpty
                            ? appPalette(context).textPrimary
                            : appPalette(context).textSecondary,
                        fontSize: 13,
                        fontWeight: fmt.isNotEmpty
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Tooltip(
                    message: 'Format is derived from discs in the Tracks tab',
                    child: Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: appPalette(context).accent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      LibraryPartialDateFieldSpec<TDraft>(
        id: 'release_date',
        label: 'Release Date',
        value: (draft) => values(draft).releaseDateParts,
        setValue: (draft, value) => values(draft).releaseDateParts = value,
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'record_label',
        label: 'Label',
        value: (draft) => _nullable(values(draft).publisher),
        setValue: (draft, value) => values(draft).publisher = value ?? '',
        options: _options(
          recordLabelOptions ?? MusicVocabularies.recordLabel.builtIns,
        ),
        pickListKey: MusicVocabularyIds.recordLabel.value,
        onManage:
            onManageRecordLabel == null ? null : (_) => onManageRecordLabel(),
      ),
      _text<TDraft>(
        id: 'catalog_number',
        label: 'Cat No',
        read: (draft) => values(draft).catalogNumber,
        write: (draft, value) => values(draft).catalogNumber = value,
      ),
      _text<TDraft>(
        id: 'barcode',
        label: 'Barcode',
        read: (draft) => values(draft).barcode,
        write: (draft, value) => values(draft).barcode = value,
      ),
      _text<TDraft>(
        id: 'cover_image_url',
        label: 'Cover image URL',
        read: (draft) => values(draft).coverImageUrl,
        write: (draft, value) => values(draft).coverImageUrl = value,
      ),
      LibraryMultiVocabularyFieldSpec<TDraft, String>(
        id: 'extra',
        label: 'Extra',
        pluralLabel: 'Extras',
        pickListKey: MusicVocabularyIds.extra.value,
        options: const [],
        values: (draft) => values(draft).extra.toSet(),
        setValues: (draft, valuesSet) =>
            values(draft).extra = List.of(valuesSet),
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'spars_code',
        label: 'SPARS Code',
        value: (draft) => _nullable(values(draft).sparsCode),
        setValue: (draft, value) => values(draft).sparsCode = value ?? '',
        options: _options(MusicVocabularies.spars.builtIns),
        pickListKey: MusicVocabularyIds.spars.value,
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'country',
        label: 'Country',
        value: (draft) => _nullable(values(draft).countryCode),
        setValue: (draft, value) => values(draft).countryCode = value ?? '',
        options: _countryOptions(
          countryOptions ?? MusicVocabularies.country.builtIns,
        ),
        pickListKey: MusicVocabularyIds.country.value,
        onManage: onManageCountry == null ? null : (_) => onManageCountry(),
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'packaging',
        label: 'Packaging',
        value: (draft) => _nullable(values(draft).packaging),
        setValue: (draft, value) => values(draft).packaging = value ?? '',
        options: _options(
          packagingOptions ?? MusicVocabularies.packaging.builtIns,
        ),
        pickListKey: MusicVocabularyIds.packaging.value,
        onManage: onManagePackaging == null ? null : (_) => onManagePackaging(),
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'box_set',
        label: 'Box Set',
        value: (draft) => _nullable(values(draft).boxSet),
        setValue: (draft, value) => values(draft).boxSet = value ?? '',
        options: const [],
        pickListKey: MusicVocabularyIds.boxSet.value,
      ),
    ], include);

List<LibraryFieldSpec<TDraft>> _included<TDraft>(
  List<LibraryFieldSpec<TDraft>> fields,
  Set<String>? include,
) =>
    include == null
        ? fields
        : fields.where((field) => include.contains(field.id)).toList();

LibraryTextFieldSpec<TDraft> _text<TDraft>({
  required String id,
  required String label,
  required String Function(TDraft draft) read,
  required void Function(TDraft draft, String value) write,
  List<LibraryTextFieldAction> actions = const [],
}) =>
    LibraryTextFieldSpec<TDraft>(
      id: id,
      label: label,
      value: read,
      setValue: write,
      actions: actions,
    );

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

List<LibraryFieldOption<String>> _options(Iterable<String> values) => [
      for (final value in values)
        LibraryFieldOption(value: value, label: value),
    ];

List<LibraryFieldOption<String>> _countryOptions(Iterable<String> values) {
  final options = [
    for (final value in values)
      LibraryFieldOption(value: value, label: musicCountryName(value) ?? value),
  ];
  options.sort((left, right) => left.label.compareTo(right.label));
  return options;
}
