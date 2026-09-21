import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/release/manga_release_edit_draft.dart';

final EditSchema<CatalogEditionDto, MangaReleaseEditDraft>
    mangaReleaseEditSchema = EditSchema(
  title: (release) => 'Edit ${release.title}',
  validate: (_, draft) {
    if (draft.title.trim().isEmpty) return 'Edition title is required';
    if (draft.releaseDateController.text.trim().isNotEmpty &&
        draft.releaseDate == null) {
      return 'Publication date is invalid';
    }
    if (draft.pageCountController.text.trim().isNotEmpty &&
        (draft.pageCount == null || draft.pageCount! < 0)) {
      return 'Page count must be a non-negative number';
    }
    return null;
  },
  tabs: [
    EditTabSpec<MangaReleaseEditDraft>(
      id: 'release',
      label: 'Edition',
      sections: [
        EditSectionSpec<MangaReleaseEditDraft>(
          id: 'identity',
          label: 'Identity',
          fields: [
            _text(
              id: 'title',
              label: 'Edition title',
              value: (draft) => draft.title,
              setValue: (draft, value) => draft.title = value,
            ),
            _text(
              id: 'format',
              label: 'Format',
              value: (draft) => draft.format ?? '',
              setValue: (draft, value) => draft.format = value,
            ),
            _text(
              id: 'binding',
              label: 'Binding',
              value: (draft) => draft.binding ?? '',
              setValue: (draft, value) => draft.binding = value,
            ),
            _text(
              id: 'language',
              label: 'Language',
              value: (draft) => draft.language ?? '',
              setValue: (draft, value) => draft.language = value,
            ),
            _text(
              id: 'region',
              label: 'Country / region',
              value: (draft) => draft.region ?? '',
              setValue: (draft, value) => draft.region = value,
            ),
            DateEditField<MangaReleaseEditDraft>(
              id: 'release_date',
              label: 'Publication date',
              value: (draft) => draft.releaseDate,
              setValue: (draft, value) => draft.releaseDate = value,
            ),
          ],
        ),
        EditSectionSpec<MangaReleaseEditDraft>(
          id: 'publishing',
          label: 'Publishing and identifiers',
          fields: [
            _text(
              id: 'publisher',
              label: 'Publisher',
              value: (draft) => draft.publisher ?? '',
              setValue: (draft, value) => draft.publisher = value,
            ),
            _text(
              id: 'imprint',
              label: 'Imprint',
              value: (draft) => draft.imprint ?? '',
              setValue: (draft, value) => draft.imprint = value,
            ),
            _text(
              id: 'distributor',
              label: 'Distributor',
              value: (draft) => draft.distributor ?? '',
              setValue: (draft, value) => draft.distributor = value,
            ),
            _text(
              id: 'isbn',
              label: 'ISBN',
              value: (draft) => draft.isbn ?? '',
              setValue: (draft, value) => draft.isbn = value,
            ),
            _text(
              id: 'barcode',
              label: 'Barcode',
              value: (draft) => draft.barcode ?? '',
              setValue: (draft, value) => draft.barcode = value,
            ),
            NumberEditField<MangaReleaseEditDraft>(
              id: 'page_count',
              label: 'Page count',
              value: (draft) => draft.pageCount?.toDouble(),
              setValue: (draft, value) => draft.pageCount = value?.toInt(),
              minimum: 0,
            ),
          ],
        ),
        EditSectionSpec<MangaReleaseEditDraft>(
          id: 'artwork',
          label: 'Artwork and notes',
          fields: [
            _text(
              id: 'cover_image_url',
              label: 'Cover image URL',
              value: (draft) => draft.coverImageUrl ?? '',
              setValue: (draft, value) => draft.coverImageUrl = value,
            ),
            _text(
              id: 'description',
              label: 'Description',
              value: (draft) => draft.description ?? '',
              setValue: (draft, value) => draft.description = value,
              maxLines: 4,
            ),
          ],
        ),
      ],
    ),
  ],
);

TextEditField<MangaReleaseEditDraft> _text({
  required String id,
  required String label,
  required String Function(MangaReleaseEditDraft draft) value,
  required void Function(MangaReleaseEditDraft draft, String value) setValue,
  int maxLines = 1,
}) =>
    TextEditField(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
      maxLines: maxLines,
    );
