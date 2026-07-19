import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'game_workspace_dto.dart';

final gameLibraryFieldDefinitions = [
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('game.title'),
    label: 'Title',
    getValue: (dto) => dto.title,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('game.series'),
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('game.number'),
    label: 'Number',
    getValue: (dto) => dto.itemNumber,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('game.publisher'),
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('game.release_date'),
    label: 'Release date',
    getValue: (dto) => dto.releaseDate,
  ),
];


final gameLibraryGroupDefinitions = [
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('title'),
    label: 'Title',
    sidebarTitle: 'Titles',
    icon: Icons.sort_by_alpha,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('audience_rating'),
    label: 'Audience Rating',
    sidebarTitle: 'Audience Ratings',
    icon: Icons.groups_2_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('developer'),
    label: 'Developer',
    sidebarTitle: 'Developers',
    icon: Icons.code_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('genre'),
    label: 'Genre',
    sidebarTitle: 'Genres',
    icon: Icons.theater_comedy_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('platform'),
    label: 'Platform',
    sidebarTitle: 'Platforms',
    icon: Icons.sports_esports_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('publisher'),
    label: 'Publisher / Studio',
    sidebarTitle: 'Publishers / Studios',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('release_date'),
    label: 'Release Date',
    sidebarTitle: 'Release Dates',
    icon: Icons.event_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('release_month'),
    label: 'Release Month',
    sidebarTitle: 'Release Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('release_year'),
    label: 'Release Year',
    sidebarTitle: 'Release Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('series'),
    label: 'Series',
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('completeness'),
    label: 'Completeness',
    sidebarTitle: 'Completeness',
    icon: Icons.checklist_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('condition'),
    label: 'Condition',
    sidebarTitle: 'Conditions',
    icon: Icons.verified_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('purchase_date'),
    label: 'Purchase Date',
    sidebarTitle: 'Purchase Dates',
    icon: Icons.shopping_bag_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('purchase_month'),
    label: 'Purchase Month',
    sidebarTitle: 'Purchase Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('purchase_store'),
    label: 'Purchase Store',
    sidebarTitle: 'Purchase Stores',
    icon: Icons.store_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('purchase_year'),
    label: 'Purchase Year',
    sidebarTitle: 'Purchase Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('value_locked'),
    label: 'Value Locked',
    sidebarTitle: 'Value Locked',
    icon: Icons.lock_outline,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('toy_subtype'),
    label: 'Subtype',
    sidebarTitle: 'Subtypes',
    icon: Icons.category_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('toy_type'),
    label: 'Type',
    sidebarTitle: 'Types',
    icon: Icons.toys_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('format'),
    label: 'Format',
    sidebarTitle: 'Formats',
    icon: Icons.album_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('regions'),
    label: 'Region',
    sidebarTitle: 'Regions',
    icon: Icons.public_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('added_date'),
    label: 'Added Date',
    sidebarTitle: 'Added Dates',
    icon: Icons.add_circle_outline,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('added_month'),
    label: 'Added Month',
    sidebarTitle: 'Added Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('added_year'),
    label: 'Added Year',
    sidebarTitle: 'Added Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('collection_status'),
    label: 'Collection Status',
    sidebarTitle: 'Collection Status',
    icon: Icons.bookmark_added_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('completed'),
    label: 'Completed',
    sidebarTitle: 'Completed',
    icon: Icons.task_alt_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('completed_date'),
    label: 'Completed Date',
    sidebarTitle: 'Completed Dates',
    icon: Icons.event_available_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('completed_month'),
    label: 'Completed Month',
    sidebarTitle: 'Completed Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('completed_year'),
    label: 'Completed Year',
    sidebarTitle: 'Completed Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('image_type'),
    label: 'Image Type',
    sidebarTitle: 'Image Types',
    icon: Icons.image_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('location'),
    label: 'Location',
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('modified_date'),
    label: 'Modified Date',
    sidebarTitle: 'Modified Dates',
    icon: Icons.edit_calendar_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('modified_month'),
    label: 'Modified Month',
    sidebarTitle: 'Modified Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('my_rating'),
    label: 'My Rating',
    sidebarTitle: 'Ratings',
    icon: Icons.star_outline,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('owner'),
    label: 'Owner',
    sidebarTitle: 'Owners',
    icon: Icons.person_outline,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('storage_device'),
    label: 'Storage Device',
    sidebarTitle: 'Storage Devices',
    icon: Icons.sd_storage_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('tags'),
    label: 'Tags',
    sidebarTitle: 'Tags',
    icon: Icons.local_offer_outlined,
    supportsBucketManagement: true,
  ),
];

