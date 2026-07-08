import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/media/video/video_workspace_progress.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/shared/media_entry_accessors.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_cell.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_item_badges.dart';
import 'package:flutter/material.dart';

const double kPlannedMediaMinCoverSize = 96;
const double kPlannedMediaDefaultCoverSize = 128;
const double kPlannedMediaMaxCoverSize = 188;
const double kPlannedMediaTableColumnSpacing = 10;
const double kPlannedMediaTableHorizontalMargin = 8;

double plannedMediaTableWidthForColumns({
  required LibraryWorkspaceConfig config,
  required Set<LibraryTableColumn> columns,
  required Map<LibraryTableColumn, double> customWidths,
}) {
  return libraryTableWidthForColumns(
    columns: columns,
    defaultColumns: config.defaultVisibleColumns,
    customWidths: customWidths,
    sizing: plannedMediaTableColumnSizing,
    columnSpacing: kPlannedMediaTableColumnSpacing,
    horizontalMargin: kPlannedMediaTableHorizontalMargin,
  );
}

double plannedMediaTableColumnWidth(
  LibraryTableColumn column,
  Map<LibraryTableColumn, double> customWidths,
) {
  return libraryTableColumnWidth(
    column: column,
    customWidths: customWidths,
    sizing: plannedMediaTableColumnSizing,
  );
}

double defaultPlannedMediaTableColumnWidth(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => 52.0,
    LibraryTableColumn.cover => 42.0,
    LibraryTableColumn.frontCover => 42.0,
    LibraryTableColumn.backCover => 42.0,
    LibraryTableColumn.hasFront => 78.0,
    LibraryTableColumn.hasBack => 78.0,
    LibraryTableColumn.extraImages => 82.0,
    LibraryTableColumn.author => 160.0,
    LibraryTableColumn.artist => 160.0,
    LibraryTableColumn.album => 260.0,
    LibraryTableColumn.title => 280.0,
    LibraryTableColumn.issue => 86.0,
    LibraryTableColumn.variant => 170.0,
    LibraryTableColumn.format => 116.0,
    LibraryTableColumn.publisher => 150.0,
    LibraryTableColumn.label => 150.0,
    LibraryTableColumn.catalogNumber => 134.0,
    LibraryTableColumn.platform => 118.0,
    LibraryTableColumn.developer => 140.0,
    LibraryTableColumn.releaseDate => 118.0,
    LibraryTableColumn.releasePlatform => 140.0,
    LibraryTableColumn.barcode => 160.0,
    LibraryTableColumn.discCount => 92.0,
    LibraryTableColumn.trackCount => 92.0,
    LibraryTableColumn.length => 92.0,
    LibraryTableColumn.vinylColor => 118.0,
    LibraryTableColumn.rpm => 78.0,
    LibraryTableColumn.grade => 88.0,
    LibraryTableColumn.condition => 124.0,
    LibraryTableColumn.completion => 110.0,
    LibraryTableColumn.price => 92.0,
    LibraryTableColumn.value => 92.0,
    LibraryTableColumn.location => 118.0,
    LibraryTableColumn.readStatus => 104.0,
    LibraryTableColumn.rating => 84.0,
    LibraryTableColumn.wishlist => 82.0,
    LibraryTableColumn.added => 112.0,
    LibraryTableColumn.updated => 112.0,
    LibraryTableColumn.country => 100.0,
    LibraryTableColumn.language => 100.0,
    LibraryTableColumn.pageCount => 80.0,
    LibraryTableColumn.ageRating => 100.0,
    LibraryTableColumn.imprint => 140.0,
  };
}

double minPlannedMediaTableColumnWidth(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => 44.0,
    LibraryTableColumn.cover => 44.0,
    LibraryTableColumn.frontCover => 44.0,
    LibraryTableColumn.backCover => 44.0,
    LibraryTableColumn.hasFront => 68.0,
    LibraryTableColumn.hasBack => 68.0,
    LibraryTableColumn.extraImages => 70.0,
    LibraryTableColumn.author => 110.0,
    LibraryTableColumn.artist => 110.0,
    LibraryTableColumn.album => 160.0,
    LibraryTableColumn.label => 110.0,
    LibraryTableColumn.issue => 64.0,
    LibraryTableColumn.price => 78.0,
    LibraryTableColumn.wishlist => 70.0,
    LibraryTableColumn.catalogNumber => 84.0,
    LibraryTableColumn.readStatus => 82.0,
    LibraryTableColumn.rating => 60.0,
    LibraryTableColumn.discCount => 64.0,
    LibraryTableColumn.trackCount => 64.0,
    LibraryTableColumn.length => 72.0,
    LibraryTableColumn.rpm => 60.0,
    _ => 86.0,
  };
}

