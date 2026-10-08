import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';

/// Canonical Comic field facts shared by forms, workspace, and filters.
abstract final class ComicFieldIdentities {
  static const seriesId = 'comic.series';
  static const seriesLabel = 'Series';
  static const issueNumberId = 'comic.issue_number';
  static const issueNumberLabel = 'Issue Number';
  static const variantId = 'comic.variant';
  static const variantLabel = 'Variant';
  static const imprintId = 'comic.imprint';
  static const imprintLabel = 'Imprint';
  static const pageCountId = 'comic.page_count';
  static const pageCountLabel = 'Page count';

  static const imprintVocabulary = VocabularyId<String>('comic.imprint');

  static const series = LibraryKindFieldMetadata(
    id: seriesId,
    label: seriesLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'series_title',
    filterable: true,
    sortable: true,
    groupable: true,
    editable: true,
  );
  static const issueNumber = LibraryKindFieldMetadata(
    id: issueNumberId,
    label: issueNumberLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'issue_number',
    sortable: true,
    editable: true,
  );
  static const variant = LibraryKindFieldMetadata(
    id: variantId,
    label: variantLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'variant_name',
    editable: true,
  );
  static const imprint = LibraryKindFieldMetadata(
    id: imprintId,
    label: imprintLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'imprint',
    editable: true,
    vocabulary: imprintVocabulary,
  );
  static const pageCount = LibraryKindFieldMetadata(
    id: pageCountId,
    label: pageCountLabel,
    valueType: LibraryFieldValueType.number,
    catalogPath: 'page_count',
    editable: true,
  );
}
