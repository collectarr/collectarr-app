import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:flutter/material.dart';

List<LibraryDetailField> buildComicPersonalDetailFields({
  required BuildContext context,
  required LibraryProjectionView item,
  required OwnedItem? ownedItem,
  required String? currency,
}) {
  final details = ownedItem?.details;
  if (details is! ComicOwnedDetails || details.coverPriceCents == null) {
    return const [];
  }
  return [
    LibraryDetailField(
      label: 'Cover price',
      value: formatMoney(details.coverPriceCents, currency),
    ),
  ];
}
