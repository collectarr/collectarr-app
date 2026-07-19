import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:flutter/material.dart';

final movieLibraryFieldDefinitions = [
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('movie.title'),
    label: 'Title',
    getValue: (dto) => dto.title,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('movie.series'),
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('movie.number'),
    label: 'Number',
    getValue: (dto) => dto.itemNumber,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('movie.publisher'),
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('movie.release_date'),
    label: 'Release date',
    getValue: (dto) => dto.releaseDate,
  ),
];

final movieLibraryGroupDefinitions = [
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('series'),
    label: 'Series',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).seriesTitle,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('title'),
    label: 'Title',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).title,
    sidebarTitle: 'Titles',
    icon: Icons.sort_by_alpha,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('audience_rating'),
    label: 'Audience Rating',
    getValue: (entry) => entry.audienceRating,
    sidebarTitle: 'Audience Ratings',
    icon: Icons.star_rate_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('color'),
    label: 'Color',
    getValue: (entry) => null,
    sidebarTitle: 'Color Details',
    icon: Icons.color_lens_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('country'),
    label: 'Country',
    getValue: (entry) => entry.country,
    sidebarTitle: 'Countries',
    icon: Icons.public_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('genre'),
    label: 'Genres',
    getValue: (entry) => entry.genres,
    sidebarTitle: 'Genres',
    icon: Icons.theater_comedy_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('language'),
    label: 'Language',
    getValue: (entry) => entry.language,
    sidebarTitle: 'Languages',
    icon: Icons.translate_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('age_rating'),
    label: 'Age',
    getValue: (entry) => entry.ageRating,
    sidebarTitle: 'Age Ratings',
    icon: Icons.family_restroom_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('movie_or_tv_series'),
    label: 'Movie / TV Series',
    getValue: (entry) => null,
    sidebarTitle: 'Movie / TV Series',
    icon: Icons.movie_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('release_date'),
    label: 'Release Date',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).releaseDate,
    sidebarTitle: 'Release Dates',
    icon: Icons.event_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('release_month'),
    label: 'Release Month',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).releaseDate,
    sidebarTitle: 'Release Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('release_year'),
    label: 'Release Year',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).releaseDate?.year,
    sidebarTitle: 'Release Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('publisher'),
    label: 'Studios',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).publisher,
    sidebarTitle: 'Studios',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('audio_tracks'),
    label: 'Audio Tracks',
    getValue: (entry) => null,
    sidebarTitle: 'Audio Tracks',
    icon: Icons.audiotrack_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('box_set'),
    label: 'Box Set',
    getValue: (entry) => null,
    sidebarTitle: 'Box Sets',
    icon: Icons.grid_view_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('distributor'),
    label: 'Distributor',
    getValue: (entry) => null,
    sidebarTitle: 'Distributors',
    icon: Icons.local_shipping_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('edition_release_date'),
    label: 'Edition Release Date',
    getValue: (entry) => null,
    sidebarTitle: 'Edition Release Dates',
    icon: Icons.event_note_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('edition_release_month'),
    label: 'Edition Release Month',
    getValue: (entry) => null,
    sidebarTitle: 'Edition Release Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('edition_release_year'),
    label: 'Edition Release Year',
    getValue: (entry) => null,
    sidebarTitle: 'Edition Release Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('extras'),
    label: 'Extras',
    getValue: (entry) => null,
    sidebarTitle: 'Extras',
    icon: Icons.featured_play_list_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('format'),
    label: 'Format',
    getValue: (entry) => entry.referenceFormatLabel,
    sidebarTitle: 'Formats',
    icon: Icons.style_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('hdr'),
    label: 'HDR',
    getValue: (entry) => null,
    sidebarTitle: 'HDR Details',
    icon: Icons.hdr_on_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('layers'),
    label: 'Disc Layers',
    getValue: (entry) => null,
    sidebarTitle: 'Disc Layers',
    icon: Icons.layers_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('packaging'),
    label: 'Packaging',
    getValue: (entry) => null,
    sidebarTitle: 'Packaging',
    icon: Icons.inventory_2_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('regions'),
    label: 'Regions',
    getValue: (entry) => null,
    sidebarTitle: 'Regions',
    icon: Icons.public_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('screen_ratios'),
    label: 'Screen Ratios',
    getValue: (entry) => null,
    sidebarTitle: 'Screen Ratios',
    icon: Icons.aspect_ratio_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('subtitles'),
    label: 'Subtitles',
    getValue: (entry) => null,
    sidebarTitle: 'Subtitles',
    icon: Icons.subtitles_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('actor'),
    label: 'Actor',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Actors',
    icon: Icons.person_outline,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('director'),
    label: 'Director',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Directors',
    icon: Icons.movie_creation_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('musician'),
    label: 'Musician',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Musicians',
    icon: Icons.music_note_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('photography'),
    label: 'Photography',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Photographers',
    icon: Icons.camera_alt_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('producer'),
    label: 'Producer',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Producers',
    icon: Icons.assignment_ind_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('writer'),
    label: 'Writer',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Writers',
    icon: Icons.edit_note_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('ownership'),
    label: 'Ownership',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).isOwned,
    sidebarTitle: 'Ownership',
    icon: Icons.inventory_2_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('added_date'),
    label: 'Added Date',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).addedAt,
    sidebarTitle: 'Added Dates',
    icon: Icons.add_task_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('added_month'),
    label: 'Added Month',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).addedAt,
    sidebarTitle: 'Added Months',
    icon: Icons.add_task_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('added_year'),
    label: 'Added Year',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).addedAt,
    sidebarTitle: 'Added Years',
    icon: Icons.add_task_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('collection_status'),
    label: 'Collection Status',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).collectionStatus,
    sidebarTitle: 'Collection Status',
    icon: Icons.stacked_bar_chart_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('condition'),
    label: 'Condition',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).condition,
    sidebarTitle: 'Conditions',
    icon: Icons.rule_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('image_type'),
    label: 'Image Type',
    getValue: (entry) => null,
    sidebarTitle: 'Image Types',
    icon: Icons.image_search_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('location'),
    label: 'Location',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).locationPath,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('modified_date'),
    label: 'Modified Date',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).updatedAt,
    sidebarTitle: 'Modified Dates',
    icon: Icons.update_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('modified_month'),
    label: 'Modified Month',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).updatedAt,
    sidebarTitle: 'Modified Months',
    icon: Icons.update_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('my_rating'),
    label: 'My Rating',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).rating,
    sidebarTitle: 'My Ratings',
    icon: Icons.star_outline,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('owner'),
    label: 'Owner',
    getValue: (entry) => null,
    sidebarTitle: 'Owners',
    icon: Icons.person_outline,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('purchase_date'),
    label: 'Purchase Date',
    getValue: (entry) => null,
    sidebarTitle: 'Purchase Dates',
    icon: Icons.shopping_bag_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('purchase_month'),
    label: 'Purchase Month',
    getValue: (entry) => null,
    sidebarTitle: 'Purchase Months',
    icon: Icons.shopping_bag_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('purchase_year'),
    label: 'Purchase Year',
    getValue: (entry) => null,
    sidebarTitle: 'Purchase Years',
    icon: Icons.shopping_bag_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('purchase_store'),
    label: 'Purchase Store',
    getValue: (entry) => null,
    sidebarTitle: 'Purchase Stores',
    icon: Icons.storefront_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('storage_device'),
    label: 'Storage Device',
    getValue: (entry) => null,
    sidebarTitle: 'Storage Devices',
    icon: Icons.sd_storage_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('tags'),
    label: 'Tags',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).tags,
    sidebarTitle: 'Tags',
    icon: Icons.sell_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('watch_date'),
    label: 'Watch Date',
    getValue: (entry) => null,
    sidebarTitle: 'Watch Dates',
    icon: Icons.play_circle_outline,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('watch_month'),
    label: 'Watch Month',
    getValue: (entry) => null,
    sidebarTitle: 'Watch Months',
    icon: Icons.play_circle_outline,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('watch_year'),
    label: 'Watch Year',
    getValue: (entry) => null,
    sidebarTitle: 'Watch Years',
    icon: Icons.play_circle_outline,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('watched'),
    label: 'Watched',
    getValue: (entry) => null,
    sidebarTitle: 'Watched',
    icon: Icons.visibility_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('watched_where'),
    label: 'Watched Where',
    getValue: (entry) => null,
    sidebarTitle: 'Watched Where',
    icon: Icons.tv_outlined,
  ),
];

