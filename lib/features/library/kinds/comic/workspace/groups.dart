import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/creator_roles.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/collection_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/dto.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart'
    show libraryCollectionStatusFromValue;
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart'
    show LibraryCollectionStatusScopeUi;
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:flutter/material.dart';

/// Folder fields of the reference Comics folder menu, by category and in
/// its order. Series, Publisher and Storage Box keep their own definitions
/// in the schemas (series folders, publisher renames, the location tree).
enum ComicGroupingField {
  hasBack('has_back', 'Has Back', 'Images'),
  hasFront('has_front', 'Has Front', 'Images'),
  imageType('image_type', 'Image Type', 'Images'),
  age('age', 'Age', 'Main'),
  country('country', 'Country', 'Main'),
  crossover('crossover', 'Crossover', 'Main'),
  genre('genre', 'Genre', 'Main'),
  imprint('imprint', 'Imprint', 'Main'),
  language('language', 'Language', 'Main'),
  publisher('publisher', 'Publisher', 'Main'),
  releaseDate('release_date', 'Release Date', 'Main'),
  releaseMonth('release_month', 'Release Month', 'Main'),
  releaseYear('release_year', 'Release Year', 'Main'),
  series('series', 'Series', 'Main'),
  seriesGroup('series_group', 'Series Group', 'Main'),
  storyArc('story_arc', 'Story Arc', 'Main'),
  customLabel('custom_label', 'Custom Label', 'Value'),
  grade('grade', 'Grade', 'Value'),
  gradingCompany('grading_company', 'Grading Company', 'Value'),
  isSigned('is_signed', 'Is Signed', 'Value'),
  key('key', 'Key', 'Value'),
  keyCategory('key_category', 'Key Category', 'Value'),
  labelType('label_type', 'Label Type', 'Value'),
  pageQuality('page_quality', 'Page Quality', 'Value'),
  purchaseDate('purchase_date', 'Purchase Date', 'Value'),
  purchaseMonth('purchase_month', 'Purchase Month', 'Value'),
  purchaseStore('purchase_store', 'Purchase Store', 'Value'),
  purchaseYear('purchase_year', 'Purchase Year', 'Value'),
  rawOrSlabbed('raw_or_slabbed', 'Raw / Slabbed', 'Value'),
  signedBy('signed_by', 'Signed by', 'Value'),
  soldDate('sold_date', 'Sold Date', 'Value'),
  soldMonth('sold_month', 'Sold Month', 'Value'),
  soldYear('sold_year', 'Sold Year', 'Value'),
  coverDate('cover_date', 'Cover Date', 'Edition'),
  coverMonth('cover_month', 'Cover Month', 'Edition'),
  coverYear('cover_year', 'Cover Year', 'Edition'),
  format('format', 'Format', 'Edition'),
  allCreators('all_creators', 'All Creators', 'Creators & Characters'),
  artist('creator_artist', 'Artist', 'Creators & Characters'),
  characters('characters', 'Characters', 'Creators & Characters'),
  colorist('creator_colorist', 'Colorist', 'Creators & Characters'),
  coverArtist('creator_cover_artist', 'Cover Artist', 'Creators & Characters'),
  coverColorist(
      'creator_cover_colorist', 'Cover Colorist', 'Creators & Characters'),
  coverInker('creator_cover_inker', 'Cover Inker', 'Creators & Characters'),
  coverPainter(
      'creator_cover_painter', 'Cover Painter', 'Creators & Characters'),
  coverPenciller(
      'creator_cover_penciller', 'Cover Penciller', 'Creators & Characters'),
  coverSeparator(
      'creator_cover_separator', 'Cover Separator', 'Creators & Characters'),
  editor('creator_editor', 'Editor', 'Creators & Characters'),
  editorInChief(
      'creator_editor_in_chief', 'Editor in Chief', 'Creators & Characters'),
  inker('creator_inker', 'Inker', 'Creators & Characters'),
  layouts('creator_layouts', 'Layouts', 'Creators & Characters'),
  letterer('creator_letterer', 'Letterer', 'Creators & Characters'),
  painter('creator_painter', 'Painter', 'Creators & Characters'),
  penciller('creator_penciller', 'Penciller', 'Creators & Characters'),
  plotter('creator_plotter', 'Plotter', 'Creators & Characters'),
  scripter('creator_scripter', 'Scripter', 'Creators & Characters'),
  separator('creator_separator', 'Separator', 'Creators & Characters'),
  translator('creator_translator', 'Translator', 'Creators & Characters'),
  writer('creator_writer', 'Writer', 'Creators & Characters'),
  addedDate('added_date', 'Added Date', 'Personal'),
  addedMonth('added_month', 'Added Month', 'Personal'),
  addedYear('added_year', 'Added Year', 'Personal'),
  bagBoardDate('bag_board_date', 'Bag/Board Date', 'Personal'),
  bagBoardMonth('bag_board_month', 'Bag/Board Month', 'Personal'),
  bagBoardYear('bag_board_year', 'Bag/Board Year', 'Personal'),
  collectionStatus('collection_status', 'Collection Status', 'Personal'),
  modifiedDate('modified_date', 'Modified Date', 'Personal'),
  modifiedMonth('modified_month', 'Modified Month', 'Personal'),
  rating('rating', 'My Rating', 'Personal'),
  owner('owner', 'Owner', 'Personal'),
  read('read', 'Read', 'Personal'),
  readDate('read_date', 'Read Date', 'Personal'),
  readMonth('read_month', 'Read Month', 'Personal'),
  readYear('read_year', 'Read Year', 'Personal'),
  storageBox('location', 'Storage Box', 'Personal'),
  tags('tags', 'Tags', 'Personal');

