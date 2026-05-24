import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showLibraryDetailPage({
  required BuildContext context,
  required LibraryDetailPageRequest request,
}) {
  context.push(AppRoutes.detail, extra: request);
}