double maxPlannedMediaTableColumnWidth(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.title => 560.0,
    LibraryTableColumn.album => 560.0,
    LibraryTableColumn.variant => 420.0,
    LibraryTableColumn.barcode => 260.0,
    LibraryTableColumn.catalogNumber => 240.0,
    LibraryTableColumn.frontCover => 90.0,
    LibraryTableColumn.backCover => 90.0,
    _ => 260.0,
  };
}

LibraryTableColumnSizing plannedMediaTableColumnSizing(
  LibraryTableColumn column,
) {
  return LibraryTableColumnSizing(
    defaultWidth: defaultPlannedMediaTableColumnWidth(column),
    minWidth: minPlannedMediaTableColumnWidth(column),
    maxWidth: maxPlannedMediaTableColumnWidth(column),
  );
}

double clampPlannedMediaTableColumnWidth(
  LibraryTableColumn column,
  double width,
) {
  return clampLibraryTableColumnWidth(
    width,
    plannedMediaTableColumnSizing(column),
  );
}

String plannedMediaTableColumnLabel(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => '',
    LibraryTableColumn.cover => '',
    LibraryTableColumn.frontCover => 'Front Cover',
    LibraryTableColumn.backCover => 'Back Cover',
    LibraryTableColumn.hasFront => 'Has Front',
    LibraryTableColumn.hasBack => 'Has Back',
    LibraryTableColumn.extraImages => 'Extra Images',
    LibraryTableColumn.author => 'Author',
    LibraryTableColumn.artist => 'Artist',
    LibraryTableColumn.album => 'Album',
    LibraryTableColumn.title => 'Title',
    LibraryTableColumn.issue => 'Number',
    LibraryTableColumn.variant => 'Edition',
    LibraryTableColumn.format => 'Format',
    LibraryTableColumn.publisher => 'Publisher',
    LibraryTableColumn.label => 'Label',
    LibraryTableColumn.catalogNumber => 'Catalog #',
    LibraryTableColumn.platform => 'Platform',
    LibraryTableColumn.developer => 'Developer',
    LibraryTableColumn.releaseDate => 'Release Date',
    LibraryTableColumn.releasePlatform => 'Release Platform',
    LibraryTableColumn.barcode => 'Barcode',
    LibraryTableColumn.discCount => 'Disc Count',
    LibraryTableColumn.trackCount => 'Track Count',
    LibraryTableColumn.length => 'Length',
    LibraryTableColumn.vinylColor => 'Vinyl Color',
    LibraryTableColumn.rpm => 'RPM',
    LibraryTableColumn.grade => 'Grade',
    LibraryTableColumn.condition => 'Condition',
    LibraryTableColumn.completion => 'Completion',
    LibraryTableColumn.price => 'Price',
    LibraryTableColumn.value => 'Value',
    LibraryTableColumn.location => 'Location',
    LibraryTableColumn.readStatus => 'Read It',
    LibraryTableColumn.rating => 'Rating',
    LibraryTableColumn.wishlist => 'Wishlist',
    LibraryTableColumn.added => 'Added Date',
    LibraryTableColumn.updated => 'Updated',
    LibraryTableColumn.country => 'Country',
    LibraryTableColumn.language => 'Language',
    LibraryTableColumn.pageCount => 'Pages',
    LibraryTableColumn.ageRating => 'Age Rating',
    LibraryTableColumn.imprint => 'Imprint',
  };
}

String plannedMediaTableColumnLabelForType(
  LibraryTypeConfig type,
  LibraryTableColumn column,
) {
  if (type.workspace.kind.apiValue == 'tv' &&
      column == LibraryTableColumn.completion) {
    return 'Progress';
  }
  return switch (column) {
    LibraryTableColumn.issue => type.mediaFields.numberLabel,
    LibraryTableColumn.variant => type.releaseFields.variantLabel,
    LibraryTableColumn.publisher => type.mediaFields.publisherLabel,
    LibraryTableColumn.barcode => type.releaseFields.barcodeLabel,
    _ => plannedMediaTableColumnLabel(column),
  };
}

