import 'dart:async';
import 'package:flutter/foundation.dart';

typedef LibrarySelectionCommand = FutureOr<void> Function();

typedef LibrarySelectionCallbacks = ({
  VoidCallback onClearSelection,
  VoidCallback onSelectAll,
  LibrarySelectionCommand? onBulkEdit,
  LibrarySelectionCommand? onPrintToPdf,
  LibrarySelectionCommand? onExportCsvTxt,
  LibrarySelectionCommand? onExportXml,
  LibrarySelectionCommand? onMerge,
  LibrarySelectionCommand? onBulkDuplicate,
  LibrarySelectionCommand? onBulkLoan,
  LibrarySelectionCommand? onTransferFieldData,
  LibrarySelectionCommand? onBulkUpdateValues,
  LibrarySelectionCommand? onBulkUpdateKeyInfo,
  LibrarySelectionCommand? onBulkMoveToEntry,
  LibrarySelectionCommand? onBulkMoveToWishlist,
  LibrarySelectionCommand? onMoveToCollection,
  LibrarySelectionCommand? onBulkRemove,
  LibrarySelectionCommand? onBulkRefreshMetadata,
});
