import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_collection_item_projection.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_collection_item_dispatch.dart';
import 'package:flutter/material.dart';

List<LibraryDetailField> buildComicPersonalDetailFields({
  required BuildContext context,
  required LibraryProjectionView item,
  required CollectionItemSummary? collectionItem,
  required LibraryCollectionItemDispatch? collectionItemDispatch,
  required String? currency,
}) {
  final details =
      ComicCollectionItemProjection.fromDispatch(collectionItemDispatch)?.details;
  if (details == null || details.coverPriceCents == null) {
    return const [];
  }
  return [
    LibraryDetailField(
      label: 'Cover price',
      value: formatMoney(details.coverPriceCents, currency),
    ),
  ];
}