String plannedMediaTableColumnDisplayName(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => 'Status',
    LibraryTableColumn.cover => 'Cover',
    LibraryTableColumn.frontCover => 'Front Cover',
    LibraryTableColumn.backCover => 'Back Cover',
    LibraryTableColumn.hasFront => 'Has Front',
    LibraryTableColumn.hasBack => 'Has Back',
    LibraryTableColumn.extraImages => 'Extra Images',
    LibraryTableColumn.author => 'Author',
    _ => plannedMediaTableColumnLabel(column),
  };
}

String plannedMediaTableColumnDisplayNameForType(
  LibraryTypeConfig type,
  LibraryTableColumn column,
) {
  return switch (column) {
    LibraryTableColumn.status => 'Status',
    LibraryTableColumn.cover => 'Cover',
    _ => plannedMediaTableColumnLabelForType(type, column),
  };
}

LibraryTableColumnGroup plannedMediaTableColumnGroup(
  LibraryTableColumn column,
) {
  return switch (column) {
    LibraryTableColumn.status ||
    LibraryTableColumn.cover ||
    LibraryTableColumn.frontCover ||
    LibraryTableColumn.backCover ||
    LibraryTableColumn.author ||
    LibraryTableColumn.artist ||
    LibraryTableColumn.album ||
    LibraryTableColumn.title ||
    LibraryTableColumn.issue ||
    LibraryTableColumn.publisher ||
    LibraryTableColumn.label ||
    LibraryTableColumn.catalogNumber ||
    LibraryTableColumn.releaseDate ||
    LibraryTableColumn.discCount ||
    LibraryTableColumn.trackCount ||
    LibraryTableColumn.length ||
    LibraryTableColumn.vinylColor ||
    LibraryTableColumn.rpm ||
    LibraryTableColumn.added ||
    LibraryTableColumn.updated =>
      LibraryTableColumnGroup.main,
    LibraryTableColumn.variant ||
    LibraryTableColumn.format ||
    LibraryTableColumn.barcode ||
    LibraryTableColumn.platform ||
    LibraryTableColumn.developer ||
    LibraryTableColumn.releasePlatform =>
      LibraryTableColumnGroup.edition,
    LibraryTableColumn.grade ||
    LibraryTableColumn.condition ||
    LibraryTableColumn.price ||
    LibraryTableColumn.value =>
      LibraryTableColumnGroup.value,
    LibraryTableColumn.location ||
    LibraryTableColumn.readStatus ||
    LibraryTableColumn.wishlist ||
    LibraryTableColumn.completion ||
    LibraryTableColumn.hasFront ||
    LibraryTableColumn.hasBack ||
    LibraryTableColumn.extraImages =>
      LibraryTableColumnGroup.personal,
    LibraryTableColumn.rating => LibraryTableColumnGroup.value,
    LibraryTableColumn.country ||
    LibraryTableColumn.language ||
    LibraryTableColumn.pageCount ||
    LibraryTableColumn.ageRating ||
    LibraryTableColumn.imprint =>
      LibraryTableColumnGroup.edition,
  };
}

String plannedMediaTableColumnGroupLabel(LibraryTableColumnGroup group) {
  return switch (group) {
    LibraryTableColumnGroup.main => 'Main',
    LibraryTableColumnGroup.edition => 'Edition',
    LibraryTableColumnGroup.value => 'Value',
    LibraryTableColumnGroup.personal => 'Personal',
  };
}

bool plannedMediaTableColumnIsNumeric(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.issue ||
    LibraryTableColumn.price ||
    LibraryTableColumn.value ||
    LibraryTableColumn.pageCount ||
    LibraryTableColumn.discCount ||
    LibraryTableColumn.trackCount ||
    LibraryTableColumn.rating =>
      true,
    _ => false,
  };
}

