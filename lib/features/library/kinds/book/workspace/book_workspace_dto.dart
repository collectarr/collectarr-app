import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class BookWorkspaceDto implements LibraryWorkspaceDto {
  BookWorkspaceDto({
    required this.common,
    required this.personal,
    required this.metadata,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;
  final BookCatalogMetadata metadata;

  String get title => common.title;
  String? get coverImageUrl => common.coverImageUrl;
  @override
  String get primaryLabel => title;
  @override
  String? get imageUrl => coverImageUrl;
  @override
  String? get secondaryLabel => null;

  String? get synopsis => common.synopsis;
  String? get currency => common.currency;

  // Domain convenience getters:
  int? get pageCount => metadata.pageCount;
  String? get imprint => metadata.imprint;
  String? get author =>
      metadata.authors.firstOrNull ?? metadata.creators.firstOrNull?.name;
  String? get publisher => metadata.publisher;
  String? get itemNumber => metadata.itemNumber;
  String? get seriesTitle => metadata.seriesTitle;
  DateTime? get releaseDate =>
      metadata.releaseDate ??
      metadata.releaseDateParts?.asDateTime ??
      common.releaseDate;
  String? get country => metadata.country;
  String? get language => metadata.language;
  String? get variant => metadata.variant;
  String? get isbn =>
      metadata.isbn ?? metadata.isbn13 ?? metadata.isbn10 ?? metadata.barcode;
  String? get identifierCode => isbn;
  String? get barcode => identifierCode;
  String? get subtitle => metadata.subtitle;
  String? get format => metadata.physicalFormat;
  String? get referenceFormatLabel => format;
  String? get translator => metadata.translators.firstOrNull;
  String? get editor => metadata.editors.firstOrNull;
  String? get illustrator => metadata.illustrators.firstOrNull;
  String? get coverArtist => metadata.coverArtists.firstOrNull;
  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
        if (author != null) author!,
        if (subtitle != null) subtitle!,
        if (translator != null) translator!,
        if (editor != null) editor!,
        if (illustrator != null) illustrator!,
      ];
}
