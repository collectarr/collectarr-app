import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_edit_presentation_builder_base.dart';

const _comicMediaTabs = [
  LibraryEditTabSpec(
      id: 'main',
      icon: AppIcons.book,
      label: 'Main',
      sectionIds: ['catalog_snapshot']),
  LibraryEditTabSpec(
      id: 'details',
      icon: AppIcons.tabDetails,
      label: 'Details',
      sectionIds: ['catalog_details']),
  LibraryEditTabSpec(
      id: 'cover',
      icon: AppIcons.tabCovers,
      label: 'Covers',
      sectionIds: ['cover_images']),
  LibraryEditTabSpec(
      id: 'creators',
      icon: AppIcons.tabCredits,
      label: 'Creators',
      sectionIds: ['comic_creators']),
  LibraryEditTabSpec(
      id: 'characters',
      icon: AppIcons.tabPersonal,
      label: 'Characters',
      sectionIds: ['comic_characters']),
  LibraryEditTabSpec(
      id: 'synopsis',
      icon: AppIcons.tabDescription,
      label: 'Plot',
      sectionIds: ['synopsis']),
  LibraryEditTabSpec(
      id: 'links',
      icon: AppIcons.tabLinks,
      label: 'Links',
      sectionIds: ['external_links']),
];

const _comicCombinedTabs = [
  LibraryEditTabSpec(
      id: 'main',
      icon: AppIcons.book,
      label: 'Main',
      sectionIds: ['catalog_snapshot']),
  LibraryEditTabSpec(
      id: 'details',
      icon: AppIcons.tabDetails,
      label: 'Details',
      sectionIds: ['catalog_details']),
  LibraryEditTabSpec(
      id: 'value',
      icon: AppIcons.tabValue,
      label: 'Value',
      sectionIds: ['purchase']),
  LibraryEditTabSpec(
      id: 'personal',
      icon: AppIcons.tabPersonal,
      label: 'Personal',
      sectionIds: ['tracking_personal']),
  LibraryEditTabSpec(
      id: 'custom',
      icon: AppIcons.tabCustomFields,
      label: 'Custom Fields',
      sectionIds: ['custom_fields']),
  LibraryEditTabSpec(
      id: 'cover',
      icon: AppIcons.tabCovers,
      label: 'Covers',
      sectionIds: ['cover_images']),
  LibraryEditTabSpec(
      id: 'photos',
      icon: AppIcons.tabImages,
      label: 'My Images',
      sectionIds: ['photos']),
  LibraryEditTabSpec(
      id: 'creators',
      icon: AppIcons.tabCredits,
      label: 'Creators',
      sectionIds: ['comic_creators']),
  LibraryEditTabSpec(
      id: 'characters',
      icon: AppIcons.tabPersonal,
      label: 'Characters',
      sectionIds: ['comic_characters']),
  LibraryEditTabSpec(
      id: 'synopsis',
      icon: AppIcons.tabDescription,
      label: 'Plot',
      sectionIds: ['synopsis']),
  LibraryEditTabSpec(
      id: 'links',
      icon: AppIcons.tabLinks,
      label: 'Links',
      sectionIds: ['external_links']),
];

const _comicEntryTabs = _comicCombinedTabs;

class ComicLibraryCombinedEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const ComicLibraryCombinedEditPresentationBuilder()
      : super(
          useEntryMainArtworkLayout: true,
          useDetailsTab: true,
          useArtworkCoverTab: true,
          useArtworkPhotosTab: true,
          trackingSectionTitle: 'Tracking edition',
          entryDigitalTrackingSectionTitle: 'Digital Entry Details',
          entryDigitalTrackingHint:
              'Digital items keep tracking, notes, and value fields, while physical media fields stay disabled.',
          entryTabs: _comicEntryTabs,
          trackedTabs: _comicCombinedTabs,
          catalogTabs: _comicCombinedTabs,
        );
}

class ComicLibraryCatalogItemEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const ComicLibraryCatalogItemEditPresentationBuilder()
      : super(
          useEntryMainArtworkLayout: true,
          useDetailsTab: true,
          useArtworkCoverTab: true,
          useArtworkPhotosTab: true,
          trackingSectionTitle: 'Tracking edition',
          entryDigitalTrackingSectionTitle: 'Digital Entry Details',
          entryDigitalTrackingHint:
              'Digital items keep tracking, notes, and value fields, while physical media fields stay disabled.',
          entryTabs: _comicMediaTabs,
          trackedTabs: _comicMediaTabs,
          catalogTabs: _comicMediaTabs,
        );
}

const comicsLibraryEditPresentation = LibraryEditPresentation(
  builder: ComicLibraryCombinedEditPresentationBuilder(),
  catalogItemBuilder: ComicLibraryCatalogItemEditPresentationBuilder(),
);
