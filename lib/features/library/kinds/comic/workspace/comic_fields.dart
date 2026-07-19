import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:flutter/material.dart';

final comicLibraryFieldDefinitions = [
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('comic.title'),
    label: 'Title',
    getValue: (dto) => dto.title,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('comic.series'),
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('comic.number'),
    label: 'Number',
    getValue: (dto) => dto.itemNumber,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('comic.publisher'),
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('comic.release_date'),
    label: 'Release date',
    getValue: (dto) => dto.releaseDate,
  ),
];

final comicLibraryGroupDefinitions = [
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('series'),
    label: 'Series',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).seriesTitle,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('title'),
    label: 'Title',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).title,
    sidebarTitle: 'Titles',
    icon: Icons.sort_by_alpha,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('age_rating'),
    label: 'Age',
    getValue: (entry) => entry.ageRating,
    sidebarTitle: 'Ages',
    icon: Icons.family_restroom_outlined,
    supportsBucketManagement: true,
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
    id: LibraryFieldId<Object?>('crossover'),
    label: 'Crossover',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).crossover,
    sidebarTitle: 'Crossovers',
    icon: Icons.hub_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('genre'),
    label: 'Genre',
    getValue: (entry) => entry.genres,
    sidebarTitle: 'Genres',
    icon: Icons.theater_comedy_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('imprint'),
    label: 'Imprint',
    getValue: (entry) => null,
    sidebarTitle: 'Imprints',
    icon: Icons.apartment_outlined,
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
    id: LibraryFieldId<Object?>('release_date'),
    label: 'Release Date',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).releaseDate,
    sidebarTitle: 'Release Dates',
    icon: Icons.event_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('release_month'),
    label: 'Release Month',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).releaseDate,
    sidebarTitle: 'Release Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('release_year'),
    label: 'Release Year',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).releaseDate?.year,
    sidebarTitle: 'Release Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('cover_date'),
    label: 'Cover Date',
    getValue: (entry) => entry.coverDate,
    sidebarTitle: 'Cover Dates',
    icon: Icons.event_note_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('cover_month'),
    label: 'Cover Month',
    getValue: (entry) => entry.coverDate,
    sidebarTitle: 'Cover Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('cover_year'),
    label: 'Cover Year',
    getValue: (entry) => entry.coverDate,
    sidebarTitle: 'Cover Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('series_group'),
    label: 'Series Group',
    getValue: (entry) => null,
    sidebarTitle: 'Series Groups',
    icon: Icons.folder_open_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('story_arc'),
    label: 'Story Arc',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).storyArcs,
    sidebarTitle: 'Story Arcs',
    icon: Icons.auto_stories_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('character'),
    label: 'Character',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).characters,
    sidebarTitle: 'Characters',
    icon: Icons.groups_2_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('creator'),
    label: 'All Creators',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'All Creators',
    icon: Icons.group_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('publisher'),
    label: 'Publisher',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).publisher,
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
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
    id: LibraryFieldId<Object?>('artist'),
    label: 'Artist',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Artists',
    icon: Icons.brush_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('penciller'),
    label: 'Penciller',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Pencillers',
    icon: Icons.edit_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('inker'),
    label: 'Inker',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Inkers',
    icon: Icons.draw_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('colorist'),
    label: 'Colorist',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Colorists',
    icon: Icons.format_color_fill_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('painter'),
    label: 'Painter',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Painters',
    icon: Icons.brush_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('letterer'),
    label: 'Letterer',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Letterers',
    icon: Icons.text_fields_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('separator'),
    label: 'Separator',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Separators',
    icon: Icons.linear_scale_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('layouts'),
    label: 'Layouts',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Layouts',
    icon: Icons.dashboard_customize_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('translator'),
    label: 'Translator',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Translators',
    icon: Icons.translate_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('plotter'),
    label: 'Plotter',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Plotters',
    icon: Icons.route_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('scripter'),
    label: 'Scripter',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Scripters',
    icon: Icons.subject_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('cover_artist'),
    label: 'Cover Artist',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Cover Artists',
    icon: Icons.image_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('cover_penciller'),
    label: 'Cover Penciller',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Cover Pencillers',
    icon: Icons.border_color_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('cover_painter'),
    label: 'Cover Painter',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Cover Painters',
    icon: Icons.brush_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('cover_inker'),
    label: 'Cover Inker',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Cover Inkers',
    icon: Icons.draw_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('cover_colorist'),
    label: 'Cover Colorist',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Cover Colorists',
    icon: Icons.format_paint_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('cover_separator'),
    label: 'Cover Separator',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Cover Separators',
    icon: Icons.splitscreen_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('editor'),
    label: 'Editor',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Editors',
    icon: Icons.fact_check_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('editor_in_chief'),
    label: 'Editor in Chief',
    getValue: (entry) => entry.creators,
    sidebarTitle: 'Editors in Chief',
    icon: Icons.assignment_ind_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('format'),
    label: 'Format',
    getValue: (entry) => entry.referenceFormatLabel,
    sidebarTitle: 'Formats',
    icon: Icons.style_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('grade'),
    label: 'Grade',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).grade,
    sidebarTitle: 'Grades',
    icon: Icons.verified_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('value_locked'),
    label: 'Value',
    getValue: (entry) => null,
    sidebarTitle: 'Value Locked',
    icon: Icons.request_quote_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('condition'),
    label: 'Condition',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).condition,
    sidebarTitle: 'Conditions',
    icon: Icons.rule_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('is_key_comic'),
    label: 'Key',
    getValue: (entry) => null,
    sidebarTitle: 'Keys',
    icon: Icons.key_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('raw_or_slabbed'),
    label: 'Raw / Slabbed',
    getValue: (entry) => null,
    sidebarTitle: 'Raw / Slabbed',
    icon: Icons.layers_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('my_rating'),
    label: 'My Rating',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).rating,
    sidebarTitle: 'My Ratings',
    icon: Icons.star_outline,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('purchase_date'),
    label: 'Purchase Date',
    getValue: (entry) => null,
    sidebarTitle: 'Purchase Dates',
    icon: Icons.event_available_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('purchase_month'),
    label: 'Purchase Month',
    getValue: (entry) => null,
    sidebarTitle: 'Purchase Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('purchase_year'),
    label: 'Purchase Year',
    getValue: (entry) => null,
    sidebarTitle: 'Purchase Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('purchase_store'),
    label: 'Purchase Store',
    getValue: (entry) => null,
    sidebarTitle: 'Purchase Stores',
    icon: Icons.storefront_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('owner'),
    label: 'Owner',
    getValue: (entry) => null,
    sidebarTitle: 'Owners',
    icon: Icons.person_outline,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('location'),
    label: 'Location',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).locationPath,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('storage_device'),
    label: 'Storage Box',
    getValue: (entry) => null,
    sidebarTitle: 'Storage Boxes',
    icon: Icons.inventory_2_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('ownership'),
    label: 'Ownership',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).isOwned,
    sidebarTitle: 'Ownership',
    icon: Icons.inventory_2_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('added_date'),
    label: 'Added Date',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).addedAt,
    sidebarTitle: 'Added Dates',
    icon: Icons.playlist_add_check_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('added_month'),
    label: 'Added Month',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).addedAt,
    sidebarTitle: 'Added Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('added_year'),
    label: 'Added Year',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).addedAt,
    sidebarTitle: 'Added Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('collection_status'),
    label: 'Collection Status',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).collectionStatus,
    sidebarTitle: 'Collection Status',
    icon: Icons.inventory_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('image_type'),
    label: 'Image Type',
    getValue: (entry) => null,
    sidebarTitle: 'Image Types',
    icon: Icons.photo_library_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('modified_date'),
    label: 'Modified Date',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).updatedAt,
    sidebarTitle: 'Modified Dates',
    icon: Icons.edit_calendar_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('modified_month'),
    label: 'Modified Month',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).updatedAt,
    sidebarTitle: 'Modified Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('tags'),
    label: 'Tags',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).tags,
    sidebarTitle: 'Tags',
    icon: Icons.sell_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('bag_board_date'),
    label: 'Bag/Board Date',
    getValue: (entry) => entry.lastBagBoardDate,
    sidebarTitle: 'Bag/Board Dates',
    icon: Icons.inventory_2_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('bag_board_month'),
    label: 'Bag/Board Month',
    getValue: (entry) => entry.lastBagBoardDate,
    sidebarTitle: 'Bag/Board Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('bag_board_year'),
    label: 'Bag/Board Year',
    getValue: (entry) => entry.lastBagBoardDate,
    sidebarTitle: 'Bag/Board Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('read_date'),
    label: 'Read Date',
    getValue: (entry) => null,
    sidebarTitle: 'Read Dates',
    icon: Icons.menu_book_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('read_month'),
    label: 'Read Month',
    getValue: (entry) => null,
    sidebarTitle: 'Read Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('read_year'),
    label: 'Read Year',
    getValue: (entry) => null,
    sidebarTitle: 'Read Years',
    icon: Icons.calendar_today_outlined,
  ),
];

