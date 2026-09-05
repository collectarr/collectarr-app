import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class ComicWorkspaceDto extends WorkspaceDtoAdapter {
  ComicWorkspaceDto({
    required this.common,
    required this.personal,
    required this.comic,
    this.ownedItem,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final ComicMedia comic;
  final ComicOwnedItem? ownedItem;

  // Domain convenience getters
  String? get writer => comic.writers.firstOrNull;
  String? get artist => comic.artists.firstOrNull;
  String? get coverArtist => comic.coverArtists.firstOrNull;
  String? get imprint => comic.imprint ?? comic.publishing?.imprint;
  @override
  String? get variant => comic.variant;
  int? get pageCount => comic.pageCount ?? comic.publishing?.pageCount;
}
