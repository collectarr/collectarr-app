import 'location.dart';
import 'package:collectarr_app/features/library/config/item_actions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showLibraryDetailPage({
  required BuildContext context,
  required LibraryDetailPageRequest request,
}) {
  context.push(LibraryDetailLocation(request.item.target).toUri().toString(),
      extra: request);
}
