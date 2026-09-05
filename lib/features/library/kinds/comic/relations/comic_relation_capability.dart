import 'package:collectarr_app/core/models/library_relation_node.dart';
import 'package:collectarr_app/features/library/config/library_relation_capability.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const comicRelationCapability = LibraryRelationCapability(
  targetFor: _comicRelationTargetFor,
  openTarget: _openComicRelationTarget,
);

LibraryRelationTarget? _comicRelationTargetFor(
  LibraryProjectionRuntime item,
) {
  final dto = item.dto;
  if (dto is! ComicWorkspaceDto) {
    return null;
  }
  final metadata = dto.metadata ?? dto.comic;
  final series = metadata.series;
  final id = series?.seriesId?.trim();
  final title = series?.seriesTitle?.trim();
  if (id == null || id.isEmpty || title == null || title.isEmpty) {
    return null;
  }
  return LibraryRelationTarget(
    id: id,
    title: title,
    label: 'Series',
  );
}

void _openComicRelationTarget(
  BuildContext context,
  LibraryRelationTarget target,
) {
  context.push(
    '/comic/series/${Uri.encodeComponent(target.id)}?title=${Uri.encodeQueryComponent(target.title)}',
  );
}
