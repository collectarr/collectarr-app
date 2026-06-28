import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:flutter/material.dart';

const _comicMediaTabs = [
  LibraryEditTabSpec(id: 'main', icon: Icons.article, label: 'Main'),
  LibraryEditTabSpec(id: 'details', icon: Icons.search, label: 'Details'),
  LibraryEditTabSpec(id: 'creators', icon: Icons.group, label: 'Creators'),
  LibraryEditTabSpec(id: 'characters', icon: Icons.face, label: 'Characters'),
  LibraryEditTabSpec(id: 'links', icon: Icons.link, label: 'Links'),
  LibraryEditTabSpec(id: 'cover', icon: Icons.image, label: 'Covers'),
  LibraryEditTabSpec(id: 'photos', icon: Icons.photo_library, label: 'My Images'),
];

const _comicReleaseTabs = [
  LibraryEditTabSpec(id: 'custom', icon: Icons.tune, label: 'Custom Fields'),
  LibraryEditTabSpec(id: 'value', icon: Icons.attach_money, label: 'Value'),
  LibraryEditTabSpec(id: 'synopsis', icon: Icons.notes, label: 'Plot'),
  LibraryEditTabSpec(id: 'personal', icon: Icons.person, label: 'Personal'),
];

const _comicCombinedTabs = [
  ..._comicMediaTabs,
  ..._comicReleaseTabs,
];

class ComicLibraryCombinedEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const ComicLibraryCombinedEditPresentationBuilder()
      : super(
          showOwnedGradingSection: true,
          useOwnedMainArtworkLayout: true,
          useDetailsTab: true,
          useArtworkCoverTab: true,
          useArtworkPhotosTab: true,
          showOwnedCoverPriceField: false,
          ownedTabs: _comicCombinedTabs,
          trackedTabs: _comicCombinedTabs,
          catalogTabs: _comicCombinedTabs,
        );

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    final sections = switch (tabId) {
      'main' => ['catalog_snapshot'],
      'details' => ['catalog_details'],
      'creators' => ['comic_creators'],
      'characters' => ['comic_characters'],
      'synopsis' => ['synopsis'],
      'links' => ['external_links'],
      'value' => ['purchase', 'value_summary'],
      'personal' => [
          'tracking_personal',
          'ownership_fields',
          'purchase_fields',
          'sold_fields',
          'wishlist_reference',
          'owned_notes',
          'collection_fields_info',
        ],
      'custom' => ['custom_fields'],
      'cover' => ['cover_images'],
      'photos' => ['photos'],
      _ => const <String>[],
    };
    return List<String>.unmodifiable(sections);
  }
}

class ComicLibraryMediaEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const ComicLibraryMediaEditPresentationBuilder()
      : super(
          showOwnedGradingSection: true,
          useOwnedMainArtworkLayout: true,
          useDetailsTab: true,
          useArtworkCoverTab: true,
          useArtworkPhotosTab: true,
          showOwnedCoverPriceField: false,
          ownedTabs: _comicMediaTabs,
          trackedTabs: _comicMediaTabs,
          catalogTabs: _comicMediaTabs,
        );

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    final sections = switch (tabId) {
      'main' => ['catalog_snapshot'],
      'details' => ['catalog_details'],
      'creators' => ['comic_creators'],
      'characters' => ['comic_characters'],
      'synopsis' => ['synopsis'],
      'links' => ['external_links'],
      'cover' => ['cover_images'],
      'photos' => ['photos'],
      _ => const <String>[],
    };
    return List<String>.unmodifiable(sections);
  }
}

class ComicLibraryReleaseEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const ComicLibraryReleaseEditPresentationBuilder()
      : super(
          showOwnedGradingSection: true,
          useOwnedMainArtworkLayout: true,
          useDetailsTab: true,
          useArtworkCoverTab: true,
          useArtworkPhotosTab: true,
          showOwnedCoverPriceField: false,
          ownedTabs: _comicReleaseTabs,
          trackedTabs: _comicReleaseTabs,
          catalogTabs: _comicReleaseTabs,
        );

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    final sections = switch (tabId) {
      'value' => ['purchase', 'value_summary'],
      'personal' => [
          'tracking_personal',
          'ownership_fields',
          'purchase_fields',
          'sold_fields',
          'wishlist_reference',
          'owned_notes',
          'collection_fields_info',
        ],
      'custom' => ['custom_fields'],
      'cover' => ['cover_images'],
      'photos' => ['photos'],
      _ => const <String>[],
    };
    return List<String>.unmodifiable(sections);
  }
}

const comicsLibraryEditPresentation = LibraryEditPresentation(
  builder: ComicLibraryCombinedEditPresentationBuilder(),
  mediaBuilder: ComicLibraryMediaEditPresentationBuilder(),
  releaseBuilder: ComicLibraryReleaseEditPresentationBuilder(),
);
