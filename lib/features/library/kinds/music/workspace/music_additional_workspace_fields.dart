import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'music_workspace_dto.dart';

typedef _Context = LibraryProjectionContext<MusicWorkspaceProjection>;

/// Explicit additional spreadsheet choices, owned by Music.
abstract final class MusicAdditionalWorkspaceFields {
  static MusicLibraryEntry? _entry(_Context context) {
    final entry = MusicLibraryEntryProjection.fromDispatch(
        context.item.libraryEntryDispatch);
    return entry is MusicLibraryEntry ? entry : null;
  }

  static LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      _text(String id, String label, String path, LibraryFieldSource source,
              String? Function(_Context) read, {bool sortable = true}) =>
          LibraryFieldDefinition(
              id: LibraryFieldId<MusicKind, String?>(id),
              metadata: LibraryKindFieldMetadata(
                  id: id,
                  label: label,
                  valueType: LibraryFieldValueType.text,
                  cardinality: LibraryFieldCardinality.one,
                  source: source,
                  sourcePath: path,
                  sortable: sortable,
                  groupable: true),
              getValue: read);

  static LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>
      _number(String id, String label, String path, LibraryFieldSource source,
              int? Function(_Context) read) =>
          LibraryFieldDefinition(
              id: LibraryFieldId<MusicKind, int?>(id),
              metadata: LibraryKindFieldMetadata(
                  id: id,
                  label: label,
                  valueType: LibraryFieldValueType.number,
                  cardinality: LibraryFieldCardinality.one,
                  source: source,
                  sourcePath: path,
                  sortable: true,
                  groupable: true),
              getValue: read);

  static final subtitle = _text('music.subtitle', 'Subtitle', 'subtitle',
      LibraryFieldSource.catalog, (c) => c.dto.music.subtitle);
  static final sortTitle = _text('music.sort_title', 'Sort Title', 'sort_title',
      LibraryFieldSource.catalog, (c) => c.dto.music.sortTitle);
  static final quantity = _number('music.quantity', 'Quantity', 'quantity',
      LibraryFieldSource.libraryEntry, (c) => _entry(c)?.personal.quantity);
  static final owner = _text('music.owner', 'Owner', 'owner_label',
      LibraryFieldSource.libraryEntry, (c) => c.item.entrySummary?.ownerLabel);
  static final notes = _text('music.notes', 'Notes', 'personal_notes',
      LibraryFieldSource.libraryEntry, (c) => c.item.entrySummary?.notes,
      sortable: false);
  static final purchaseStore = _text(
      'music.purchase_store',
      'Purchase Store',
      'purchase_store',
      LibraryFieldSource.libraryEntry,
      (c) => c.item.entrySummary?.purchaseStore);
  static final collectionStatus = _text(
      'music.collection_status',
      'Collection Status',
      'collection_status',
      LibraryFieldSource.libraryEntry,
      (c) => _entry(c)?.personal.collectionStatus);
  static final tags = LibraryFieldDefinition<MusicKind,
          MusicWorkspaceProjection, Iterable<String>>(
      id: const LibraryFieldId('music.tags'),
      metadata: const LibraryKindFieldMetadata(
          id: 'music.tags',
          label: 'Tags',
          valueType: LibraryFieldValueType.text,
          cardinality: LibraryFieldCardinality.many,
          source: LibraryFieldSource.libraryEntry,
          sourcePath: 'tags',
          groupable: true),
      getValue: (c) => _entry(c)?.personal.tags ?? const <String>[]);
  static final releaseYear = _number(
      'music.release_year',
      'Release Year',
      'release_date.year',
      LibraryFieldSource.derived,
      (c) => c.dto.music.releaseDateParts?.year);
  static final releaseMonth = _number(
      'music.release_month',
      'Release Month',
      'release_date.month',
      LibraryFieldSource.derived,
      (c) => c.dto.music.releaseDateParts?.month);
  static final originalReleaseDate =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>(
          id: const LibraryFieldId('music.original_release_date'),
          metadata: const LibraryKindFieldMetadata(
              id: 'music.original_release_date',
              label: 'Original Release Date',
              valueType: LibraryFieldValueType.partialDate,
              cardinality: LibraryFieldCardinality.one,
              source: LibraryFieldSource.catalog,
              sourcePath: 'original_release_date',
              sortable: true,
              groupable: true),
          getValue: (c) => c.dto.music.originalReleaseDate);
  static final originalReleaseYear = _number(
      'music.original_release_year',
      'Original Release Year',
      'original_release_date.year',
      LibraryFieldSource.derived,
      (c) => c.dto.music.originalReleaseDateParts?.year);
  static final originalReleaseMonth = _number(
      'music.original_release_month',
      'Original Release Month',
      'original_release_date.month',
      LibraryFieldSource.derived,
      (c) => c.dto.music.originalReleaseDateParts?.month);
  static LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, bool>
      _boolean(String id, String label, String path,
              bool Function(_Context) read) =>
          LibraryFieldDefinition(
              id: LibraryFieldId<MusicKind, bool>(id),
              metadata: LibraryKindFieldMetadata(
                  id: id,
                  label: label,
                  valueType: LibraryFieldValueType.boolean,
                  cardinality: LibraryFieldCardinality.one,
                  source: LibraryFieldSource.derived,
                  sourcePath: path,
                  sortable: true,
                  groupable: true),
              getValue: read);
  static final hasFront = _boolean('music.has_front', 'Has Front',
      'cover_image_url', (c) => c.dto.imageUrl?.isNotEmpty == true);
  static final hasBack = _boolean(
      'music.has_back',
      'Has Back',
      'back_cover_image_url',
      (c) => c.dto.music.backCoverImageUrl?.isNotEmpty == true);
  static final loanTo = _text('music.loan_to', 'Loaned To',
      'loans[].borrower_name', LibraryFieldSource.derived, (c) {
    final active = c.personal.loans.where((l) => l.returnedDate == null);
    return active.isEmpty ? null : active.first.borrowerName;
  });

  static final catalog =
      <LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, Object?>>[
    subtitle,
    sortTitle,
    releaseYear,
    releaseMonth,
    originalReleaseDate,
    originalReleaseYear,
    originalReleaseMonth,
    hasFront,
    hasBack,
  ];
  static final personal =
      <LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, Object?>>[
    quantity,
    owner,
    notes,
    purchaseStore,
    collectionStatus,
    tags,
    loanTo,
  ];
}
