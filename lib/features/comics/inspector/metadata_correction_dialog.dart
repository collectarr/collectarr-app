import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/library/inspector/generic_metadata_correction_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Comics-specific convenience wrapper that passes [comicsLibraryConfig].
Future<void> showMetadataCorrectionDialog({
  required BuildContext context,
  required WidgetRef ref,
  required CatalogItem item,
}) =>
    showGenericMetadataCorrectionDialog(
      context: context,
      ref: ref,
      item: item,
      type: comicsLibraryConfig,
    );
