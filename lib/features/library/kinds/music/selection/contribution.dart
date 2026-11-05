import 'package:collectarr_app/features/library/selection/commands.dart';
import 'package:collectarr_app/features/library/selection/shared_actions.dart';
import 'package:collectarr_app/features/library/selection/action.dart';
import 'package:collectarr_app/ui/app_icons.dart';

const musicSelectionActions = <LibrarySelectionAction>[
  selectionEdit,
  selectionRemove,
  selectionPrint,
  selectionCsv,
  selectionXml,
  selectionDuplicate,
  selectionLoan,
  selectionTransfer,
  selectionMoveCollection,
  selectionMoveEntry,
  selectionMoveWishlist,
  selectionCore,
  _merge,
];
const _merge = LibrarySelectionAction(
    id: 'music.merge',
    label: 'Merge Albums',
    icon: AppIcons.merge,
    command: _mergeCommand,
    homogeneousOnly: true,
    enabled: _canMerge,
    scopes: {LibrarySelectionTargetScope.entry},
    order: 65);
LibrarySelectionCommand? _mergeCommand(LibrarySelectionCommands commands) =>
    commands.onMerge;

bool _canMerge(LibrarySelectionActionContext context) =>
    context.selection.entries.length >= 2;
