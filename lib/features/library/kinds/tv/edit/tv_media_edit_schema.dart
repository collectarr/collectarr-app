import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_media_edit_draft.dart';

final EditSchema<TvSeries, TvMediaEditDraft> tvMediaEditSchema = EditSchema(
  title: (series) => 'Edit ${series.title}',
  validate: (_, draft) {
    if (draft.title.trim().isEmpty) return 'Series title is required';
    if (draft.originalAirDateController.text.trim().isNotEmpty &&
        draft.originalAirDate == null) {
      return 'First air date is invalid';
    }
    if (draft.endDateController.text.trim().isNotEmpty &&
        draft.endDate == null) {
      return 'End date is invalid';
    }
    if (draft.originalAirDate != null &&
        draft.endDate != null &&
        draft.endDate!.isBefore(draft.originalAirDate!)) {
      return 'End date cannot be before first air date';
    }
    return null;
  },
  tabs: [
    EditTabSpec<TvMediaEditDraft>(
      id: 'series',
      label: 'Series',
      sections: [
        EditSectionSpec<TvMediaEditDraft>(
          id: 'identity',
          label: 'Identity',
          fields: [
            _text(
              id: 'title',
              label: 'Title',
              value: (draft) => draft.title,
              setValue: (draft, value) => draft.title = value,
            ),
            _text(
              id: 'sort_title',
              label: 'Sort title',
              value: (draft) => draft.sortTitle,
              setValue: (draft, value) => draft.sortTitle = value,
            ),
            _text(
              id: 'description',
              label: 'Synopsis',
              value: (draft) => draft.description,
              setValue: (draft, value) => draft.description = value,
              maxLines: 4,
            ),
          ],
        ),
        EditSectionSpec<TvMediaEditDraft>(
          id: 'broadcast',
          label: 'Broadcast',
          fields: [
            _text(
              id: 'network',
              label: 'Network / studio',
              value: (draft) => draft.network,
              setValue: (draft, value) => draft.network = value,
            ),
            _text(
              id: 'status',
              label: 'Status',
              value: (draft) => draft.status,
              setValue: (draft, value) => draft.status = value,
            ),
            _text(
              id: 'streaming_service',
              label: 'Streaming service',
              value: (draft) => draft.streamingService,
              setValue: (draft, value) => draft.streamingService = value,
            ),
            _text(
              id: 'original_language',
              label: 'Original language',
              value: (draft) => draft.originalLanguage,
              setValue: (draft, value) => draft.originalLanguage = value,
            ),
          ],
        ),
        EditSectionSpec<TvMediaEditDraft>(
          id: 'classification',
          label: 'Classification',
          fields: [
            _text(
              id: 'genres',
              label: 'Genres',
              value: (draft) => draft.genres.join(', '),
              setValue: (draft, value) => draft.genres = _split(value),
            ),
            _text(
              id: 'content_rating',
              label: 'Content rating',
              value: (draft) => draft.contentRating,
              setValue: (draft, value) => draft.contentRating = value,
            ),
            DateEditField<TvMediaEditDraft>(
              id: 'first_air_date',
              label: 'First air date',
              value: (draft) => draft.originalAirDate,
              setValue: (draft, value) => draft.originalAirDate = value,
            ),
            DateEditField<TvMediaEditDraft>(
              id: 'end_date',
              label: 'End date',
              value: (draft) => draft.endDate,
              setValue: (draft, value) => draft.endDate = value,
            ),
          ],
        ),
      ],
    ),
  ],
);

TextEditField<TvMediaEditDraft> _text({
  required String id,
  required String label,
  required String Function(TvMediaEditDraft draft) value,
  required void Function(TvMediaEditDraft draft, String value) setValue,
  int maxLines = 1,
}) =>
    TextEditField(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
      maxLines: maxLines,
    );

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);