  const ComicGroupingField(this._key, this.label, this.category);

  final String _key;
  final String label;
  final String category;

  String get id => 'comic.$_key';

  /// Folders that read the copy rather than the catalog item.
  bool get personal => category == 'Value' || category == 'Personal';

  /// Folders the schemas define themselves.
  bool get ownDefinition =>
      this == series || this == publisher || this == storageBox;
}

const comicGroupingCategories = [
  'Images',
  'Main',
  'Value',
  'Edition',
  'Creators & Characters',
  'Personal',
];

List<LibraryGroupDefinition<ComicKind, ComicWorkspaceDto, Object?>>
    comicWorkspaceGroupDefinitions({required bool includePersonal}) => [
          for (final field in ComicGroupingField.values)
            if (!field.ownDefinition && (includePersonal || !field.personal))
              LibraryGroupDefinition(
                id: LibraryGroupId<ComicKind, Object?>(field.id),
                label: field.label,
                sidebarTitle: field.label,
                category: field.category,
                icon: switch (field.category) {
                  'Images' => Icons.image_outlined,
                  'Personal' => Icons.person_outline,
                  'Value' => Icons.attach_money,
                  'Edition' => Icons.menu_book_outlined,
                  'Creators & Characters' => Icons.people_outline,
                  _ => Icons.folder_outlined,
                },
                getValue: (context) => _groupValue(field, context),
              ),
        ];

