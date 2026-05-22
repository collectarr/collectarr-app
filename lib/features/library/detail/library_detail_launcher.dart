import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/detail/library_detail_page.dart';
import 'package:flutter/material.dart';

void showLibraryDetailPage({
  required BuildContext context,
  required LibraryDetailPageRequest request,
}) {
  final builder = request.type.detailPageBuilder ?? _buildDefaultLibraryDetailPage;
  Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (context) => builder(context, request),
    ),
  );
}

Widget _buildDefaultLibraryDetailPage(
  BuildContext context,
  LibraryDetailPageRequest request,
) {
  return LibraryDetailPage(
    type: request.type,
    entry: request.entry,
    ownedItem: request.ownedItem,
    accent: request.accent,
    onAddOwned: request.onAddOwned,
    onRemoveOwned: request.onRemoveOwned,
    onAddWishlist: request.onAddWishlist,
    onRemoveWishlist: request.onRemoveWishlist,
    onEdit: request.onEdit,
    onFilterByValue: request.onFilterByValue,
  );
}