LibrarySortColumn? plannedMediaTableColumnSort(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.cover => null,
    LibraryTableColumn.frontCover => null,
    LibraryTableColumn.backCover => null,
    LibraryTableColumn.hasFront => null,
    LibraryTableColumn.hasBack => null,
    LibraryTableColumn.extraImages => null,
    LibraryTableColumn.status => LibrarySortColumn.status,
    LibraryTableColumn.author => null,
    LibraryTableColumn.artist => null,
    LibraryTableColumn.album => LibrarySortColumn.title,
    LibraryTableColumn.title => LibrarySortColumn.title,
    LibraryTableColumn.issue => LibrarySortColumn.issue,
    LibraryTableColumn.variant => LibrarySortColumn.variant,
    LibraryTableColumn.format => LibrarySortColumn.format,
    LibraryTableColumn.publisher => LibrarySortColumn.publisher,
    LibraryTableColumn.label => LibrarySortColumn.publisher,
    LibraryTableColumn.catalogNumber => null,
    LibraryTableColumn.platform => null,
    LibraryTableColumn.developer => null,
    LibraryTableColumn.releaseDate => LibrarySortColumn.releaseDate,
    LibraryTableColumn.releasePlatform => LibrarySortColumn.format,
    LibraryTableColumn.barcode => LibrarySortColumn.barcode,
    LibraryTableColumn.discCount => null,
    LibraryTableColumn.trackCount => null,
    LibraryTableColumn.length => null,
    LibraryTableColumn.vinylColor => null,
    LibraryTableColumn.rpm => null,
    LibraryTableColumn.grade => LibrarySortColumn.grade,
    LibraryTableColumn.condition => LibrarySortColumn.condition,
    LibraryTableColumn.price => LibrarySortColumn.price,
    LibraryTableColumn.value => LibrarySortColumn.price,
    LibraryTableColumn.location => LibrarySortColumn.location,
    LibraryTableColumn.readStatus => null,
    LibraryTableColumn.wishlist => LibrarySortColumn.wishlist,
    LibraryTableColumn.completion => LibrarySortColumn.collectionStatus,
    LibraryTableColumn.rating => null,
    LibraryTableColumn.added => LibrarySortColumn.added,
    LibraryTableColumn.updated => LibrarySortColumn.updated,
    LibraryTableColumn.country => LibrarySortColumn.country,
    LibraryTableColumn.language => LibrarySortColumn.language,
    LibraryTableColumn.pageCount => LibrarySortColumn.pageCount,
    LibraryTableColumn.ageRating => LibrarySortColumn.ageRating,
    LibraryTableColumn.imprint => LibrarySortColumn.imprint,
  };
}

