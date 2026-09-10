import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:flutter/material.dart';

List<LibraryDetailField> buildComicPersonalDetailFields({
  required BuildContext context,
  required LibraryProjectionView item,
  required OwnedItemSummary? ownedItem,
  required Object? typedOwnedItem,
  required String? currency,
}) {
  final typedOwned = typedOwnedItem;
  final details = typedOwned is ComicOwnedItem ? typedOwned.details : null;
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
