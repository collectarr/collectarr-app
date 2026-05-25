import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_builders.dart';
import 'package:flutter/material.dart';

class VideoLibraryEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const VideoLibraryEditPresentationBuilder()
      : super(
          showCatalogReleaseFields: false,
          trackingSectionTitle: 'Title tracking',
          ownershipReferenceTitle: 'Release / copy reference',
          ownedBundleLabel: 'Owned release bundle',
        );
}

const videoLibraryEditPresentation = LibraryEditPresentation(
  builder: VideoLibraryEditPresentationBuilder(),
);

Widget buildVideoLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return buildGenericLibraryEditDialog(context, request);
}