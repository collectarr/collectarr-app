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
            ReadOnlyEditField<MusicOwnedEditDraft, int>(
              id: 'medium_count',
              label: 'Medium details',
              value: (draft) => draft.media.length,
              display: (value) => value?.toString() ?? '0',
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
              value: (draft) => draft.media.fold<int>(
                0,
                (total, medium) => total + medium.matrixRunouts.length,
              ),
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