final gameLibrarySortDefinitions = [
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'series',
    compare: (left, right) => (left.series?.seriesTitle ?? "").compareTo(right.series?.seriesTitle ?? ""),
    label: 'Series',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'publisher',
    compare: (left, right) => (left.publisher ?? "").compareTo(right.publisher ?? ""),
    label: 'Publisher / Studio',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
      id: 'status',
    compare: (left, right) => (left.isOwned ? 0 : 1).compareTo(right.isOwned ? 0 : 1), label: 'Status'),
  LibrarySortDefinition<LibraryWorkspaceEntry>(id: 'title',
    compare: (left, right) => (left.resolvedTitle ?? "").compareTo(right.resolvedTitle ?? ""), label: 'Title'),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'issue',
    compare: (left, right) => (left.itemNumber ?? "").compareTo(right.itemNumber ?? ""),
    label: 'Issue / number',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'story_arc',
    compare: (left, right) => (left.storyArcs?.join(", ") ?? "").compareTo(right.storyArcs?.join(", ") ?? ""),
    label: 'Story arc',
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
    compare: (left, right) => (left.releaseDate ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(right.releaseDate ?? DateTime.fromMillisecondsSinceEpoch(0)),
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
    id: 'grade',
    compare: (left, right) => (left.grade ?? "").compareTo(right.grade ?? ""),
    label: 'Grade',
    group: 'Value',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'condition',
    compare: (left, right) => (left.condition ?? "").compareTo(right.condition ?? ""),
    label: 'Condition',
    group: 'Value',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'price',
    compare: (left, right) => (left.pricePaidCents ?? 0).compareTo(right.pricePaidCents ?? 0),
    label: 'Purchase price',
    group: 'Value',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'location',
    compare: (left, right) => (left.locationPath ?? "").compareTo(right.locationPath ?? ""),
    label: 'Location',
    group: 'Personal',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'collection_status',
    compare: (left, right) => (left.collectionStatus ?? "").compareTo(right.collectionStatus ?? ""),
    label: 'Collection status',
    group: 'Personal',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'wishlist',
    compare: (left, right) => (left.isWishlisted ? 1 : 0).compareTo(right.isWishlisted ? 1 : 0),
    label: 'Wishlist',
    group: 'Personal',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'added',
    compare: (left, right) => (left.addedAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(left.addedAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
    label: 'Added date',
    group: 'Personal',
    defaultAscending: false,
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'updated',
    compare: (left, right) => (left.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(right.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
    label: 'Updated',
    group: 'Personal',
    defaultAscending: false,
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
      id: 'country',
    compare: (left, right) => (left.country ?? "").compareTo(right.country ?? ""), label: 'Country'),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'language',
    compare: (left, right) => (left.language ?? "").compareTo(right.language ?? ""),
    label: 'Language',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'page_count',
    compare: (left, right) => GameWorkspaceDto.fromEntry(left).pageCount.compareTo(GameWorkspaceDto.fromEntry(right).pageCount),
    label: 'Page count',
    group: 'Edition',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'age_rating',
    compare: (left, right) => (left.ageRating ?? "").compareTo(right.ageRating ?? ""),
    label: 'Age rating',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'imprint',
    compare: (left, right) => (GameWorkspaceDto.fromEntry(left).imprint ?? "").compareTo(GameWorkspaceDto.fromEntry(right).imprint ?? ""),
    label: 'Imprint',
  ),
];
const gamesLibraryDefaultVisibleColumnIds = {
  'status',
  'cover',
  'title',
  'publisher',
  'release_date',
  'barcode',
  'condition',
  'location',
  'wishlist',
  'updated',
};
final gameLibraryColumnDefinitions = [
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('status'),
    label: 'Status',
    getValue: (entry) {
      final dto = GameWorkspaceDto.fromEntry(entry);
      return dto.isWishlisted ? 'wishlist' : (dto.isOwned ? 'owned' : null);
    },
    cellValue: (entry) {
      final dto = GameWorkspaceDto.fromEntry(entry);
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
    getValue: (entry) => GameWorkspaceDto.fromEntry(entry).title,
    cellValue: (entry) => Text(GameWorkspaceDto.fromEntry(entry).title),
    defaultWidth: 260,
    maxWidth: 520,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('publisher'),
    label: 'Publisher',
    getValue: (entry) => GameWorkspaceDto.fromEntry(entry).publisher,
    cellValue: (entry) => Text(GameWorkspaceDto.fromEntry(entry).publisher ?? ''),
    defaultWidth: 140,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('release_date'),
    label: 'Release Date',
    getValue: (entry) => GameWorkspaceDto.fromEntry(entry).releaseDate,
    cellValue: (entry) => Text(_formatDate(GameWorkspaceDto.fromEntry(entry).releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('wishlist'),
    label: 'Wishlist',
    getValue: (entry) => GameWorkspaceDto.fromEntry(entry).isWishlisted,
    cellValue: (entry) => Text(GameWorkspaceDto.fromEntry(entry).isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('updated'),
    label: 'Updated',
    getValue: (entry) => GameWorkspaceDto.fromEntry(entry).updatedAt,
    cellValue: (entry) => Text(_formatDate(GameWorkspaceDto.fromEntry(entry).updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('added'),
    label: 'Added',
    getValue: (entry) => GameWorkspaceDto.fromEntry(entry).addedAt,
    cellValue: (entry) => Text(_formatDate(GameWorkspaceDto.fromEntry(entry).addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('location'),
    label: 'Location',
    getValue: (entry) => GameWorkspaceDto.fromEntry(entry).locationPath,
    cellValue: (entry) => Text(GameWorkspaceDto.fromEntry(entry).locationPath ?? ''),
    group: 'Personal',
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('condition'),
    label: 'Condition',
    getValue: (entry) => GameWorkspaceDto.fromEntry(entry).condition,
    cellValue: (entry) => Text(GameWorkspaceDto.fromEntry(entry).condition ?? ''),
    group: 'Value',
    defaultWidth: 124,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('price'),
    label: 'Purchase Price',
    getValue: (entry) => GameWorkspaceDto.fromEntry(entry).pricePaidCents,
    cellValue: (entry) {
      final dto = GameWorkspaceDto.fromEntry(entry);
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
    label: 'Platform / Edition',
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