final movieLibrarySortDefinitions = [
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'series',
    compare: (left, right) {
      final l = MovieWorkspaceDto.fromEntry(left);
      final r = MovieWorkspaceDto.fromEntry(right);
      return (l.seriesTitle ?? "").compareTo(r.seriesTitle ?? "");
    },
    label: 'Series',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'publisher',
    compare: (left, right) {
      final l = MovieWorkspaceDto.fromEntry(left);
      final r = MovieWorkspaceDto.fromEntry(right);
      return (l.publisher ?? "").compareTo(r.publisher ?? "");
    },
    label: 'Studio / Network',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'status',
    compare: (left, right) {
      final l = MovieWorkspaceDto.fromEntry(left);
      final r = MovieWorkspaceDto.fromEntry(right);
      int rank(MovieWorkspaceDto dto) {
        if (dto.isOwned) return 0;
        if (dto.isWishlisted) return 1;
        return 2;
      }
      final res = rank(l).compareTo(rank(r));
      return res != 0 ? res : l.title.compareTo(r.title);
    },
    label: 'Status',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'title',
    compare: (left, right) {
      final l = MovieWorkspaceDto.fromEntry(left);
      final r = MovieWorkspaceDto.fromEntry(right);
      return l.title.compareTo(r.title);
    },
    label: 'Title',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'issue',
    compare: (left, right) {
      final l = MovieWorkspaceDto.fromEntry(left);
      final r = MovieWorkspaceDto.fromEntry(right);
      return (l.itemNumber ?? "").compareTo(r.itemNumber ?? "");
    },
    label: 'Episode / Issue number',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'variant',
    compare: (left, right) => (left.variant ?? "").compareTo(right.variant ?? ""),
    label: 'Variant',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'format',
    compare: (left, right) => (left.referenceFormatLabel ?? "").compareTo(right.referenceFormatLabel ?? ""),
    label: 'Format',
    group: 'Edition',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'release_date',
    compare: (left, right) {
      final l = MovieWorkspaceDto.fromEntry(left);
      final r = MovieWorkspaceDto.fromEntry(right);
      return (l.releaseDate ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(r.releaseDate ?? DateTime.fromMillisecondsSinceEpoch(0));
    },
    label: 'Release date',
    defaultAscending: false,
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'barcode',
    compare: (left, right) => (left.barcode ?? "").compareTo(right.barcode ?? ""),
    label: 'Barcode',
    group: 'Edition',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'condition',
    compare: (left, right) {
      final l = MovieWorkspaceDto.fromEntry(left);
      final r = MovieWorkspaceDto.fromEntry(right);
      return (l.condition ?? "").compareTo(r.condition ?? "");
    },
    label: 'Condition',
    group: 'Value',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'price',
    compare: (left, right) {
      final l = MovieWorkspaceDto.fromEntry(left);
      final r = MovieWorkspaceDto.fromEntry(right);
      return (l.pricePaidCents ?? 0).compareTo(r.pricePaidCents ?? 0);
    },
    label: 'Purchase price',
    group: 'Value',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'location',
    compare: (left, right) {
      final l = MovieWorkspaceDto.fromEntry(left);
      final r = MovieWorkspaceDto.fromEntry(right);
      return (l.locationPath ?? "").compareTo(r.locationPath ?? "");
    },
    label: 'Location',
    group: 'Personal',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'collection_status',
    compare: (left, right) {
      final l = MovieWorkspaceDto.fromEntry(left);
      final r = MovieWorkspaceDto.fromEntry(right);
      return (l.collectionStatus ?? "").compareTo(r.collectionStatus ?? "");
    },
    label: 'Collection status',
    group: 'Personal',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'wishlist',
    compare: (left, right) {
      final l = MovieWorkspaceDto.fromEntry(left);
      final r = MovieWorkspaceDto.fromEntry(right);
      return (l.isWishlisted ? 1 : 0).compareTo(r.isWishlisted ? 1 : 0);
    },
    label: 'Wishlist',
    group: 'Personal',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'added',
    compare: (left, right) {
      final l = MovieWorkspaceDto.fromEntry(left);
      final r = MovieWorkspaceDto.fromEntry(right);
      return (l.addedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(r.addedAt ?? DateTime.fromMillisecondsSinceEpoch(0));
    },
    label: 'Added date',
    group: 'Personal',
    defaultAscending: false,
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'updated',
    compare: (left, right) {
      final l = MovieWorkspaceDto.fromEntry(left);
      final r = MovieWorkspaceDto.fromEntry(right);
      return l.updatedAt.compareTo(r.updatedAt);
    },
    label: 'Updated',
    group: 'Personal',
    defaultAscending: false,
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'country',
    compare: (left, right) => (left.country ?? "").compareTo(right.country ?? ""),
    label: 'Country',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'language',
    compare: (left, right) => (left.language ?? "").compareTo(right.language ?? ""),
    label: 'Language',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'age_rating',
    compare: (left, right) => (left.ageRating ?? "").compareTo(right.ageRating ?? ""),
    label: 'Age rating',
  ),
];

final movieLibraryColumnDefinitions = [
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('status'),
    label: 'Status',
    getValue: (entry) {
      final dto = MovieWorkspaceDto.fromEntry(entry);
      return dto.isWishlisted ? 'wishlist' : (dto.isOwned ? 'owned' : null);
    },
    cellValue: (entry) {
      final dto = MovieWorkspaceDto.fromEntry(entry);
      return Text(dto.isWishlisted ? 'Wishlist' : (dto.isOwned ? 'Owned' : ''));
    },
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('cover'),
    label: '',
    getValue: (entry) => entry.coverImageUrl,
    cellValue: (entry) => entry.coverImageUrl == null
        ? const SizedBox.shrink()
        : Image.network(
            entry.coverImageUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
    sortable: false,
    groupable: false,
    defaultWidth: 42,
    minWidth: 44,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('title'),
    label: 'Title',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).title,
    cellValue: (entry) => Text(MovieWorkspaceDto.fromEntry(entry).title),
    defaultWidth: 260,
    maxWidth: 520,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('publisher'),
    label: 'Studio',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).publisher,
    cellValue: (entry) => Text(MovieWorkspaceDto.fromEntry(entry).publisher ?? ''),
    defaultWidth: 140,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('release_date'),
    label: 'Release Date',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).releaseDate,
    cellValue: (entry) => Text(_formatDate(MovieWorkspaceDto.fromEntry(entry).releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('wishlist'),
    label: 'Wishlist',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).isWishlisted,
    cellValue: (entry) => Text(MovieWorkspaceDto.fromEntry(entry).isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('updated'),
    label: 'Updated',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).updatedAt,
    cellValue: (entry) => Text(_formatDate(MovieWorkspaceDto.fromEntry(entry).updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('added'),
    label: 'Added',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).addedAt,
    cellValue: (entry) => Text(_formatDate(MovieWorkspaceDto.fromEntry(entry).addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('location'),
    label: 'Location',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).locationPath,
    cellValue: (entry) => Text(MovieWorkspaceDto.fromEntry(entry).locationPath ?? ''),
    group: 'Personal',
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('condition'),
    label: 'Condition',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).condition,
    cellValue: (entry) => Text(MovieWorkspaceDto.fromEntry(entry).condition ?? ''),
    group: 'Value',
    defaultWidth: 124,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('price'),
    label: 'Purchase Price',
    getValue: (entry) => MovieWorkspaceDto.fromEntry(entry).pricePaidCents,
    cellValue: (entry) {
      final dto = MovieWorkspaceDto.fromEntry(entry);
      return Text(_formatCents(dto.pricePaidCents, entry.currency));
    },
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('format'),
    label: 'Format',
    getValue: (entry) => entry.referenceFormatLabel,
    cellValue: (entry) => Text(entry.referenceFormatLabel ?? ''),
    defaultWidth: 100,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('variant'),
    label: 'Format / Edition',
    getValue: (entry) => entry.variant,
    cellValue: (entry) => Text(entry.variant ?? ''),
    defaultWidth: 170,
    maxWidth: 420,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('barcode'),
    label: 'UPC / Barcode',
    getValue: (entry) => entry.barcode,
    cellValue: (entry) => Text(entry.barcode ?? ''),
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
];

const moviesLibraryDefaultVisibleColumnIds = {
  'status',
  'cover',
  'title',
  'publisher',
  'release_date',
  'barcode',
  'condition',
  'price',
  'location',
  'wishlist',
  'updated',
};

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String _formatCents(int? cents, String? currency) {
  if (cents == null) return '';
  final amount = (cents / 100).toStringAsFixed(2);
  return currency == null ? amount : '$currency $amount';
}