Widget plannedMediaTableCell(
  LibraryWorkspaceEntry entry,
  LibraryTableColumn column,
  PlannedMediaEntryAccessors accessors,
) {
  if (entry.mediaType == 'tv' && column == LibraryTableColumn.completion) {
    return VideoWorkspaceProgressCell(entry: entry);
  }
  return switch (column) {
    LibraryTableColumn.status => LibraryItemStatusIcons(
        isOwned: entry.isOwned,
        isTracked: entry.isTracked,
        isWishlisted: entry.isWishlisted,
        hasMissingCover: entry.hasMissingCover,
        hasMissingMetadata: entry.hasMissingMetadata,
        hasFrontImage: entry.hasFrontImage,
        hasBackImage: entry.hasBackImage,
        extraImageCount: entry.extraImageCount,
        hasKeyMarker: accessors.keyComic(entry),
        hasSlabMarker: accessors.rawOrSlabbed(entry) != null ||
            accessors.gradingCompany(entry) != null,
        hasNotesMarker: entry.notes != null && entry.notes!.trim().isNotEmpty,
        contractDiagnosticLabel: libraryHierarchyContractDiagnosticLabel(
          entry,
        ),
      ),
    LibraryTableColumn.cover => SizedBox(
        width: 24,
        height: 32,
        child: LibraryCoverImage(
          title: entry.resolvedTitle,
          itemNumber: entry.itemNumber,
          imageUrl: entry.displayCoverUrl,
          ownedItemId: entry.ownedItemId,
        ),
      ),
    LibraryTableColumn.frontCover => SizedBox(
        width: 24,
        height: 32,
        child: LibraryCoverImage(
          title: entry.resolvedTitle,
          itemNumber: entry.itemNumber,
          imageUrl: entry.frontCoverUrl ?? entry.displayCoverUrl,
          localBytes: entry.frontImage?.imageData,
          ownedItemId: entry.ownedItemId,
        ),
      ),
    LibraryTableColumn.backCover => SizedBox(
        width: 24,
        height: 32,
        child: LibraryCoverImage(
          title: entry.resolvedTitle,
          itemNumber: entry.itemNumber,
          imageUrl: entry.backCoverUrl,
          localBytes: entry.backImage?.imageData,
          ownedItemId: entry.ownedItemId,
        ),
      ),
    LibraryTableColumn.hasFront => _ImagePresenceCell(
        present: entry.hasFrontImage,
      ),
    LibraryTableColumn.hasBack => _ImagePresenceCell(
        present: entry.hasBackImage,
      ),
    LibraryTableColumn.extraImages => _ImagePresenceCell(
        present: entry.extraImageCount > 0,
        label: entry.extraImageCount > 0 ? '${entry.extraImageCount}' : '-',
      ),
    LibraryTableColumn.title => Text(
        entry.resolvedTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    LibraryTableColumn.author => LibraryTableCellText(_bookAuthor(entry)),
    LibraryTableColumn.artist => LibraryTableCellText(_musicArtist(entry)),
    LibraryTableColumn.album => LibraryTableCellText(entry.title),
    LibraryTableColumn.issue => LibraryTableCellText(entry.itemNumber),
    LibraryTableColumn.variant => LibraryTableCellText(
        [
          if (entry.variant != null && entry.variant!.trim().isNotEmpty)
            entry.variant,
          if (entry.referenceScopeLabel != null)
            'Scope: ${entry.referenceScopeLabel!}',
          if (entry.referenceFormatLabel != null)
            'Format: ${entry.referenceFormatLabel!}',
        ].join('  ·  '),
      ),
    LibraryTableColumn.format =>
      LibraryTableCellText(entry.referenceFormatLabel),
    LibraryTableColumn.publisher => LibraryTableCellText(entry.publisher),
    LibraryTableColumn.label => LibraryTableCellText(entry.publisher),
    LibraryTableColumn.catalogNumber =>
      LibraryTableCellText(_musicCatalogNumber(entry)),
    LibraryTableColumn.releaseDate =>
      LibraryTableCellText(formatNullableDate(entry.releaseDate)),
    LibraryTableColumn.barcode => LibraryTableCellText(entry.barcode),
    LibraryTableColumn.discCount =>
      LibraryTableCellText(_musicDiscCount(entry)?.toString()),
    LibraryTableColumn.trackCount =>
      LibraryTableCellText(_musicTrackCount(entry)?.toString()),
    LibraryTableColumn.length => LibraryTableCellText(_musicLength(entry)),
    LibraryTableColumn.vinylColor =>
      LibraryTableCellText(_musicVinylColor(entry)),
    LibraryTableColumn.rpm => LibraryTableCellText(_musicRpm(entry)),
    LibraryTableColumn.grade => LibraryTableCellText(entry.grade),
    LibraryTableColumn.condition => LibraryTableCellText(entry.condition),
    LibraryTableColumn.price =>
      Text(formatMoney(entry.pricePaidCents, entry.currency)),
    LibraryTableColumn.value =>
      Text(formatMoney(entry.pricePaidCents, entry.currency)),
    LibraryTableColumn.platform =>
      LibraryTableCellText(_firstDisplayValue(accessors.rawPlatforms(entry))),
    LibraryTableColumn.developer =>
      LibraryTableCellText(accessors.developer(entry)),
    LibraryTableColumn.releasePlatform =>
      LibraryTableCellText(accessors.releasePlatform(entry)),
    LibraryTableColumn.completion =>
      LibraryTableCellText(accessors.completion(entry)),
    LibraryTableColumn.location => LibraryTableCellText(entry.locationPath),
    LibraryTableColumn.readStatus => LibraryTableCellText(entry.readStatus),
    LibraryTableColumn.wishlist =>
      entry.isWishlisted ? const Icon(Icons.star, size: 18) : const Text(''),
    LibraryTableColumn.rating => LibraryTableCellText(entry.rating?.toString()),
    LibraryTableColumn.added => Text(
        formatDate(entry.addedAt ?? entry.updatedAt),
        style: const TextStyle(fontSize: 12),
      ),
    LibraryTableColumn.updated => Text(
        formatDate(entry.updatedAt),
        style: const TextStyle(fontSize: 12),
      ),
    LibraryTableColumn.country =>
      LibraryTableCellText(accessors.country(entry)),
    LibraryTableColumn.language =>
      LibraryTableCellText(accessors.language(entry)),
    LibraryTableColumn.pageCount =>
      LibraryTableCellText(entry.publishing?.pageCount?.toString()),
    LibraryTableColumn.ageRating =>
      LibraryTableCellText(accessors.ageRating(entry)),
    LibraryTableColumn.imprint =>
      LibraryTableCellText(entry.publishing?.imprint),
  };
}

class _ImagePresenceCell extends StatelessWidget {
  const _ImagePresenceCell({
    required this.present,
    this.label,
  });

  final bool present;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            present ? Icons.check_circle_outline : Icons.remove_circle_outline,
            size: 16,
            color: present ? colorScheme.primary : colorScheme.outline,
            semanticLabel: label,
          ),
          if (label != null && label!.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: present ? colorScheme.primary : colorScheme.outline,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

String? _firstDisplayValue(List<String>? values) {
  if (values == null) return null;
  for (final value in values) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return null;
}

String? _musicArtist(LibraryWorkspaceEntry entry) {
  final series = entry.series?.seriesTitle?.trim();
  if (series != null && series.isNotEmpty) {
    return series;
  }
  final creators = entry.creators ?? const <Map<String, dynamic>>[];
  for (final creator in creators) {
    final name =
        (creator['name'] ?? creator['display_name'] ?? '').toString().trim();
    if (name.isNotEmpty) {
      return name;
    }
  }
  return null;
}

String? _bookAuthor(LibraryWorkspaceEntry entry) {
  final creators = entry.creators ?? const <Map<String, dynamic>>[];
  for (final creator in creators) {
    final role = creator['role']?.toString().trim().toLowerCase();
    final name =
        (creator['name'] ?? creator['display_name'] ?? '').toString().trim();
    if (name.isEmpty) {
      continue;
    }
    if (role == null || role.isEmpty) {
      return name;
    }
    if (role.contains('author') ||
        role.contains('writer') ||
        role.contains('novelist')) {
      return name;
    }
  }
  for (final creator in creators) {
    final name =
        (creator['name'] ?? creator['display_name'] ?? '').toString().trim();
    if (name.isNotEmpty) {
      return name;
    }
  }
  return null;
}

String? _musicCatalogNumber(LibraryWorkspaceEntry entry) {
  final catalogNumber = entry.music?.catalogNumber?.trim();
  if (catalogNumber != null && catalogNumber.isNotEmpty) {
    return catalogNumber;
  }
  return entry.publishing?.subtitle?.trim();
}

int? _musicDiscCount(LibraryWorkspaceEntry entry) {
  final discs = entry.music?.discs;
  if (discs != null && discs.isNotEmpty) {
    return discs.length;
  }
  return entry.editions.isNotEmpty ? entry.editions.length : null;
}

int? _musicTrackCount(LibraryWorkspaceEntry entry) {
  final trackCount = entry.music?.trackCount;
  if (trackCount != null) {
    return trackCount;
  }
  final tracks = entry.music?.tracks;
  return tracks == null || tracks.isEmpty ? null : tracks.length;
}

String? _musicLength(LibraryWorkspaceEntry entry) {
  final tracks = entry.music?.tracks;
  if (tracks == null || tracks.isEmpty) {
    return null;
  }
  var totalSeconds = 0;
  for (final track in tracks) {
    final seconds = track.durationSeconds;
    if (seconds != null && seconds > 0) {
      totalSeconds += seconds;
    }
  }
  if (totalSeconds <= 0) {
    return null;
  }
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String? _musicVinylColor(LibraryWorkspaceEntry entry) {
  final color = entry.music?.vinylColor?.trim();
  return color == null || color.isEmpty ? null : color;
}

String? _musicRpm(LibraryWorkspaceEntry entry) {
  final rpm = entry.music?.rpm?.trim();
  return rpm == null || rpm.isEmpty ? null : '$rpm RPM';
}
