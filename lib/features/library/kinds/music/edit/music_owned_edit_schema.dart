import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_owned_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';

final EditSchema<MusicOwnedDetails, MusicOwnedEditDraft> musicOwnedEditSchema =
    EditSchema(
  title: (_) => 'Edit music ownership',
  tabs: [
    EditTabSpec<MusicOwnedEditDraft>(
      id: 'owned',
      label: 'Owned',
      sections: [
        EditSectionSpec<MusicOwnedEditDraft>(
          id: 'physical',
          label: 'Physical copy',
          fields: [
            _text(
              id: 'storage_device',
              label: 'Storage device',
              value: (draft) => draft.storageDevice ?? '',
              setValue: (draft, value) => draft.storageDevice = value,
            ),
            _text(
              id: 'storage_slot',
              label: 'Storage slot',
              value: (draft) => draft.storageSlot ?? '',
              setValue: (draft, value) => draft.storageSlot = value,
            ),
            _text(
              id: 'signed_by',
              label: 'Signed by',
              value: (draft) => draft.signedBy ?? '',
              setValue: (draft, value) => draft.signedBy = value,
            ),
            DateEditField<MusicOwnedEditDraft>(
              id: 'last_cleaned_date',
              label: 'Last cleaned',
              value: (draft) => draft.lastCleanedDate,
              setValue: (draft, value) => draft.lastCleanedDate = value,
            ),
            ReadOnlyEditField<MusicOwnedEditDraft, int>(
              id: 'matrix_runout_count',
              label: 'Matrix/runout entries',
              value: (draft) => draft.matrixRunouts.length,
              display: (value) => value?.toString() ?? '0',
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
}) =>
    TextEditField(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
    );
