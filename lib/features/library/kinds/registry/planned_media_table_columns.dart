part of 'planned_media_adapters.dart';

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
    LibraryTableColumn.title => 280.0,
    LibraryTableColumn.issue => 86.0,
    LibraryTableColumn.variant => 170.0,
    LibraryTableColumn.format => 116.0,
    LibraryTableColumn.publisher => 150.0,
    LibraryTableColumn.platform => 118.0,
    LibraryTableColumn.developer => 140.0,
    LibraryTableColumn.releaseDate => 118.0,
    LibraryTableColumn.releasePlatform => 140.0,
    LibraryTableColumn.barcode => 160.0,
    LibraryTableColumn.grade => 88.0,
    LibraryTableColumn.condition => 124.0,
    LibraryTableColumn.completion => 110.0,
    LibraryTableColumn.price => 92.0,
    LibraryTableColumn.value => 92.0,
    LibraryTableColumn.location => 118.0,
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
    LibraryTableColumn.issue => 64.0,
    LibraryTableColumn.price => 78.0,
    LibraryTableColumn.wishlist => 70.0,
    _ => 86.0,
  };
}

double maxPlannedMediaTableColumnWidth(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.title => 560.0,
    LibraryTableColumn.variant => 420.0,
    LibraryTableColumn.barcode => 260.0,
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
    LibraryTableColumn.title => 'Title',
    LibraryTableColumn.issue => 'Number',
    LibraryTableColumn.variant => 'Edition',
    LibraryTableColumn.format => 'Format',
    LibraryTableColumn.publisher => 'Publisher',
    LibraryTableColumn.platform => 'Platform',
    LibraryTableColumn.developer => 'Developer',
    LibraryTableColumn.releaseDate => 'Release Date',
    LibraryTableColumn.releasePlatform => 'Release Platform',
    LibraryTableColumn.barcode => 'Barcode',
    LibraryTableColumn.grade => 'Grade',
    LibraryTableColumn.condition => 'Condition',
    LibraryTableColumn.completion => 'Completion',
    LibraryTableColumn.price => 'Price',
    LibraryTableColumn.value => 'Value',
    LibraryTableColumn.location => 'Location',
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
    LibraryTableColumn.title ||
    LibraryTableColumn.issue ||
    LibraryTableColumn.publisher ||
    LibraryTableColumn.releaseDate ||
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
    LibraryTableColumn.wishlist ||
    LibraryTableColumn.completion =>
      LibraryTableColumnGroup.personal,
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
    LibraryTableColumn.pageCount =>
      true,
    _ => false,
  };
}

LibrarySortColumn? plannedMediaTableColumnSort(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.cover => null,
    LibraryTableColumn.status => LibrarySortColumn.status,
    LibraryTableColumn.title => LibrarySortColumn.title,
    LibraryTableColumn.issue => LibrarySortColumn.issue,
    LibraryTableColumn.variant => LibrarySortColumn.variant,
    LibraryTableColumn.format => LibrarySortColumn.format,
    LibraryTableColumn.publisher => LibrarySortColumn.publisher,
    LibraryTableColumn.platform => null,
    LibraryTableColumn.developer => null,
    LibraryTableColumn.releaseDate => LibrarySortColumn.releaseDate,
    LibraryTableColumn.releasePlatform => LibrarySortColumn.format,
    LibraryTableColumn.barcode => LibrarySortColumn.barcode,
    LibraryTableColumn.grade => LibrarySortColumn.grade,
    LibraryTableColumn.condition => LibrarySortColumn.condition,
    LibraryTableColumn.price => LibrarySortColumn.price,
    LibraryTableColumn.value => LibrarySortColumn.price,
    LibraryTableColumn.location => LibrarySortColumn.location,
    LibraryTableColumn.wishlist => LibrarySortColumn.wishlist,
    LibraryTableColumn.completion => LibrarySortColumn.collectionStatus,
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
  return switch (column) {
    LibraryTableColumn.status => LibraryItemStatusIcons(
        isOwned: entry.isOwned,
        isTracked: entry.isTracked,
        isWishlisted: entry.isWishlisted,
        hasMissingCover: entry.hasMissingCover,
        hasMissingMetadata: entry.hasMissingMetadata,
        hasKeyMarker: accessors.keyComic(entry),
        hasSlabMarker: accessors.rawOrSlabbed(entry) != null ||
            accessors.gradingCompany(entry) != null,
        hasNotesMarker: entry.notes != null && entry.notes!.trim().isNotEmpty,
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
    LibraryTableColumn.title => Text(
        entry.resolvedTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
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
    LibraryTableColumn.releaseDate =>
      LibraryTableCellText(formatNullableDate(entry.releaseDate)),
    LibraryTableColumn.barcode => LibraryTableCellText(entry.barcode),
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
    LibraryTableColumn.wishlist =>
      entry.isWishlisted ? const Icon(Icons.star, size: 18) : const Text(''),
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