final comicLibrarySortDefinitions = [
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'series',
    label: 'Series',
    compare: (left, right) {
      final l = ComicWorkspaceDto.fromEntry(left);
      final r = ComicWorkspaceDto.fromEntry(right);
      return _compareStrings(l.seriesTitle, r.seriesTitle);
    },
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'publisher',
    label: 'Publisher',
    compare: (left, right) {
      final l = ComicWorkspaceDto.fromEntry(left);
      final r = ComicWorkspaceDto.fromEntry(right);
      return _compareStrings(l.publisher, r.publisher);
    },
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'status',
    label: 'Status',
    compare: (left, right) {
      final l = ComicWorkspaceDto.fromEntry(left);
      final r = ComicWorkspaceDto.fromEntry(right);
      int rank(ComicWorkspaceDto dto) {
        if (dto.isOwned) return 0;
        if (dto.isWishlisted) return 1;
        return 2;
      }
      final res = rank(l).compareTo(rank(r));
      return res != 0 ? res : _compareStrings(l.title, r.title);
    },
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'title',
    label: 'Title',
    compare: (left, right) {
      final l = ComicWorkspaceDto.fromEntry(left);
      final r = ComicWorkspaceDto.fromEntry(right);
      return _compareStrings(l.title, r.title);
    },
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'comic.issue',
    label: 'Issue / Number',
    compare: (left, right) => _compareIssueNumber(left, right),
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'story_arc',
    label: 'Story Arc',
    compare: (left, right) {
      final l = ComicWorkspaceDto.fromEntry(left);
      final r = ComicWorkspaceDto.fromEntry(right);
      return _compareStrings(l.storyArcs?.join(', '), r.storyArcs?.join(', '));
    },
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'variant',
    label: 'Variant',
    compare: (left, right) => _compareStrings(left.variant, right.variant),
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'format',
    label: 'Format',
    compare: (left, right) =>
        _compareStrings(left.referenceFormatLabel, right.referenceFormatLabel),
    group: 'Edition',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'release_date',
    label: 'Release Date',
    compare: (left, right) {
      final l = ComicWorkspaceDto.fromEntry(left);
      final r = ComicWorkspaceDto.fromEntry(right);
      return _compareDates(l.releaseDate, r.releaseDate);
    },
    defaultAscending: false,
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'barcode',
    label: 'Barcode',
    compare: (left, right) => _compareStrings(left.barcode, right.barcode),
    group: 'Edition',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'grade',
    label: 'Grade',
    compare: (left, right) => _compareGrade(
      ComicWorkspaceDto.fromEntry(left).grade,
      ComicWorkspaceDto.fromEntry(right).grade,
    ),
    group: 'Value',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'raw_or_slabbed',
    label: 'Raw / Slabbed',
    compare: (left, right) => _compareStrings(left.title, right.title),
    group: 'Edition',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'grading_company',
    label: 'Grading Company',
    compare: (left, right) => _compareStrings(left.title, right.title),
    group: 'Edition',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'condition',
    label: 'Condition',
    compare: (left, right) {
      final l = ComicWorkspaceDto.fromEntry(left);
      final r = ComicWorkspaceDto.fromEntry(right);
      return _compareStrings(l.condition, r.condition);
    },
    group: 'Value',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'price',
    compare: (left, right) {
      final l = ComicWorkspaceDto.fromEntry(left);
      final r = ComicWorkspaceDto.fromEntry(right);
      return _compareNums(l.pricePaidCents, r.pricePaidCents);
    },
    label: 'Purchase Price',
    group: 'Value',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'location',
    compare: (left, right) {
      final l = ComicWorkspaceDto.fromEntry(left);
      final r = ComicWorkspaceDto.fromEntry(right);
      return _compareStrings(l.locationPath, r.locationPath);
    },
    label: 'Location',
    group: 'Personal',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'collection_status',
    compare: (left, right) {
      final l = ComicWorkspaceDto.fromEntry(left);
      final r = ComicWorkspaceDto.fromEntry(right);
      return _compareStrings(l.collectionStatus, r.collectionStatus);
    },
    label: 'Collection Status',
    group: 'Personal',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'wishlist',
    compare: (left, right) {
      final l = ComicWorkspaceDto.fromEntry(left);
      final r = ComicWorkspaceDto.fromEntry(right);
      return _compareBools(l.isWishlisted, r.isWishlisted);
    },
    label: 'Wishlist',
    group: 'Personal',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'comic.key_issue',
    label: 'Key Comic',
    compare: (left, right) {
      final leftKey = ComicWorkspaceDto.fromEntry(left).keyComic;
      final rightKey = ComicWorkspaceDto.fromEntry(right).keyComic;
      if (leftKey != rightKey) {
        return leftKey ? -1 : 1;
      }
      return _compareStrings(left.title, right.title);
    },
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'added',
    compare: (left, right) {
      final l = ComicWorkspaceDto.fromEntry(left);
      final r = ComicWorkspaceDto.fromEntry(right);
      return _compareDates(l.addedAt, r.addedAt);
    },
    label: 'Added Date',
    group: 'Personal',
    defaultAscending: false,
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'updated',
    compare: (left, right) {
      final l = ComicWorkspaceDto.fromEntry(left);
      final r = ComicWorkspaceDto.fromEntry(right);
      return _compareDates(l.updatedAt, r.updatedAt);
    },
    label: 'Updated',
    group: 'Personal',
    defaultAscending: false,
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'country',
    label: 'Country',
    compare: (left, right) => _compareStrings(left.country, right.country),
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'language',
    label: 'Language',
    compare: (left, right) => _compareStrings(left.language, right.language),
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'page_count',
    label: 'Page Count',
    compare: (left, right) => _compareStrings(left.title, right.title),
    group: 'Edition',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'age_rating',
    label: 'Age Rating',
    compare: (left, right) => _compareStrings(left.ageRating, right.ageRating),
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'imprint',
    label: 'Imprint',
    compare: (left, right) => _compareStrings(left.title, right.title),
  ),
];

