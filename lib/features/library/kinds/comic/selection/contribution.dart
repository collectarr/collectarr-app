import 'package:collectarr_app/features/library/selection/commands.dart';
import 'package:collectarr_app/features/library/selection/shared_actions.dart';
import 'package:collectarr_app/features/library/selection/action.dart';
import 'package:collectarr_app/ui/app_icons.dart';

const comicSelectionActions = <LibrarySelectionAction>[
  selectionEdit,
  selectionRemove,
  selectionPrint,
  selectionValues,
  selectionCsv,
  selectionXml,
  selectionDuplicate,
  selectionLoan,
  selectionTransfer,
  selectionMoveCollection,
  selectionMoveEntry,
  selectionMoveWishlist,
  selectionCore,
  _keys,
];
const _keys = LibrarySelectionAction(
    id: 'comic.keys',
    category: 'Core',
    label: 'Update Key Info',
    icon: AppIcons.key,
    command: _keysCommand,
    homogeneousOnly: true,
    scopes: {LibrarySelectionTargetScope.entry},
    unavailableMessage: 'Key info updates are not available',
    order: 115);
LibrarySelectionCommand? _keysCommand(LibrarySelectionCommands commands) =>
    commands.onBulkUpdateKeyInfo;
