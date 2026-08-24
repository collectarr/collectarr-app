import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class BookWorkspaceDto extends WorkspaceDtoAdapter {
  BookWorkspaceDto({
    required this.common,
    required this.personal,
    required this.book,
    this.metadata,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final BookCatalogItem book;
  final BookCatalogMetadata? metadata;

  // Domain convenience getters:
  int? get pageCount =>
      metadata?.editions.firstOrNull?.pageCount ?? book.publishing.pageCount;
  String? get imprint =>
      metadata?.editions.firstOrNull?.imprint ?? book.publishing.imprint;
  String? get author =>
      metadata?.authors.firstOrNull ?? book.work.creators.firstOrNull?.name;
  String? get isbn =>
      metadata?.editions.firstOrNull?.isbn ?? book.releases.firstOrNull?.isbn;
  String? get subtitle => metadata?.subtitle;
  String? get format => metadata?.editions.firstOrNull?.format;
  String? get translator => metadata?.translators.firstOrNull;
  String? get editor => metadata?.editors.firstOrNull;
  String? get illustrator => metadata?.illustrators.firstOrNull;
  String? get coverArtist => metadata?.coverArtists.firstOrNull;
  String? get printing => metadata?.editions.firstOrNull?.printing;
  String? get numberLine => metadata?.editions.firstOrNull?.numberLine;
  bool get firstEdition =>
      metadata?.editions.firstOrNull?.firstEdition ??
      (book.publishing.firstEdition ?? false);
  String? get dewey =>
      metadata?.editions.firstOrNull?.dewey ?? book.publishing.dewey;
  String? get locClassification =>
      metadata?.editions.firstOrNull?.locClassification;
}
