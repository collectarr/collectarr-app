import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_box_set_membership.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_profile.dart';
import 'package:flutter/material.dart';

final EditSchema<MusicRelease, MusicReleaseEditDraft> musicReleaseEditSchema =
    EditSchema(
  title: (release) => 'Edit ${release.title}',
  validate: (_, draft) {
    if (draft.title.trim().isEmpty) return 'Release title is required';
    if (draft.hasIncompleteContributions) {
      return 'Complete or remove each unfinished release credit';
    }
    return null;
  },
  tabs: [
    EditTabSpec<MusicReleaseEditDraft>(
      id: 'release',
      label: 'Release',
      icon: Icons.album_outlined,
      sections: [
        EditSectionSpec<MusicReleaseEditDraft>(
          id: 'identity',
          label: 'Identity',
          fields: [
            _text(
                id: 'title',
                label: 'Title',
                value: (draft) => draft.title,
                setValue: (draft, value) => draft.title = value),
            _text(
                id: 'sort_title',
                label: 'Sort title',
                value: (draft) => draft.sortTitle ?? '',
                setValue: (draft, value) => draft.sortTitle = value),
            _text(
                id: 'subtitle',
                label: 'Subtitle',
                value: (draft) => draft.subtitle ?? '',
                setValue: (draft, value) => draft.subtitle = value),
            _text(
                id: 'physical_format',
                label: 'Format',
                value: (draft) =>
                    draft.physicalFormatLabel ?? draft.physicalFormat ?? '',
                setValue: (draft, value) {
                  draft.physicalFormat = value;
                  draft.physicalFormatLabel = value;
                }),
            LibraryVocabularyFieldSpec<MusicReleaseEditDraft, String>(
              id: 'release_type',
              label: 'Release type',
              value: (draft) => draft.releaseType,
              setValue: (draft, value) => draft.releaseType = value,
              options: _options(
                  const ['Album', 'EP', 'Single', 'Compilation', 'Live']),
            ),
            LibraryVocabularyFieldSpec<MusicReleaseEditDraft, String>(
              id: 'release_status',
              label: 'Release status',
              value: (draft) => draft.releaseStatus,
              setValue: (draft, value) => draft.releaseStatus = value,
              options: _options(const ['Official', 'Promotional', 'Bootleg']),
            ),
            LibraryDateFieldSpec<MusicReleaseEditDraft>(
              id: 'release_date',
              label: 'Release date',
              value: (draft) => draft.releaseDate,
              setValue: (draft, value) => draft.releaseDate = value,
            ),
          ],
        ),
        EditSectionSpec<MusicReleaseEditDraft>(
          id: 'edition',
          label: 'Edition',
          fields: [
            _text(
                id: 'publisher',
                label: 'Record label',
                value: (draft) => draft.publisher ?? '',
                setValue: (draft, value) => draft.publisher = value),
            _text(
                id: 'catalog_number',
                label: 'Catalog number',
                value: (draft) => draft.catalogNumber ?? '',
                setValue: (draft, value) => draft.catalogNumber = value),
            _text(
                id: 'barcode',
                label: 'Barcode',
                value: (draft) => draft.barcode ?? '',
                setValue: (draft, value) => draft.barcode = value),
            _text(
                id: 'upc',
                label: 'UPC',
                value: (draft) => draft.upc ?? '',
                setValue: (draft, value) => draft.upc = value),
            LibraryVocabularyFieldSpec<MusicReleaseEditDraft, String>(
              id: 'country_code',
              label: 'Country',
              value: (draft) => draft.countryCode,
              setValue: (draft, value) => draft.countryCode = value,
              options: _options(MusicVocabularies.country.builtIns),
            ),
            _text(
                id: 'language',
                label: 'Language',
                value: (draft) => draft.language ?? '',
                setValue: (draft, value) => draft.language = value),
            _text(
                id: 'packaging',
                label: 'Packaging',
                value: (draft) => draft.packaging ?? '',
                setValue: (draft, value) => draft.packaging = value),
            _text(
                id: 'box_set_ref',
                label: 'Box set reference',
                value: (draft) => draft.boxSetMembership?.boxSetRef.id ?? '',
                setValue: (draft, value) {
                  final id = value.trim();
                  if (id.isEmpty) {
                    draft.boxSetMembership = null;
                    return;
                  }
                  final current = draft.boxSetMembership;
                  draft.boxSetMembership = MusicBoxSetMembership(
                    boxSetRef: CatalogEntityRef(
                      kind: CatalogMediaKind.music,
                      entityType: const CatalogEntityTypeId('box_set'),
                      id: id,
                      rootId: current?.boxSetRef.rootId,
                      parentId: current?.boxSetRef.parentId,
                    ),
                    sequenceNumber: current?.sequenceNumber,
                  );
                }),
            _text(
              id: 'box_set_name',
              label: 'Box set name',
              value: (draft) => draft.boxSetName ?? '',
              setValue: (draft, value) => draft.boxSetName = value,
            ),
            LibraryNumberFieldSpec<MusicReleaseEditDraft>(
              id: 'box_set_position',
              label: 'Box set position',
              value: (draft) =>
                  draft.boxSetMembership?.sequenceNumber?.toDouble(),
              setValue: (draft, value) {
                final membership = draft.boxSetMembership;
                if (membership == null) return;
                draft.boxSetMembership = MusicBoxSetMembership(
                  boxSetRef: membership.boxSetRef,
                  sequenceNumber: value?.toInt(),
                );
              },
              minimum: 1,
            ),
          ],
        ),
      ],
    ),
    EditTabSpec<MusicReleaseEditDraft>(
      id: 'tracking',
      label: 'Tracking',
      icon: Icons.headphones_outlined,
      sections: [
        EditSectionSpec<MusicReleaseEditDraft>(
          id: 'listening',
          label: 'Listening',
          fields: [
            LibraryVocabularyFieldSpec<MusicReleaseEditDraft, String>(
              id: 'tracking_status',
              label: 'Status',
              value: (draft) => draft.trackingStatus,
              setValue: (draft, value) => draft.trackingStatus = value,
              options: [
                for (final option in musicTrackingProfile.options)
                  LibraryFieldOption(
                    value: option.storageValue,
                    label: option.label,
                  ),
              ],
            ),
            LibraryNumberFieldSpec<MusicReleaseEditDraft>(
              id: 'tracking_rating',
              label: 'Rating',
              value: (draft) => draft.trackingRating,
              setValue: (draft, value) => draft.trackingRating = value?.toInt(),
              minimum: 0,
              maximum: 5,
            ),
            _text(
              id: 'tracking_notes',
              label: 'Notes',
              value: (draft) => draft.trackingNotes ?? '',
              setValue: (draft, value) => draft.trackingNotes = value,
              maxLines: 3,
            ),
          ],
        ),
      ],
    ),
  ],
);

LibraryTextFieldSpec<MusicReleaseEditDraft> _text({
  required String id,
  required String label,
  required String Function(MusicReleaseEditDraft draft) value,
  required void Function(MusicReleaseEditDraft draft, String value) setValue,
  int maxLines = 1,
}) =>
    LibraryTextFieldSpec(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
      maxLines: maxLines,
    );

List<LibraryFieldOption<String>> _options(Iterable<String> values) => [
      for (final value in values)
        LibraryFieldOption(value: value, label: value),
    ];
