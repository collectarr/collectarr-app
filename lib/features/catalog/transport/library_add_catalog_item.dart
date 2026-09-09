import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';

/// Opaque catalog transport item used by the Add host.
///
/// Add UI and orchestration can carry a selected result without making the
/// Core catalog DTO its application-domain model. The owning kind receives
/// this boundary value through its Add capability and the transport DTO is
/// unwrapped only when persistence or an HTTP mutation is required.
final class LibraryAddCatalogItem {
  const LibraryAddCatalogItem._(this._item);

  factory LibraryAddCatalogItem.fromItem(CatalogItemDto item) {
    return LibraryAddCatalogItem._(item);
  }

  factory LibraryAddCatalogItem.fromJson(Map<String, dynamic> json) {
    return LibraryAddCatalogItem._(CatalogItemDto.fromJson(json));
  }

  final CatalogItemDto _item;

  String get id => _item.id;
  CatalogMediaKind get mediaKind => _item.mediaKind;
  LibraryItemIdentity get identity => _item.identity;
  String get kind => _item.kind;
  Map<String, dynamic> get payload => _item.payload;
  dynamic get kindMetadata => _item.kindMetadata;
  String get title => _item.title;
  String? get displayTitle => _item.displayTitle;
  String? get localizedTitle => _item.localizedTitle;
  String? get originalTitle => _item.originalTitle;
  String? get titleExtension => _item.titleExtension;
  List<String>? get searchAliases => _item.searchAliases;
  String? get sortKey => _item.sortKey;
  String? get synopsis => _item.synopsis;
  String? get coverImageUrl => _item.coverImageUrl;
  String? get thumbnailImageUrl => _item.thumbnailImageUrl;
  String? get coverImageData => _item.coverImageData;
  DateTime? get releaseDate => _item.releaseDate;
  int? get releaseYear => _item.releaseYear;
  List<TrailerLinkDto> get trailerUrls => _item.trailerUrls;
  List<CatalogEditionDto> get editions => _item.editions;
  String? get itemNumber => _item.itemNumber;
  String? get variant => _item.variant;
  String? get publisher => _item.publisher;
  String? get barcode => _item.barcode;
  String? get physicalFormat => _item.physicalFormat;
  String? get physicalFormatLabel => _item.physicalFormatLabel;
  String? get editionTitle => _item.editionTitle;
  String get resolvedDisplayTitle => _item.resolvedDisplayTitle;
  String? get displayCoverUrl => _item.displayCoverUrl;
  CatalogEntityRef get catalogRef => _item.catalogRef;
  Map<String, dynamic> toSyncPayload() => _item.toSyncPayload();

  CatalogEntityRef catalogRefForPersonalAnchor(PersonalItemAnchor? anchor) {
    return _item.catalogRefForPersonalAnchor(anchor);
  }

  LibraryAddCatalogItem copyWith({
    LibraryItemIdentity? identity,
    String? title,
    Object? displayTitle = _unset,
    Object? localizedTitle = _unset,
    Object? originalTitle = _unset,
    Object? titleExtension = _unset,
    Object? searchAliases = _unset,
    Object? sortKey = _unset,
    Object? synopsis = _unset,
    Object? coverImageUrl = _unset,
    Object? thumbnailImageUrl = _unset,
    Object? coverImageData = _unset,
    Object? releaseDate = _unset,
    Object? releaseYear = _unset,
    List<CatalogEditionDto>? editions,
    List<TrailerLinkDto>? trailerUrls,
    Object? physicalFormat = _unset,
    Object? physicalFormatLabel = _unset,
    Object? kindMetadata,
  }) {
    return LibraryAddCatalogItem._(
      _item.copyWith(
        identity: identity,
        title: title,
        displayTitle: displayTitle,
        localizedTitle: localizedTitle,
        originalTitle: originalTitle,
        titleExtension: titleExtension,
        searchAliases: searchAliases,
        sortKey: sortKey,
        synopsis: synopsis,
        coverImageUrl: coverImageUrl,
        thumbnailImageUrl: thumbnailImageUrl,
        coverImageData: coverImageData,
        releaseDate: releaseDate,
        releaseYear: releaseYear,
        editions: editions,
        trailerUrls: trailerUrls,
        physicalFormat: physicalFormat,
        physicalFormatLabel: physicalFormatLabel,
        kindMetadata: kindMetadata,
      ),
    );
  }

  LibraryAddCatalogItem withKindMetadata(Object? kindMetadata) {
    return LibraryAddCatalogItem._(_item.withKindMetadata(kindMetadata));
  }

  CatalogItemDto toTransportItem() => _item;
}

const _unset = Object();