Object? _groupValue(
  ComicGroupingField field,
  LibraryProjectionContext<ComicWorkspaceDto> context,
) {
  final dto = context.dto;
  final comic = dto.comic;
  final entry = dto.libraryEntry;
  final personal = entry?.personal;
  final details = personal?.details;
  final release = comic.releaseDateParts ?? _parts(dto.releaseDate);
  final cover = comic.coverDateParts ?? _parts(comic.coverDate);
  final purchase = _parts(personal?.purchaseDate);
  final sold = _parts(personal?.soldAt);
  final bagBoard = _parts(details?.lastBagBoardDate);
  final read = _parts(personal?.reading.finishedAt);
  final added = _parts(entry?.createdAt ?? context.addedAt);
  final modified = _parts(entry?.updatedAt ?? context.updatedAt);
  final imageTypes = {
    if (dto.coverImageUrl?.isNotEmpty == true) 'Front Cover',
    for (final image in context.personal.images) _imageType(image.imageType),
    for (final type in context.personal.imageTypes) _imageType(type),
  };
  final roleIndex = _creatorRoleFields.indexOf(field);
  if (roleIndex >= 0) {
    return comicCreatorNames(dto, kComicCreatorRoles[roleIndex]).toSet();
  }
  return switch (field) {
    ComicGroupingField.hasBack => _yesNo(imageTypes.contains('Back Cover')),
    ComicGroupingField.hasFront => _yesNo(imageTypes.contains('Front Cover')),
    ComicGroupingField.imageType => imageTypes.toList(),
    ComicGroupingField.age => comic.publicationAge,
    ComicGroupingField.country => comic.country,
    ComicGroupingField.crossover => comic.crossover,
    ComicGroupingField.genre => comic.genres,
    ComicGroupingField.imprint => comic.imprint,
    ComicGroupingField.language => comic.language,
    ComicGroupingField.releaseDate => release?.isoString,
    ComicGroupingField.releaseMonth => _monthLabel(release),
    ComicGroupingField.releaseYear => release?.year,
    ComicGroupingField.seriesGroup => comic.seriesGroup,
    ComicGroupingField.storyArc =>
      comic.storyArcs.map((arc) => arc.name).whereType<String>().toSet(),
    ComicGroupingField.customLabel => details?.customLabel,
    ComicGroupingField.grade => personal?.grade,
    ComicGroupingField.gradingCompany => details?.gradingCompany,
    ComicGroupingField.isSigned => personal == null
        ? null
        : _yesNo(details?.signedBy?.trim().isNotEmpty == true),
    ComicGroupingField.key =>
      personal == null ? null : _yesNo(details?.keyComic == true),
    ComicGroupingField.keyCategory => details?.keyCategory,
    ComicGroupingField.labelType => details?.labelType,
    ComicGroupingField.pageQuality => details?.pageQuality,
    ComicGroupingField.purchaseDate => purchase?.isoString,
    ComicGroupingField.purchaseMonth => _monthLabel(purchase),
    ComicGroupingField.purchaseStore => personal?.purchaseStore,
    ComicGroupingField.purchaseYear => purchase?.year,
    ComicGroupingField.rawOrSlabbed => details?.rawOrSlabbed,
    ComicGroupingField.signedBy =>
      details?.signedBy?.split(',') ?? const <String>[],
    ComicGroupingField.soldDate => sold?.isoString,
    ComicGroupingField.soldMonth => _monthLabel(sold),
    ComicGroupingField.soldYear => sold?.year,
    ComicGroupingField.coverDate => cover?.isoString,
    ComicGroupingField.coverMonth => _monthLabel(cover),
    ComicGroupingField.coverYear => cover?.year,
    ComicGroupingField.format => dto.format,
    ComicGroupingField.allCreators =>
      comic.creators.map((creator) => creator.name).whereType<String>().toSet(),
    ComicGroupingField.characters => comic.characters
        .map((character) => character.name)
        .whereType<String>()
        .toSet(),
    ComicGroupingField.addedDate => added?.isoString,
    ComicGroupingField.addedMonth => _monthLabel(added),
    ComicGroupingField.addedYear => added?.year,
    ComicGroupingField.bagBoardDate => bagBoard?.isoString,
    ComicGroupingField.bagBoardMonth => _monthLabel(bagBoard),
    ComicGroupingField.bagBoardYear => bagBoard?.year,
    ComicGroupingField.collectionStatus => personal == null
        ? null
        : libraryCollectionStatusFromValue(personal.collectionStatus).label,
    ComicGroupingField.modifiedDate => modified?.isoString,
    ComicGroupingField.modifiedMonth => _monthLabel(modified),
    ComicGroupingField.rating => personal?.reading.rating,
    ComicGroupingField.owner => personal?.ownerLabel,
    ComicGroupingField.read =>
      personal == null ? null : _yesNo(personal.reading.status == 'Read'),
    ComicGroupingField.readDate => read?.isoString,
    ComicGroupingField.readMonth => _monthLabel(read),
    ComicGroupingField.readYear => read?.year,
    ComicGroupingField.tags => personal?.tags ?? const <String>[],
    _ => throw ArgumentError.value(field, 'field', 'Defined by the schema.'),
  };
}

/// The per-role creator folders, in [kComicCreatorRoles] order.
const _creatorRoleFields = [
  ComicGroupingField.writer,
  ComicGroupingField.artist,
  ComicGroupingField.coverArtist,
  ComicGroupingField.coverPenciller,
  ComicGroupingField.coverPainter,
  ComicGroupingField.coverInker,
  ComicGroupingField.coverColorist,
  ComicGroupingField.coverSeparator,
  ComicGroupingField.penciller,
  ComicGroupingField.inker,
  ComicGroupingField.colorist,
  ComicGroupingField.painter,
  ComicGroupingField.letterer,
  ComicGroupingField.separator,
  ComicGroupingField.layouts,
  ComicGroupingField.translator,
  ComicGroupingField.plotter,
  ComicGroupingField.scripter,
  ComicGroupingField.editor,
  ComicGroupingField.editorInChief,
];

String _imageType(String raw) {
  final type =
      raw.startsWith('personal:') ? raw.substring('personal:'.length) : raw;
  return switch (type) {
    'front_cover' => 'Front Cover',
    'back_cover' => 'Back Cover',
    _ => type,
  };
}

PartialDate? _parts(DateTime? value) =>
    value == null ? null : PartialDate.fromDateTime(value);

String _yesNo(bool value) => value ? 'Yes' : 'No';

String? _monthLabel(PartialDate? value) {
  final month = value?.month;
  if (month == null) return null;
  const names = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${month.toString().padLeft(2, '0')} - ${names[month - 1]}';
}
