import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:collectarr_app/features/library/collections/repository.dart';

Future<void> selectLibraryCollection(
  BuildContext context, {
  required LibraryCollectionRepository repository,
  required String mediaKind,
  required String? activeId,
  required LibraryCollectionSummary collection,
  ValueChanged<LibraryCollectionSummary>? onSelected,
}) async {
  if (collection.id == activeId) return;
  await repository.activate(collection.id);
  if (!context.mounted) return;
  if (collection.kind != mediaKind) {
    context.go(
        Uri(path: '/libraries', queryParameters: {'kind': collection.kind})
            .toString());
  } else {
    onSelected?.call(collection);
  }
}
