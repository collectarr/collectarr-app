import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_owned_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:flutter/material.dart';

final EditSchema<MusicOwnedItem, MusicOwnedEditDraft> musicOwnedEditSchema =
    EditSchema(
  title: (_) => 'Edit music copy',
  validate: (_, draft) =>
      draft.quantity < 1 ? 'Quantity must be at least 1' : null,
  tabs: [
    EditTabSpec<MusicOwnedEditDraft>(
      id: 'personal',
      label: 'Personal',
      icon: Icons.person_outline,
      sections: [
        EditSectionSpec<MusicOwnedEditDraft>(
          id: 'condition',
          label: 'Condition & ownership',
          fields: [
            VocabularyEditField<MusicOwnedEditDraft, String>(
              id: 'condition',
              label: 'Condition',
              value: (draft) => draft.condition,
              setValue: (draft, value) => draft.condition = value,
              options: _options(MusicVocabularies.condition.builtIns),
            ),
            _text(
              id: 'grade',
              label: 'Grade',
              value: (draft) => draft.grade ?? '',
              setValue: (draft, value) => draft.grade = value,
            ),
            _text(
              id: 'owner',
              label: 'Owner',
              value: (draft) => draft.ownerLabel ?? '',
              setValue: (draft, value) => draft.ownerLabel = value,
            ),
            SelectEditField<MusicOwnedEditDraft, bool>(
              id: 'digital',
              label: 'Copy type',
              value: (draft) => draft.isDigital,
              setValue: (draft, value) => draft.isDigital = value,
              options: const [
                EditOption(value: false, label: 'Physical'),
                EditOption(value: true, label: 'Digital'),
              ],
            ),
            NumberEditField<MusicOwnedEditDraft>(
              id: 'quantity',
              label: 'Quantity',
              value: (draft) => draft.quantity,
              setValue: (draft, value) => draft.quantity = value?.toInt() ?? 1,
              minimum: 1,
            ),
            NumberEditField<MusicOwnedEditDraft>(
              id: 'index_number',
              label: 'Collection number',
              value: (draft) => draft.indexNumber,
              setValue: (draft, value) => draft.indexNumber = value?.toInt(),
              minimum: 1,
            ),
          ],
        ),
        EditSectionSpec<MusicOwnedEditDraft>(
          id: 'purchase',
          label: 'Purchase & value',
          fields: [
            DateEditField<MusicOwnedEditDraft>(
              id: 'purchase_date',
              label: 'Purchase date',
              value: (draft) => draft.purchaseDate,
              setValue: (draft, value) => draft.purchaseDate = value,
            ),
            MoneyEditField<MusicOwnedEditDraft>(
              id: 'purchase_price',
              label: 'Purchase price',
              cents: (draft) => draft.pricePaidCents,
              setCents: (draft, value) => draft.pricePaidCents = value,
              currency: (draft) => draft.currency ?? 'USD',
            ),
            _text(
              id: 'currency',
              label: 'Currency code',
              value: (draft) => draft.currency ?? '',
              setValue: (draft, value) => draft.currency = value,
            ),
            _text(
              id: 'purchase_store',
              label: 'Purchase store',
              value: (draft) => draft.purchaseStore ?? '',
              setValue: (draft, value) => draft.purchaseStore = value,
            ),
            MoneyEditField<MusicOwnedEditDraft>(
              id: 'current_value',
              label: 'Current value',
              cents: (draft) => draft.marketValueCents,
              setCents: (draft, value) => draft.marketValueCents = value,
              currency: (draft) => draft.currency ?? 'USD',
            ),
          ],
        ),
        EditSectionSpec<MusicOwnedEditDraft>(
          id: 'personal_notes',
          label: 'Personal details',
          fields: [
            _text(
              id: 'tags',
              label: 'Tags',
              value: (draft) => draft.tags ?? '',
              setValue: (draft, value) => draft.tags = value,
            ),
            _text(
              id: 'location',
              label: 'Location',
              value: (draft) => draft.locationId ?? '',
              setValue: (draft, value) => draft.locationId = value,
            ),
            _text(
              id: 'collection_status',
              label: 'Collection status',
              value: (draft) => draft.collectionStatus ?? '',
              setValue: (draft, value) => draft.collectionStatus = value,
            ),
            _text(
              id: 'signed_by',
              label: 'Signed by',
              value: (draft) => draft.signedBy ?? '',
              setValue: (draft, value) => draft.signedBy = value,
            ),
            DateEditField<MusicOwnedEditDraft>(
              id: 'last_cleaned',
              label: 'Last cleaned',
              value: (draft) => draft.lastCleanedDate,
              setValue: (draft, value) => draft.lastCleanedDate = value,
            ),
            _text(
              id: 'notes',
              label: 'Notes',
              value: (draft) => draft.personalNotes ?? '',
              setValue: (draft, value) => draft.personalNotes = value,
              maxLines: 4,
            ),
          ],
        ),
        EditSectionSpec<MusicOwnedEditDraft>(
          id: 'sale',
          label: 'Sale details',
          fields: [
            DateEditField<MusicOwnedEditDraft>(
              id: 'sold_at',
              label: 'Sold at',
              value: (draft) => draft.soldAt,
              setValue: (draft, value) => draft.soldAt = value,
            ),
            MoneyEditField<MusicOwnedEditDraft>(
              id: 'sell_price',
              label: 'Sell price',
              cents: (draft) => draft.sellPriceCents,
              setCents: (draft, value) => draft.sellPriceCents = value,
              currency: (draft) => draft.currency ?? 'USD',
            ),
            _text(
              id: 'sold_to',
              label: 'Sold to',
              value: (draft) => draft.soldTo ?? '',
              setValue: (draft, value) => draft.soldTo = value,
            ),
          ],
        ),
      ],
    ),
  ],
);

TextEditField<MusicOwnedEditDraft> _text({
  required String id,
  required String label,
  required String Function(MusicOwnedEditDraft draft) value,
  required void Function(MusicOwnedEditDraft draft, String value) setValue,
  int maxLines = 1,
}) =>
    TextEditField(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
      maxLines: maxLines,
    );

List<EditOption<String>> _options(Iterable<String> values) => [
      for (final value in values) EditOption(value: value, label: value),
    ];