final comicLibraryColumnDefinitions = [
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('status'),
    label: 'Status',
    getValue: (entry) {
      final dto = ComicWorkspaceDto.fromEntry(entry);
      return dto.isWishlisted ? 'wishlist' : (dto.isOwned ? 'owned' : null);
    },
    cellValue: (entry) {
      final dto = ComicWorkspaceDto.fromEntry(entry);
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
    id: LibraryFieldId<Object?>('front_cover'),
    label: 'Front Cover',
    getValue: (entry) => entry.frontCoverUrl,
    cellValue: (entry) => entry.frontCoverUrl == null
        ? const SizedBox.shrink()
        : Image.network(
            entry.frontCoverUrl!,
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
    id: LibraryFieldId<Object?>('back_cover'),
    label: 'Back Cover',
    getValue: (entry) => entry.backCoverUrl,
    cellValue: (entry) => entry.backCoverUrl == null
        ? const SizedBox.shrink()
        : Image.network(
            entry.backCoverUrl!,
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
    id: LibraryFieldId<Object?>('has_front'),
    label: 'Has Front',
    getValue: (entry) => entry.frontCoverUrl != null,
    cellValue: (entry) => Text(entry.frontCoverUrl != null ? 'Yes' : 'No'),
    sortable: false,
    groupable: false,
    defaultWidth: 78,
    minWidth: 68,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('has_back'),
    label: 'Has Back',
    getValue: (entry) => entry.backCoverUrl != null,
    cellValue: (entry) => Text(entry.backCoverUrl != null ? 'Yes' : 'No'),
    sortable: false,
    groupable: false,
    defaultWidth: 78,
    minWidth: 68,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('extra_images'),
    label: 'Extra Images',
    getValue: (entry) => entry.itemImages.length,
    cellValue: (entry) => Text('${entry.itemImages.length}'),
    sortable: false,
    groupable: false,
    isNumeric: true,
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('title'),
    label: 'Series',
    displayName: 'Series',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).title,
    cellValue: (entry) => Text(ComicWorkspaceDto.fromEntry(entry).title),
    defaultWidth: 260,
    maxWidth: 520,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('issue'),
    label: 'Issue',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).itemNumber,
    cellValue: (entry) => Text(ComicWorkspaceDto.fromEntry(entry).itemNumber ?? ''),
    sortId: 'comic.issue',
    defaultWidth: 64,
    minWidth: 54,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('variant'),
    label: 'Variant Description',
    displayName: 'Variant Description',
    getValue: (entry) => entry.variant,
    cellValue: (entry) {
      final parts = <String>[
        if (entry.variant != null && entry.variant!.trim().isNotEmpty) entry.variant!.trim(),
        if (entry.referenceScopeLabel != null && entry.referenceScopeLabel!.trim().isNotEmpty)
          'Scope: ${entry.referenceScopeLabel!.trim()}',
        if (entry.referenceFormatLabel != null && entry.referenceFormatLabel!.trim().isNotEmpty)
          'Format: ${entry.referenceFormatLabel!.trim()}',
      ];
      return Text(parts.join('  \u00b7  '));
    },
    defaultWidth: 170,
    maxWidth: 420,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('publisher'),
    label: 'Publisher',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).publisher,
    cellValue: (entry) => Text(ComicWorkspaceDto.fromEntry(entry).publisher ?? ''),
    defaultWidth: 140,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('release_date'),
    label: 'Release Date',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).releaseDate,
    cellValue: (entry) => Text(_formatDate(ComicWorkspaceDto.fromEntry(entry).releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('barcode'),
    label: 'Barcode',
    getValue: (entry) => entry.barcode,
    cellValue: (entry) => Text(entry.barcode ?? ''),
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('grade'),
    label: 'Grade',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).grade,
    cellValue: (entry) => Text(ComicWorkspaceDto.fromEntry(entry).grade ?? ''),
    group: 'Value',
    defaultWidth: 88,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('condition'),
    label: 'Condition',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).condition,
    cellValue: (entry) => Text(ComicWorkspaceDto.fromEntry(entry).condition ?? ''),
    group: 'Value',
    defaultWidth: 124,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('value'),
    label: 'Value',
    getValue: (entry) => entry.marketValueCents,
    cellValue: (entry) =>
        Text(_formatCents(entry.marketValueCents, entry.marketValueCurrency)),
    group: 'Value',
    sortable: false,
    isNumeric: true,
    defaultWidth: 92,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('price'),
    label: 'Purchase Price',
    displayName: 'Purchase Price',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).pricePaidCents,
    cellValue: (entry) {
      final dto = ComicWorkspaceDto.fromEntry(entry);
      return Text(_formatCents(dto.pricePaidCents, entry.currency));
    },
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('location'),
    label: 'Location',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).locationPath,
    cellValue: (entry) => Text(ComicWorkspaceDto.fromEntry(entry).locationPath ?? ''),
    group: 'Personal',
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('wishlist'),
    label: 'Wishlist',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).isWishlisted,
    cellValue: (entry) => Text(ComicWorkspaceDto.fromEntry(entry).isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('format'),
    label: 'Format',
    getValue: (entry) => entry.referenceFormatLabel,
    cellValue: (entry) => Text(entry.referenceFormatLabel ?? ''),
    defaultWidth: 100,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('added'),
    label: 'Added',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).addedAt,
    cellValue: (entry) => Text(_formatDate(ComicWorkspaceDto.fromEntry(entry).addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('updated'),
    label: 'Updated',
    getValue: (entry) => ComicWorkspaceDto.fromEntry(entry).updatedAt,
    cellValue: (entry) => Text(_formatDate(ComicWorkspaceDto.fromEntry(entry).updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
];

const comicLibraryDefaultVisibleColumnIds = {
  'status',
  'cover',
  'front_cover',
  'back_cover',
  'title',
  'issue',
  'variant',
  'publisher',
  'release_date',
  'barcode',
  'grade',
  'condition',
  'value',
  'price',
  'location',
  'wishlist',
  'format',
  'added',
  'updated',
};

const comicDefaultSortId = 'title';
const comicDefaultGroupId = 'series';

int _compareStrings(String? left, String? right) {
  final leftValue = left ?? '';
  final rightValue = right ?? '';
  if (leftValue.isEmpty && rightValue.isNotEmpty) {
    return 1;
  }
  if (leftValue.isNotEmpty && rightValue.isEmpty) {
    return -1;
  }
  return leftValue.toLowerCase().compareTo(rightValue.toLowerCase());
}

int _compareNums(num? left, num? right) {
  if (left == null && right == null) return 0;
  if (left == null) return 1;
  if (right == null) return -1;
  return left.compareTo(right);
}

int _compareDates(DateTime? left, DateTime? right) {
  if (left == null && right == null) return 0;
  if (left == null) return 1;
  if (right == null) return -1;
  return left.compareTo(right);
}

int _compareBools(bool left, bool right) {
  if (left == right) return 0;
  return left ? 1 : -1;
}

int _compareStatus(LibraryWorkspaceEntry left, LibraryWorkspaceEntry right) {
  int rank(LibraryWorkspaceEntry entry) {
    if (entry.isOwned) return 0;
    if (entry.isWishlisted) return 1;
    return 2;
  }

  final result = rank(left).compareTo(rank(right));
  return result != 0 ? result : _compareStrings(left.title, right.title);
}

int _compareGrade(String? left, String? right) {
  final leftNum = left == null ? null : double.tryParse(left);
  final rightNum = right == null ? null : double.tryParse(right);
  if (leftNum != null && rightNum != null) {
    return leftNum.compareTo(rightNum);
  }
  return _compareStrings(left, right);
}

int _compareIssueNumber(
    LibraryWorkspaceEntry left, LibraryWorkspaceEntry right) {
  num? parse(String? raw) {
    if (raw == null) return null;
    final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(raw);
    return match == null ? null : num.tryParse(match.group(0)!);
  }

  final leftNum = parse(left.itemNumber);
  final rightNum = parse(right.itemNumber);
  if (leftNum != null && rightNum != null) {
    return leftNum.compareTo(rightNum);
  }
  return _compareStrings(left.itemNumber, right.itemNumber);
}

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
