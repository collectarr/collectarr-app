import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_builders.dart';
import 'package:flutter/material.dart';

class VideoLibraryEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const VideoLibraryEditPresentationBuilder()
      : super(
          trackingSectionTitle: 'Watch tracking',
          ownershipReferenceTitle: 'Release / copy reference',
          ownedBundleLabel: 'Owned release bundle',
          ownedTabs: const [
            LibraryEditTabSpec(
                id: 'media', icon: Icons.movie, label: 'Media'),
            LibraryEditTabSpec(
                id: 'cast', icon: Icons.people, label: 'Cast & Crew'),
            LibraryEditTabSpec(
                id: 'main', icon: Icons.inventory_2, label: 'Ownership'),
            LibraryEditTabSpec(
                id: 'value', icon: Icons.attach_money, label: 'Value'),
            LibraryEditTabSpec(
                id: 'personal', icon: Icons.person, label: 'Personal'),
            LibraryEditTabSpec(
                id: 'sold', icon: Icons.sell, label: 'Sold'),
            LibraryEditTabSpec(
                id: 'photos',
                icon: Icons.photo_library,
                label: 'Photos'),
            LibraryEditTabSpec(
                id: 'cover', icon: Icons.image, label: 'Cover'),
            LibraryEditTabSpec(
                id: 'synopsis', icon: Icons.notes, label: 'Synopsis'),
          ],
          trackedTabs: const [
            LibraryEditTabSpec(
                id: 'media', icon: Icons.movie, label: 'Media'),
            LibraryEditTabSpec(
                id: 'cast', icon: Icons.people, label: 'Cast & Crew'),
            LibraryEditTabSpec(
                id: 'main', icon: Icons.track_changes, label: 'Tracking'),
            LibraryEditTabSpec(
                id: 'personal', icon: Icons.person, label: 'Personal'),
            LibraryEditTabSpec(
                id: 'cover', icon: Icons.image, label: 'Cover'),
            LibraryEditTabSpec(
                id: 'synopsis', icon: Icons.notes, label: 'Synopsis'),
          ],
          catalogTabs: const [
            LibraryEditTabSpec(
                id: 'media', icon: Icons.movie, label: 'Media'),
            LibraryEditTabSpec(
                id: 'cast', icon: Icons.people, label: 'Cast & Crew'),
            LibraryEditTabSpec(
                id: 'cover', icon: Icons.image, label: 'Cover'),
            LibraryEditTabSpec(
                id: 'synopsis', icon: Icons.notes, label: 'Synopsis'),
          ],
        );

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    final sections = switch (tabId) {
      'media' => ['catalog_snapshot'],
      'cast' => ['cast_crew'],
      'main' => [
        'tracking_context',
        'ownership_reference',
        'owned_grading',
      ],
      'value' => ['purchase', 'value_summary'],
      'personal' => [
        'tracking_personal',
        'wishlist_reference',
        'owned_notes',
        'collection_fields_info',
      ],
      'sold' => ['sold_status', 'profit_loss'],
      'custom' => ['custom_fields'],
      'photos' => ['photos'],
      'cover' => ['cover_images'],
      'synopsis' => ['synopsis'],
      _ => const <String>[],
    };
    return List<String>.unmodifiable(sections);
  }
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