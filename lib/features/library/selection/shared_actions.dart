import 'package:collectarr_app/features/library/actions/ui_action.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';
import 'action.dart';
import 'commands.dart';

const selectionEdit = LibrarySelectionAction(
    id: 'edit',
    label: 'Edit',
    icon: AppIcons.inlineEdit,
    command: _edit,
    placement: UiActionPlacement.toolbar,
    order: 0,
    scopes: {LibrarySelectionTargetScope.entry});
LibrarySelectionCommand? _edit(LibrarySelectionCallbacks commands) =>
    commands.onBulkEdit;

const selectionRemove = LibrarySelectionAction(
    id: 'remove',
    label: 'Remove',
    icon: AppIcons.delete,
    command: _remove,
    placement: UiActionPlacement.toolbar,
    order: 10);
LibrarySelectionCommand? _remove(LibrarySelectionCallbacks commands) =>
    commands.onBulkRemove;

const selectionPrint = LibrarySelectionAction(
    id: 'print',
    label: 'Print to PDF',
    icon: AppIcons.print,
    command: _print,
    placement: UiActionPlacement.toolbar,
    order: 20);
LibrarySelectionCommand? _print(LibrarySelectionCallbacks commands) =>
    commands.onPrintToPdf;

const selectionValues = LibrarySelectionAction(
    id: 'values',
    label: 'Update values',
    icon: Icons.payments_outlined,
    command: _values,
    placement: UiActionPlacement.toolbar,
    order: 30,
    scopes: {LibrarySelectionTargetScope.entry},
    unavailableMessage: 'Automatic value updates are not available');
LibrarySelectionCommand? _values(LibrarySelectionCallbacks commands) =>
    commands.onBulkUpdateValues;

const selectionCsv = LibrarySelectionAction(
    id: 'csv',
    label: 'Export to CSV / TXT',
    icon: AppIcons.exportCsv,
    command: _csv,
    placement: UiActionPlacement.bulkMenu,
    order: 40);
LibrarySelectionCommand? _csv(LibrarySelectionCallbacks commands) =>
    commands.onExportCsvTxt;

const selectionXml = LibrarySelectionAction(
    id: 'xml',
    label: 'Export to XML',
    icon: AppIcons.exportXml,
    command: _xml,
    placement: UiActionPlacement.bulkMenu,
    order: 50,
    scopes: {LibrarySelectionTargetScope.entry});
LibrarySelectionCommand? _xml(LibrarySelectionCallbacks commands) =>
    commands.onExportXml;

const selectionDuplicate = LibrarySelectionAction(
    id: 'duplicate',
    label: 'Duplicate',
    icon: AppIcons.duplicates,
    command: _duplicate,
    placement: UiActionPlacement.secondary,
    order: 60,
    scopes: {LibrarySelectionTargetScope.entry});
LibrarySelectionCommand? _duplicate(LibrarySelectionCallbacks commands) =>
    commands.onBulkDuplicate;

const selectionLoan = LibrarySelectionAction(
    id: 'loan',
    label: 'Loan',
    icon: AppIcons.loans,
    command: _loan,
    placement: UiActionPlacement.secondary,
    order: 70,
    scopes: {LibrarySelectionTargetScope.entry});
LibrarySelectionCommand? _loan(LibrarySelectionCallbacks commands) =>
    commands.onBulkLoan;

const selectionTransfer = LibrarySelectionAction(
    id: 'transfer',
    label: 'Transfer Field Data',
    icon: AppIcons.transferFieldData,
    command: _transfer,
    placement: UiActionPlacement.bulkMenu,
    order: 80,
    scopes: {LibrarySelectionTargetScope.entry});
LibrarySelectionCommand? _transfer(LibrarySelectionCallbacks commands) =>
    commands.onTransferFieldData;

const selectionMoveCollection = LibrarySelectionAction(
    id: 'moveCollection',
    label: 'Move to other collection',
    icon: AppIcons.searchAll,
    command: _moveCollection,
    placement: UiActionPlacement.bulkMenu,
    order: 90,
    scopes: {LibrarySelectionTargetScope.entry});
LibrarySelectionCommand? _moveCollection(LibrarySelectionCallbacks commands) =>
    commands.onMoveToCollection;

const selectionMoveEntry = LibrarySelectionAction(
    id: 'moveEntry',
    label: 'Move to entry',
    icon: Icons.inventory_2_outlined,
    command: _moveEntry,
    placement: UiActionPlacement.secondary,
    order: 100,
    scopes: {
      LibrarySelectionTargetScope.catalog,
      LibrarySelectionTargetScope.wishlist
    });
LibrarySelectionCommand? _moveEntry(LibrarySelectionCallbacks commands) =>
    commands.onBulkMoveToEntry;

const selectionMoveWishlist = LibrarySelectionAction(
    id: 'moveWishlist',
    label: 'Move to wishlist',
    icon: Icons.star_border,
    command: _moveWishlist,
    placement: UiActionPlacement.secondary,
    order: 110,
    scopes: {
      LibrarySelectionTargetScope.catalog,
      LibrarySelectionTargetScope.entry
    });
LibrarySelectionCommand? _moveWishlist(LibrarySelectionCallbacks commands) =>
    commands.onBulkMoveToWishlist;

const selectionCore = LibrarySelectionAction(
    id: 'core',
    label: 'Update from Core',
    icon: AppIcons.updateFromCore,
    command: _core,
    placement: UiActionPlacement.bulkMenu,
    order: 120);
LibrarySelectionCommand? _core(LibrarySelectionCallbacks commands) =>
    commands.onBulkRefreshMetadata;
